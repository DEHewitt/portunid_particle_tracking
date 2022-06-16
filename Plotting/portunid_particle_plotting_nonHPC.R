# script to create site map and supplementary figures
# these figures do not require any processed data

library(ggplot2)
library(tidyverse)
library(rnaturalearth)
library(patchwork)
library(sf)
library(jpeg)
library(grid)
library(ggrepel)
library(ggspatial)
library(tidync)

#setwd("C:/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking")

#################
### load data ###
#################
# random output file selected because it's roughly halfway along the coast
# aiming to capture the eac jet and eddy field
particles <- hyper_tibble("github/portunid_particle_tracking/Data/gmc_2013_12_forwards.nc")
# shape file of australia
oz <- ne_states(country = "australia", returnclass = "sf")
# forwards release locations
# gmc
gmc.release <- read_csv("github/portunid_particle_tracking/Data/gmc_possible_locations.csv") %>% filter(lat < -18)
# bsc
bsc.release <- read_csv("github/portunid_particle_tracking/Data/bsc_possible_locations.csv")
# locations of estuaries where GMC/BSC are fished
estuaries <- read_csv("github/portunid_particle_tracking/Data/portunid_settlement_locations.csv")
# shapefile of the continental shelf
shelf <- read_sf(dsn = "github/portunid_particle_tracking/Data/200m_isobath.shp")
# eac features
eac.core <- data.frame(feature = c("EAC jet"), lat = c(-26.5), lon = c(152))
eac.sep <- data.frame(feature = c("EAC separation"), lat = c(-32), lon = c(151))
eddy.field <- data.frame(feature = "Eddy field", lat = -39.5, lon = 156)
gbr <- read_sf(dsn = "github/portunid_particle_tracking/Data/GBRMPA_Data/zipfolder/Great_Barrier_Reef_Marine_Park_Boundary.shp")
gbr.label <- data.frame(feature = "Great\n Barrier Reef", lat = -20, lon = 147.5)
# random day of ozroms velocities/sst
ozroms <- hyper_tibble("github/portunid_particle_tracking/Data/20101109.nc") %>% 
  filter(sst != is.nan(sst)) %>%
  filter(depth == max(depth))
# degree days v days
settlement.sst <- data.frame(days = seq(1, 40, by = 1)) %>%
  mutate(cold.18 = days*18,
         med.22 = days*22,
         warm.26 = days*26)
# state labels
nsw <- data.frame(state = "NSW", lat = c(-32), lon = c(145))
qld <- data.frame(state = "QLD", lat = c(-24), lon = c(145))
vic <- data.frame(state = "VIC", lat = c(-37.5), lon = c(145))

# degree days cut-offs
gmc.dd.mean <- 535
gmc.dd.sd <- 32 # taken from processing script
bsc.dd.mean <- 382.5
bsc.dd.sd <- 50 # taken from processing script

# degree days v stage
settlement.stage <- data.frame(stage = c("Larvae 1", "Larvae 2", "Larvae 3", "Larvae 4", "Larvae 5", "Megalopa",
                                   "Larvae 1", "Larvae 2", "Larvae 3", "Larvae 4", "Megalopa"),
                         dd = c(0, 127.5, 212.5, 312.5, 420, 535, 0, 77.5, 167.5, 282.5, 382.5),
                         species = c(rep("Giant Mud Crab", 6), rep("Blue Swimmer Crab", 5)))

# inset pictures of crab silhouettes
gmc.silhouette <- readJPEG("github/portunid_particle_tracking/Data/gmc_silhouette.jpg")
bsc.silhouette <- readJPEG("github/portunid_particle_tracking/Data/bsc_silhouette.jpg")

# convert silhouettes to grobs for plotting
gmc.grob <- rasterGrob(gmc.silhouette, interpolate = T)
bsc.grob <- rasterGrob(bsc.silhouette, interpolate = T)

#######################
### fig 1: site map ###
#######################

