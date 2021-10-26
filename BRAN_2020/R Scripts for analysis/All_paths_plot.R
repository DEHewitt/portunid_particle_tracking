# Katana Plot all paths

library(tidyverse)
mydata <- readRDS("/srv/scratch/z3374139/portunid_particle_tracking/spanner/forwards/full_paths/All_together_now_paths.rds")
head(mydata)

mydata2 <- mydata %>% distinct_all()

dat <- mydata2 %>% group_by(ParticleID) %>% filter(obs == max(obs)) %>%
  mutate(zone7_landed = case_when(((shelf == "Success" & lat >= -29.428612 & lat <= -28.1643) ~ "zone 7 landed"),
                                  TRUE ~ shelf)) %>%
  filter(zone7_landed == "zone 7 landed")

head(dat)

mydata2 <- mydata2 %>% mutate(zone7_landed = case_when(ParticleID %in% dat$zone7_landed ~ "NSW GOOD",
                                                       TRUE ~ shelf))

head(dat)
#hist(dat$DD_max)

small <- mydata2 %>% group_by(zone7_landed) %>% slice_sample(n = 10000) %>% distinct(ParticleID)
small2 <- mydata2 %>% filter(ParticleID %in% small$ParticleID)

write_csv(small2, "Many paths small.csv")

# 
# library("rnaturalearth")
# library("rnaturalearthdata")
# 
# 
# world <- ne_countries(country = 'australia',scale = "large", returnclass = "sf")
# 
# ggplot(mydata, aes(x=lon, y=lat, group=ParticleID)) + geom_path(alpha=0.02) + 
#   facet_wrap(~Region7) +
#   geom_sf(data=world, col="grey80", fill = "grey80", inherit.aes = FALSE)+
#   coord_sf()
# 
# 
# ggsave("BRAN All Paths subset.png", dpi = 600, width = 14.8, height=21, units="cm")