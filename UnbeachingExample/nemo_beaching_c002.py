from parcels import FieldSet, VectorField, AdvectionRK4, ParticleFile, ParticleSet, JITParticle, Variable
from parcels import ErrorCode
import numpy as np
from glob import glob
import time as timelib
from datetime import timedelta as delta

print 'Running file: %s' % __file__


def get_nemo_fieldset():
    data_dir = '/Users/delandmeter/data/NEMO-MEDUSA/ORCA0083-N006/'
    ufiles = sorted(glob(data_dir+'means/ORCA0083-N06_200?????d05U.nc'))
    vfiles = sorted(glob(data_dir+'means/ORCA0083-N06_200?????d05V.nc'))
    mesh_mask = data_dir + 'domain/coordinates.nc'

    filenames = {'U': ufiles,
                 'V': vfiles,
                 'mesh_mask': mesh_mask}

    variables = {'U': 'uo',
                 'V': 'vo'}
    dimensions = {'lon': 'glamf', 'lat': 'gphif', 'time': 'time_counter'}
    field_set = FieldSet.from_nemo(filenames, variables, dimensions)

    files = 'ORCA0083-N06_unbeaching_vel.nc'
    filenames = {'unBeachU': files,
                 'unBeachV': files,
                 'mesh_mask': files}

    variables = {'unBeachU': 'unBeachU',
                 'unBeachV': 'unBeachV'}
    dimensions = {'lon': 'glamf', 'lat': 'gphif'}
    field_setUnBeach = FieldSet.from_nemo(filenames, variables, dimensions, tracer_interp_method='cgrid_linear')
    UVunbeach = VectorField('UVunbeach', field_setUnBeach.unBeachU, field_setUnBeach.unBeachV)
    field_set.add_field(field_setUnBeach.unBeachU)
    field_set.add_field(field_setUnBeach.unBeachV)
    field_set.add_vector_field(UVunbeach)
    return field_set


def DeleteParticle(particle, fieldset, time, dt):
    particle.delete()


field_set = get_nemo_fieldset()


class PlasticParticle(JITParticle):
    age = Variable('age', dtype=np.float32, initial=0.)

def Ageing(particle, fieldset, time, dt):
    particle.age += dt 

def UnBeaching(particle, fieldset, time, dt):
    (u, v) = fieldset.UV[time, particle.lon, particle.lat, particle.depth]
    if u == 0 and v == 0:
        (ub, vb) = fieldset.UVunbeach[time, particle.lon, particle.lat, particle.depth]
        particle.lon += ub * dt
        particle.lat += vb * dt

#    if particle.age > 86400*180:
#        particle.delete()


# Release particles
vec = np.linspace(0,1,6)
xsi, eta = np.meshgrid(vec, vec)

# Rotterdam
lonCorners = [2.96824026, 3.22713804, 3.26175451, 3.002671]
latCorners = [51.60693741, 51.58454132, 51.73711395, 51.759758] 
lon_r = (1-xsi)*(1-eta) * lonCorners[0] + xsi*(1-eta) * lonCorners[1] + \
        xsi*eta * lonCorners[2] + (1-xsi)*eta * lonCorners[3]
lat_r = (1-xsi)*(1-eta) * latCorners[0] + xsi*(1-eta) * latCorners[1] + \
        xsi*eta * latCorners[2] + (1-xsi)*eta * latCorners[3]

lonCorners = [1.37941658, 1.63887346, 1.67183721, 1.41217935]
latCorners = [51.58309555, 51.56196213, 51.71636581, 51.73773575]
lon_t = (1-xsi)*(1-eta) * lonCorners[0] + xsi*(1-eta) * lonCorners[1] + \
        xsi*eta * lonCorners[2] + (1-xsi)*eta * lonCorners[3]
lat_t = (1-xsi)*(1-eta) * latCorners[0] + xsi*(1-eta) * latCorners[1] + \
        xsi*eta * latCorners[2] + (1-xsi)*eta * latCorners[3]

lons = np.concatenate((lon_r.flatten(), lon_t.flatten()))
lats = np.concatenate((lat_r.flatten(), lat_t.flatten()))
times = np.arange(np.datetime64('2000-01-05'), np.datetime64('2001-01-05'))

lon = np.tile(lons, [len(times)])
lat = np.tile(lats, [len(times)])
time = np.repeat(times, len(lons))

pset = ParticleSet.from_list(field_set, PlasticParticle,
                             lon=[lon[297]],
                             lat=[lat[297]],
                             time=[time[297]])
kernel = AdvectionRK4 + pset.Kernel(UnBeaching) + pset.Kernel(Ageing)
outfile = './'+__file__[:-3]
pfile = ParticleFile(outfile, pset)
pfile.write(pset, pset[0].time)
tic = timelib.time()
print pset[0].lon
print pset[0].lat
print pset[0].time
print pset[0].time / 86400.

ndays = 60
for d in range(ndays/2):
    day = 2 * d
    print('running %d / %d [time %g s]: %d particles ' % (day+1, ndays, timelib.time()-tic, len(pset)))
    pset.execute(kernel, runtime=delta(days=2), dt=900, verbose_progress=False)#, recovery={ErrorCode.ErrorOutOfBounds: DeleteParticle})
    pfile.write(pset, pset[0].time)

