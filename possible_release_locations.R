library(tidync)
library(tidyverse)
library(ggplot2)

# Load the ozroms bathymetry data
bathy <- tidync("C:/Users/Dan/Documents/PhD/Dispersal/data_raw/bathymetry.nc") %>% hyper_tibble()

head(bathy)
range(bathy$h)

# plot it to see what it looks like
ggplot() +
  geom_point(data = bathy,
             aes(x = lon,
                 y = lat,
                 colour = h))

shelf <- bathy %>% 
  filter(h < 200 & h > 15) %>%
  # remove shallow areas that aren't on the shelf
  filter(lon < 155) %>%
  filter(!lon > 149.5 | !lat > -18) %>%
  filter(!lon > 151.5 | !lat > -20) %>%
  filter(!lon > 153.5 | !lat > -22.5)

# plot to see how it looks
ggplot() +
  geom_point(data = shelf,
             aes(x = lon,
                 y = lat,
                 colour = h)) +
  scale_x_continuous(breaks = seq(145, 155, 1)) +
  scale_y_continuous(breaks = seq(-15, -38, -1))

# set up the ocean_zone column
ocean_zones <- data.frame(max_lat = seq(-15, -37, by = -1), min_lat = seq(-16, -38, by = -1))
ocean_zones <- ocean_zones %>%
  #mutate(state = if_else(min_lat < -28, "NSW", "QLD")) %>%
  #group_by(state) %>%
  mutate(zone_number = row_number()) %>%
  ungroup() %>%
  mutate(ocean_zone = zone_number) %>%
  select(max_lat, min_lat, ocean_zone)

# gmc
gmc.locations <- shelf %>%
  mutate(max_lat = as.numeric(substr(lat, 1, 3))) %>%
  left_join(ocean_zones) %>%
  select(lon, lat, ocean_zone) %>%
  filter(lat > -34)

ggplot() +
  geom_point(data = gmc.locations,
             aes(x = lon,
                 y = lat))

write_csv(gmc.locations, "C:/Users/Dan/Documents/PhD/Dispersal/data_processed/gmc_possible_locations.csv")
write_csv(gmc.locations, "C:/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking/Simulations/gmc_possible_locations.csv")

# bsc
bsc.locations <- shelf %>%
  mutate(max_lat = as.numeric(substr(lat, 1, 3))) %>%
  left_join(ocean_zones) %>%
  select(lon, lat, ocean_zone) %>%
  filter(lat > -35 & lat < -23)

ggplot() +
  geom_point(data = bsc.locations,
             aes(x = lon,
                 y = lat))

write_csv(bsc.locations, "C:/Users/Dan/Documents/PhD/Dispersal/data_processed/bsc_possible_locations.csv")
write_csv(bsc.locations, "C:/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking/Simulations/bsc_possible_locations.csv")
