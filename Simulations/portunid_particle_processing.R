library(tidyverse)
library(lubridate)
library(tidync)
library(ncdf4)
library(zoo)

if (Sys.info()[6] == "Dan"){
  # this part is just for testing on my laptop
  # set species
  species <- "gmc"
  
  # set direction
  direction <- "forwards"
  
  # set file path
  file.path <- "C:/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking/Data/output_testing"
  
  # list files
  files <- list.files(file.path, pattern = ".nc")
  
  # open the data
  particles <- hyper_tibble(paste(file.path, files[4], sep = "/"))
  
  # open the aux info
  particles.info <- nc_open(paste(file.path, files[4], sep = "/"))
} else {
  # set to scratch directory
  setwd("../../srv/scratch/z5278054/portunid_particle_tracking")
  
  # file path
  file.path <- "/srv/scratch/z5278054/portunid_particle_tracking"
  
  # import the array index
  index <- as.integer(Sys.getenv('PBS_ARRAY_INDEX'))
  
  # import the species name
  species <- Sys.getenv("species")
  
  # import the direction of the simulation
  direction <- Sys.getenv("direction")
  
  # import the test function for testing different values of mortality
  test <- as.numeric(Sys.getenv("test"))
  
  # list files
  files <- list.files(paste(file.path, species, direction, sep = "/"), pattern = ".nc")
  
  # open the data
  particles <- hyper_tibble(paste(file.path, species, direction, files[index], sep = "/"))
  
  # open the auxilliary info
  particles.info <- nc_open(paste(file.path, species, direction, files[index], sep = "/"))
}

# load custom functions
source("R/convert_time.R")
source("R/missing_temperature.R")
source("R/degree_days.R")
source("R/release_info.R")
source("R/spawning_season.R")
source("R/apply_mortality.R")
source("R/settlement_locations.R")
source("R/final_points.R")
source("R/save_object.R")
source("R/settlement_points.R")
source("R/bring_out_your_dead.R")
source("R/settlers.R")

# convert time to a readable format (i.e., not seconds since x)
particles <- particles %>% convert_time(particles.info)

# remove columns that are unused
if (species != "spanner"){
  particles <- particles %>% select(-trajectory, -time, -z, -age)
}

# assign release location (lat & lon) and date
particles <- particles %>% release_info()

# create a unique particle.id
particles <- particles %>% mutate(particle.id = paste(particle.id = paste0(traj, "_", rel_lat, "_", rel_lon, "_", rel_date)))

# replace missing temperature values with the last non-zero observation
particles <- particles %>% missing_temperature()

# calculate degree-days for each particle
particles <- particles %>% degree_days()

if (direction == "forwards"){
  # remove any particles spawned after the spawning season ended
  particles <- particles %>% spawning_season()
  
  # apply mortality
  if (species == "spanner"){
    particles <- particles %>% apply_mortality(test = test)
  } else {
    particles <- particles %>% apply_mortality()
  }
  
  # assign particles spatially (i.e., to estuaries, mgmt zones, etc.)
  particles <- particles %>% settlement_locations() # doesn't do anything to backwards particles
  
  # did the particle settle?
  particles <- particles %>% settlers(direction = direction)
  
  # get out the mortality summary
  mortalities <- particles %>% bring_out_your_dead()
  
  # save the mortality table
  mortalities %>% save_object(type = "mortalities")
}

# get final points (on and off shelf, still alive)
particles.final <- particles %>% final_points()

# delete raw output before saving the processed output (need to save space)
#file.remove(paste(file.path, species, direction, files[index], sep = "/"))

# save the output
if (species == "spanner"){
  particles.final %>% save_object(type = "final", test = test)
} else {
  particles.final %>% save_object(type = "final")
}

# get settlement points (dd.cutoff, alive, made it to an estuary)
particles.settled <- particles.final %>% settlement_points()

# save the output
if (species == "spanner"){
  particles.settled %>% save_object(type = "settled", test = test)
} else {
  particles.settled %>% save_object(type = "settled")
}