#!home/z5278054/python_parcels/bin/python3

from parcels import FieldSet, Field, AdvectionRK4, ParticleSet, JITParticle, Variable, DiffusionUniformKh, random
from parcels import ErrorCode
import numpy as np
from glob import glob
from datetime import timedelta as delta
from datetime import datetime as datetime
import os
import math
#from operator import attrgetter

out_dir = '/srv/scratch/z5278054/GMC_particle_tracking'

npart = 1000  # number of particles to be released
repeatdt = delta(days = 1)  # release from the same set of locations every X day

array_ref = int(os.environ['PBS_ARRAY_INDEX'])

###############
# Forward: 42 #
###############

temp_lon_array = np.array([147.848])#,# 146.875, 147.866])#, # Hinchinbrook Channel
#                  152.538, #152.447, 152.600, # The Narrows
 #                 153.762, #153.268, 153.818, # Hervey Bay
  #                153.636, #153.570, 153.761, # Moreton Bay
   #               153.790, #153.640, 153.869, # Tweed River
    #              153.799, #153.630, 153.852, # Richmond River
     #             153.736, #153.483, 153.771, # Clarence River
      #            153.172, #153.104, 153.275, # Macleay River
       #           153.048, #152.928, 153.134, # Camden Haven
        #          152.946, #152.787, 153.094, # Manning River
         #         152.775, #152.605, 153.013, # Wallis Lake
          #        152.312, #152.261, 152.764, # Port Stephens
           #       152.045, #151.975, 152.602, # Hunter River
            #      151.577])#, 151.438, 151.936]) # Hawkesbury River
temp_lat_array = np.array([-18.541])#, #-18.541, -18.541])#, 
 #                 -23.850, #-23.850, -23.850,
  #                -25.817, #-25.817, -25.817, 
   #               -27.339, #-27.339, -27.339,
    #              -28.165, #-28.165, -28.165,
     #             -28.890, #-28.890, -28.890,
      #            -29.432, #-29.432, -29.432,
       #           -30.864, #-30.864, -30.864,
        #          -31.645, #-31.645, -31.645, 
         #         -31.899, #-31.899, -31.899, 
          #        -32.193, #-32.193, -32.193,
           #       -32.719, #-32.719, -32.719, 
            #      -32.917, #-32.917, -32.917,
             #     -33.578])#, -33.578, -33.578])
temp_year_array = np.arange(2009, 2019, 1) # this only returns a range from 2009-2018

lon_array = np.repeat(temp_lon_array, temp_year_array.size)
lat_array = np.repeat(temp_lat_array, temp_year_array.size)
year_array = np.tile(temp_year_array, temp_lat_array.size)

lon = np.repeat(lon_array[array_ref], npart)
lat = np.repeat(lat_array[array_ref], npart)

#################
# Backwards: 14 #
#################

#lon_array = [147.848, 152.538, 153.762, 153.636, 153.790, 153.799, 153.736, 153.172, 153.048, 152.946, 152.775, 152.312, 152.045, 151.577]
#lat_array = [-18.541, -23.850, -25.817, -27.339, -28.165, -28.890, -29.432, -30.864, -31.645, -31.899, -32.193, -32.719, -32.917, -33.578]
#year_array = np.arange(2009, 2019, 1)

#lon = np.repeat(lon_array,npart)
#lat = np.repeat(lat_array,npart)

# Spawning season is September to March (Heasman et al. 1985), add on a month to ensure release particles have enough time to reach degree-days

start_time = datetime(year_array[array_ref], 9, 1) # year, month, day
end_time = datetime(year_array[array_ref]+1, 4, 30) # year, month, day

runtime = end_time-start_time + delta(days=1)

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
out_file = str(out_dir)+'/'+str(year_array[array_ref])+'_Lat'+str(lat_array[array_ref])+'_BRAN2015_Forward.nc' # be sure to change naming for back/forawrd runs

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
         
#start_time = np.repeat(start_time,len(lon))

pset = ParticleSet.from_list(fieldset, pclass=SampleParticle, time=start_time, lon=lon, lat=lat, repeatdt=repeatdt)

pfile = pset.ParticleFile(out_file, outputdt=delta(days=1))

# SampleInitial kernel must come first to initialise particles in JIT mode
kernels = SampleInitial + pset.Kernel(AdvectionRK4) + SampleAge + SampleTemp + SampleBathy + SampleSalt + SampleDistance + DiffusionUniformKh

pset.execute(kernels, 
             dt=delta(minutes=5), 
             output_file=pfile, 
             verbose_progress=True,
             runtime = runtime,
             recovery={ErrorCode.ErrorOutOfBounds: DeleteParticle})
pfile.close()