# -*- coding: utf-8 -*-
"""
Created on Tue Mar 23 10:26:45 2021

@author: Dan
"""


from parcels import FieldSet, ParticleSet, JITParticle, AdvectionRK4_3D, Variable
from glob import glob
import numpy as np
from datetime import timedelta as delta
from os import path

data_path = 'C:/Users/Dan/Documents/PhD/Dispersal/data_raw/ozroms/'
ufiles = sorted(glob('C:/Users/Dan/Documents/PhD/Dispersal/data_raw/ozroms/2008*'))
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

fieldset = FieldSet.from_nemo(filenames, variables, dimensions, allow_time_extrapolation = True)

class SampleParticle(JITParticle): 
    sampled = Variable('sampled', dtype = np.float32, initial = 0, to_write=False)
    #rel_bathy = Variable('rel_bathy', dtype=np.float32, initial=fieldset.bathy)
    bathy = Variable('bathy', dtype=np.float32, initial= 0, to_write = True)
    #sigma = Variable('sigma', dtype = np.float32, initial = fieldset.WA.grid.depth[0])
    depth_m = Variable('depth_m', dtype = np.float32, initial = 0)
    
def SampleBathy(particle, fieldset, time):
    particle.bathy = fieldset.bathy[0, 0, particle.lat, particle.lon]
    
def SampleParticleDepth(particle, fieldset, time):
    particle.depth_m = particle.bathy*particle.depth
    
#def SampleSigma(particle, fieldset, time):
 #   particle.sigma = particle.depth
    
def SampleInitial(particle, fieldset, time): 
    if particle.sampled == 0:
         #particle.temp = fieldset.temp[time, particle.depth, particle.lat, particle.lon]
         #particle.prev_lon = particle.lon
         #particle.prev_lat = particle.lat
         particle.bathy = fieldset.bathy
         particle.sampled = 1
         
def AdvectionRK4_3D_alternative(particle, fieldset, time):
    """Advection of particles using fourth-order Runge-Kutta integration with vertical velocity independent of vertical grid distortion.

    Function needs to be converted to Kernel object before execution"""
    temp_m = particle.depth*particle.bathy
    (u1, v1) = fieldset.UV[time, particle.depth, particle.lat, particle.lon]
    w1 = fieldset.WA[time, particle.depth, particle.lat, particle.lon]
    lon1 = particle.lon + u1*.5*particle.dt
    lat1 = particle.lat + v1*.5*particle.dt
    dep1 = particle.depth + w1*.5*particle.dt
    (u2, v2) = fieldset.UV[time + .5 * particle.dt, dep1, lat1, lon1]
    w2 = fieldset.WA[time + .5 * particle.dt, dep1, lat1, lon1]
    lon2 = particle.lon + u2*.5*particle.dt
    lat2 = particle.lat + v2*.5*particle.dt
    dep2 = particle.depth + w2*.5*particle.dt
    (u3, v3) = fieldset.UV[time + .5 * particle.dt, dep2, lat2, lon2]
    w3 = fieldset.WA[time + .5 * particle.dt, dep2, lat2, lon2]
    lon3 = particle.lon + u3*particle.dt
    lat3 = particle.lat + v3*particle.dt
    dep3 = particle.depth + w3*particle.dt
    (u4, v4) = fieldset.UV[time + particle.dt, dep3, lat3, lon3]
    w4 = fieldset.WA[time + particle.dt, dep3, lat3, lon3]
    particle.lon += (u1 + 2*u2 + 2*u3 + u4) / 6. * particle.dt
    particle.lat += (v1 + 2*v2 + 2*v3 + v4) / 6. * particle.dt
    particle.depth += (w1 + 2*w2 + 2*w3 + w4) / 6. * particle.dt
    particle.depth = temp_m/particle.bathy

#floatSpeed = round(0.0333333/288*3, 7)

#x = np.float64(0.03333333/288*3)

#sLevels = fieldset.W.grid.depth[0:30]

#sDiff = []
#for i in range(30):
 #   sDiff = np.append(sDiff, sLevels[i]-sLevels[i-1])

# create a buoyancy kernel
def larvalBuoyancy(particle, fieldset, time):
    surfaceLevel = -0.0166672221875 # surface s-level
    floatSpeed =  (-particle.depth_m/10/288)/particle.bathy # equal to 3 s-levels per day
    if particle.depth < surfaceLevel:
        particle.depth += floatSpeed
    
pset = ParticleSet.from_line(fieldset=fieldset, pclass = SampleParticle,
                             size=10,
                             start=(152.922850, -31.966555),
                             finish=(152.922850, -31.966555),
                             time = 0,
                             depth=np.repeat(fieldset.WA.grid.depth[0], 10))

kernels = SampleInitial + pset.Kernel(AdvectionRK4_3D_alternative) + SampleBathy + SampleParticleDepth + larvalBuoyancy
pset.execute(kernels, runtime=delta(days = 0), dt=delta(minutes = 5))
pset.execute(kernels, runtime=delta(days = 30), dt=delta(minutes = 5), output_file = pset.ParticleFile("C:/Users/Dan/Documents/PhD/Dispersal/temp/3d_advect.nc", outputdt=delta(days=1)))

depth_level = 0
print("Level[%d] depth is: [%g %g]" % (depth_level, fieldset.W.grid.depth[depth_level], fieldset.W.grid.depth[depth_level+1]))
pset.show(field=fieldset.V, depth_level=depth_level)
