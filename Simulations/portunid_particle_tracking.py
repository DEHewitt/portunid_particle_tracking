#!home/z5278054/python_parcels/bin/python3

from parcels import FieldSet, Field, AdvectionRK4, ParticleSet, JITParticle, Variable, DiffusionUniformKh, random
from parcels import ErrorCode
import numpy as np
from glob import glob
from datetime import timedelta as delta
from datetime import datetime as datetime
import os
import math
import pandas as pd

# Change these lines manually for the run you want to conduct
# You will need to adjust the .pbs script accordingly so that you run the right number of jobs (i.e. # zones * # years)
Species = "GMC"
# Species = "BSC"
Direction = "forwards"
#Direction = "backwards"
Model = "BRAN2015"

out_dir = '/srv/scratch/z5278054/portunid_particle_tracking'
#out_dir = '/srv/scratch/z3374139/GMC_particle_tracking'

# How many particles to release
if Direction == "forwards":
    npart = 1000  # number of particles to be released
else:
    npart = 100

# How often to release them
repeatdt = delta(days = 1) 

# Release locations
if Species == "GMC" and Direction == "forwards":
    possible_locations = pd.read_csv("/srv/scratch/z5278054/shared/gmc_possible_locations.csv") # read the points extracted from GEBCO
elif Species == "BSC" and Direction == "forwards":
    possible_locations = pd.read_csv("/srv/scratch/z5278054/shared/bsc_possible_locations.csv") 
elif Species == "GMC" and Direction == "backwards":
    "file directory for GMC backwards releases"
elif Species == "BSC" and Direction == "backwards":
    "file directory for BSC backwards releases"

# Convert possible_locations to a Pandas dataframe
df = pd.DataFrame(possible_locations) 

# Make a list of the zones (i.e. 1 degree latitude bands to be released from)
# These can be anything you want (e.g. a box, a point) jsut as long as they're labelled in the .csv in lines 35-43
zones = df['ocean_zone'].unique()

# This is taken from the .pbs and is the product of the number of years (duration of the model) times the number of zones for particles to be released in
array_ref = int(os.environ['PBS_ARRAY_INDEX'])
# This calculates the remainder after diving by 19 (to be used to get release location, ie pick one of 10 ocean zones)
mod_array_num = array_ref % len(zones)  
# Define the duration of the model (in years) and then repeat it by the number of zones (so there is a job in each zone each year)
year_array = np.repeat(np.arange(2009, 2019, 1), len(zones))

# subset possible locations dataframe (df) to specific ocean zone
df = df[df['ocean_zone'] == zones[mod_array_num]]

# Delete #
### I think this next bit could now be tidied up (Don't think we need all the grouping)
#n_locations = df['ocean_zone'].nunique() # number of release locations
# Delete #

# Spawning season, add on a month to ensure release particles have enough time to reach degree-days
# See "portunid_aus_spawning_season_201007.xls"
if Species == "GMC" and Direction == "forwards":
    start_time = datetime(year_array[array_ref], 9, 1) # year, month, day
    end_time = datetime(year_array[array_ref]+1, 5, 30) # year, month, day
elif Species == "BSC" and Direction == "forwards":
    start_time = datetime(year_array[array_ref], 8, 1)
    end_time = datetime(year_array[array_ref]+1, 5, 30)
elif Species == "GMC" and Direction == "backwards":
    start_time = datetime(year_array[array_ref], 8, 30)
    end_time = datetime(year_array[array_ref]+1, 5, 10)
elif Species == "BSC" and Direction == "backwards":
    start_time = datetime(year_array[array_ref], 7, 31)
    end_time = datetime(year_array[array_ref]+1, 5, 30)

runtime = end_time-start_time + delta(days=1)

