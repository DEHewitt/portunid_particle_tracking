plot_sources <- function(data, species, bw){
  # data is the parcels output
  # species is either "gmc" or "bsc"
  # bw specifies the bandwidth for kde (see: https://rdrr.io/r/stats/bandwidth.html)
  
  if (species == "gmc"){
    plot <- ggplot() +
      geom_density(data = data,
                   aes(x = rel_lat),
                   bw = bw) +
      geom_vline(data = data, aes(xintercept = est.lat), linetype = "dashed") +
      coord_flip() +
      facet_wrap(vars(estuary)) +
      theme_bw() +
      theme(panel.grid = element_blank(),
            strip.background = element_blank(),
            strip.text = element_text(size = 10, colour = "black"),
            axis.text = element_text(colour = "black", size = 10),
            axis.title = element_text(colour = "black", size = 12)) +
      scale_x_continuous(limits = c(-35, -15)) +
      xlab(expression("Release latitude ("*degree*"; source)")) +
      ylab("Relative larval supply") +
      inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.20)
    
  } else if (species == "bsc"){
    plot <- ggplot() +
      geom_density(data = data,
                   aes(x = rel_lat),
                   bw = 0.5) +
      geom_vline(data = data, aes(xintercept = est.lat), linetype = "dashed") +
      coord_flip() +
      facet_wrap(vars(estuary)) +
      theme_bw() +
      theme(panel.grid = element_blank(),
            strip.background = element_blank(),
            strip.text = element_text(size = 10, colour = "black"),
            axis.text = element_text(colour = "black", size = 10),
            axis.title = element_text(colour = "black", size = 12)) +
      scale_x_continuous(limits = c(-35, -15)) +
      xlab(expression("Release latitude ("*degree*"; source)")) +
      ylab("Relative larval supply")  +
      inset_element(bsc.grob, left = 0.75, bottom = 0, right = 1, top = 0.20)
  }
  plot
}