# gmc
gmc.estuaries <- estuaries %>% filter(species == "gmc" | species == "both")
gmc.sites <- ggplot() +
  geom_point(data = gmc.release, # possible points for forwards simulations
                     aes(x = lon,
                         y = lat),
                     colour = "darkgreen") +
  geom_sf(data = shelf) +
  geom_rect(aes(xmin = 145, xmax = 163, # hide shelf break in SE Asia
                ymin = -12.5, ymax = -8), 
            fill = "white") +
  geom_rect(aes(xmin = 140, xmax = 145, # hide shelf break in SE Asia
                ymin = -10.5, ymax = -8), 
            fill = "white") +
  annotation_custom(gmc.grob, xmin = 156, xmax = 162, ymin = -15, ymax = -10) + # add a picture of a crab
  geom_segment(aes(x = min(ozroms$lon), # southern boundary
                   xend = max(ozroms$lon),
                   y = min(ozroms$lat),
                   yend = min(ozroms$lat)),
               linetype = "dotted") +
  geom_segment(aes(x = min(ozroms$lon), # northern boundary
                   xend = max(ozroms$lon),
                   y = max(ozroms$lat),
                   yend = max(ozroms$lat)),
               linetype = "dotted") +
  geom_segment(aes(x = max(ozroms$lon), # western boundary
                   xend = max(ozroms$lon),
                   y = min(ozroms$lat),
                   yend = max(ozroms$lat)),
               linetype = "dotted") +
  geom_sf(data = oz) +
  geom_point(data = gmc.estuaries, # points for settlement and backwards simulations
             aes(x = lon,
                 y = lat), 
             size = 2, 
             col = "white", 
             shape = 21, 
             fill = "black", 
             stroke = 1) +
  geom_text_repel(data = gmc.estuaries, 
                  aes(x = lon, 
                      y = lat, 
                      label = estuary), 
                  xlim = c(154, NA), direction = "y",
                  bg.colour = "white",
                  bg.r = 0.25) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        axis.title = element_text(size = 12, colour = "black"),
        axis.text = element_text(size = 12, colour = "black"),
        axis.title.x = element_blank()) +
  coord_sf(xlim = c(142, 162), 
           ylim = c(-40, -10),
           expand = F) +
  ylab("Latitude") +
  xlab("Longitude") +
  geom_text_repel(data = nsw,
                  aes(x = lon,
                      y = lat,
                      label = state),
                  hjust = 1,
                  xlim = c(145, 147.5),
                  bg.colour = "white",
                  bg.r = 0.25) +
  geom_text_repel(data = qld,
                  aes(x = lon,
                      y = lat,
                      label = state),
                  hjust = 1,
                  xlim = c(140, 151.8),
                  bg.colour = "white",
                  bg.r = 0.25) +
  geom_text_repel(data = vic,
                  aes(x = lon,
                      y = lat,
                      label = state),
                  hjust = 1,
                  xlim = c(140, 151.8),
                  bg.colour = "white",
                  bg.r = 0.25)
  
# bsc
bsc.estuaries <- estuaries %>% filter(species == "bsc" | species == "both") %>% filter(estuary != "Hawkesbury River")
bsc.sites <- ggplot() +
  geom_point(data = bsc.release, # possible points for forwards simulations
             aes(x = lon,
                 y = lat),
             colour = "steelblue2") +
  geom_sf(data = shelf) +
  geom_rect(aes(xmin = 145, xmax = 163, # hide shelf break in SE Asia
                ymin = -12.5, ymax = -8), 
            fill = "white") +
  geom_rect(aes(xmin = 140, xmax = 145, # hide shelf break in SE Asia
                ymin = -10.5, ymax = -8), 
            fill = "white") +
  annotation_custom(bsc.grob, xmin = 156, xmax = 162, ymin = -15, ymax = -10) + # add a picture of a crab
  geom_segment(aes(x = min(ozroms$lon), # southern boundary
                   xend = max(ozroms$lon),
                   y = min(ozroms$lat),
                   yend = min(ozroms$lat)),
               linetype = "dotted") +
  geom_segment(aes(x = min(ozroms$lon), # northern boundary
                   xend = max(ozroms$lon),
                   y = max(ozroms$lat),
                   yend = max(ozroms$lat)),
               linetype = "dotted") +
  geom_segment(aes(x = max(ozroms$lon), # western boundary
                   xend = max(ozroms$lon),
                   y = min(ozroms$lat),
                   yend = max(ozroms$lat)),
               linetype = "dotted") +
  geom_sf(data = oz) +
  geom_point(data = bsc.estuaries, # points for settlement and backwards simulations
             aes(x = lon,
                 y = lat), 
             size = 2, 
             col = "white", 
             shape = 21, 
             fill = "black", 
             stroke = 1) +
  geom_text_repel(data = bsc.estuaries, 
                  aes(x = lon, 
                      y = lat, 
                      label = estuary), 
                  xlim = c(154, NA), direction = "y",
                  bg.colour = "white",
                  bg.r = 0.25) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        axis.title = element_text(size = 12, colour = "black"),
        axis.text = element_text(size = 12, colour = "black"),
        axis.text.y = element_blank(),
        axis.title.y = element_blank()) +
  coord_sf(xlim = c(142, 162), 
           ylim = c(-40, -10),
           expand = F) +
  ylab("Latitude") +
  xlab("Longitude")

