# -*- coding: utf-8 -*-
"""
Created on Wed May  6 15:20:21 2020

@author: hayde
"""
from parcels import FieldSet, Field,  ParticleSet, JITParticle, Variable, random, plotTrajectoriesFile #AdvectionRK4, DiffusionUniformKh
from parcels import ErrorCode
import numpy as np
from glob import glob
from datetime import timedelta as delta
from datetime import datetime as datetime
import os
import math
from operator import attrgetter
#import cartopy
import pandas as pd
#import netCDF4


#filenames = {'U': (glob('/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking/BRAN/AUS/ocean_u_*')), 
#             'V': (glob('/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking/BRAN/AUS/ocean_v_*')),
#             'temp': (glob('/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking/BRAN/AUS/ocean_temp_*'))}
filenames = {'U': sorted(glob('/srv/scratch/z3374139/BRAN_AUS/Ocean_u_*')),
                  'V': sorted(glob('/srv/scratch/z3374139/BRAN_AUS/Ocean_v_*')),
                  'temp': sorted(glob('/srv/scratch/z3374139/BRAN_AUS/Ocean_temp_*')),
                  'bathy': '/srv/scratch/z3374139/BRAN_AUS/grid_spec.nc'}

#filenames = {'U': sorted(glob('/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN/AUS/Ocean_u_*')),
#                  'V': sorted(glob('/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN/AUS/Ocean_v_*')),
#                  'temp': sorted(glob('/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN/AUS/Ocean_temp_*')),
#                  'bathy': '/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN/AUS/grid_spec.nc'}


#filenames = {'U': '/Users/hayde/Crab-Dispersal/BRAN/ocean_u_1994_01X.nc',
#             'V': '/Users/hayde/Crab-Dispersal/BRAN/ocean_v_1994_01X.nc'}

npart = 1000  # number of particles to be released
repeatdt = delta(days=1)  # release from the same set of locations every X day

# Forward: 9
# lon_array = [153.8072, 153.5873, 153.5460, 153.6929, 153.7817, 153.7955, 153.7790, 153.7062, 153.5131]
# lat_array = [-26.0, -26.5, -27.0, -27.5, -28.0, -28.5, -29.0, -29.50, -30.00]

# Backwards: 13
#lon_array = [150.8550, 151.4167, 152.8444, 150.2451, 153.7313, 153.7861, 148.9148, 150.1600, 150.3833, 153.0958, 153.3182, 153.8036, 153.6422]
#lat_array = [-35.1, -33.8, -32, -36.2, -29.4, -28.1, -38, -37, -35.7, -31.4, -30.4, -28.8, -27.3]

##lon_array = [150.8550 , 151.4167, 152.8444, 150.2451]#, 153.7313, 153.7861, 148.9148, 150.1600, 150.3833, 153.0958, 153.3182, 153.8036, 153.6422]
##lat_array = [-35.1, -33.8, -32, -36.2]#, -29.4, -28.1, -38, -37, -35.7, -31.4, -30.4, -28.8, -27.3]

#lon = lon_array[array_ref] * np.ones(npart)
#lat = lat_array[array_ref] * np.ones(npart)

##lon = np.repeat(lon_array,npart)
##lat = np.repeat(lat_array,npart)

array_ref = int(os.environ['PBS_ARRAY_INDEX'])
#array_ref = 0 # 6*26-1


possible_locations = pd.read_csv("/srv/scratch/z5278054/portunid_particle_tracking/spanner_possible_locations.csv")

df = pd.DataFrame(possible_locations) 
# Make a list of the zones (i.e. 1 degree latitude bands to be released from)
# These can be anything you want (e.g. a box, a point) 
zones = df['ocean_zone'].unique()
# This calculates the remainder after diving by the number of release locations ('ocean_zones') you are modelling
mod_array_num = array_ref % len(zones)

year_array = np.arange(1993, 2020, 1) # change to 1993 later

