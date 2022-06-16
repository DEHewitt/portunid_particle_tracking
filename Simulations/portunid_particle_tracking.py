#!home/z5278054/python_parcels/bin/python3

from parcels import FieldSet, Field, ParticleSet, JITParticle, Variable, DiffusionUniformKh, random, AdvectionRK4#_3D
from parcels import ErrorCode
import numpy as np
from glob import glob
from datetime import timedelta as delta
from datetime import datetime as datetime
import os
import math
import pandas as pd

# These are specified in the .pbs script for job submission
species = os.environ['species']
direction = os.environ['direction'] 
    
# Where to save the files based on the input
out_dir = '/srv/scratch/z5278054/portunid_particle_tracking/'+str(species)+'/'+str(direction)

# How many particles to release
if direction == "forwards":
    npart = 1000  
elif direction == "backwards":
    npart = 455 # based on Cetina-Heredia et al., 2015

array_ref = int(os.environ['PBS_ARRAY_INDEX']) # has to equal number of locations * number of years

# How often to release the particles
repeatdt = delta(days = 1) 

# release locations initially extracted from GEBCO, except for gmc+backwards (they're at the mouths of major estuaries)
if species == "gmc" and direction == "backwards":
    lat = np.repeat([-18.541, -23.850, -25.817, -27.339, -28.165, -28.890, -29.432, -30.864, -31.645, -31.899, -32.193, -32.719, -32.917, -33.578], npart)
    lon = np.repeat([147.848, 152.538, 153.762, 153.636, 153.790, 153.799, 153.736, 153.172, 153.048, 152.946, 152.775, 152.312, 152.045, 151.577], npart)
elif species == "bsc" and direction == "backwards":
    lat = np.repeat([-25.817, -27.339, -32.193, -32.719, -32.917, -33.578, -34.5457], npart)
    lon = np.repeat([153.762, 153.636, 152.775, 152.312, 152.045, 151.577, 151.0173], npart)
else:
    possible_locations = pd.read_csv("/srv/scratch/z5278054/portunid_particle_tracking/"+str(species)+"_possible_locations.csv") # either in '.../portunid_particle_tracking/Simulations' or '...data_processed/'

# Convert possible_locations to a Pandas dataframe
if direction == "forwards" or species == "spanner" and direction == "backwards":
    df = pd.DataFrame(possible_locations) 
    # Make a list of the zones (i.e. 1 degree latitude bands to be released from)
    # These can be anything you want (e.g. a box, a point) 
    zones = df['ocean_zone'].unique()
    # This calculates the remainder after diving by the number of release locations ('ocean_zones') you are modelling
    mod_array_num = array_ref % len(zones)
    
# Define the duration of the model (in years) 
year_array = np.arange(2008, 2018, 1)  # to be changed out to 2018 once all data is shared by UWA

if direction == "backwards" and species == "gmc" or direction == "backwards" and species == "bsc":
    year_array = year_array
else:
    # repeat the year_array by the number of zones (so there is a job in each zone each year) for the random release method
    year_array = np.repeat(year_array, len(zones))

if direction == "forwards" or species == "spanner" and direction == "backwards":
    df = df[df['ocean_zone'] == zones[mod_array_num]] # subset possible locations dataframe (df) to specific ocean zone

# Spawning season, add on a month to ensure release particles have enough time to reach degree-days
# See "portunid_aus_spawning_season_201007.xls"
if species == "gmc" and direction == "forwards":
    start_time = datetime(year_array[array_ref], 9, 1) # year, month, day
    end_time = datetime(year_array[array_ref]+1, 5, 30)
elif species == "bsc" and direction == "forwards":
    start_time = datetime(year_array[array_ref], 9, 1)
    end_time = datetime(year_array[array_ref]+1, 5, 30)
elif species == "gmc" and direction == "backwards":
    start_time = datetime(year_array[array_ref], 9, 1)
    end_time = datetime(year_array[array_ref]+1, 6, 10)
elif species == "bsc" and direction == "backwards":
    start_time = datetime(year_array[array_ref], 9, 1)
    end_time = datetime(year_array[array_ref]+1, 6, 10)