# eac
#ozroms.thinned <- ozroms %>%
 # filter(row_number() %% 75 == 1)

eac <- ggplot() +
  geom_point(data = ozroms, # sst
              aes(x = lon,
                  y = lat,
                  colour = sst)) +
  # thie below adds velocity vector arrows from ozroms
  # thinned by up to a facotr of 100 they're still uninformative
  #geom_segment(data = ozroms.thinned, 
   #            aes(x = lon, 
    #               xend = lon + u/100, 
     #              y = lat, 
      #             yend = lat + v/100), 
       #        arrow = arrow(angle = 10, 
        #                     length = unit(0.05, "cm"), 
         #                    type = "open")) +
  geom_segment(aes(x = 152.5, # label the eddy field southern boundary
                   xend = max(ozroms$lon), 
                   y = min(ozroms$lat), 
                   yend = min(ozroms$lat)),
               linetype = "dashed") +
  geom_segment(aes(x = min(ozroms$lon), # label the eddy field northern boundary
                   xend = max(ozroms$lon), 
                   y = -32, 
                   yend = -32),
               linetype = "dashed") +
  geom_segment(aes(x = max(ozroms$lon), # label the eddy field eastern boundary
                   xend = max(ozroms$lon), 
                   y = min(ozroms$lat), 
                   yend = -32),
               linetype = "dashed") +
  geom_segment(aes(x = 152.5, # label the eddy field western boundary
                   xend = 152.5, 
                   y = min(ozroms$lat), 
                   yend = -32),
               linetype = "dashed") +
  geom_sf(data = gbr, fill = NA, linetype = "dashed", colour = "black") +
  coord_sf(xlim = c(142, 162), 
         ylim = c(-40, -10),
           expand = F) +
  scale_color_gradientn(colours = rainbow(5, start = 0, end = 4/6), trans = "reverse") +
  theme_bw() +
  theme(panel.grid = element_blank(),
        axis.title = element_text(size = 12, colour = "black"),
        axis.text = element_text(size = 12, colour = "black"),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        legend.text = element_text(size = 12, colour = "black"),
        legend.title = element_text(size = 12, colour = "black")) +
  guides(colour = guide_colourbar(reverse = T)) +
  labs(colour = "SST (°C)") +
  geom_sf(data = oz) + # map of australia
  geom_segment(data = eac.core, # label eac core
               aes(x = lon,
                   xend = lon+1.5,
                   y = lat,
                   yend = lat,
                   group = feature),
               size = 1,
               arrow = arrow(length = unit(0.2, "cm"))) +
  geom_text_repel(data = eac.core,
                  aes(x = lon,
                      y = lat,
                      label = feature),
                  hjust = 1,
                  xlim = c(140, 151.8),
                  bg.colour = "white",
                  bg.r = 0.25) +
  geom_segment(data = eac.sep, # label eac separation
               aes(x = lon,
                   xend = lon+1.5,
                   y = lat,
                   yend = lat,
                   group = feature),
               size = 1,
               arrow = arrow(length = unit(0.2, "cm"))) +
  geom_text_repel(data = eac.sep,
                  aes(x = lon,
                      y = lat,
                      label = feature),
                  hjust = 1,
                  xlim = c(140, 150.8),
                  bg.colour = "white",
                  bg.r = 0.25) +
  geom_text_repel(data = eddy.field,
                  aes(x = lon,
                      y = lat,
                      label = feature),
                  hjust = 0.5,
                  xlim = c(152.5, 160),
                  bg.colour = "white",
                  bg.r = 0.25) +
  geom_text_repel(data = gbr.label,
                  aes(x = lon,
                      y = lat,
                      label = feature),
                  hjust = 0.5,
                  xlim = c(142.5, 147.5),
                  bg.colour = "white",
                  bg.r = 0.25) +
  coord_sf(xlim = c(142, 162), 
           ylim = c(-40, -10),
           expand = F) +
  annotation_north_arrow(location = "tr", which_north = "true",
                         style = north_arrow_fancy_orienteering)

