load_data <- function(species, direction, type){
  data <- readRDS(paste0("github/portunid_particle_tracking/Data/Output/", species, "_", direction, "_master_", type, ".rds"))
}
