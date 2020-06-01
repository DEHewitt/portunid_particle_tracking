# -*- coding: utf-8 -*-
"""
Created on Mon Jun  1 13:12:42 2020

@author: Dan
"""
file.BRAN = {'U': (glob('/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking/BRAN/AUS/ocean_u_*')), 
             'V': (glob('/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking/BRAN/AUS/ocean_v_*')),
             'temp': (glob('/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking/BRAN/AUS/ocean_temp_*')) # read in file(s) for BRAN for specific year (e.g. 2007)
file.ROMS = (glob('/srv/scratch/z3097808/20year_run/20year_freerun_output_NEWnci/outer_avg_*') # read in file(s) for ROMS for specific year (e.g. 2007)

dimensions.BRAN = {'U': {'lat': 'yu_ocean', 'lon': 'xu_ocean', 'depth': 'st_ocean', 'time': 'Time'},
                   'V': {'lat': 'yu_ocean', 'lon': 'xu_ocean', 'depth': 'st_ocean', 'time': 'Time'},
                   'temp': {'lat': 'yt_ocean', 'lon': 'xt_ocean', 'depth': 'st_ocean', 'time': 'Time'}}
timestamp.BRAN = # not sure what this means
indices.BRAN = {'depth': [0]} # specify surface bin - taken from previous script. different to ROMS (=29)

field.BRAN.U = Field.from_netcdf(file.BRAN, variable = ('U':'u'), dimensions = dimesnions.BRAN, timestamps = timestamp.BRAN) # zonal velocity 
field.BRAN.V = # meridional velocity
field.BRAN.T = # temp

dimensions.ROMS = {'U': {'lon': 'lon_psi', 'lat': 'lat_psi', 'depth': 's_rho', 'time': 'ocean_time'},
             'V': {'lon': 'lon_psi', 'lat': 'lat_psi', 'depth': 's_rho', 'time': 'ocean_time'},
             'temp': {'lon': 'lon_psi', 'lat': 'lat_psi', 'depth': 's_rho', 'time': 'ocean_time'},
             'bathy': {'lon': 'lon_rho', 'lat': 'lat_rho'}}
timestamp.ROMS = 
indices.ROMS = {'depth': [29]} # specify surface bin - taken from previous script. different to BRAN (=0)
field.ROMS.U = Field.from_nemo(file.BRAN, variable = ('U':'u'), dimensions = dimesnions.ROMS, timestamps = timestamp.ROMS) # zonal  velocity
field.ROMS.V = # meridional velocity
field.ROMS.T = # temp
field.ROMS.B = '/home/z5278054/EACouter_mesh_srho.nc' # bathymetry
field.ROMS.M = '/home/z5278054/EACouter_mesh_srho.nc' # mesh-mask

U = NestedField('U', [field.BRAN.U, field.ROMS.U])
V = NestedField('V', [field.BRAN.V, field.ROMS.V])
T = NestedField('T', [field.BRAN.T, field.ROMS.T])
B = NestedField('h', [ , field.ROMS.B]) # no bathy in BRAN - issue? is it called 'bathy' or 'h'?

fieldset = FieldSet(U, V, T, B)