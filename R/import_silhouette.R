import_silhouette <- function(species){
  silhouette <- readJPEG(paste0("github/portunid_particle_tracking/Data/", species, "_silhouette.jpg")) %>% 
    rasterGrob(interpolate = T)
}