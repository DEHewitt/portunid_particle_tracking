# -*- coding: utf-8 -*-
"""
Created on Wed May  6 15:20:21 2020

@author: hayde
"""
from parcels import FieldSet, Field, AdvectionRK4, ParticleSet, JITParticle, Variable, BrownianMotion2D, random
from parcels import ErrorCode
import numpy as np
from glob import glob
#import time as timelib
from datetime import timedelta as delta
from datetime import datetime as datetime
#import cartopy
import math
import os
from operator import attrgetter

out_dir = '/srv/scratch/z3374139/BRAN_AUS/'

filenames = {'U': sorted(glob('/srv/scratch/z3374139/BRAN_AUS/Ocean_u_*')), 
             'V': sorted(glob('/srv/scratch/z3374139/BRAN_AUS/Ocean_v_*')),
             'temp': sorted(glob('/srv/scratch/z3374139/BRAN_AUS/Ocean_temp_*'))}


npart = 3  # number of particles to be released
repeatdt = delta(days=1)  # release from the same set of locations every X day

# Forward: 9
# lon_array = [153.8072, 153.5873, 153.5460, 153.6929, 153.7817, 153.7955, 153.7790, 153.7062, 153.5131]
# lat_array = [-26.0, -26.5, -27.0, -27.5, -28.0, -28.5, -29.0, -29.50, -30.00]

# Backwards: 13
#lon_array = [150.8550, 151.4167, 152.8444, 150.2451, 153.7313, 153.7861, 148.9148, 150.1600, 150.3833, 153.0958, 153.3182, 153.8036, 153.6422]
#lat_array = [-35.1, -33.8, -32, -36.2, -29.4, -28.1, -38, -37, -35.7, -31.4, -30.4, -28.8, -27.3]

lon_array = [150.8550 , 151.4167, 152.8444, 150.2451]#, 153.7313, 153.7861, 148.9148, 150.1600, 150.3833, 153.0958, 153.3182, 153.8036, 153.6422]
lat_array = [-35.1, -33.8, -32, -36.2]#, -29.4, -28.1, -38, -37, -35.7, -31.4, -30.4, -28.8, -27.3]


#lon = lon_array[array_ref] * np.ones(npart)
#lat = lat_array[array_ref] * np.ones(npart)

lon = np.repeat(lon_array,npart)
lat = np.repeat(lat_array,npart)

# Set the year here
#array_ref = int(os.environ['PBS_ARRAYID'])
array_ref = 3

year_array = np.arange(1994, 2016, 1)

start_time = datetime(year_array[array_ref],2, 15)
end_time = datetime(year_array[array_ref],4, 20)  #year, month, day,

runtime = end_time-start_time + delta(days=1)

variables = {'U': 'u',
             'V': 'v',
             'temp': 'temp'}

dimensions = {}
dimensions['U'] = {'lat': 'yu_ocean', 'lon': 'xu_ocean', 'depth': 'st_ocean', 'time': 'Time'}
dimensions['V'] = {'lat': 'yu_ocean', 'lon': 'xu_ocean', 'depth': 'st_ocean', 'time': 'Time'}
dimensions['temp'] = {'lat': 'yt_ocean', 'lon': 'xt_ocean', 'depth': 'st_ocean', 'time': 'Time'} 

indices = {'depth': [0]}

# Set diffusion constants.
Kh_zonal = 10
Kh_meridional = 10

# Make fieldset
fieldset = FieldSet.from_netcdf(filenames, variables, dimensions, allow_time_extrapolation = True)

fieldset.add_constant('maxage', 40.*86400)
fieldset.temp.interp_method = 'nearest'


# Diffusion
size2D = (fieldset.U.grid.ydim, fieldset.U.grid.xdim)
fieldset.add_field(Field('Kh_zonal', Kh_zonal*np.ones(size2D), 
                         lon=fieldset.U.grid.lon, lat=fieldset.U.grid.lat, mesh='spherical'))
fieldset.add_field(Field('Kh_meridional', Kh_meridional*np.ones(size2D), 
                         lon=fieldset.U.grid.lon, lat=fieldset.U.grid.lat, mesh='spherical'))

random.seed(123456) # Set random seed

class SampleParticle(JITParticle):         # Define a new particle class
    age = Variable('age', dtype=np.float32, initial=0.) # initialise age
    temp = Variable('temp', dtype=np.float32, initial=fieldset.temp)  # initialise temperature
    #bathy = Variable('bathy', dtype=np.float32, initial=fieldset.bathy)  # initialise bathy
    distance = Variable('distance', initial=0., dtype=np.float32)  # the distance travelled
    prev_lon = Variable('prev_lon', dtype=np.float32, to_write=False,
                        initial=attrgetter('lon'))  # the previous longitude
    prev_lat = Variable('prev_lat', dtype=np.float32, to_write=False,
                        initial=attrgetter('lat'))  # the previous latitude.


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


end_time = np.repeat(end_time,len(lon))
start_time = np.repeat(start_time,len(lon))


pset = ParticleSet.from_list(fieldset, pclass=SampleParticle,time = end_time, lon=lon, lat=lat, repeatdt=repeatdt) #, time=start_time


out_file = str(out_dir)+'/'+str(year_array[array_ref])+'_Back.nc'
pfile = pset.ParticleFile(out_file, outputdt=delta(days=1))

if os.path.exists(out_file):
    os.remove(out_file)



kernels = pset.Kernel(AdvectionRK4) +  SampleAge+ SampleTemp +  SampleDistance + BrownianMotion2D #SampleBathy  +


pset.execute(kernels, 
             dt=-delta(minutes=30), 
             output_file=pfile, 
             verbose_progress=True,
             #moviedt=delta(hours=1),
             runtime = runtime,
             recovery={ErrorCode.ErrorOutOfBounds: DeleteParticle})
pfile.close()