site.map <- (gmc.sites|bsc.sites|eac) + plot_annotation(tag_levels = "a") 

ggsave("C:/Users/Dan/OneDrive - UNSW/Documents/PhD/Dispersal/figures/fig_one_site_map.png", 
       plot = site.map, 
       device = "png", 
       width = 29, # a4 dimensions
       height = 20, 
       units = "cm", 
       dpi = 600)

#######################
## supp. figs for eg ##
#######################

# summary file to pick out a particle with a nice spread of temp, bath and longitude
particles.sum <- particles %>% 
  group_by(traj) %>%
  summarise(min.temp = min(temp),
            max.temp = max(temp),
            range.temp = max.temp-min.temp,
            min.bathy = min(bathy),
            max.bathy = max(bathy),
            min.lon = min(lon),
            max.lon = max(lon),
            min.lat = min(lat),
            max.lat = max(lat),
            rel_date = min(time)) %>%
  filter(min.temp != 0)

particle <- particles %>% 
  filter(traj == "186913") %>% 
  mutate(dd = cumsum(temp)) %>% 
  mutate(gmc = if_else(dd > 535, "settled", "not settled"),
         bsc = if_else(dd > 382.5, "settled", "not settled"))

# sst v. days
sst.path <- ggplot() + 
  geom_sf(data = oz) + 
  geom_path(data = particle, 
            aes(x = lon, 
                y = lat,
                colour = temp),
            size = 1) +
  scale_color_gradient(low = "blue", 
                       high = "red") +
  coord_sf(xlim = c(148, 156),
           ylim = c(-35, -26)) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        axis.title = element_text(size = 12, colour = "black"),
        axis.text = element_text(size = 12, colour = "black"),
        legend.position = "none") +
  ylab("Latitude (°)") +
  xlab("Longitude (°)") +
  labs(colour = "Temperature (°C)") +
  annotation_north_arrow(location = "tr", which_north = "true",
                         style = north_arrow_fancy_orienteering)

dd.v.days <- ggplot() +
  geom_path(data = particle,
            aes(x = obs,
                y = dd,
                colour = temp),
            size = 1) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        axis.title = element_text(size = 12, colour = "black"),
        axis.text = element_text(size = 12, colour = "black"),
        legend.text = element_text(size = 12, colour = "black"),
        legend.title = element_text(size = 12, colour = "black")) +
  ylab("Degree-days") +
  xlab("Days") +
  scale_color_gradient(low = "blue", 
                       high = "red") +
  labs(colour = "Temperature (°C)")

sst.path <- sst.path|dd.v.days

ggsave("C:/Users/Dan/Documents/PhD/Dispersal/figures/supp_fig_sst_path_example.png", 
       plot = sst.path, 
       device = "png", 
       width = 20, # a4 dimensions
       height = 15, 
       units = "cm", 
       dpi = 600)

