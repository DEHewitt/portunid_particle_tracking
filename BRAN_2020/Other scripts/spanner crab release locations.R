# BRAN Bathymetry

library(tidync)
library(tidyverse)

grid_identifier <- "D3,D2"
#tidync(filename) %>% activate(grid_identifier)

mydata <- tidync("C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN/AUS/grid_spec.nc") %>% activate(grid_identifier) %>%
  hyper_tibble() %>% rename(lon = grid_x_T, lat = grid_y_T)


ggplot(mydata, aes(x=lon, y = lat, fill= depth_t)) + geom_tile() + coord_quickmap()


mydata2 <- mydata %>% 
  # first pass at selecting the shelf
  filter(depth_t < 200 & depth_t > 15) %>%
  # remove shallow areas that aren't on the shelf
  filter(lon < 155) %>%
  filter(!lon > 149.5 | !lat > -18) %>%
  filter(!lon > 151.5 | !lat > -20) %>%
  filter(!lon > 153.5 | !lat > -22.5)

# plot to see how it looks
ggplot() +
  geom_point(data = mydata2,
             aes(x = lon,
                 y = lat,
                 colour = depth_t)) +
  scale_x_continuous(breaks = seq(145, 155, 1)) +
  scale_y_continuous(breaks = seq(-15, -38, -1)) +
 # geom_sf(data = oz) +
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

spanner.locations <- mydata2 %>%
  filter(lat > -29.428612 & lat < -23) %>%
  #filter(h < 100 & h > 15) %>%
  mutate(ocean_zone = if_else(lat < -23 & lat > -24, 2,
                              if_else(lat < -24 & lat > -25, 3,
                                      if_else(lat < -25 & lat > -26.5, 4,
                                              if_else(lat < -26.5 & lat > -27.5, 5,
                                                      if_else(lat < -27.5 & lat > -28.1643, 6,
                                                              if_else(lat < -28.1643 & lat > -29.428612, 7, 9999)))))))


# plot to see how it looks
ggplot() +
  geom_point(data = spanner.locations,
             aes(x = lon,
                 y = lat,
                 colour = depth_t)) +
  scale_x_continuous(breaks = seq(145, 155, 1)) +
  scale_y_continuous(breaks = seq(-15, -38, -1)) +
  # geom_sf(data = oz) +
  coord_sf(xlim = c(142, 154), ylim = c(-38, -15))

write_csv(spanner.locations, "C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN/AUS/spanner_possible_locations.csv")

hist(spanner.locations$depth_t)

spanner2 <- spanner.locations %>% select(!starts_with("ds"))
write_csv(spanner2, "C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN/AUS/spanner_possible_locations.csv")


### Now program starting depths
levels = c(2.5, 7.5, 12.5, 17.515390396118164, 22.667020797729492, 28.16938018798828, 34.2180061340332, 40.95497512817383,
           48.45497512817383, 56.7180061340332, 65.66938018798828, 75.16702270507812, 85.01538848876953, 95.0, 105.0, 115.0,
           125.0, 135.0, 145.0, 155.0, 165.0, 175.0, 185.0, 195.0, 205.1898956298828)

spanner2$starting_particle_depth <- 2.5

for (i in (1:nrow(spanner2))){
  for (j in levels){
    if (spanner2$depth_t[i] > j) {
      spanner2$starting_particle_depth[i] <- j
    }
  }
}

hist(spanner2$starting_particle_depth)
write_csv(spanner2, "C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN/AUS/spanner_possible_locations.csv")
summary(spanner2$depth_t)
