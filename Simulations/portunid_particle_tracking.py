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

# These are specified in the .pbs script for job submission
species = "gmc"
direction = "forwards"
    
# Where to save the files based on the input
out_dir = '/srv/scratch/z5278054/portunid_particle_tracking/'+str(species)+'/'+str(direction)

# How many particles to release
if direction == "forwards":
    npart = 10  # number of particles to be released - to be changed to 1000
elif direction == "backwards":
    npart = 10 # to be changed to 100

array_ref = int(os.environ['PBS_ARRAY_INDEX'])

# How often to release the particles
repeatdt = delta(days = 1) 

# release locations initially extracted from GEBCO, except for gmc+backwards (they're at the mouths of major estuaries)
if species == "gmc" and direction == "backwards":
    lat = np.repeat([-18.541, -23.850, -25.817, -27.339, -28.165, -28.890, -29.432, -30.864, -31.645, -31.899, -32.193, -32.719, -32.917, -33.578], npart)
    lon = np.repeat([147.848, 152.538, 153.762, 153.636, 153.790, 153.799, 153.736, 153.172, 153.048, 152.946, 152.775, 152.312, 152.045, 151.577], npart)
    depth = np.repeat([])
else:    
    possible_locations = pd.read_csv("/srv/scratch/z5278054/portunid_particle_tracking/"+str(species)+"_possible_locations.csv") # either in '.../portunid_particle_tracking/Simulations' or '...data_processed/'

# Convert possible_locations to a Pandas dataframe
if direction == "forwards" and species == "gmc" or species == "bsc" and direction == "backwards" or direction == "forwards":
    df = pd.DataFrame(possible_locations) 
    # Make a list of the zones (i.e. 1 degree latitude bands to be released from)
    # These can be anything you want (e.g. a box, a point) 
    zones = df['ocean_zone'].unique()
    # This calculates the remainder after diving by the number of release locations ('ocean_zones') you are modelling
    mod_array_num = array_ref % len(zones)
    
# Define the duration of the model (in years) 
#year_array = np.arange(2000, 2009, 1) # will need to change once all files are shared (from Mirjam)
year_array = 2000

if species == "gmc" and direction == "backwards":
    year_array = year_array
else:
    # repeat the year_array by the number of zones (so there is a job in each zone each year) for the random release method
    year_array = np.repeat(year_array, len(zones))

if direction == "forwards" and species == "gmc" or species == "bsc" and direction == "backwards" or direction == "forwards":
    df = df[df['ocean_zone'] == zones[mod_array_num]] # subset possible locations dataframe (df) to specific ocean zone

# Spawning season, add on a month to ensure release particles have enough time to reach degree-days
# See "portunid_aus_spawning_season_201007.xls"
if species == "gmc" and direction == "forwards":
    start_time = datetime(year_array[array_ref], 9, 1) # year, month, day
    end_time = datetime(year_array[array_ref]+1, 5, 30) # year, month, day
elif species == "bsc" and direction == "forwards":
    start_time = datetime(year_array[array_ref], 8, 1)
    end_time = datetime(year_array[array_ref]+1, 5, 30)
elif species == "gmc" and direction == "backwards":
    start_time = datetime(year_array[array_ref], 8, 30)
    end_time = datetime(year_array[array_ref]+1, 5, 10)
elif species == "bsc" and direction == "backwards":
    start_time = datetime(year_array[array_ref], 7, 31)
    end_time = datetime(year_array[array_ref]+1, 5, 30)

runtime = end_time-start_time + delta(days=1)


if direction == "forwards" and species == "gmc" or species == "bsc" and direction == "backwards" or direction == "forwards":
    # Randomly choose a new release location for each day of the spawning season
    # Still need the grouping, not sure why - maybe something to do with the apply() function
    locations = df.groupby('ocean_zone').apply(pd.DataFrame.sample, n = runtime.days).reset_index(drop=True)[["lat", "lon", 'ocean_zone']] # list of random points for every release
    lat = np.repeat(locations["lat"], npart) # repeat every location by the number of particles 
    lon = np.repeat(locations["lon"], npart)
    depth = 
    # Testing to see about passing a custom variable into a particleset
    #ocean_zone = np.repeat(locations["ocean_zone"], npart)
    

# Set up the hydrodynamic model
ufiles = sorted(glob('/srv/scratch/z5278054/portunid_particle_tracking/ozroms/ozroms_2000/*'))
vfiles = ufiles
wfiles = ufiles
tfiles = ufiles
mesh_mask = 'srv/scratch/z5278054/portunid_particle_tracking/ozroms/bathymetry.nc'

filenames = {'U': ufiles,
             'V': vfiles,
             'temp': tfiles}#,
             'bathy': mesh_mask}

variables = {'U': 'u',
             'V': 'v',
             'temp': 'sst'}#,
             'bathy': 'h'}

dimensions = {'U': {'lon': 'lon', 'lat': 'lat', 'depth': 'depth', 'time': 'time'},
             'V': {'lon': 'lon', 'lat': 'lat', 'depth': 'depth', 'time': 'time'},
             'temp': {'lon': 'lon', 'lat': 'lat', 'depth': 'depth', 'time': 'time'}}#, # double check when you get the new files
             'bathy': {'depth': 'depth', 'lon': 'lon', 'lat': 'lat'}} # double check when you get the new files

#indices = {'depth': [1]} # surface