elif species == "spanner" and direction == "forwards":
    start_time = datetime(year_array[array_ref], 10, 1)
    end_time = datetime(year_array[array_ref]+1, 3, 31)
elif species == "spanner" and direction == "backwards":
    start_time = datetime(year_array[array_ref], 9, 30)
    end_time = datetime(year_array[array_ref]+1, 3, 11)

runtime = end_time-start_time + delta(days=1)

if direction == "forwards" or species == "spanner" and direction == "backwards":
    # Randomly choose a new release location for each day of the spawning season
    # Still need the grouping, not sure why - maybe something to do with the apply() function
    locations = df.groupby('ocean_zone').apply(pd.DataFrame.sample, n = runtime.days, replace = True).reset_index(drop = True)[["lat", "lon", 'ocean_zone']] # list of random points for every release
    lat = np.repeat(locations["lat"], npart) # repeat every location by the number of particles 
    lon = np.repeat(locations["lon"], npart)
    # Testing to see about passing a custom variable into a particleset
    ocean_zone = np.repeat(locations["ocean_zone"], npart)
    

# Set up the hydrodynamic model
data_path = '/srv/scratch/z5278054/portunid_particle_tracking/ozroms/'
#data_path = 'C:/Users/Dan/OneDrive - UNSW/Documents/PhD/Dispersal/data_raw/'
#ufiles = data_path + '20180731.nc'
ufiles = sorted(glob('/srv/scratch/z5278054/portunid_particle_tracking/ozroms/2*'))
vfiles = ufiles
wfiles = ufiles
tfiles = ufiles
mesh_mask = data_path + 'bathymetry.nc'

filenames = {'U': {'lon': mesh_mask, 'lat': mesh_mask, 'depth': mesh_mask, 'data': ufiles},
             'V': {'lon': mesh_mask, 'lat': mesh_mask, 'depth': mesh_mask, 'data': vfiles},
             'WA': {'lon': mesh_mask, 'lat': mesh_mask, 'depth': mesh_mask, 'data': wfiles},
             'temp': {'lon': mesh_mask, 'lat': mesh_mask, 'depth': mesh_mask, 'data': tfiles},
             'bathy': {'lon': mesh_mask, 'lat': mesh_mask, 'depth': mesh_mask, 'data': mesh_mask}}

variables = {'U': 'u',
             'V': 'v',
             'WA': 'w',
             'temp': 'sst',
             'bathy': 'h'}

dimensions = {'U': {'lon': 'lon', 'lat': 'lat', 'depth': 'depth', 'time': 'time'},
              'V': {'lon': 'lon', 'lat': 'lat', 'depth': 'depth', 'time': 'time'},
              'WA': {'lon': 'lon', 'lat': 'lat', 'depth': 'depth', 'time': 'time'},
              'temp': {'lon': 'lon', 'lat': 'lat', 'depth': 'depth', 'time': 'time'},
              'bathy': {'lon': 'lon', 'lat': 'lat', 'time': 'time'}}

# Define fieldset
fieldset = FieldSet.from_netcdf(filenames, variables, dimensions, allow_time_extrapolation = True) 
if species == "gmc" or species == "bsc":
    fieldset.add_constant('maxage', 40.) # changed so that larvalBuoyancy kernel works
else:
    fieldset.add_constant('maxage', 40.) # longer because spanner takes longer to grow
fieldset.temp.interp_method = 'nearest'

Kh_zonal = 8.8 # following Cetina Heredia et al. (2015, 2019)
Kh_meridional = Kh_zonal

size2D = (fieldset.U.grid.ydim, fieldset.U.grid.xdim) # size3D? add: fieldset.U.grid.zdim
fieldset.add_field(Field('Kh_zonal', Kh_zonal*np.ones(size2D), # size3D?
                         lon=fieldset.U.grid.lon, lat=fieldset.U.grid.lat, mesh='spherical'))
fieldset.add_field(Field('Kh_meridional', Kh_meridional*np.ones(size2D), # size3D?
                         lon=fieldset.U.grid.lon, lat=fieldset.U.grid.lat, mesh='spherical'))