# Randomly choose a new release location for each day of the spawning season
# Still need the grouping, not sure why - maybe something to do with the apply() function
locations = df.groupby('ocean_zone').apply(pd.DataFrame.sample, n = runtime.days).reset_index(drop=True)[["lat", "lon", 'ocean_zone']] # list of random points for every release
lat = np.repeat(locations["lat"], npart) # repeat every location by the number of particles 
lon = np.repeat(locations["lon"], npart)

# Set up the hydrodynamic model
filenames = {'U': sorted(glob('/srv/scratch/z5278054/shared/BRAN_2015/Ocean_u_*')), 
             'V': sorted(glob('/srv/scratch/z5278054/shared/BRAN_2015/Ocean_v_*')),
             'temp': sorted(glob('/srv/scratch/z5278054/shared/BRAN_2015/Ocean_temp_*')),
             'bathy': '/srv/scratch/z5278054/shared/BRAN_2015/grid_spec.nc',
             'salt': sorted(glob('/srv/scratch/z5278054/shared/BRAN_2015/Ocean_salt_*'))}

variables = {'U': 'u',
             'V': 'v',
             'temp': 'temp',
             'bathy': 'depth_t',
             'salt':'salt'}

dimensions = {}
dimensions['U'] = {'lat': 'yu_ocean', 'lon': 'xu_ocean', 'depth': 'st_ocean', 'time': 'Time'}
dimensions['V'] = {'lat': 'yu_ocean', 'lon': 'xu_ocean', 'depth': 'st_ocean', 'time': 'Time'}
dimensions['temp'] = {'lat': 'yt_ocean', 'lon': 'xt_ocean', 'depth': 'st_ocean', 'time': 'Time'}
dimensions['bathy'] = {'lat': 'grid_y_T', 'lon': 'grid_x_T'} 
dimensions['salt'] = {'lat': 'yt_ocean', 'lon': 'xt_ocean', 'depth': 'st_ocean', 'time': 'Time'}

#indices = {'depth': [0]} # try commenting this out and remove from call to FieldSet.from_netcdf()

# Define fieldset
fieldset = FieldSet.from_netcdf(filenames, variables, dimensions, allow_time_extrapolation = True) # indices, 
fieldset.add_constant('maxage', 40.*86400)
fieldset.temp.interp_method = 'nearest'

# Set diffusion constants and add them to the fieldset (units = m/s)
Kh_zonal = 10
Kh_meridional = 10

size2D = (fieldset.U.grid.ydim, fieldset.U.grid.xdim)
fieldset.add_field(Field('Kh_zonal', Kh_zonal*np.ones(size2D), 
                         lon=fieldset.U.grid.lon, lat=fieldset.U.grid.lat, mesh='spherical'))
fieldset.add_field(Field('Kh_meridional', Kh_meridional*np.ones(size2D), 
                         lon=fieldset.U.grid.lon, lat=fieldset.U.grid.lat, mesh='spherical'))

# Where to save
out_file = str(out_dir)+'/'+str(Species)+'_'+str(year_array[array_ref])+'_'+str(zones[mod_array_num])+'_'+str(Model)+'_'+str(Direction)+'.nc'

# If output file already exists then remove it
if os.path.exists(out_file):
    os.remove(out_file)

random.seed(123456) # Set random seed
  
# Define a new particle class - includes fixes so particles initialise in JIT mode (see SampleInitial kernel below)  
class SampleParticle(JITParticle): 
    sampled = Variable('sampled', dtype = np.float32, initial = 0, to_write=False)
    age = Variable('age', dtype=np.float32, initial=0.) # initialise age
    temp = Variable('temp', dtype=np.float32, initial=0)  # initialise temperature
    bathy = Variable('bathy', dtype=np.float32, initial=0) # initialise bathymetry
    salt = Variable('salt', dtype=np.float32, initial=0) # initialise salinity
    distance = Variable('distance', initial=0., dtype=np.float32)  # the distance travelled
    prev_lon = Variable('prev_lon', dtype=np.float32, to_write=False,
                        initial=0)  # the previous longitude
    prev_lat = Variable('prev_lat', dtype=np.float32, to_write=False,
                        initial=0)  # the previous latitude

