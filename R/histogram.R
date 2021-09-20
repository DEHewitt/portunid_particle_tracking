histogram <- function(data, scaled = TRUE){
  # data is the parcels output
  # species is which crab species (character)
  # scaled logical indicating whether to scale histograms or not (default = TRUE), if TRUE then settlement is not comparable across zones
  
  # set number of bins
  pld.bins <- abs(min(data$obs)-max(data$obs))
  disp.bins <- round(abs(min(data$distance)-max(data$distance))/100)
  lat.bins <- round(abs(min(data$lat.distance)-max(data$lat.distance))/100)
  
  means <- data %>% group_by(eac.zone) %>%
    summarise(mean.obs = mean(obs),
              mean.dispersal.distance = mean(distance),
              mean.lat.distance = mean(lat.distance))
  
  data <- data %>% left_join(means)
  
  pld <- ggplot(data = data) +
    geom_histogram(aes(x = obs, 
                       y = ..ncount..,
                       fill = shelf.zone),
                   position = "identity",
                   alpha = 0.75,
                   bins = pld.bins) +
    facet_wrap(vars(eac.zone)) +
    geom_vline(aes(xintercept = mean.obs), 
               linetype = "dashed", 
               colour = "red", 
               size = 1) +
    scale_fill_grey() +
    theme_bw() +
    theme(panel.grid = element_blank(),
          axis.text = element_text(size = 12, colour = "black"),
          axis.title = element_text(size = 12, colour = "black"),
          axis.title.y = element_blank(),
          strip.background = element_blank(),
          strip.text = element_text(size = 12, colour = "black"),
          legend.position = "none") +
    scale_x_continuous(expand = c(0, 0)) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
    labs(fill = "Shelf zone") +
    xlab("Pelagic larval duration (days)") +
    ylab("Rescaled larval settlement")
  
  disp.dist <- ggplot(data = data) +
    geom_histogram(aes(x = distance, 
                       y = ..ncount..,
                       fill = shelf.zone),
                   position = "identity",
                   alpha = 0.75, 
                   bins = disp.bins) +
    facet_wrap(vars(eac.zone)) +
    geom_vline(aes(xintercept = mean.dispersal.distance), 
               linetype = "dashed", 
               colour = "red", 
               size = 1) +
    scale_fill_grey() +
    theme_bw() +
    theme(panel.grid = element_blank(),
          axis.text = element_text(size = 12, colour = "black"),
          axis.title = element_text(size = 12, colour = "black"),
          strip.background = element_blank(),
          strip.text = element_blank(),
          legend.text = element_text(size = 12, colour = "black")) +
    scale_x_continuous(expand = c(0, 0)) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
    labs(fill = "Shelf zone") +
    xlab("Dispersal distance (km)") +
    ylab("Rescaled larval settlement")
  
  lat.dist <- ggplot(data = data) +
    geom_histogram(aes(x = lat.distance, 
                       y = ..ncount..,
                       fill = shelf.zone),
                   position = "identity",
                   alpha = 0.75,
                   bins = lat.bins) +
    facet_wrap(vars(eac.zone)) +
    geom_vline(aes(xintercept = mean.lat.distance), 
               linetype = "dashed", 
               colour = "red", 
               size = 1) +
    scale_fill_grey() +
    theme_bw() +
    theme(panel.grid = element_blank(),
          axis.text = element_text(size = 12, colour = "black"),
          axis.title = element_text(size = 12, colour = "black"),
          axis.title.y = element_blank(),
          strip.background = element_blank(),
          strip.text = element_blank(),
          legend.position = "none") +
    scale_x_continuous(expand = c(0, 0)) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
    labs(fill = "Shelf zone") +
    xlab("Latitudinal dispersal (km)") +
    ylab("Rescaled larval settlement")
  
  plot <- pld/disp.dist/lat.dist
  
  plot
}