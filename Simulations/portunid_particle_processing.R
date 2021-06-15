library(tidyverse)
library(lubridate)
library(tidync)
library(ncdf4)
library(zoo)

if (Sys.info()[6] == "Dan"){
  # set species
  species <- "gmc"
  
  # set direction
  direction <- "forwards"
  
  # set file path
  file.path <- "github/portunid_particle_tracking/Data/output_testing"
  
  # list files
  files <- list.files(file.path, pattern = ".nc")
  
  # open the data
  particles <- hyper_tibble(paste(file.path, files[2], sep = "/"))
  
  # open the aux info
  particles.info <- nc_open(paste(file.path, files[2], sep = "/"))
} else {
  # set to scratch directory
  setwd("../../srv/scratch/z5278054/portunid_particle_tracking")
  
  # import the array index
  index <- as.integer(Sys.getenv('PBS_ARRAY_INDEX'))
  
  # import the species name
  species <- Sys.getenv("species")
  
  # import the direction of the simulation
  direction <- Sys.getenv("direction")
  
  # open the data
  particles <- hyper_tibble(paste(species, direction, files[index], sep = "/"))
  
  # open the auxillary info
  particles.info <- nc_open(paste(species, direction, files[index], sep = "/"))
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

# the old way - delete if the above works
#if (Sys.info()[6] == "Dan"){
 # species <- "gmc"
  #direction <- "forwards"
  #file.path <- "C:/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking/Data/output_testing"
  #files <- list.files(file.path, pattern = ".nc")
  
  #particles <- hyper_tibble(paste(file.path, files[2], sep = "/"))
  #particles.info <- nc_open(paste(file.path, files[2], sep = "/"))
#} else {
  # import variables from .pbs
 # index <- as.integer(Sys.getenv('PBS_ARRAY_INDEX'))
  #species <- Sys.getenv("species")
  #direction <- Sys.getenv("direction")
  
  # point to the portunid_tracking directory
  #file.path <- "../../srv/scratch/z5278054/portunid_particle_tracking"
  
  # list all the files in the relevant directory
  #files <- list.files(paste(file.path, species, direction, sep = "/"), pattern = ".nc")
#}

# empty dfs to store results of each iteration
# master file that will include everything
# particles.master <- data.frame()
# subset of master include only final (i.e. settled) positions of particles
#particles.final <- data.frame()

#if (Sys.info()[6] == "Dan"){
 # particles <- hyper_tibble(paste(file.path, files[2], sep = "/"))
  #particles.info <- nc_open(paste(file.path, files[2], sep = "/"))
#} else {
 # particles <- hyper_tibble(paste(file.path, species, direction, files[index], sep = "/"))
  #particles.info <- nc_open(paste(file.path, species, direction, files[index], sep = "/"))
#}

# convert time to a readable format (i.e., not seconds since x)
particles <- particles %>% convert_time(particles.info)

# remove columns that are unused
particles <- particles %>% select(-trajectory, -time, -z, -age, -depth_m)

# replace missing temperature values with the last non-zero observation
particles <- particles %>% missing_temperature()

# calculate degree-days for each particle
particles <- particles %>% degree_days()

# assign release location (lat & lon) and date
particles <- particles %>% release_info()

# remove any particles spawned after the spawning season ended (forwards)
particles <- particles %>% spawning_season()

# apply mortality
particles <- particles %>% apply_mortality()

# assign particles spatially (i.e. to estuaries, mgmt zones, etc.,)
particles <- particles %>% settlement_locations() # doesn't do anything to backwards particles

# get final points (on and off shelf, still alive)
particles.final <- particles %>% final_points()

# save the output
particles.final %>% save_object(type = "final")

# get settlement points (dd.cutoff, alive, made it to an estuary)
particles.settled <- particles.final %>% settlement_points()

# save the output
particles.settled %>% save_object(type = "settled")