# Define fieldset
fieldset = FieldSet.from_netcdf(filenames, variables, dimensions, allow_time_extrapolation = True) #, indices
fieldset.add_constant('maxage', 40.*86400)
fieldset.temp.interp_method = 'nearest'

Kh_zonal = 8.8
Kh_meridional = Kh_zonal

# Set diffusion constants and add them to the fieldset (units = m/s) - this method is from Peliz et al., 2007 (doi:10.1016/j.jmarsys.2006.11.007)
# set turbulent dissipation rate ('jerk'; m^2/s^-3)
#turb_dissip_rate = 10**-9
#across = 4 # across-shore resolution = 4km
#along = 4 # along-shore resolution = 4km
#resolution = (across*along)**3 # convert from km to m
#Kh_zonal = (turb_dissip_rate**(1/3))*(resolution**(4/3))
#Kh_meridional = Kh_zonal

size2D = (fieldset.U.grid.ydim, fieldset.U.grid.xdim)
fieldset.add_field(Field('Kh_zonal', Kh_zonal*np.ones(size2D), 
                         lon=fieldset.U.grid.lon, lat=fieldset.U.grid.lat, mesh='spherical'))
fieldset.add_field(Field('Kh_meridional', Kh_meridional*np.ones(size2D), 
                         lon=fieldset.U.grid.lon, lat=fieldset.U.grid.lat, mesh='spherical'))

# Where to save
if direction == "forwards" and species == "gmc" or species == "bsc" and direction == "backwards" or direction == "forwards":
    out_file = str(out_dir)+'/'+str(species)+'_'+str(year_array[array_ref])+'_'+str(zones[mod_array_num])+'_'+str(direction)+'.nc'
else:
    out_file = str(out_dir)+'/'+str(species)+'_'+str(year_array[array_ref])+'_'+str(direction)+'.nc'

# If output file already exists then remove it
if os.path.exists(out_file):
    os.remove(out_file)

random.seed(123456) # Set random seed
  
# Define a new particle class - includes fixes so particles initialise in JIT mode (see SampleInitial kernel below)
if direction == "forwards" and species == "gmc" or species == "bsc" and direction == "backwards" or direction == "forwards":
    class SampleParticle(JITParticle): 
        sampled = Variable('sampled', dtype = np.float32, initial = 0, to_write=False)
        age = Variable('age', dtype=np.float32, initial=0.) # initialise age
        temp = Variable('temp', dtype=np.float32, initial=0)  # initialise temperature
        #bathy = Variable('bathy', dtype=np.float32, initial=0) # initialise bathymetry
        distance = Variable('distance', initial=0., dtype=np.float32)  # the distance travelled
        prev_lon = Variable('prev_lon', dtype=np.float32, to_write=False,
                            initial=0)  # the previous longitude
        prev_lat = Variable('prev_lat', dtype=np.float32, to_write=False,
                            initial=0)  # the previous latitude
        ocean_zone = Variable('ocean_zone', initial=0)
else:
    class SampleParticle(JITParticle): 
        sampled = Variable('sampled', dtype = np.float32, initial = 0, to_write=False)
        age = Variable('age', dtype=np.float32, initial=0.) # initialise age
        temp = Variable('temp', dtype=np.float32, initial=0)  # initialise temperature
        #bathy = Variable('bathy', dtype=np.float32, initial=0) # initialise bathymetry
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
    
#def SampleBathy(particle, fieldset, time):
 #   particle.bathy = fieldset.bathy[0, 0, particle.lat, particle.lon]
    
# Kernel to speed up initialisation by using JIT mode not scipy
def SampleInitial(particle, fieldset, time): 
    if particle.sampled == 0:
         particle.temp = fieldset.temp[time, particle.depth, particle.lat, particle.lon]
         particle.prev_lon = particle.lon
         particle.prev_lat = particle.lat
         particle.sampled = 1

if direction == "forwards":
    # Define when you want tracking to start (i.e. start of the spawning season)
    pset_start = (start_time-datetime.strptime(str(fieldset.time_origin)[0:10], "%Y-%m-%d")).total_seconds()
    # Create an array of release times 
    release_times = pset_start + (np.arange(0, runtime.days) * repeatdt.total_seconds())  # can be made to go backwards by changing '+' to '-'
    # Multiply the release times by the number of particles
    time = np.repeat(release_times, npart)
elif direction == "backwards" and species == "bsc":
    # This might take some testing give start/end time confusion when going backwards...
    pset_start = (start_time-datetime.strptime(str(fieldset.time_origin)[0:10], "%Y-%m-%d")).total_seconds() # I think start_time will have to be end_time
    release_times = pset_start - (np.arange(0, runtime.days) * repeatdt.total_seconds())
    time = np.repeat(release_times, npart)
    
if direction == "forwards" and species == "gmc" or species == "bsc" and direction == "backwards" or direction == "forwards":
    pset = ParticleSet.from_list(fieldset, pclass=SampleParticle, time=time, lon=lon, lat=lat, ocean_zone=ocean_zone, repeatdt=None)   
else:
    pset = ParticleSet.from_list(fieldset, pclass=SampleParticle, lon=lon, lat=lat, time = end_time, repeatdt=repeatdt)

pfile = pset.ParticleFile(out_file, outputdt=delta(days=1))

# SampleInitial kernel must come first to initialise particles in JIT mode
kernels = SampleInitial + pset.Kernel(AdvectionRK4) + SampleAge + SampleDistance + DiffusionUniformKh + SampleTemp# + SampleBathy

if direction == "forwards":
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