# settlement stage
# gmc
gmc.settlement.stage <- settlement.stage %>% filter(species == "Giant Mud Crab")
gmc.stage <- ggplot() +
  geom_path(data = gmc.settlement.stage,
            aes(x = dd,
                y = stage),
            group = 1) +
  geom_vline(xintercept = gmc.dd.mean,
             linetype = "dashed",
             size = 1) +
  geom_hline(yintercept = "Megalopa",
             linetype = "dotted",
             size = 1) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        axis.title = element_text(size = 12, colour = "black"),
        axis.title.x = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text = element_text(size = 12, colour = "black"),
        legend.text = element_text(size = 12, colour = "black"),
        legend.title = element_text(size = 12, colour = "black")) +
  ylab("Larval stage") +
  xlab("Degree-days") +
  scale_x_continuous(breaks = c(seq(0, 400, 200), 535, 600),
                     limits = c(0, 600)) +
  annotate(geom = "text", 
           420, "Megalopa", 
           label = "Settlement", 
           size = 4, 
           colour = "black", 
           vjust = -.5)# +
 # annotation_custom(gmc.grob, xmin = 536, xmax = 631, ymin = "Larvae 5", ymax = "Megalopa") # add a picture of a crab
  
# bsc
bsc.settlement.stage <- settlement.stage %>% filter(species == "Blue Swimmer Crab")
bsc.stage <- ggplot() +
  geom_path(data = bsc.settlement.stage,
            aes(x = dd,
                y = stage),
            group = 1) +
  geom_vline(xintercept = bsc.dd.mean,
             linetype = "dashed",
             size = 1) +
  geom_hline(yintercept = "Megalopa",
             linetype = "dotted",
             size = 1) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        axis.title = element_text(size = 12, colour = "black"),
        axis.text = element_text(size = 12, colour = "black"),
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.text = element_text(size = 12, colour = "black"),
        legend.title = element_text(size = 12, colour = "black")) +
  ylab("Larval stage") +
  xlab("Degree-days") +
  scale_x_continuous(breaks = c(seq(0, 300, 100), 382.5, 400),
                     limits = c(0, 440),
                     labels = c("0", "100", "200", "300", "382.5", "")) +
  annotate(geom = "text", 
           300, "Megalopa", 
           label = "Settlement", 
           size = 4, 
           colour = "black", 
           vjust = -.5)# +
 # annotation_custom(bsc.grob, xmin = 384.5, xmax = 460, ymin = "Larvae 4", ymax = "Megalopa")

settlement <- gmc.stage/bsc.stage

ggsave("C:/Users/Dan/Documents/PhD/Dispersal/figures/supp_fig_settlement_stage_example.png", 
       plot = settlement, 
       device = "png", 
       width = 10, # a4 dimensions
       height = 15, 
       units = "cm", 
       dpi = 600)
   
# dd and various sst
# gmc
gmc.dd.sst <- ggplot() +
  geom_line(data = settlement.sst,
            aes(x = days, 
                y = cold.18), 
            size = 1, 
            colour = "blue") +
  geom_line(data = settlement.sst,
            aes(x = days, 
                y = med.22), 
            size = 1, 
            colour = "purple") +
  geom_line(data = settlement.sst,
            aes(x = days, 
                y = warm.26), 
            size = 1, 
            colour = "red") +
  theme_bw() + 
  coord_cartesian(xlim = c(0, 30), 
                  ylim = c(0, 600)) +
  geom_hline(yintercept = 535, 
             linetype = "dotted") +
  geom_vline(xintercept = 535/18, 
             linetype = "dashed", 
             colour = "blue") +
  geom_vline(xintercept = 535/22, 
             linetype = "dashed", 
             colour = "purple") +
  geom_vline(xintercept = 535/26, 
             linetype = "dashed", 
             colour = "red") +
  annotate(geom = "text", 535/26 - 0.5, 
           535, label = "Settlement", 
           size = 4, 
           colour = "black", 
           vjust = -0.5,
           hjust = 1) +
  scale_y_continuous(breaks = c(seq(0, 600, 200), 535)) +
  scale_x_continuous(breaks = seq(0, 30, 5)) +
  xlab("Days") +
  ylab("Degree-days") +
  theme(axis.text = element_text(size = 12, colour = "black"), 
        axis.title.x = element_blank(),
        axis.title = element_text(size = 12, colour = "black"),
        panel.grid = element_blank())# +
 # annotation_custom(gmc.grob, xmin = -1, xmax = 5, ymin = 535, ymax = 635)

