summary_plot <- function(data, species, type, statistic){
  # figure out a general way to add the silhouette
  if (species == "gmc"){
    grob <- gmc.grob
    
  } else if (species == "bsc"){
    grob <- bsc.grob
  }
  
  # type refers to which plot you want:
  # distance = dispersal distance
  # latdist = latitudinal distance
  # obs = particle age
  
  # statistic refers to either "mean" or "median"
  
  if (statistic == "mean"){
    if (type == "distance"){
      p <- ggplot(data = data,
                  aes(x = mean_dist,
                      y = rel_lat_round,
                      colour = season)) +
        geom_point() +
        #geom_smooth(method = "lm", se = F) +
        scale_colour_viridis_d()
      
    } else if (type == "latdist"){
      p <- ggplot(data = data,
                  aes(x = mean_latdist,
                      y = rel_lat_round,
                      colour = season)) +
        geom_point() +
        #geom_smooth(method = "lm", se = F) +
        scale_colour_viridis_d()
      
    } else if (type == "obs"){
      p <- ggplot(data = data,
                  aes(x = mean_obs,
                      y = rel_lat_round,
                      colour = season)) +
        geom_point() +
        #geom_smooth(method = "lm", se = F) +
        scale_colour_viridis_d()
      
    }
  } else if (statistic == "median"){
    if (type == "distance"){
      p <- ggplot(data = data,
                  aes(x = median_dist,
                      y = rel_lat_round,
                      colour = season)) +
        geom_point() +
        #geom_smooth(method = "lm", se = F) +
        scale_colour_viridis_d()
      
    } else if (type == "latdist"){
      p <- ggplot(data = data,
                  aes(x = median_latdist,
                      y = rel_lat_round,
                      colour = season)) +
        geom_point() +
        #geom_smooth(method = "lm", se = F) +
        scale_colour_viridis_d()
      
    } else if (type == "obs"){
      p <- ggplot(data = data,
                  aes(x = median_obs,
                      y = rel_lat_round,
                      colour = season)) +
        geom_point() +
        #geom_smooth(method = "lm", se = F) +
        scale_colour_viridis_d()
      
    }
  }
  p
}
