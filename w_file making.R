# create empty w velocity file to help parcels run

setwd("~/GitHub/portunid_particle_tracking")

library(ncdf4)
nc=nc_open('20160101.nc', write=T) # original u file
nc
# str(nc)
# 

nc <- ncvar_rename(nc, old_varname = "u", new_varname = "w")

nc=nc_open('20160101.nc', write=T) # original u file
nc

ncvar_put(nc, varid = "w", vals=rep(0,11615040))
ncatt_get(nc, "w")
table(ncvar_get(nc, "w"))

nc_sync(nc)
nc_close(nc)

### need to restart R here to stop nc being "used by another process"
setwd("~/GitHub/portunid_particle_tracking")
file.rename('20160101.nc', to = "w_file.nc")
library(ncdf4)
nc=nc_open('w_file.nc', write=T) # original u file
nc