year_array = np.repeat(year_array, len(zones))

df = df[df['ocean_zone'] == zones[mod_array_num]] # subset possible locations dataframe (df) to specific ocean zone

### Need to update this for Katana
start_time = datetime(year_array[array_ref],10, 1)
end_time = datetime(year_array[array_ref]+1,4, 30)  #year, month, day,

runtime = end_time-start_time + delta(days=1)

# Randomly choose a new release location for each day of the spawning season
# Still need the grouping, not sure why - maybe something to do with the apply() function
locations = df.groupby('ocean_zone').apply(pd.DataFrame.sample, n = runtime.days, replace=True).reset_index(drop=True)[["lat", "lon", 'ocean_zone', 'starting_particle_depth']] # list of random points for every release
lat = np.repeat(locations["lat"], npart) # repeat every location by the number of particles 
lon = np.repeat(locations["lon"], npart)
start_depth = np.repeat(locations["starting_particle_depth"], npart)
# Testing to see about passing a custom variable into a particleset
ocean_zone = np.repeat(locations["ocean_zone"], npart)  ### FIX

#lon = np.tile(lon, runtime.days)
#lat = np.tile(lat, runtime.days)

variables = {'U': 'u',
             'V': 'v',
             'temp': 'temp',
             'bathy': 'depth_t'}

dimensions = {}
dimensions['U'] = {'lat': 'yu_ocean', 'lon': 'xu_ocean', 'depth': 'st_ocean', 'time': 'Time'}
dimensions['V'] = {'lat': 'yu_ocean', 'lon': 'xu_ocean', 'depth': 'st_ocean', 'time': 'Time'}
dimensions['temp'] = {'lat': 'yt_ocean', 'lon': 'xt_ocean', 'depth': 'st_ocean', 'time': 'Time'} 
dimensions['bathy'] = {'lat': 'grid_y_T', 'lon': 'grid_x_T'} 

#indices = {'depth': [0]}

# Set diffusion constants.
Kh_zonal = 8.8
Kh_meridional = 8.8

# Make fieldset
fieldset = FieldSet.from_netcdf(filenames, variables, dimensions, allow_time_extrapolation = True)

fieldset.add_constant('maxage', 60.*86400)
fieldset.temp.interp_method = 'nearest'


## Define when you want tracking to start (i.e. start of the spawning season)
#pset_start = (start_time-datetime.strptime(str(fieldset.time_origin)[0:10], "%Y-%m-%d")).total_seconds()
# Create an array of release times 
#release_times = pset_start + (np.arange(0, runtime.days) * repeatdt.total_seconds())  # can be made to go backwards by changing '+' to '-'
#
## Multiply the release times by the number of particles
#time = np.repeat(release_times, npart*len(lon_array))



pset_start = (start_time-datetime.strptime(str(fieldset.time_origin)[0:10], "%Y-%m-%d")).total_seconds()
#print(pset_start)
# Create an array of release times 
release_times = pset_start + (np.arange(0, runtime.days) * repeatdt.total_seconds())  # can be made to go backwards by changing '+' to '-'
#print(release_times)
# Multiply the release times by the number of particles
time = np.repeat(release_times, npart)



# Diffusion
size2D = (fieldset.U.grid.ydim, fieldset.U.grid.xdim)
fieldset.add_field(Field('Kh_zonal', Kh_zonal*np.ones(size2D), 
                         lon=fieldset.U.grid.lon, lat=fieldset.U.grid.lat, mesh='spherical'))
fieldset.add_field(Field('Kh_meridional', Kh_meridional*np.ones(size2D), 
                         lon=fieldset.U.grid.lon, lat=fieldset.U.grid.lat, mesh='spherical'))

random.seed(123456) # Set random seed

