load_data <- function(species, direction, type){
  if (Sys.info()[6] == "Dan"){
  data <- readRDS(paste0("github/portunid_particle_tracking/Data/Output/", species, "_", direction, "_master_", type, ".rds"))
  } else {
  data <- readRDS(paste0("output/", species, "_", direction, "_master_", type, ".rds"))
  }
}
