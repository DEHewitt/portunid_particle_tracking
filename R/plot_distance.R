plot_distance <- function(data, species, type){
  # data is the parcels output
  # species is either "gmc" or "bsc"
  # type refers to either dispersal or latitudinal distance
  
  if (species == "gmc" & type == "dispersal"){
    plot <- ggplot(data = data,
                   aes(y = rel_lat_round,
                       x = distance,
                       group = rel_lat_round)) +
      geom_violin(fill = "darkgreen", alpha = 0.5) +
      facet_wrap(vars(season)) +
      theme_bw() +
      theme(panel.grid = element_blank(),
            strip.background = element_blank(),
            strip.text = element_text(size = 10, colour = "black"),
            axis.text = element_text(colour = "black", size = 10),
            axis.title = element_text(colour = "black", size = 12)) +
      ylab(expression("Release latitude ("*degree*")")) +
      xlab("Cumulative dispersal distance (km)") +
      inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)
    
  } else if (species == "bsc" & type == "dispersal"){
    plot <- ggplot(data = data,
                   aes(y = rel_lat_round,
                       x = distance,
                       group = rel_lat_round)) +
      geom_violin(fill = "steelblue2", alpha = 0.5) +
      facet_wrap(vars(season)) +
      theme_bw() +
      theme(panel.grid = element_blank(),
            strip.background = element_blank(),
            strip.text = element_text(size = 10, colour = "black"),
            axis.text = element_text(colour = "black", size = 10),
            axis.title = element_text(colour = "black", size = 12)) +
      ylab(expression("Release latitude ("*degree*")")) +
      xlab("Cumulative dispersal distance (km)") +
      inset_element(bsc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)
    
  } else if (species == "gmc" & type == "latitudinal"){
    plot <- ggplot(data = data,
                   aes(y = rel_lat_round,
                       x = lat.distance,
                       group = rel_lat_round)) +
      geom_violin(fill = "darkgreen", alpha = 0.5) +
      geom_vline(xintercept = 0, linetype = "dashed") +
      facet_wrap(vars(season)) +
      theme_bw() +
      theme(panel.grid = element_blank(),
            strip.background = element_blank(),
            strip.text = element_text(size = 10, colour = "black"),
            axis.text = element_text(colour = "black", size = 10),
            axis.title = element_text(colour = "black", size = 12)) +
      ylab(expression("Release latitude ("*degree*")")) +
      xlab("Latitudinal dispersal distance (km)") +
      inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)
    
  } else if (species == "bsc" & type == "latitudinal"){
    plot <- ggplot(data = data,
                   aes(y = rel_lat_round,
                       x = lat.distance,
                       group = rel_lat_round)) +
      geom_violin(fill = "steelblue2", alpha = 0.5) +
      geom_vline(xintercept = 0, linetype = "dashed") +
      facet_wrap(vars(season)) +
      theme_bw() +
      theme(panel.grid = element_blank(),
            strip.background = element_blank(),
            strip.text = element_text(size = 10, colour = "black"),
            axis.text = element_text(colour = "black", size = 10),
            axis.title = element_text(colour = "black", size = 12)) +
      ylab(expression("Release latitude ("*degree*")")) +
      xlab("Latitudinal dispersal distance (km)") +
      inset_element(bsc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)
  }
  plot
}