# Define all the sampling kernels
def SampleDistance(particle, fieldset, time):
    # Calculate the distance in latitudinal direction (using 1.11e2 kilometer per degree latitude)
    lat_dist = (particle.lat - particle.prev_lat) * 1.11e2
    # Calculate the distance in longitudinal direction, using cosine(latitude) - spherical earth
    lon_dist = (particle.lon - particle.prev_lon) * 1.11e2 * math.cos(particle.lat * math.pi / 180)
    # Calculate the total Euclidean distance travelled by the particle
    particle.distance += math.sqrt(math.pow(lon_dist, 2) + math.pow(lat_dist, 2))
    particle.prev_lon = particle.lon  # Set the stored values for next iteration.
    particle.prev_lat = particle.lat
    
def DeleteParticle(particle, fieldset, time):
    particle.delete()
    
def SampleAge(particle, fieldset, time):
    particle.age = particle.age + math.fabs(particle.dt)
    if particle.age > fieldset.maxage:
        particle.delete()

def SampleTemp(particle, fieldset, time):
    particle.temp = fieldset.temp[time, particle.depth, particle.lat, particle.lon]
    
def SampleSalt(particle, fieldset, time):
    particle.salt = fieldset.salt[time, particle.depth, particle.lat, particle.lon]
    
def SampleBathy(particle, fieldset, time):
    particle.bathy = fieldset.bathy[0, 0, particle.lat, particle.lon]
    
# Kernel to speed up initialisation by using JIT mode not scipy
def SampleInitial(particle, fieldset, time): 
    if particle.sampled == 0:
         particle.temp = fieldset.temp[time, particle.depth, particle.lat, particle.lon]
         particle.prev_lon = particle.lon
         particle.prev_lat = particle.lat
         particle.sampled = 1

# Define when you want tracking to start
pset_start = (datetime(year_array[array_ref], 9, 1) - datetime.strptime(str(fieldset.time_origin)[0:10], "%Y-%m-%d")).total_seconds()  # start of spawning season
#pset_start = start_time - datetime.strptime(str(fieldset.time_origin)[0:10], "%Y-%m-%d")).total_seconds()  # start of spawning season

# Create an array of release times (replace "+" with "-" for backwards)
release_times = pset_start + (np.arange(0, runtime.days) * repeatdt.total_seconds()) 
#release_times = pset_start + (np.arange(0, 2) * repeatdt.total_seconds()) # for local testing

#time = np.tile(release_times, n_locations*npart) # duplicate release time for each point and the number of particles per point
#time = np.tile(np.repeat(release_times, npart), n_locations)

# Multiply the release times by the number of particles
time = np.repeat(release_times, npart)

pset = ParticleSet.from_list(fieldset, pclass=SampleParticle, time=time, lon=lon, lat=lat, repeatdt=None) # repeatdt not used as the list of times is where the repeating is done

pfile = pset.ParticleFile(out_file, outputdt=delta(days=1))

# SampleInitial kernel must come first to initialise particles in JIT mode
kernels = SampleInitial + pset.Kernel(AdvectionRK4) + SampleAge + SampleTemp + SampleBathy + SampleSalt + SampleDistance + DiffusionUniformKh

if Direction == "forwards":
    pset.execute(kernels, 
             dt=delta(minutes=5), 
             output_file=pfile, 
             verbose_progress=True,
             runtime = runtime,
             recovery={ErrorCode.ErrorOutOfBounds: DeleteParticle})
else:
        pset.execute(kernels, 
             dt=-delta(minutes=5), 
             output_file=pfile, 
             verbose_progress=True,
             runtime = runtime,
             recovery={ErrorCode.ErrorOutOfBounds: DeleteParticle})
pfile.close()