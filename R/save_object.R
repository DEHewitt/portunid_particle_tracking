save_object <- function(data, type){
  # type can either be "final" or "settled"
  
  if (type == "final"){
    file <- paste(file.path, species, direction, "processed", paste(species, min(year(particles$rel_date)), unique(particles$ocean_zone), direction, "final_points.rds", sep = "_"), sep = "/")
  } else if (type == "settled"){
    file <- paste(file.path, species, direction, "processed", paste(species, min(year(particles$rel_date)), unique(particles$ocean_zone), direction, "settled.rds", sep = "_"), sep = "/")
  }
  if(file.exists(file)){
    file.remove(file)
  }
  saveRDS(data, file = file)
}
