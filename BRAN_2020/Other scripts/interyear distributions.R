# Spanner Crab Output

library(tidyverse)

setwd("C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN_2020/")

mydata_shelf <- readRDS("Output/spanner_forwards_master_settled.rds")

mydata_shelf$age <- mydata_shelf$age/86400
mydata_shelf$Year <- lubridate::year(mydata_shelf$rel_date)
mydata_shelf$Month <- lubridate::month(mydata_shelf$rel_date)

mydata_shelf <- mydata_shelf %>% mutate(spawning_year = case_when(Month < 6 ~ Year -1, # identifies year the spawning season begins
                                                      TRUE ~ Year)) %>% 
  filter(bathy <=200 & Month != 3 & Month !=2) %>% filter(spawning_year != 2019)# %>% filter(Month != 1)

mydata_all <- readRDS("Dist_plots/spanner_forwards_master_final.rds")
mydata_all$age <- mydata_all$age/86400
mydata_all$Year <- lubridate::year(mydata_all$rel_date)
mydata_all$Month <- lubridate::month(mydata_all$rel_date)

mydata_all <- mydata_all %>% mutate(spawning_year = case_when(Month < 6 ~ Year -1, # identifies year the spawning season begins
                                                                  TRUE ~ Year)) %>% 
  filter(Month != 3 & Month !=2) %>% filter(spawning_year != 2019)# %>% filter(Month != 1)

table(mydata_all$Month)


all_small_2013 <- mydata_all %>% filter(spawning_year == 2012 & Month ==12)
all_small_2011 <- mydata_all %>% filter(spawning_year == 2003 & Month ==12)
all_small <- bind_rows(all_small_2013, all_small_2011)

library("rnaturalearth")
library("rnaturalearthdata")

world <- ne_countries(country = 'australia',scale = "large", returnclass = "sf")
class(world)

#sub_dat <- all_small_2013 %>%  sample_n(10000) # group_by(ocean_zone) %>%
ggplot(all_small, aes(lon, lat)) +  facet_wrap(~spawning_year)+
  geom_sf(data=world, col="grey70", fill = "grey80", inherit.aes = FALSE)+
  coord_sf(xlim = c(147, 156), ylim = c(-30, -22), expand = FALSE)+
  scale_color_discrete(name="Release\nZone")+
  geom_point(alpha=0.03) + theme_classic()

