# # create empty w velocity file to help parcels run
# 
# setwd("~/GitHub/portunid_particle_tracking")
# 
# library(ncdf4)
# nc=nc_open('20160101.nc', write=T) # original u file
# nc
# # str(nc)
# #
# 
# nc <- ncvar_rename(nc, old_varname = "u", new_varname = "w")
# 
# nc=nc_open('20160101.nc', write=T) # original u file
# nc
# 
# ncvar_put(nc, varid = "w", vals=rep(0,11615040))
# ncatt_get(nc, "w")
# table(ncvar_get(nc, "w"))
# 
# nc_sync(nc)
# nc_close(nc)
# 
# ### need to restart R here to stop nc being "used by another process"
# setwd("~/GitHub/portunid_particle_tracking")
# file.rename('20160101.nc', to = "w_file.nc")
# library(ncdf4)
# nc=nc_open('w_file.nc', write=T) # original u file
# nc


#### Method 2

#===========================================================================
# PART 2.  ADD A NEW VARIABLE TO THE FILE
#===========================================================================
setwd("~/GitHub/portunid_particle_tracking")

file_list <- list.files(path = "~/GitHub/portunid_particle_tracking/",pattern = ".nc")
library(ncdf4)

for(i in 1:length(file_list)){
#---------------------------------------------------
# Open the existing file we're going to add a var to
#---------------------------------------------------
ncid_old <- nc_open(file_list[i], write=TRUE ) # open the files
#ncid_old

ncvar_put(ncid_old, varid = "vel", vals=rep(0,11615040)) # overwrite the vel field
ncvar_rename(ncid_old, old_varname = "vel", new_varname = "w") # rename the vel field to w
nc_sync(ncid_old) # save the changes
nc_close(ncid_old) # close nc file before opening next one
}


