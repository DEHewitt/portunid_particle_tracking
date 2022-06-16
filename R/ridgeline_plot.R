ridgeline_plot() <- function(data, species){
  
}



ggplot(data = particles,
       aes(x = rel_lat,
           y = reorder(estuary, desc(estuary)))) +
  stat_density_ridges(quantile_lines = TRUE) +
  facet_wrap(vars(season)) +
  #scale_y_discrete(limits = rev(levels(particles$estuary))) +
  geom_segment(aes(x = est.lat, xend = est.lat, 
                   y = as.numeric(reorder(estuary, desc(estuary))), 
                   yend = as.numeric(reorder(estuary, desc(estuary))) + 0.9),
               colour = "red") +
  theme_bw() +
  theme(panel.grid = element_blank(),
       axis.text = element_text(size = 10, colour = "black"),
       axis.title = element_text(size = 12, colour = "black"),
       strip.background = element_blank(),
       strip.text = element_text(size = 10, colour = "black"),
       legend.text = element_text(size = 10, colour = "black")) +
  ylab(expression("Settlement estuary (sink)")) +
  xlab(expression("Putative spawning latitude ("*degree*"; source)"))
