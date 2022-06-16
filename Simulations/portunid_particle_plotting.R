# load packages
library(tidyverse)
library(lubridate)
library(ggplot2)
library(rnaturalearth)
library(fy)
library(sf)

# set the working directory
if (Sys.info()[6] == "Dan"){
  print("Working directory is already set")
} else {
  setwd("../../srv/scratch/z5278054/portunid_particle_tracking")
  
  # file path
  file.path <- "/srv/scratch/z5278054/portunid_particle_tracking"
}

# load custom functions
source("R/load_data.R")

# set up some plotting defaults
theme_set(theme_bw())
theme_update(strip.background = element_blank(),
             axis.text = element_text(size = 12, colour = "black"),
             axis.title = element_text(size = 12, colour = "black"),
             panel.grid = element_blank(),
             strip.text = element_text(size = 12, colour = "black"))

# import features for plots
oz <- ne_states(country = "australia", returnclass = "sf")
shelf <- read_sf(dsn = "plotting/200m_isobath.shp")

# so we cna loop through both species
species <- c("bsc", "gmc")

# now execute the loop
for (i in 1:length(species)){
  # load the data
  if (Sys.info()[6] == "Dan"){
    settled <- readRDS("temp/bsc_backwards_master_settled.rds") %>% sample_n(10000)
  } else {
    settled <- load_data(species = species[i], direction = "backwards", type = "settled")
    final <- load_data(species = species[i], direction = "backwards", type = "final")
  }
  
  # fix up the rel_lat/rel_est stuff
  if (species[i] == "bsc"){
    settled <- 
      settled %>%
      mutate(
        rel_lat = round(rel_lat, 3),
        rel_est = case_when(
          rel_lat == -25.817 ~ "Hervey Bay",
          rel_lat == -27.339 ~ "Moreton Bay",
          #rel_lat == -31.645 ~ "Camden Haven", # DJ might suggest we add this estuary again
          rel_lat == -32.193 ~ "Wallis Lake",
          rel_lat == -32.719 ~ "Port Stephens",
          rel_lat == -32.917 ~ "Hunter River",
          rel_lat == -33.578 ~ "Hawkesbury River",
          rel_lat == -34.546 ~ "Lake Illawarra"
        ),
        season = date2fy(date)
      )
    
    settled <- settled %>%
      mutate(rel_est = factor(
        rel_est, 
        levels = c(
          "Hervey Bay",
          "Moreton Bay",
          "Wallis Lake",
          "Port Stephens",
          "Hunter River",
          "Hawkesbury River",
          "Lake Illawarra"
        )
      )
      )
    
    final <- final %>%
      mutate(rel_lat = round(rel_lat, 3),
             rel_est = case_when(
               rel_lat == -25.817 ~ "Hervey Bay",
               rel_lat == -27.339 ~ "Moreton Bay",
               #rel_lat == -31.645 ~ "Camden Haven", # DJ might suggest we add this estuary again
               rel_lat == -32.193 ~ "Wallis Lake",
               rel_lat == -32.719 ~ "Port Stephens",
               rel_lat == -32.917 ~ "Hunter River",
               rel_lat == -33.578 ~ "Hawkesbury River",
               rel_lat == -34.546 ~ "Lake Illawarra"),
             season = date2fy(date))
    
    final <- final %>%
      mutate(rel_est = factor(
        rel_est, 
        levels = c(
          "Hervey Bay",
          "Moreton Bay",
          "Wallis Lake",
          "Port Stephens",
          "Hunter River",
          "Hawkesbury River",
          "Lake Illawarra"
        )
      )
      )
  } else {
    settled <- settled %>%
      mutate(rel_lat = round(rel_lat, 3),
             rel_est = case_when(
               rel_lat == -18.541 ~ "Hinchinbrook",
               rel_lat == -23.850 ~ "The Narrows",
               rel_lat == -25.817 ~ "Hervey Bay",
               rel_lat == -27.339 ~ "Moreton Bay",
               rel_lat == -28.165 ~ "Tweed River",
               rel_lat == -28.890 ~ "Richmond River",
               rel_lat == -29.432 ~ "Clarence River",
               rel_lat == -30.864 ~ "Macleay River",
               rel_lat == -31.645 ~ "Camden Haven",
               rel_lat == -31.899 ~ "Manning River",
               rel_lat == -32.193 ~ "Wallis Lake",
               rel_lat == -32.719 ~ "Port Stephens",
               rel_lat == -32.917 ~ "Hunter River",
               rel_lat == -33.578 ~ "Hawkesbury River"),
             season = date2fy(date))
    
    settled <- settled %>%
      mutate(rel_est = factor(
        rel_est, 
        levels = c(
          "Hinchinbrook",
          "The Narrows",
          "Hervey Bay",
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
          "Hawkesbury River"
        )
      )
      )
    
    final <- final %>%
      mutate(rel_lat = round(rel_lat, 3),
             rel_est = case_when(
               rel_lat == -18.541 ~ "Hinchinbrook",
               rel_lat == -23.850 ~ "The Narrows",
               rel_lat == -25.817 ~ "Hervey Bay",
               rel_lat == -27.339 ~ "Moreton Bay",
               rel_lat == -28.165 ~ "Tweed River",
               rel_lat == -28.890 ~ "Richmond River",
               rel_lat == -29.432 ~ "Clarence River",
               rel_lat == -30.864 ~ "Macleay River",
               rel_lat == -31.645 ~ "Camden Haven",
               rel_lat == -31.899 ~ "Manning River",
               rel_lat == -32.193 ~ "Wallis Lake",
               rel_lat == -32.719 ~ "Port Stephens",
               rel_lat == -32.917 ~ "Hunter River",
               rel_lat == -33.578 ~ "Hawkesbury River"),
             season = date2fy(date))
    
    final <- final %>%
      mutate(rel_est = factor(
        rel_est, 
        levels = c(
          "Hinchinbrook",
          "The Narrows",
          "Hervey Bay",
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
          "Hawkesbury River"
        )
      )
      )
  }
  
  state_border <- -28.16
  separation_north <- -28
  separation_south <- -31
  
  text <- data.frame(
    state_border = rep(abs(state_border), 2),
    separation_lat = rep(abs(-29.5), 2),
    separation = c("EAC jet", "Eddy-field"),
    sep_label = c(NA, paste0("Separation zone (~",abs(separation_north), "-", abs(separation_south), "°S)")),
    state = c("Queensland", "New South Wales"),
    state_label = c(NA, paste0("NSW/QLD border (~", round(abs(state_border), 1), "°S)"))
  ) %>%
    mutate(
      state = factor(state, levels = c("Queensland", "New South Wales")),
      separation = factor(separation, levels = c("EAC jet", "Eddy-field"))
    )
  
  ozroms <- data.frame(
    xmin = 142,
    xmax = 160,
    ymin = -37.5,
    ymax = -15
  )
  
  settled <- settled %>% mutate(lat.distance = (abs(rel_lat)-abs(lat))*111)
  
  # histogram of spawning latitudes facetted by estuary
  ggplot(data = settled,
         aes(x = abs(lat))) + 
    annotate("rect", xmin = abs(separation_south), xmax = abs(separation_north), 
             ymin = 0, ymax = Inf, alpha = 0.2, fill = "red") +
    geom_histogram(aes(y = stat(density*width)*100), binwidth = 0.5) +
    #geom_rug(aes(x = abs(rel_lat))) +
    scale_y_continuous(expand = c(0, 0)) +
    geom_segment(data = settled, aes(x = abs(rel_lat), xend = abs(rel_lat), y = 0.1, yend = 2), arrow = arrow(length = unit(0.1, "cm"), ends = "first", type = "open")) +
    facet_wrap(vars(rel_est)) +
    geom_vline(xintercept = abs(state_border), linetype = "dashed", colour = "black", size = 1) +
    coord_flip() +
    scale_x_reverse() +
    #geom_vline(aes(xintercept = abs(rel_lat)), linetype = "dashed", colour = "red", size = 1) +
    ylab("Percentage (%)") +
    xlab("Putative spawning latitude (°S)") +
    theme_bw() +
    theme(strip.background = element_blank(),
          axis.text = element_text(size = 12, colour = "black"),
          axis.title = element_text(size = 12, colour = "black"),
          panel.grid = element_blank(),
          strip.text = element_text(size = 12, colour = "black"))
  
  # save the plot
  ggsave(paste0(file.path, "/output/", species[i], "_estuary_histogram.png"), device = "png", width = 15, height = 15, units = "cm", dpi = 600)
  
  # create separation variable
  settled <- settled %>% mutate(
    separation = case_when(
      rel_lat > separation_north ~ "EAC jet",
      rel_lat < separation_north & rel_lat > separation_south ~ "EAC separation",
      rel_lat < separation_south ~ "Eddy-field"),
    separation = factor(
      separation, 
      levels = c("EAC jet", "EAC separation", "Eddy-field")))
  
  final <- final %>% mutate(
    separation = case_when(
      rel_lat > separation_north ~ "EAC jet",
      rel_lat < separation_north & rel_lat > separation_south ~ "EAC separation",
      rel_lat < separation_south ~ "Eddy-field"),
    separation = factor( # make into a factor for nice plotting
      separation, 
      levels = c("EAC jet", "EAC separation", "Eddy-field")))
  
  # create state variable
  settled <- settled %>% mutate(
    state = if_else(
      rel_lat < state_border, 
      "New South Wales", # if true
      "Queensland"), # if false
    state = factor( # make into a factor for nice plotting
      state, 
      levels = c("Queensland", "New South Wales")))
  
  final <- final %>% mutate(
    state = if_else(
      rel_lat < state_border, 
      "New South Wales", 
      "Queensland"),
    state = factor(state, levels = c("Queensland", "New South Wales")))
  
  # plot of particle released north/south and where they likely came from
  ggplot(data = settled,
         aes(x = abs(lat))) + 
    annotate("rect", xmin = abs(separation_south), xmax = abs(separation_north), 
             ymin = 0, ymax = Inf, alpha = 0.2, fill = "red") +
    geom_histogram(aes(y = stat(density*width)*100), binwidth = 0.5) +
    geom_rug(aes(x = abs(rel_lat))) +
    facet_wrap(vars(separation)) +
    coord_flip() +
    scale_x_reverse() +
    geom_vline(xintercept = abs(state_border), linetype = "dashed", colour = "black", size = 1) +
    ylab("Percentage (%)") +
    xlab("Putative spawning latitude (°S)") +
    theme_bw() +
    theme(strip.background = element_blank(),
          axis.text = element_text(size = 12, colour = "black"),
          axis.title = element_text(size = 12, colour = "black"),
          panel.grid = element_blank(),
          strip.text = element_text(size = 12, colour = "black")) +
    geom_text(data = text, aes(x = separation_lat, y = Inf, label = sep_label), vjust = 0, hjust = 1.01) +
    geom_text(data = text, aes(x = state_border, y = Inf, label = state_label), vjust = -0.6, hjust = 1.01)
  
  # make sure the dimensions look good
  # different species means different number of facets
  if(species[i] == "bsc"){
    width <- 15
    height <- 10
  } else {
    width <- 28
    height <- 28/3
  }
  
  # save the plot
  ggsave(paste0(file.path, "/output/", species[i], "_separation_histogram.png"), device = "png", width = width, height = height, units = "cm", dpi = 600)
  
  # plot of particle origins facetted by separation and season
  ggplot(data = settled,
         aes(x = abs(lat))) + 
    annotate("rect", xmin = abs(separation_south), xmax = abs(separation_north), 
             ymin = 0, ymax = Inf, alpha = 0.2, fill = "red") +
    geom_histogram(aes(y = stat(density*width)*100), binwidth = 0.5) +
    geom_rug(aes(x = abs(rel_lat))) +
    facet_grid(separation ~ season) +
    coord_flip() +
    scale_x_reverse() +
    geom_vline(xintercept = abs(state_border), linetype = "dashed", colour = "black", size = 1) +
    ylab("Percentage (%)") +
    xlab("Putative spawning latitude (°S)") +
    theme_bw() +
    theme(strip.background = element_blank(),
          axis.text = element_text(size = 12, colour = "black"),
          axis.title = element_text(size = 12, colour = "black"),
          panel.grid = element_blank(),
          strip.text = element_text(size = 12, colour = "black"))
  
  if(species[i] == "bsc"){
    width <- 27
    height <- 10
  } else {
    width <- 27
    height <- 15
  }
  
  # save the plot
  ggsave(paste0(file.path, "/output/", species[i], "_seasonal_separation_histogram.png"), device = "png", width = width, height = height, units = "cm", dpi = 600)
  
  # particle origins facetted by state
  ggplot(data = settled,
         aes(x = abs(lat))) + 
    annotate("rect", xmin = abs(separation_south), xmax = abs(separation_north), 
             ymin = 0, ymax = Inf, alpha = 0.2, fill = "red") +
    geom_histogram(aes(y = stat(density*width)*100), binwidth = 0.5) +  
    geom_rug(aes(x = abs(rel_lat))) +
    facet_wrap(vars(state)) +
    coord_flip() +
    scale_x_reverse() +
    geom_vline(xintercept = abs(state_border), linetype = "dashed", colour = "black", size = 1) +
    ylab("Percentage (%)") +
    xlab("Putative spawning latitude (°S)") +
    theme_bw() +
    theme(strip.background = element_blank(),
          axis.text = element_text(size = 12, colour = "black"),
          axis.title = element_text(size = 12, colour = "black"),
          panel.grid = element_blank(),
          strip.text = element_text(size = 12, colour = "black")) +
    geom_text(data = text, aes(x = separation_lat, y = Inf, label = sep_label), vjust = 0, hjust = 1.01) +
    geom_text(data = text, aes(x = state_border, y = Inf, label = state_label), vjust = -0.6, hjust = 1.01)
  
  # save the plot
  ggsave(paste0(file.path, "/output/", species[i], "_state_histogram.png"), device = "png", width = 15, height = 10, units = "cm", dpi = 600)
  
  # particle origins facetted by state and season
  ggplot(data = settled,
         aes(x = abs(lat))) + 
    annotate("rect", xmin = abs(separation_south), xmax = abs(separation_north), 
             ymin = 0, ymax = Inf, alpha = 0.2, fill = "red") +
    geom_histogram(aes(y = stat(density*width)*100), binwidth = 0.5) +  
    geom_rug(aes(x = abs(rel_lat))) +
    facet_grid(state ~ season) +
    coord_flip() +
    scale_x_reverse() +
    geom_vline(xintercept = abs(state_border), linetype = "dashed", colour = "black", size = 1) +
    ylab("Percentage (%)") +
    xlab("Putative spawning latitude (°S)") +
    theme_bw() +
    theme(strip.background = element_blank(),
          axis.text = element_text(size = 12, colour = "black"),
          axis.title = element_text(size = 12, colour = "black"),
          panel.grid = element_blank(),
          strip.text = element_text(size = 12, colour = "black"))
  
  # save the plot
  ggsave(paste0(file.path, "/output/", species[i], "_seasonal_state_histogram.png"), device = "png", width = 27, height = 10, units = "cm", dpi = 600)
  
  # create some pretty maps
  map <- final %>%
    mutate(lat_bin = round(lat, 2)) %>% # rounding to 2 gives ~ per km^2
    mutate(lon_bin = round(lon, 2)) %>%
    group_by(lat_bin, lon_bin, rel_est, rel_lat, rel_lon) %>%
    summarise(count = n()) %>%
    ungroup()
  
  ggplot(data = map) +
    geom_tile(aes(x = lon_bin,
                  y = lat_bin,
                  colour = count)) +
    geom_hline(yintercept = separation_north, linetype = "dashed", colour = "red", size = 0.5) +
    geom_hline(yintercept = separation_south, linetype = "dashed", colour = "red", size = 0.5) +
    geom_sf(data = oz) +
    geom_rect(data = ozroms, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax), fill = NA, linetype = "dashed") +
    #geom_sf(data = shelf) +
    geom_point(data = final, # points for settlement and backwards simulations
               aes(x = rel_lon,
                   y = rel_lat), 
               size = 2, 
               col = "white", 
               shape = 21, 
               fill = "black") +
    scale_colour_viridis_c(trans = "log10") +
    coord_sf(xlim = c(142, 160), 
             ylim = c(-37.5, -15),
             expand = F) +
    ylab("Latitude") +
    xlab("Longitude") +
    labs(colour = expression(paste("Particle density (km"^2, ")"))) +
    facet_wrap(vars(rel_est))  +
    theme_bw() +
    theme(strip.background = element_blank(),
          axis.text = element_text(size = 10, colour = "black"),
          axis.title = element_text(size = 12, colour = "black"),
          panel.grid = element_blank(),
          strip.text = element_text(size = 10, colour = "black"))
  
  # save the plot
  ggsave(paste0(file.path, "/output/", species[i], "_estuary_map.png"), device = "png", width = 20, height = 27, units = "cm", dpi = 600)
  
  map <- final %>%
    mutate(lat_bin = round(lat, 2)) %>% # rounding to 2 gives ~ per km^2
    mutate(lon_bin = round(lon, 2)) %>%
    group_by(lat_bin, lon_bin, separation) %>%
    summarise(count = n()) %>%
    ungroup()

  ggplot(data = map) +
    geom_rect(data = ozroms, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax), fill = NA, colour = "black", linetype = "dashed") +
    geom_tile(aes(x = lon_bin,
                  y = lat_bin,
                  colour = count)) +
    geom_hline(yintercept = separation_north, linetype = "dashed", colour = "red", size = 0.5) +
    geom_hline(yintercept = separation_south, linetype = "dashed", colour = "red", size = 0.5) +
    geom_sf(data = oz) +
    geom_sf(data = shelf) +
    scale_colour_viridis_c(trans = "log10") +
    geom_point(data = final, # points for settlement and backwards simulations
               aes(x = rel_lon,
                   y = rel_lat), 
               size = 2, 
               col = "white", 
               shape = 21, 
               fill = "black")  +
    scale_x_continuous(limits = c(142, 160),
                       breaks = seq(145, 160, 5),
                       labels = c("145°S", "", "155°S", "")) +
    scale_y_continuous(limits = c(-37.5, -15)) +
    ylab("Latitude") +
    xlab("Longitude") +
    labs(colour = expression(paste("Particle density (km"^2, ")"))) +
    facet_wrap(vars(separation)) +
    theme_bw() +
    theme(strip.background = element_blank(),
          axis.text = element_text(size = 10, colour = "black"),
          axis.title = element_text(size = 12, colour = "black"),
          panel.grid = element_blank(),
          strip.text = element_text(size = 10, colour = "black"))
  
  if(species[i] == "bsc"){
    width <- 15
    height <- 10
  } else {
    width <- 28
    height <- 28/3
  }
  
  ggsave(paste0(file.path, "/output/", species[i], "_separation_map.png"), device = "png", width = width, height = height, units = "cm", dpi = 600)
  
  map <- final %>%
    mutate(lat_bin = round(lat, 2)) %>% # rounding to 2 gives ~ per km^2
    mutate(lon_bin = round(lon, 2)) %>%
    group_by(lat_bin, lon_bin, separation, season) %>%
    summarise(count = n()) %>%
    ungroup() 
  
  ggplot(data = map) +
    geom_rect(data = ozroms, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax), fill = NA, colour = "black", linetype = "dashed") +
    geom_tile(aes(x = lon_bin,
                  y = lat_bin,
                  colour = count)) +
    geom_hline(yintercept = separation_north, linetype = "dashed", colour = "red", size = 0.5) +
    geom_hline(yintercept = separation_south, linetype = "dashed", colour = "red", size = 0.5) +
    geom_sf(data = oz) +
    geom_sf(data = shelf) +
    scale_colour_viridis_c(trans = "log10") +
    geom_point(data = final, # points for settlement and backwards simulations
               aes(x = rel_lon,
                   y = rel_lat), 
               size = 2, 
               col = "white", 
               shape = 21, 
               fill = "black") +
    scale_x_continuous(limits = c(142, 160),
                       breaks = seq(145, 160, 5),
                       labels = c("145°S", "", "155°S", "")) +
    scale_y_continuous(limits = c(-37.5, -15)) +
    ylab("Latitude") +
    xlab("Longitude") +
    labs(colour = expression(paste("Particle density (km"^2, ")"))) +
    facet_grid(separation ~ season) +
    theme_bw() +
    theme(strip.background = element_blank(),
          axis.text = element_text(size = 10, colour = "black"),
          axis.title = element_text(size = 12, colour = "black"),
          panel.grid = element_blank(),
          strip.text = element_text(size = 8, colour = "black"))
  
  if(species[i] == "bsc"){
    width <- 27
    height <- 15
  } else {
    width <- 27
    height <- 21
  }
  
  ggsave(paste0(file.path, "/output/", species[i], "_seasonal_separation_map.png"), device = "png", width = width, height = height, units = "cm", dpi = 600)
  
  map <- final %>%
    mutate(lat_bin = round(lat, 2)) %>% # rounding to 2 gives ~ per km^2
    mutate(lon_bin = round(lon, 2)) %>%
    group_by(lat_bin, lon_bin, state) %>%
    summarise(count = n()) %>%
    ungroup() 
  
  ggplot(data = map) +
    geom_rect(data = ozroms, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax), fill = NA, colour = "black", linetype = "dashed") +
    geom_tile(aes(x = lon_bin,
                  y = lat_bin,
                  colour = count)) +
    geom_hline(yintercept = separation_north, linetype = "dashed", colour = "red", size = 0.5) +
    geom_hline(yintercept = separation_south, linetype = "dashed", colour = "red", size = 0.5) +
    geom_sf(data = oz) +
    geom_sf(data = shelf) +
    geom_point(data = final, # points for settlement and backwards simulations
               aes(x = rel_lon,
                   y = rel_lat), 
               size = 2, 
               col = "white", 
               shape = 21, 
               fill = "black") +
    scale_colour_viridis_c(trans = "log10") +
    scale_x_continuous(limits = c(142, 160),
                       breaks = seq(145, 160, 5),
                       labels = c("145°S", "", "155°S", "")) +
    scale_y_continuous(limits = c(-37.5, -15)) +
    ylab("Latitude") +
    xlab("Longitude") +
    labs(colour = expression(paste("Particle density (km"^2, ")"))) +
    facet_wrap(vars(state)) +
    theme_bw() +
    theme(strip.background = element_blank(),
          axis.text = element_text(size = 10, colour = "black"),
          axis.title = element_text(size = 12, colour = "black"),
          panel.grid = element_blank(),
          strip.text = element_text(size = 10, colour = "black"))
  
  width <- 15
  height <- 10
  
  
  ggsave(paste0(file.path, "/output/", species[i], "_state_map.png"), device = "png", width = width, height = height, units = "cm", dpi = 600)
  
  map <- final %>%
    mutate(lat_bin = round(lat, 2)) %>% # rounding to 2 gives ~ per km^2
    mutate(lon_bin = round(lon, 2)) %>%
    group_by(lat_bin, lon_bin, state, season) %>%
    summarise(count = n()) %>%
    ungroup() 
  
  ggplot(data = map) +
    geom_rect(data = ozroms, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax), fill = NA, colour = "black", linetype = "dashed") +
    geom_tile(aes(x = lon_bin,
                  y = lat_bin,
                  colour = count)) +
    geom_hline(yintercept = separation_north, linetype = "dashed", colour = "red", size = 0.5) +
    geom_hline(yintercept = separation_south, linetype = "dashed", colour = "red", size = 0.5) +
    geom_sf(data = oz) +
    geom_sf(data = shelf) +
    geom_point(data = final, # points for settlement and backwards simulations
               aes(x = rel_lon,
                   y = rel_lat), 
               size = 2, 
               col = "white", 
               shape = 21, 
               fill = "black") +
    scale_colour_viridis_c(trans = "log10") +
    scale_x_continuous(limits = c(142, 160),
                       breaks = seq(145, 160, 5),
                       labels = c("145°S", "", "155°S", "")) +
    scale_y_continuous(limits = c(-37.5, -15)) +
    ylab("Latitude") +
    xlab("Longitude") +
    labs(colour = expression(paste("Particle density (km"^2, ")"))) +
    facet_grid(state ~ season) +
    theme_bw() +
    theme(strip.background = element_blank(),
          axis.text = element_text(size = 10, colour = "black"),
          axis.title = element_text(size = 12, colour = "black"),
          panel.grid = element_blank(),
          strip.text = element_text(size = 8, colour = "black"))
  
  width <- 27
  height <- 10
  
  ggsave(paste0(file.path, "/output/", species[i], "_seasonal_state_map.png"), device = "png", width = width, height = height, units = "cm", dpi = 600)
  
  # now summarise the information into a table
  # estuary contribution summary
  estuary.summary <- settled %>%
    group_by(rel_est, season) %>%
    mutate(northern.contribution = length(which(lat > rel_lat)),
           southern.contribution = length(which(lat < rel_lat)),
           north.cont.perc = northern.contribution/n()*100,
           south.cont.perc = southern.contribution/n()*100,
           mean.lat.dist.season = mean(lat.distance),
           mean.dist.season = mean(distance)) %>%
    ungroup() %>%
    group_by(rel_est) %>%
    arrange(desc(rel_lat)) %>%
    summarise(mean.north.perc = mean(north.cont.perc),
              sd.north.perc = sd(north.cont.perc),
              cv.north.perc = sd.north.perc/mean.north.perc,
              mean.south.perc = mean(south.cont.perc),
              sd.south.perc = sd(south.cont.perc),
              cv.south.perc = sd.south.perc/mean.south.perc,
              mean.lat.dist = mean(lat.distance),
              sd.lat.dist = sd(lat.distance),
              cv.lat.dist = sd.lat.dist/mean.lat.dist,
              mean.dist = mean(distance),
              sd.dist = sd(distance),
              cv.dist = sd.dist/mean.dist,
              mean.age = mean(obs),
              sd.age = sd(obs),
              cv.age = sd.age/mean.age)# %>%
    #select(rel_est, mean.north.perc, sd.north.perc, mean.south.perc, sd.south.perc)
  
  write_csv(estuary.summary, paste0(file.path, "/output/", species[i], "_direction_contribution_summary_total.csv"))
  
  state.summary <- settled %>%
    group_by(rel_est, season) %>%
    mutate(qld.contribution = length(which(lat > state_border)),
           nsw.contribution = length(which(lat < state_border)),
           qld.cont.perc = qld.contribution/n()*100,
           nsw.cont.perc = nsw.contribution/n()*100) %>%
    ungroup() %>%
    group_by(rel_est) %>%
    arrange(desc(lat)) %>%
    summarise(mean.qld.perc = mean(qld.cont.perc),
              sd.qld.perc = sd(qld.cont.perc),
              cv.qld.perc = sd.qld.perc/mean.qld.perc,
              mean.nsw.perc = mean(nsw.cont.perc),
              sd.nsw.perc = sd(nsw.cont.perc),
              cv.nsw.perc = sd.nsw.perc/mean.nsw.perc,
              mean.lat.dist = mean(lat.distance),
              sd.lat.dist = sd(lat.distance),
              cv.lat.dist = sd.lat.dist/mean.lat.dist,
              mean.dist = mean(distance),
              sd.dist = sd(distance),
              cv.dist = sd.dist/mean.dist,
              mean.age = mean(obs),
              sd.age = sd(obs),
              cv.age = sd.age/mean.age) #%>%
    #select(rel_est, mean.qld.perc, sd.qld.perc, mean.nsw.perc, sd.nsw.perc)
  
  write_csv(state.summary, paste0(file.path, "/output/", species[i], "_state_contribution_summary_total.csv"))
  
  separation.summary <- settled %>%
    group_by(rel_est, season) %>%
    mutate(north.sep.contribution = length(which(lat > separation_north)),
           south.sep.contribution = length(which(lat < separation_south)),
           within.sep.contribution = length(which(lat > separation_south & lat < separation_north)),
           north.sep.cont.perc = north.sep.contribution/n()*100,
           south.sep.cont.perc = south.sep.contribution/n()*100,
           within.sep.cont.perc = within.sep.contribution/n()*100) %>%
    ungroup() %>%
    group_by(rel_est) %>%
    arrange(desc(lat)) %>%
    summarise(mean.north.sep.perc = mean(north.sep.cont.perc),
              sd.north.sep.perc = sd(north.sep.cont.perc),
              cv.north.sep.perc = sd.north.sep.perc/mean.north.sep.perc,
              mean.south.sep.perc = mean(south.sep.cont.perc),
              sd.south.sep.perc = sd(south.sep.cont.perc),
              cv.south.sep.perc = sd.south.sep.perc/mean.south.sep.perc,
              mean.within.sep.perc = mean(within.sep.cont.perc),
              sd.within.sep.perc = sd(within.sep.cont.perc),
              cv.within.sep.perc = sd.within.sep.perc/mean.within.sep.perc,
              mean.lat.dist = mean(lat.distance),
              sd.lat.dist = sd(lat.distance),
              cv.lat.dist = sd.lat.dist/mean.lat.dist,
              mean.dist = mean(distance),
              sd.dist = sd(distance),
              cv.dist = sd.dist/mean.dist,
              mean.age = mean(obs),
              sd.age = sd(obs),
              cv.age = sd.age/mean.age) #%>%
    #select(rel_est, mean.north.sep.perc, sd.north.sep.perc, mean.within.sep.perc, sd.within.sep.perc, mean.south.sep.perc, sd.south.sep.perc)
  
  write_csv(separation.summary, paste0(file.path, "/output/", species[i], "_separation_contribution_summary_total.csv"))
  
  print(species[i])
  print("settled")
  print(nrow(settled))
  print("final")
  print(nrow(final))
  
}

