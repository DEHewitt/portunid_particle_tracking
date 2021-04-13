library(tidync)
library(tidyverse)
library(ggplot2)
library(rnaturalearth)
library(sf)

# Load the ozroms bathymetry data
bathy <- tidync("C:/Users/Dan/Documents/PhD/Dispersal/data_raw/bathymetry.nc") %>% hyper_tibble()
oz <- ne_states(country = "australia", returnclass = "sf")

head(bathy)
range(bathy$h)

# plot it to see what it looks like
ggplot() +
  geom_point(data = bathy,
             aes(x = lon,
                 y = lat,
                 colour = h))

# having an issue with some particles being released on land
# first subset bathy by selecting only cells that have a velocity
# this requires loading a velocity file, because those values
# are stored separate to the bathymetry data

# load a velocities file
vel.file <- hyper_tibble("C:/Users/Dan/Documents/PhD/Dispersal/data_raw/ozroms/20150101.nc")
# select the non-NaN velocity cells (i.e. the ones that are in the ocean)
vel.file <- vel.file %>%
  filter(u != is.nan(u))
# use that to select from the bathy file
lon <- unique(vel.file$lon)
shelf <- data.frame()
for (i in 1:length(lon)){
  temp <- bathy %>% filter(lon == lon[i])
  shelf <- bind_rows(shelf, temp)
}

shelf <- shelf %>% 
  # first pass at selecting the shelf
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
  scale_y_continuous(breaks = seq(-15, -38, -1)) +
  geom_sf(data = oz) +
  coord_sf(xlim = c(142, 154), ylim = c(-38, -15))
  

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