# Where to save
if direction == "forwards" or species == "spanner" and direction == "backwards":
    out_file = str(out_dir)+'/'+str(species)+'_'+str(year_array[array_ref])+'_'+str(zones[mod_array_num])+'_'+str(direction)+'.nc'
else:
    out_file = str(out_dir)+'/'+str(species)+'_'+str(year_array[array_ref])+'_'+str(direction)+str(array_ref)+'.nc'

# If output file already exists then remove it
if os.path.exists(out_file):
    os.remove(out_file)

random.seed(123456) # Set random seed
  
# Define a new particle class - includes fixes so particles initialise in JIT mode (see SampleInitial kernel below)
if direction == "forwards" or species == "spanner" and direction == "backwards":
    class SampleParticle(JITParticle): 
        sampled = Variable('sampled', dtype = np.float32, initial = 0, to_write=False)
        age = Variable('age', dtype=np.float32, initial=0.) # initialise age
       # ageRise = Variable('ageRise', dtype=np.float32, initial=0.)
        temp = Variable('temp', dtype=np.float32, initial=0)  # initialise temperature
        bathy = Variable('bathy', dtype=np.float32, initial=0) # initialise bathymetry - try changing 0 to fieldset.bathy[particle.lat, particle.lon]
        distance = Variable('distance', initial=0., dtype=np.float32)  # the distance travelled
        prev_lon = Variable('prev_lon', dtype=np.float32, to_write=False,
                            initial=0)  # the previous longitude
        prev_lat = Variable('prev_lat', dtype=np.float32, to_write=False,
                            initial=0)  # the previous latitude
        ocean_zone = Variable('ocean_zone', initial=0)
        depth_m = Variable('depth_m', dtype = np.float32, initial = 0)
        temp_m = Variable('temp_m', dtype = np.float32, initial = 0, to_write=False)
        u_vel = Variable('u_vel', dtype = np.float32, initial = 0)
        v_vel = Variable('v_vel', dtype = np.float32, initial = 0)
        beached = Variable('beached', dtype = np.float32, initial = 0)
else:
    class SampleParticle(JITParticle): 
        sampled = Variable('sampled', dtype = np.float32, initial = 0, to_write=False)
        age = Variable('age', dtype=np.float32, initial=0.) # initialise age
       # ageRise = Variable('ageRise', dtype=np.float32, initial=0.)
        temp = Variable('temp', dtype=np.float32, initial=0)  # initialise temperature
        bathy = Variable('bathy', dtype=np.float32, initial=0) # initialise bathymetry
        distance = Variable('distance', initial=0., dtype=np.float32)  # the distance travelled
        prev_lon = Variable('prev_lon', dtype=np.float32, to_write=False,
                            initial=0)  # the previous longitude
        prev_lat = Variable('prev_lat', dtype=np.float32, to_write=False,
                            initial=0)  # the previous latitude
        depth_m = Variable('depth_m', dtype = np.float32, initial = 0)
        #temp_m = Variable('temp_m', dtype = np.float32, initial = 0, to_write=False)
        u_vel = Variable('u_vel', dtype = np.float32, initial = 0)
        v_vel = Variable('v_vel', dtype = np.float32, initial = 0)
        beached = Variable('beached', dtype = np.float32, initial = 0)
        
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
    
def SampleAge(particle, fieldset, time): # for deleting particles/recording their age (in days)
    particle.age = particle.age + math.fabs(particle.dt/86400)
    if particle.age > fieldset.maxage:
        particle.delete()
        
def SampleVelocities(particle, fieldset, time):
    particle.u_vel = fieldset.U[time, particle.depth, particle.lat, particle.lon]
    particle.v_vel = fieldset.V[time, particle.depth, particle.lat, particle.lon]
    
def Unbeaching(particle, fieldset, time):
    if particle.age == 0 and particle.u_vel == 0 and particle.v_vel == 0: # velocity = 0 means particle is on land so nudge it eastward
        particle.lon += random.uniform(0.5, 1)
    elif particle.u_vel == 0 and particle.v_vel == 0: # if a particle is advected on to land so mark it as beached (=1)
        particle.beached = 1

