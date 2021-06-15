library(dplyr)

species <- Sys.getenv("species")
direction <- Sys.getenv("direction")
file.path <- paste("../../srv/scratch/z5278054/portunid_particle_tracking",
                   species, direction, "processed", sep = "/")
files <- list.files(file.path, pattern = "settled.rds")

particles <- data.frame()
for (i in 1:length(files)){
  temp <- readRDS(paste(file.path, files[i], sep = "/"))
  particles <- bind_rows(particles, temp)
}

saveRDS(particles, paste(file.path, paste(species, direction, "master_settled.rds", sep = "_"), sep = "/"))

files <- list.files(file.path, pattern = "final_points.rds")

particles <- data.frame()
for (i in 1:length(files)){
  temp <- readRDS(paste(file.path, files[i], sep = "/"))
  particles <- bind_rows(particles, temp)
}

saveRDS(particles, paste(file.path, paste(species, direction, "master_final.rds", sep = "_"), sep = "/"))