class SampleParticle(JITParticle):         # Define a new particle class
    sampled = Variable('sampled', dtype = np.float32, initial = 0, to_write=False)
    age = Variable('age', dtype=np.float32, initial=0.) # initialise age
    temp = Variable('temp', dtype=np.float32, initial=0)  # initialise temperature
    bathy = Variable('bathy', dtype=np.float32, initial=0)  # initialise bathy
    depthA = Variable('depthA', dtype=np.float32, initial=0)  # initialise bathy
    distance = Variable('distance', initial=0., dtype=np.float32)  # the distance travelled
    prev_lon = Variable('prev_lon', dtype=np.float32, to_write=False,
                        initial=0)  # the previous longitude
    prev_lat = Variable('prev_lat', dtype=np.float32, to_write=False,
                        initial=0)  # the previous latitude.
    start_depth = Variable('start_depth', dtype=np.float32, to_write=True,
                        initial=0)  # the starting depth of a particle.
    u_vel = Variable('u_vel', dtype = np.float32, initial = 0)
    v_vel = Variable('v_vel', dtype = np.float32, initial = 0)
    ocean_zone = Variable('ocean_zone', initial=0)


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
    
def SampleDepth(particle, fieldset, time):
    particle.depthA = particle.depth
    
def SampleBathy(particle, fieldset, time):
    particle.bathy = fieldset.bathy[0,0,particle.lat, particle.lon]
    
def SampleVelocities(particle, fieldset, time):
    particle.u_vel = fieldset.U[time, particle.depth, particle.lat, particle.lon]
    particle.v_vel = fieldset.V[time, particle.depth, particle.lat, particle.lon]

# Kernel to speed up initialisation by using JIT mode not scipy
def SampleInitial(particle, fieldset, time): 
    if particle.sampled == 0:
         particle.temp = fieldset.temp[time, particle.depth, particle.lat, particle.lon]
         particle.bathy = fieldset.bathy[0,0,particle.lat, particle.lon]
         particle.prev_lon = particle.lon
         particle.prev_lat = particle.lat
         particle.sampled = 1
         particle.start_depth = particle.depth
         particle.depthA = particle.depth
         particle.u_vel = fieldset.U[time, particle.depth, particle.lat, particle.lon]
         particle.v_vel = fieldset.V[time, particle.depth, particle.lat, particle.lon]
         particle.ocean_zone = particle.ocean_zone


 #create a buoyancy kernel
 # Step 1 - need to start at the bottom - done
def larvalBuoyancy(particle, fieldset, time):
    surfaceLevel = 2.5 # surface depth
    if particle.depth > surfaceLevel:
        particle.depth -= (particle.start_depth-2.5)/(10*86400/particle.dt)
        if particle.depth < 2.5:
            particle.depth = 2.5
  
def Unbeaching(particle, fieldset, time):
    if particle.age == 0 and particle.u_vel == 0 and particle.v_vel == 0: # velocity = 0 means particle is on land so nudge it eastward
        particle.lon += random.uniform(0.5, 1)
    elif particle.u_vel == 0 and particle.v_vel == 0: # if a particle is advected on to land delete it
        particle.delete()

        
        
def AdvectionRK4_3D_alternative(particle, fieldset, time):
#    """Advection of particles using fourth-order Runge-Kutta integration with vertical velocity independent of vertical grid distortion.
#
#    Function needs to be converted to Kernel object before execution"""
    (u1, v1) = fieldset.UV[time, particle.depth, particle.lat, particle.lon]
    w1 = 0
    lon1 = particle.lon + u1*.5*particle.dt
    lat1 = particle.lat + v1*.5*particle.dt
    dep1 = particle.depth + w1*.5*particle.dt
    (u2, v2) = fieldset.UV[time + .5 * particle.dt, dep1, lat1, lon1]
    w2 = 0
    lon2 = particle.lon + u2*.5*particle.dt
    lat2 = particle.lat + v2*.5*particle.dt
    dep2 = particle.depth + w2*.5*particle.dt
    (u3, v3) = fieldset.UV[time + .5 * particle.dt, dep2, lat2, lon2]
    w3 = 0
    lon3 = particle.lon + u3*particle.dt
    lat3 = particle.lat + v3*particle.dt
    dep3 = particle.depth + w3*particle.dt
    (u4, v4) = fieldset.UV[time + particle.dt, dep3, lat3, lon3]
    w4 = 0
    particle.lon += (u1 + 2*u2 + 2*u3 + u4) / 6. * particle.dt
    particle.lat += (v1 + 2*v2 + 2*v3 + v4) / 6. * particle.dt
    particle.depth += (w1 + 2*w2 + 2*w3 + w4) / 6. * particle.dt


