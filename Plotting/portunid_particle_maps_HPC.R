# load libraries
library(tidyverse)
library(lubridate)
library(ggplot2)
library(jpeg)
library(grid)
library(patchwork)
library(rnaturalearth)
library(sf)

# set the working directory
if (Sys.info()[6] == "Dan"){
  print("Working directory is already set")
} else {
  setwd("../../srv/scratch/z5278054/portunid_particle_tracking")
  
  # file path
  file.path <- "/srv/scratch/z5278054/portunid_particle_tracking"
}

# load functions
source("R/load_data.R")
#source("R/import_silhouette.R")
source("R/reformat.R")

# import silhouettes for plotting
#gmc.grob <- import_silhouette(species = "gmc")
#bsc.grob <- import_silhouette(species = "bsc")

# import features for plots
oz <- ne_states(country = "australia", returnclass = "sf")
shelf <- read_sf(dsn = "plotting/200m_isobath.shp")

species <- c("gmc", "bsc")
direction <- c("forwards", "backwards")

for (i in 1:length(species)){
  for (j in 1:length(direction)){
    # load the data
    particles <- load_data(species = species[i], direction = direction[j], type = "final") # change to final
    
    # reformat the data
    particles <- particles %>% reformat(species = species[i], direction = direction[j])
    
    if(direction[j]  == "forwards"){
      
      particles <- particles %>% mutate(rel_lat_round = round(rel_lat))
      
      # df for plotting by release latitude
      map <- particles %>%
        mutate(lat_bin = round(lat, 2)) %>% # rounding to 2 gives ~ per km^2
        mutate(lon_bin = round(lon, 2)) %>%
        group_by(lat_bin, lon_bin, eac.zone) %>%
        summarise(count = n()) %>%
        mutate(eac.zone = case_when(eac.zone == "Great Barrier Reef" ~ "Great Barrier Reef (15-24°S)",
                                    eac.zone == "EAC jet" ~ "EAC jet (24-28°S)",
                                    eac.zone == "EAC separation" ~ "EAC separation (28-31°S)",
                                    eac.zone == "Eddy field" ~ "Eddy field (31-37.5°S)"),
               eac.zone = factor(eac.zone, levels = c("Great Barrier Reef (15-24°S)", 
                                                      "EAC jet (24-28°S)", 
                                                      "EAC separation (28-31°S)", 
                                                      "Eddy field (31-37.5°S)")))
      
      p <- ggplot(data = map) +
        geom_sf(data = oz) +
        geom_tile(aes(x = lon_bin,
                      y = lat_bin,
                      colour = count)) +
        geom_sf(data = shelf) +
        scale_colour_viridis_c(trans = "log10") +
        facet_wrap(vars(eac.zone)) +
        theme_bw() +
        theme(panel.grid = element_blank(),
              axis.text = element_text(size = 12, colour = "black"),
              axis.title = element_text(size = 12, colour = "black"),
              strip.background = element_blank(),
              strip.text = element_text(size = 12, colour = "black"),
              legend.text = element_text(size = 12, colour = "black"))  +
        coord_sf(xlim = c(142, 160), 
                 ylim = c(-37.5, -15),
                 expand = F) +
        ylab("Latitude") +
        xlab("Longitude") +
        labs(colour = expression(paste("Larval density (km"^-2, ")"))) # +
      #inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3) # need to change this - getting rid of things spawned north of -17
      
      ggsave(paste0("output/", species[i], "_", direction[j], "_con_map.png"), device = "png", width = 29, height = 20, units = "cm", dpi = 600)
      
    } else if(direction[j] == "backwards"){
      if (species[i] == "gmc"){
        map <- particles %>%
          mutate(lat_bin = round(lat, 2)) %>% # rounding to 2 gives ~ per km^2
          mutate(lon_bin = round(lon, 2)) %>%
          mutate(rel_lon = case_when(rel_est == "Hinchinbrook Island" ~ 147.848, 
                                     rel_est == "The Narrows" ~ 152.538,
                                     rel_est == "Maryborough" ~ 153.762,
                                     rel_est == "Moreton Bay" ~ 153.636,
                                     rel_est == "Tweed River" ~ 153.79, 
                                     rel_est == "Richmond River" ~ 153.799,
                                     rel_est == "Clarence River" ~ 153.736, 
                                     rel_est == "Macleay River" ~ 153.172, 
                                     rel_est == "Camden Haven" ~ 153.048,
                                     rel_est == "Manning River" ~ 152.946,
                                     rel_est == "Wallis Lake" ~ 152.775, 
                                     rel_est == "Port Stephens" ~ 152.312,
                                     rel_est == "Hunter River" ~ 152.045,
                                     rel_est == "Hawkesbury River" ~ 151.577,
                                     rel_est == "Lake Illawarra" ~ 151.017)) %>%
          group_by(lat_bin, lon_bin, rel_est, rel_lat, rel_lon) %>%
          summarise(count = n()) %>%
          mutate(rel_est = factor(rel_est,
                                  levels = c("Hinchinbrook Island", 
                                             "The Narrows", 
                                             "Maryborough",
                                             "Moreton Bay", 
                                             "Tweed River", 
                                             "Richmond River",
                                             "Clarence River", 
                                             "Macleay River", 
                                             "Camden Haven",
                                             "Manning River", 
                                             "Wallis Lake", 
                                             "Port Stephens",
                                             "Hunter River", 
                                             "Hawkesbury River")))
      } else if (species[i] == "bsc"){
        map <- particles %>%
          mutate(lat_bin = round(lat, 2)) %>% # rounding to 2 gives ~ per km^2
          mutate(lon_bin = round(lon, 2)) %>%
          mutate(rel_lon = case_when(rel_est == "Maryborough" ~ 153.762,
                                     rel_est == "Moreton Bay" ~ 153.636, 
                                     rel_est == "Wallis Lake" ~ 152.775, 
                                     rel_est == "Port Stephens" ~ 152.312,
                                     rel_est == "Hunter River" ~ 152.045,
                                     rel_est == "Hawekesbury River" ~ 151.577,
                                     rel_est == "Lake Illawarra" ~ 151.017)) %>%
          group_by(lat_bin, lon_bin, rel_est, rel_lat, rel_lon) %>%
          summarise(count = n()) %>%
          mutate(rel_est = factor(rel_est,
                                  levels = c("Maryborough",
                                             "Moreton Bay", 
                                             "Wallis Lake", 
                                             "Port Stephens",
                                             "Hunter River",
                                             "Lake Illawarra"))) %>%
          filter(!is.na(rel_est))
      }
      
      ggplot(data = map) +
        geom_sf(data = oz) +
        geom_tile(aes(x = lon_bin,
                      y = lat_bin,
                      colour = count)) +
        geom_sf(data = shelf) +
        geom_point(data = map, # points for settlement and backwards simulations
                   aes(x = rel_lon,
                       y = rel_lat), 
                   size = 2, 
                   col = "white", 
                   shape = 21, 
                   fill = "black") +
        scale_colour_viridis_c(trans = "log10") +
        theme_bw() +
        theme(panel.grid = element_blank(),
              axis.text = element_text(size = 10, colour = "black"),
              axis.title = element_text(size = 12, colour = "black"),
              strip.background = element_blank(),
              strip.text = element_text(size = 10, colour = "black"),
              legend.text = element_text(size = 10, colour = "black")) +
        coord_sf(xlim = c(142, 160), 
                 ylim = c(-37.5, -15),
                 expand = F) +
        ylab("Latitude") +
        xlab("Longitude") +
        labs(colour = expression(paste("Larval density (km"^-2, ")"))) +
        facet_wrap(vars(rel_est))
      
      ggsave(paste0("output/", species[i], "_", direction[j], "_con_map.png"), device = "png", width = 29, height = 20, units = "cm", dpi = 600)
    }
  }
}
  
  