# bsc
bsc.dd.sst <- ggplot() +
  geom_line(data = settlement.sst,
            aes(x = days, 
                y = cold.18), 
            size = 1, 
            colour = "blue") +
  geom_line(data = settlement.sst,
            aes(x = days, 
                y = med.22), 
            size = 1, 
            colour = "purple") +
  geom_line(data = settlement.sst,
            aes(x = days, 
                y = warm.26), 
            size = 1, 
            colour = "red") +
  theme_bw() + 
  coord_cartesian(xlim = c(0, 25), 
                  ylim = c(0, 440)) +
  geom_hline(yintercept = 382.5, 
             linetype = "dotted") +
  geom_vline(xintercept = 382.5/18, 
             linetype = "dashed", 
             colour = "blue") +
  geom_vline(xintercept = 382.5/22, 
             linetype = "dashed", 
             colour = "purple") +
  geom_vline(xintercept = 382.5/26, 
             linetype = "dashed", 
             colour = "red") +
  annotate(geom = "text", 382.5/26 - 0.5, 
           382.5, 
           label = "Settlement", 
           size = 4, 
           colour = "black", 
           vjust = -0.5,
           hjust = 1) +
  scale_y_continuous(breaks = c(seq(0, 300, 100), 382.5, 400),
                     labels = c("0", "100", "200", "300", "382.5", "")) +
  scale_x_continuous(breaks = seq(0, 25, 5)) +
  xlab("Days") +
  ylab("Degree-days") +
  theme(axis.text = element_text(size = 12, colour = "black"), 
        axis.title = element_text(size = 12, colour = "black"),
        panel.grid = element_blank())# +
 # annotation_custom(bsc.grob, xmin = -1, xmax = 5, ymin = 384.5, ymax = 460)

dd.sst <- gmc.dd.sst/bsc.dd.sst

ggsave("C:/Users/Dan/Documents/PhD/Dispersal/figures/supp_fig_dd_sst_example.png", 
       plot = dd.sst, 
       device = "png", 
       width = 10, # a4 dimensions
       height = 15, 
       units = "cm", 
       dpi = 600)  

dd.examples <- settlement|dd.sst

ggsave("C:/Users/Dan/Documents/PhD/Dispersal/figures/supp_fig_dd_example.jpeg", 
       plot = dd.examples, 
       device = "jpeg", 
       width = 20, # a4 dimensions
       height = 15, 
       units = "cm", 
       dpi = 300) 

# mortality example
mortality <- data.frame(day = seq(0, 39, 1), init.n.part = rep(1000, 40))

mortality <- mortality %>%
  mutate(deg.day25 = day*25) %>%
  #mutate(deg.day18 = day*18) %>%
  mutate(n.part25 = if_else(deg.day25 > 535, round(init.n.part*(1-0.027)^(day-21)), init.n.part))# %>%
  #mutate(n.part18 = if_else(deg.day18 > 535, round(init.n.part*(1-0.027)^(day-29)), init.n.part))

mortality.plot <- ggplot() +
  geom_line(data = mortality,
            aes(x = day,
                y = n.part25),
            size = 1) +
  #geom_line(data = mortality,
   #         aes(x = day,
    #            y = n.part18+2),
     #       colour = "blue",
      #      size = 1) +
  geom_vline(aes(xintercept = 21), linetype = "dashed", size = 1) +
  #geom_vline(aes(xintercept = 29), colour = "blue", linetype = "dashed", size = 1) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        axis.title = element_text(size = 12, colour = "black"),
        axis.text = element_text(size = 12, colour = "black")) +
  xlab("Particle age (days)") +
  ylab("Number of particles")
  
ggsave("C:/Users/Dan/Documents/PhD/Dispersal/figures/supp_fig_mort_example.png", 
       plot = mortality.plot, 
       device = "png", 
       width = 20, # a4 dimensions
       height = 15, 
       units = "cm", 
       dpi = 600) 
                     