# -*- coding: utf-8 -*-
"""
Created on Mon Jun  1 13:12:42 2020

@author: Dan
"""
from parcels import FieldSet, Field, AdvectionRK4, ParticleSet, JITParticle, Variable, BrownianMotion2D, random, NestedField
from parcels import ErrorCode, plotTrajectoriesFile
import numpy as np
from glob import glob
#import time as timelib
from datetime import timedelta as delta
from datetime import datetime as datetime
#import cartopy
import math
import os
from operator import attrgetter

out_dir = '/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking/Nesting/Output'
#out_dir = 'C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/Nesting/Output'

npart = 1  # number of particles to be released
repeatdt = delta(days=4)  # release from the same set of locations every X day

# Forward: 9
# lon_array = []
# lat_array = []

# Backwards: 13
lon_array = [153.790, 153.799, 153.736, 153.172, 153.048, 152.946, 152.775, 152.312, 152.045, 151.577]
lat_array = [-28.165, -28.890, -29.432, -30.864, -31.645, -31.899, -32.193, -32.719, -32.917, -33.578]

lon = np.repeat(lon_array,npart)
lat = np.repeat(lat_array,npart)

array_ref = 0 # which season to simulate (0 = 1994/95, 22 = 2015/16)

# Spawning season is September to March (Heasman et al. 1985)
# Reality language: start date will be 30th August and run until 15th May (the year after) to allow for the full 40 days of tracking.
# Particle reality: the first day of life (and hence the 'start') for particles will be 15th May.

# Manually set the filenames. The names correspond to the number of days since 1, 1, 1990
file_nos = np.arange(1461, 9742, 30)
year_array = np.arange(1994, 2016, 1)

## I think we can delete the following commented out section but leaving for now
# Days since 1990
#start_time = datetime(year_array[array_ref],8, 30) # year, month, day
#start_dys = start_time-datetime(1990,1,1) + delta(days=1)
#start_id = np.where(file_nos<=start_dys.days) #Find the reference file location
#start_id = start_id[0][-1]

#end_time = datetime(year_array[array_ref]+1, 5, 15)  #year, month, day
#end_dys = end_time-datetime(1990,1,1) + delta(days=1)
#end_id = np.where(file_nos>=end_dys.days) #Find the reference file location
#end_id = end_id[0][0]

#runtime = end_time-start_time + delta(days=1)

start_time = datetime(year_array[array_ref],1, 15) # year, month, day
end_time = datetime(year_array[array_ref], 3, 15)  #year, month, day


# Set diffusion constants (in m/s)
Kh_zonal = 10
Kh_meridional = 10
### Define fieldsets then read fields from there and nest (see https://github.com/OceanParcels/Parcelsv2.0PaperNorthSeaScripts/blob/master/run_northsea_mp.py#L82-L83)
# Time stored differently in BRAN (days since 1/1/1979) and ROMS (days since 1/1/1990)
# Solutions: 
# a) Name them differently (e.g. time_BRAN and time_ROMS) and store both in output and correct in R
# b) Sammple the field being interpolated and correct based on this
# BRAN - needs mesh?
filenames_BRAN = {'U': (glob('/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking/BRAN/AUS/ocean_u_*')), 
             'V': (glob('/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking/BRAN/AUS/ocean_v_*')),
             'temp': (glob('/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking/BRAN/AUS/ocean_temp_*'))}
#filenames_BRAN = {'U': (glob('C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN/AUS/Ocean_u_*')), 
 #            'V': (glob('C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN/AUS/Ocean_v_*')),
  #           'temp': (glob('C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN/AUS/Ocean_temp_*'))}

variables_BRAN = {'U': 'u',
             'V': 'v',
             'temp': 'temp'}

dimensions_BRAN = {}
dimensions_BRAN['U'] = {'lat': 'yu_ocean', 'lon': 'xu_ocean', 'depth': 'st_ocean', 'time': 'Time'}
dimensions_BRAN['V'] = {'lat': 'yu_ocean', 'lon': 'xu_ocean', 'depth': 'st_ocean', 'time': 'Time'}
dimensions_BRAN['temp'] = {'lat': 'yt_ocean', 'lon': 'xt_ocean', 'depth': 'st_ocean', 'time': 'Time'} 

indices_BRAN = {'depth': [0]} # surface? not sure how many layers BRAN has

fieldset_BRAN = FieldSet.from_netcdf(filenames_BRAN, variables_BRAN, dimensions_BRAN, allow_time_extrapolation = True)

fieldset_BRAN.add_constant('maxage', 40.*86400)
fieldset_BRAN.temp.interp_method = 'nearest'

# ROMS

#ufiles = sorted(glob('C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/Nesting/ROMS Data/outer_avg_*'))
ufiles = sorted(glob('/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking/Nesting/outer_avg_*'))
ufiles = ufiles#[start_id:end_id+1] # not sure what the +1 is doing here/this part is for katana jobs?
vfiles = ufiles
tfiles = ufiles
# bfiles = '/home/z5278054/EACouter_mesh_srho.nc'
mesh_mask = 'C:/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking/Nesting/EACouter_mesh_srho.nc' 

filenames_ROMS = {'U': ufiles,
             'V': vfiles,
             'temp': tfiles,
            # 'bathy': bfiles, # not using
             'mesh_mask': mesh_mask}

variables_ROMS = {'U': 'u',
             'V': 'v',
             'temp': 'temp'}