def SampleTemp(particle, fieldset, time):
    particle.temp = fieldset.temp[time, particle.depth, particle.lat, particle.lon]
    
def SampleBathy(particle, fieldset, time):
    particle.bathy = fieldset.bathy[0, 0, particle.lat, particle.lon]
    
def SampleParticleDepth(particle, fieldset, time):
    particle.depth_m = particle.bathy*particle.depth
    
# Kernel to speed up initialisation by using JIT mode not scipy
if direction == "forwards" or species == "spanner" and direction == "backwards":
    def SampleInitial(particle, fieldset, time): # do we have to add particle.age and particle.ageRise
        if particle.sampled == 0:
            particle.age = particle.age
            #particle.ageRise = particle.ageRise
            particle.temp = fieldset.temp[time, particle.depth, particle.lat, particle.lon]
            particle.bathy = fieldset.bathy[time, particle.depth, particle.lat, particle.lon]
            particle.distance = particle.distance
            particle.prev_lon = particle.lon
            particle.prev_lat = particle.lat
            particle.ocean_zone = particle.ocean_zone 
            particle.depth_m = particle.bathy*particle.depth
            particle.temp_m = particle.depth*particle.bathy
            particle.u_vel = fieldset.U[time, particle.depth, particle.lat, particle.lon]
            particle.v_vel = fieldset.V[time, particle.depth, particle.lat, particle.lon]
            particle.beached = particle.beached
            particle.sampled = 1
            
elif direction == "backwards":
    def SampleInitial(particle, fieldset, time): # do we have to add particle.age and particle.ageRise
        if particle.sampled == 0:
            particle.age = particle.age
            #particle.ageRise = particle.ageRise
            particle.temp = fieldset.temp[time, particle.depth, particle.lat, particle.lon]
            particle.bathy = fieldset.bathy[time, particle.depth, particle.lat, particle.lon]
            particle.distance = particle.distance
            particle.prev_lon = particle.lon
            particle.prev_lat = particle.lat
           # particle.ocean_zone = particle.ocean_zone 
            particle.depth_m = particle.bathy*particle.depth
            #particle.temp_m = particle.depth*particle.bathy
            particle.u_vel = fieldset.U[time, particle.depth, particle.lat, particle.lon]
            particle.v_vel = fieldset.V[time, particle.depth, particle.lat, particle.lon]
            particle.beached = particle.beached
            particle.sampled = 1
         
# kernel to force particles above the bottom boundary if they ever go through it
#def ResetDepth(particle, fieldset, time):
 #   if particle.temp_m/particle.bathy < -0.9833334: 
  #      particle.depth = -0.983333
   # else: particle.depth = particle.temp_m/particle.bathy
    
# kernel to get the particles to float to the surface
#def larvalBuoyancy(particle, fieldset, time):
 #   surfaceLevel = -0.0166672221875 # surface s-level
    #floatSpeed =  (-particle.depth_m/10/288)/particle.bathy # equal to 3 s-levels per day
    #if particle.depth < surfaceLevel:
    #    particle.depth += floatSpeed
    #age2 = round(particle.age) # to whole numbers
  #  age2 = particle.age
   # if age2 <= 10:
    #    floatSpeed = (-particle.depth_m/(10-age2))/particle.bathy/288
     #   if (particle.depth + floatSpeed >= surfaceLevel):
      #      particle.depth = surfaceLevel
       # else: 
        #    particle.depth += floatSpeed
    #else: particle.depth= surfaceLevel
        
