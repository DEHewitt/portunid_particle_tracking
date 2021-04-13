library(tidyverse)
library(lubridate)
library(tidync)
library(ncdf4)
library(zoo)

# load the data
particles <- hyper_tibble("C:/Users/Dan/Documents/PhD/Dispersal/temp/gmc_2013_3_forwards.nc")
particles.info <- nc_open("C:/Users/Dan/Documents/PhD/Dispersal/temp/gmc_2013_3_forwards.nc")

# set up biological parameters
# mean and sd of degree-days to generate normal dist. to sample from

# extract the time.origin
time.origin <- ymd(str_sub(particles.info$var$time$units, 15, 24))

# convert time to a readable format (i.e. not in seconds since...)
particles <- particles %>%
  mutate(date = time.origin + duration(time, units = "seconds"))

# are there any beached particles anymore?
u <- which(particles$u_vel==0)
length(u)
v <- which(particles$v_vel==0)
length(v)
setdiff(u, v)
setdiff(v, u)
# way, way less! we will treat this as a success for now

# back fill missing temperature values
is.na(particles$temp) <- particles$temp == 0 # change 0 to NA
particles$temp <- na.locf(particles$temp, na.rm=FALSE) # replace NA with last non-NA observation carried forward
particles$temp <- na.locf(particles$temp, na.rm=FALSE, fromLast = TRUE)

# calculate temperature values
particles <- particles %>% 
  group_by(traj) %>% 
  mutate(degree.days = cumsum(temp)) %>%
  ungroup()

# assign release location (lat & lon) and date
particles <- particles %>%
  mutate(rel_lat = if_else(obs == 1, lat, NA_real_)) %>%
  mutate(rel_lon = if_else(obs == 1, lon, NA_real_)) %>%
  mutate(rel_date = if_else(obs == 1, date, as.POSIXct(NA_Date_)))
particles$rel_lat <- na.locf(particles$rel_lat, na.rm = F) 
particles$rel_lon <- na.locf(particles$rel_lon, na.rm = F)
particles$rel_date <- na.locf(particles$rel_date, na.rm = F)

# apply mortality (only to forwards runs)
p  <- particles %>% group_by(rel_date) %>% slice_sample(n = 3)

p <- particles %>%
  group_by(rel_date) %>%
  slice_sample(n = round(10*(1-0.1))) 
# 10 to be replaced with npart
# 0.1 to be replaced with daily mortality rate
# work out how to iterate through every day of tracking

# apply degree-days filter
particles <- particles %>%
  mutate(dd.cutoff = rnorm(nrow(particles), mean = 10, sd = 2)) # fill mean and sd with species specific estimates
