# This code redefines the calendar type of the BRAN model files from "GREGORIAN" to "gregorian" to make it readable by PARCELS
# Hayden Schilling
# 25/9/20

library(ncdf4)

file_list <- list.files("../../srv/scratch/z3374139/BRAN_AUS/", recursive = T, full.names = T, pattern ="Ocean_")

for (i in file_list){

mydata <- nc_open(i, write = TRUE)

#head(mydata)
#str(mydata)

ncatt_put(mydata, "Time", 'calendar', attval = 'gregorian', prec = 'text')
ncatt_put(mydata, "Time", 'calendar_type', attval = 'gregorian', prec = 'text')

ncatt_get(mydata, "Time")

nc_sync(mydata)
nc_close(mydata)
}

# # Code for single file
# 
# mydata <- nc_open("C:/Users/hayde/Crab-Dispersal/BRAN/AUS/ocean_v_1994_01.nc", write = TRUE)
# 
# head(mydata)
# str(mydata)
# 
# mydata$dim$Time
# 
# ncatt_put(mydata, "Time", 'calendar', attval = 'gregorian', prec = 'text')
# ncatt_put(mydata, "Time", 'calendar_type', attval = 'gregorian', prec = 'text')
# mydata$dim$Time
# 
# ncatt_get(mydata, "Time")
# 
# nc_sync(mydata)
# nc_close(mydata)