dimensions_ROMS = {'U': {'lon': 'lon_psi', 'lat': 'lat_psi', 'depth': 's_rho', 'time': 'ocean_time'},
             'V': {'lon': 'lon_psi', 'lat': 'lat_psi', 'depth': 's_rho', 'time': 'ocean_time'},
             'temp': {'lon': 'lon_psi', 'lat': 'lat_psi', 'depth': 's_rho', 'time': 'ocean_time'}}

indices_ROMS = {'depth': [29]} # surface?

fieldset_ROMS = FieldSet.from_nemo(filenames_ROMS, variables_ROMS, dimensions_ROMS, indices_ROMS, allow_time_extrapolation=True)
fieldset_ROMS.add_constant('maxage', 40.*86400)
fieldset_ROMS.temp.interp_method = 'nearest'

out_file = str(out_dir)+'/'+str(year_array[array_ref])+'_Back.nc'

# If output file already exists then remove it
if os.path.exists(out_file):
    os.remove(out_file)
    
def DeleteParticle(particle, fieldset, time):
    particle.delete()

# Nest the two models    
U = NestedField('U', [fieldset_ROMS.U, fieldset_BRAN.U])
V = NestedField('V', [fieldset_ROMS.V, fieldset_BRAN.V])
temp = NestedField('temp', [fieldset_ROMS.temp, fieldset_BRAN.temp]) 
fieldset = FieldSet(U, V)

fieldset.add_field(temp)
fieldset.temp.interp_method = 'nearest'

# Keep track of which field is being interpolated: Box 6 & 7 https://nbviewer.jupyter.org/github/OceanParcels/parcels/blob/master/parcels/examples/tutorial_NestedFields.ipynb
# This was modified to match the code block below as it was having a similar error due to the grid not being defined right.
# Adding this made the code REALLY SLOW - Once we confirm the nesting is working correctly, I suggest removing (commenting out).
size2D_ROMS = (fieldset_ROMS.U.grid.ydim, fieldset_ROMS.U.grid.xdim)
size2D_BRAN = (fieldset_BRAN.U.grid.ydim, fieldset_BRAN.U.grid.xdim)
F1 = Field('F1', np.ones((size2D_ROMS), dtype=np.float32), lon=fieldset.U[0].grid.lon, lat=fieldset.U[0].grid.lat, mesh='spherical')
F2 = Field('F2', 2*np.ones((size2D_BRAN), dtype=np.float32), lon=fieldset.U[1].grid.lon, lat=fieldset.U[1].grid.lat, mesh='spherical')
F = NestedField('F', [F1, F2])
fieldset.add_field(F)

# Create field of Kh_zonal and Kh_meridional, using same grid as U
# See Eriks comment on github: https://github.com/OceanParcels/parcels/issues/798
# Note this now uses the BRAN grid (shown by the [1]) not the ROMS grid (which was [0])
size2D_1 = (fieldset.U[1].grid.ydim, fieldset.U[1].grid.xdim)
fieldset.add_field(Field('Kh_zonal', Kh_zonal*np.ones(size2D_1), 
                         lon=fieldset.U[1].grid.lon, lat=fieldset.U[1].grid.lat, mesh='spherical'))
fieldset.add_field(Field('Kh_meridional', Kh_meridional*np.ones(size2D_1), 
                         lon=fieldset.U[1].grid.lon, lat=fieldset.U[1].grid.lat, mesh='spherical'))

fieldset.add_constant('maxage', 40.*86400)

random.seed(123456) # Set random seed

class SampleParticle(JITParticle): # Define a new particle class
    age = Variable('age', dtype=np.float32, initial=0.) # initialise age
    temp = Variable('temp', dtype=np.float32, initial=fieldset.temp[0])  # initialise temperature
    #bathy = Variable('bathy', dtype=np.float32, initial=fieldset.bathy)  # initialise bathy
    distance = Variable('distance', initial=0., dtype=np.float32)  # the distance travelled
    prev_lon = Variable('prev_lon', dtype=np.float32, to_write=False,
                        initial=attrgetter('lon'))  # the previous longitude
    prev_lat = Variable('prev_lat', dtype=np.float32, to_write=False,
                        initial=attrgetter('lat'))  # the previous latitude.
    f = Variable('f', dtype=np.int32) # Identifies the grid the particle is in (ROMS or BRAN)

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

# Kernel to identify which grid a particle is in (Very slow once this is included)        
def SampleNestedFieldIndex(particle, fieldset, time):
    particle.f = fieldset.F[time, particle.depth, particle.lat, particle.lon]

def SampleTemp(particle, fieldset, time):
    particle.temp = fieldset.temp[time, particle.depth, particle.lat, particle.lon]

end_time = np.repeat(end_time,len(lon))

pset = ParticleSet.from_list(fieldset, pclass=SampleParticle, lon=lon, lat=lat, time=end_time, repeatdt=repeatdt)

pfile = pset.ParticleFile(out_file, outputdt=delta(days=1))

kernels = pset.Kernel(AdvectionRK4) + SampleAge + SampleDistance + BrownianMotion2D + SampleNestedFieldIndex + SampleTemp #+ SampleBathy

pset.execute(kernels, 
             dt=-delta(minutes=30), 
             output_file=pfile, 
             verbose_progress=True,
             recovery={ErrorCode.ErrorOutOfBounds: DeleteParticle},
			 endtime = start_time)
pfile.close()

plotTrajectoriesFile('/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking/Nesting/Output/1994_Back.nc')

# Note the basic plotting of fields does not work because there is no fieldset.grid (would be nice to fix this)
# pset.show()