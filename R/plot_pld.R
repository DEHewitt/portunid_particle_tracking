plot_pld <- function(data, species){
  # data is the parcels output
  # species is either "gmc" or "bsc"
  
  if (species == "gmc"){
    plot <- ggplot(data = data,
                   aes(y = rel_lat_round,
                       x = obs,
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
      xlab("Settlement age (days)") +
      inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)

  } else if (species == "bsc"){
    plot <- ggplot(data = data,
                   aes(y = rel_lat_round,
                       x = obs,
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
      xlab("Settlement age (days)") +
      inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)
  }
  plot
}