def DiffusionUniformKh2(particle, fieldset, time):
    dWx = random.uniform(-1., 1.) * math.sqrt(math.fabs(particle.dt) * 3)
    dWy = random.uniform(-1., 1.) * math.sqrt(math.fabs(particle.dt) * 3)
    bx = math.sqrt(2 * fieldset.Kh_zonal[time, particle.depth, particle.lat, particle.lon])
    by = math.sqrt(2 * fieldset.Kh_meridional[time, particle.depth, particle.lat, particle.lon])
    particle.lon += bx * dWx
    particle.lat += by * dWy


#end_time = np.repeat(end_time,len(lon))
#start_time = np.repeat(start_time,len(lon))


pset = ParticleSet.from_list(fieldset, pclass=SampleParticle, lon=lon, lat=lat,ocean_zone=ocean_zone, time = time, depth =start_depth) #, time=start_time

#pset.show(domain={'N':-28, 'S':-30, 'E':154.5, 'W':153}) #

#out_file = "/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN/Output/BRAN_Test_output.nc"
out_file = str("/srv/scratch/z5278054/portunid_particle_tracking/spanner/forwards/spanner_") +str(year_array[array_ref])+'_'+str("forward_")+str(array_ref)+'.nc'
pfile = pset.ParticleFile(out_file, outputdt=delta(days=1))

if os.path.exists(out_file):
    os.remove(out_file)



kernels = SampleInitial + pset.Kernel(AdvectionRK4_3D_alternative) + DiffusionUniformKh2 + SampleAge+ SampleTemp + SampleDepth+ SampleDistance + SampleVelocities + SampleBathy + larvalBuoyancy + Unbeaching

pset.execute(kernels, runtime=delta(days = 0), dt=delta(minutes = 5))
pset.execute(kernels, 
             dt=delta(minutes=5), 
             output_file=pfile, 
             verbose_progress=True,
             #moviedt=delta(hours=1),
             runtime = runtime, #runtime,
             recovery={ErrorCode.ErrorOutOfBounds: DeleteParticle})
pfile.close()

#depth_level = 7.5

#pset.show(domain={'N':-28, 'S':-30, 'E':154.5, 'W':153}, field='vector') #

#pset.show(domain={'N':-23, 'S':-40, 'E':160, 'W':145}, field='vector')
#pset.show(domain={'N':-23, 'S':-40, 'E':160, 'W':145}, field='bathy', show_time=0) #


#plotTrajectoriesFile("/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking/BRAN/Output/BRAN_Test_output.nc");
#plotTrajectoriesFile("/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN/Output/BRAN_Test_output.nc");

#fieldset.U.show(domain={'N':-28, 'S':-30, 'E':154.5, 'W':153})
#fieldset.temp.show(domain={'N':-20, 'S':-35, 'E':157, 'W':150})
#fieldset.V.show(domain={'N':-28, 'S':-30, 'E':154.5, 'W':153})
#fieldset.U.show(domain={'N':-28, 'S':-29, 'E':154, 'W':153.2})
#pset.show(domain={'N':-28, 'S':-37, 'E':157, 'W':150}, field='vector') #, projection=cartopy.crs.EqualEarth()