#def AdvectionRK4_3D_alternative(particle, fieldset, time):
    """Advection of particles using fourth-order Runge-Kutta integration with vertical velocity independent of vertical grid distortion.

    Function needs to be converted to Kernel object before execution"""
   # particle.temp_m = particle.depth*particle.bathy
   #(u1, v1) = fieldset.UV[time, particle.depth, particle.lat, particle.lon]
    #w1 = fieldset.WA[time, particle.depth, particle.lat, particle.lon]
    #lon1 = particle.lon + u1*.5*particle.dt
    #lat1 = particle.lat + v1*.5*particle.dt
    #dep1 = particle.depth + w1*.5*particle.dt
    #(u2, v2) = fieldset.UV[time + .5 * particle.dt, dep1, lat1, lon1]
    #w2 = fieldset.WA[time + .5 * particle.dt, dep1, lat1, lon1]
    #lon2 = particle.lon + u2*.5*particle.dt
    #lat2 = particle.lat + v2*.5*particle.dt
    #dep2 = particle.depth + w2*.5*particle.dt
    #(u3, v3) = fieldset.UV[time + .5 * particle.dt, dep2, lat2, lon2]
    #w3 = fieldset.WA[time + .5 * particle.dt, dep2, lat2, lon2]
    #lon3 = particle.lon + u3*particle.dt
    #lat3 = particle.lat + v3*particle.dt
    #dep3 = particle.depth + w3*particle.dt
    #(u4, v4) = fieldset.UV[time + particle.dt, dep3, lat3, lon3]
    #w4 = fieldset.WA[time + particle.dt, dep3, lat3, lon3]
    #particle.lon += (u1 + 2*u2 + 2*u3 + u4) / 6. * particle.dt
    #particle.lat += (v1 + 2*v2 + 2*v3 + v4) / 6. * particle.dt
    #particle.depth += (w1 + 2*w2 + 2*w3 + w4) / 6. * particle.dt
    #particle.depth = temp_m/particle.bathy

if direction == "forwards":
    # Define when you want tracking to start (i.e. start of the spawning season)
    pset_start = (start_time-datetime.strptime(str(fieldset.time_origin)[0:10], "%Y-%m-%d")).total_seconds()
    # Create an array of release times 
    release_times = pset_start + (np.arange(0, runtime.days) * repeatdt.total_seconds())  
    # Multiply the release times by the number of particles
    time = np.repeat(release_times, npart)
elif direction == "backwards" and species == "spanner":
    # This might take some testing give start/end time confusion when going backwards...
    pset_start = (start_time-datetime.strptime(str(fieldset.time_origin)[0:10], "%Y-%m-%d")).total_seconds() # I think start_time will have to be end_time
    release_times = pset_start + (np.arange(0, runtime.days) * repeatdt.total_seconds())
    time = np.repeat(release_times, npart)
    
if direction == "forwards" or species == "spanner" and direction == "backwards":
    pset = ParticleSet.from_list(fieldset, 
                                 pclass=SampleParticle, 
                                 time=time, 
                                 lon=lon, 
                                 lat=lat,
                                 ocean_zone=ocean_zone,
                                 repeatdt=None,
                                 depth=np.repeat(fieldset.WA.grid.depth[0], len(lat)))
else:
    pset = ParticleSet.from_list(fieldset, 
                                 pclass=SampleParticle, 
                                 lon=lon, 
                                 lat=lat, 
                                 time = end_time, # what?
                                 repeatdt=repeatdt, 
                                 depth=np.repeat(fieldset.WA.grid.depth[29], len(lat))) # last index is shallowest... I think/hope

pfile = pset.ParticleFile(out_file, outputdt=delta(days=1))

# SampleInitial kernel must come first to initialise particles in JIT mode
kernels = SampleInitial + pset.Kernel(AdvectionRK4) + SampleAge + SampleDistance + DiffusionUniformKh + SampleTemp + SampleBathy + SampleVelocities + Unbeaching + SampleParticleDepth#+ ResetDepth + larvalBuoyancy

if direction == "forwards": #or species == "spanner" and direction == "backwards": 
    pset.execute(kernels, runtime=delta(days = 0), dt=delta(minutes = 5)) # to get initial values for everything
    pset.execute(kernels, 
             dt=delta(minutes=5), 
             output_file=pfile, 
             verbose_progress=True,
             runtime = runtime,
             recovery={ErrorCode.ErrorOutOfBounds: DeleteParticle})
else:
    pset.execute(kernels, runtime=delta(days = 0), dt=-delta(minutes = 5)) # to get initial values for everything
    pset.execute(kernels, 
         dt=-delta(minutes=5), 
         output_file=pfile, 
         verbose_progress=True,
         runtime = runtime,
         recovery={ErrorCode.ErrorOutOfBounds: DeleteParticle})
pfile.close()