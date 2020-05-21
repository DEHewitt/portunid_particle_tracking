#!/home/z5278054/py3_parcels/bin/python

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

out_dir = '/srv/scratch/z5278054/GMC_particle_tracking/'

npart = 100  # number of particles to be released
repeatdt = delta(days=1)  # release from the same set of locations every X day

# Forward: 9
# lon_array = []
# lat_array = []

# Backwards: 13
lon_array = [153.790, 153.799, 153.736, 153.172, 153.048, 152.946, 152.775, 152.312, 152.045, 151.577]
lat_array = [-28.165, -28.890, -29.432, -30.864, -31.645, -31.899, -32.193, -32.719, -32.917, -33.578]

lon = np.repeat(lon_array,npart)
lat = np.repeat(lat_array,npart)

array_ref = 9 # which season to simulate (0 = 1994/95, 22 = 2015/16)

# Spawning season is September to March (Heasman et al. 1985)
# Reality language: start date will be 30th August and run until 15th May (the year after) to allow for the full 40 days of tracking.
# Particle reality: the first day of life (and hence the 'start') for particles will be 15th May.

# Manually set the filenames. The names correspond to the number of days since 1, 1, 1990
file_nos = np.arange(1461, 9742, 30)
year_array = np.arange(1994, 2016, 1)

# Days since 1990
start_time = datetime(year_array[array_ref],8, 30) # year, month, day
start_dys = start_time-datetime(1990,1,1) + delta(days=1)
start_id = np.where(file_nos<=start_dys.days) #Find the reference file location
start_id = start_id[0][-1]

end_time = datetime(year_array[array_ref]+1, 5, 15)  #year, month, day
end_dys = end_time-datetime(1990,1,1) + delta(days=1)
end_id = np.where(file_nos>=end_dys.days) #Find the reference file location
end_id = end_id[0][0]

runtime = end_time-start_time + delta(days=1)

ufiles = sorted(glob('/srv/scratch/z3097808/20year_run/20year_freerun_output_NEWnci/outer_avg_*'))
ufiles = ufiles[start_id:end_id+1] # not sure what the +1 is doing here
vfiles = ufiles
tfiles = ufiles
bfiles = '/home/z5278054/EACouter_mesh_srho.nc' # For Hayden
mesh_mask = '/home/z5278054/EACouter_mesh_srho.nc' # For Hayden

# Set diffusion constants (in m/s)
Kh_zonal = 10
Kh_meridional = 10

filenames = {'U': ufiles,
             'V': vfiles,
             'temp': tfiles,
             'bathy': bfiles,
             'mesh_mask': mesh_mask}

variables = {'U': 'u',
             'V': 'v',
             'temp': 'temp',
             'bathy': 'h'}

out_file = str(out_dir)+'/'+str(year_array[array_ref])+'_Back.nc'


dimensions = {'U': {'lon': 'lon_psi', 'lat': 'lat_psi', 'depth': 's_rho', 'time': 'ocean_time'},
             'V': {'lon': 'lon_psi', 'lat': 'lat_psi', 'depth': 's_rho', 'time': 'ocean_time'},
             'temp': {'lon': 'lon_psi', 'lat': 'lat_psi', 'depth': 's_rho', 'time': 'ocean_time'},
             'bathy': {'lon': 'lon_rho', 'lat': 'lat_rho'}}

indices = {'depth': [29]}

if os.path.exists(out_file):
    os.remove(out_file)

def DeleteParticle(particle, fieldset, time):
    particle.delete()

fieldset = FieldSet.from_nemo(filenames, variables, dimensions, indices, allow_time_extrapolation=True)
fieldset.add_constant('maxage', 40.*86400)
fieldset.temp.interp_method = 'nearest'

# Create field of Kh_zonal and Kh_meridional, using same grid as U
size2D = (fieldset.U.grid.ydim, fieldset.U.grid.xdim)
fieldset.add_field(Field('Kh_zonal', Kh_zonal*np.ones(size2D), 
                         lon=fieldset.U.grid.lon, lat=fieldset.U.grid.lat, mesh='spherical'))
fieldset.add_field(Field('Kh_meridional', Kh_meridional*np.ones(size2D), 
                         lon=fieldset.U.grid.lon, lat=fieldset.U.grid.lat, mesh='spherical'))

random.seed(123456) # Set random seed

class SampleParticle(JITParticle): # Define a new particle class
    age = Variable('age', dtype=np.float32, initial=0.) # initialise age
    temp = Variable('temp', dtype=np.float32, initial=fieldset.temp)  # initialise temperature
    bathy = Variable('bathy', dtype=np.float32, initial=fieldset.bathy)  # initialise bathy
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
    
def SampleAge(particle, fieldset, time):
    particle.age = particle.age + math.fabs(particle.dt)
    if particle.age > fieldset.maxage:
        particle.delete()

def SampleTemp(particle, fieldset, time):
    particle.temp = fieldset.temp[time, particle.depth, particle.lat, particle.lon]

def SampleBathy(particle, fieldset, time):
    particle.bathy = fieldset.bathy[0, 0, particle.lat, particle.lon]

end_time = np.repeat(end_time,len(lon))

pset = ParticleSet.from_list(fieldset, pclass=SampleParticle, lon=lon, lat=lat, time=end_time, repeatdt=repeatdt)

pfile = pset.ParticleFile(out_file, outputdt=delta(days=1))

kernels = pset.Kernel(AdvectionRK4) + SampleAge + SampleTemp + SampleBathy + SampleDistance + BrownianMotion2D

pset.execute(kernels, 
             dt=-delta(minutes=5), 
             output_file=pfile, 
             verbose_progress=True,
             recovery={ErrorCode.ErrorOutOfBounds: DeleteParticle},
			 endtime = start_time)
pfile.close()