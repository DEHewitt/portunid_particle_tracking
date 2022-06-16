# Try to plot successfulk vs non successful

library(tidync)
library(tidyverse)
library(lubridate)
library(ncdf4)
library(zoo)

mydata <- tidync("C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN_2020/Output/spanner_1993_forward_4.nc") %>% hyper_tibble()
particles.info <- nc_open("C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN_2020/Output/spanner_1993_forward_4.nc")
direction = "forwards"
species <- "spanner"

convert_time <- function(particles, particles.info) {
  
  # particles is the actual data
  # particles.info is the link to the netcdf
  
  # extract the time.origin
  time.origin <- ymd(str_sub(particles.info$var$time$units, 15, 24))
  
  # convert time to a readable format (i.e. not in seconds since...)
  particles <- particles %>%
    mutate(date = time.origin + duration(time, units = "seconds"))
}
release_info <- function(data){
  data <- data %>%
    mutate(rel_lat = if_else(obs == 1, lat, NA_real_)) %>%
    mutate(rel_lon = if_else(obs == 1, lon, NA_real_)) %>%
    mutate(rel_date = if_else(obs == 1, date, as.POSIXct(NA_Date_))) %>%
    mutate(rel_date = as.character(rel_date))
  data$rel_lat <- na.locf(data$rel_lat, na.rm = F) 
  data$rel_lon <- na.locf(data$rel_lon, na.rm = F)
  data$rel_date <- na.locf(data$rel_date, na.rm = F)
  
  if (direction == "backwards" & species == "gmc" | direction == "backwards" & species == "bsc"){
    data <- data %>%
      mutate(rel_est = case_when(rel_lat == -18.541 ~ "Hinchinbrook Island",
                                 rel_lat == -23.850 ~ "The Narrows",
                                 rel_lat == -25.817 ~ "Maryborough/Hervey Bay",
                                 rel_lat == -26.339 ~ "Moreton Bay",
                                 rel_lat == -27.165 ~ "Tweed River",
                                 rel_lat == -28.890 ~ "Richmond River",
                                 rel_lat == -29.432 ~ "Clarence River",
                                 rel_lat == -30.864 ~ "Macleay River",
                                 rel_lat == -31.645 ~ "Camden Haven",
                                 rel_lat == -31.899 ~ "Manning River",
                                 rel_lat == -32.193 ~ "Wallis Lake",
                                 rel_lat == -32.719 ~ "Port Stephens",
                                 rel_lat == -32.917 ~ "Hunter River",
                                 rel_lat == -33.578 ~ "Hawkesbury River",
                                 rel_lat == -34.546 ~ "Lake Illawarra"))
  } 
  data
}


mydata <- mydata %>% convert_time(particles.info = particles.info) %>% release_info() %>%
  mutate(ParticleID = paste0(rel_lat,"_",rel_lon,"_",rel_date,"_",traj))
nc_close(particles.info)
particles.info <- NULL

### Attempt 2

mydata2 <- readRDS("C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN_2020/Output/spanner_forwards_master_final.rds")

mydata2 <- mydata2 %>% mutate(ParticleID = paste0(rel_lat,"_",rel_lon,"_",rel_date,"_",traj),
                              shelf = case_when((bathy <= 200 & !is.na(region)) ~ "Success",
                                                TRUE ~ "Fail"))
n_distinct(mydata2$ParticleID)

DD_limits <- mydata2 %>% dplyr::select(obs,ParticleID,  state, region, shelf) %>% rename(obs_limit=obs)
mydata2 <- NULL

mydata <- mydata %>% filter(ParticleID %in% DD_limits$ParticleID) %>%
  left_join(DD_limits) %>% filter(obs <= obs_limit) %>% select(lat, lon, distance, rel_lat:rel_date,
                                                               ParticleID, region:shelf,obs)# %>% filter(!is.na(region))
table(mydata$settlement)

#write_csv(mydata, "Output1XX.csv") # way too big
saveRDS(mydata, "Output1XX.rds")
#test <- readRDS("Output1XX.rds")

small <- mydata %>% group_by(shelf) %>% slice_sample( n = 100) %>% distinct(ParticleID)
small2 <- mydata %>% filter(ParticleID %in% small$ParticleID)

str(small2)

ggplot(survivors, aes(x=lon, y=lat, group=ParticleID)) + geom_path(alpha=0.02) + 
  facet_wrap(~shelf) +
  coord_quickmap()

table(survivors$shelf, survivors$region)
