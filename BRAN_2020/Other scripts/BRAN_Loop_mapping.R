### BRAN MAPPING LOOP

# BRAN Output plotting test

setwd("C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN_2020/")

library(tidyverse)
library(tidync)
library(lubridate)
library(metR)

u_files <- list.files("Aus/", pattern="Ocean_u_", full.names = T)
v_files <- list.files("Aus/", pattern="Ocean_v_", full.names = T)
temp_files <- list.files("Aus/", pattern="Ocean_temp_", full.names = T)

library("rnaturalearth")
library("rnaturalearthdata")

world <- ne_countries(country = 'australia',scale = "large", returnclass = "sf")
class(world)

#x <- ncmeta::nc_atts("AUS/Ocean_u_1994_01.nc", "Time")
#x$value[2]

for (i in (1:length(u_files))) {
  dat1 <- tidync(u_files[i]) %>% hyper_filter(st_ocean  = st_ocean  == 2.5) %>%
  hyper_tibble() %>% mutate(Time = as.Date(Time, origin="1979-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>% 
  group_by(Month,xu_ocean ,yu_ocean ) %>% summarise(across(where(is.double),~ mean(.x, na.rm = TRUE))) %>%
  filter(xu_ocean >143 & yu_ocean>-35)
#head(dat1)
#range(dat1$Time)

dat2 <- tidync(v_files[i]) %>% hyper_filter(st_ocean  = st_ocean  == 2.5) %>%
  hyper_tibble() %>% mutate(Time = as.Date(Time, origin="1979-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>% 
  group_by(Month,xu_ocean ,yu_ocean ) %>% summarise(across(where(is.double),~ mean(.x, na.rm = TRUE))) %>%
  filter(xu_ocean >143 & yu_ocean>-35)
#head(dat2)

dat3 <- tidync(temp_files[i]) %>% hyper_filter(st_ocean  = st_ocean  == 2.5) %>%
  hyper_tibble() %>% mutate(Time = as.Date(Time, origin="1979-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>% 
  group_by(Month,xt_ocean ,yt_ocean ) %>% summarise(across(where(is.double),~ mean(.x, na.rm = TRUE))) %>%
  filter(xt_ocean >143 & yt_ocean>-35)
#head(dat3)
#range(dat3$Time)

full_dat <- left_join(dat1, dat2)
#head(full_dat)

# ggplot(full_dat, aes(x=xu_ocean, y=yu_ocean)) +
#   geom_tile(data=dat3, aes(x=xt_ocean, y=yt_ocean, col=temp, fill=temp))+
#   geom_vector(aes(angle = atan2(dlat(v), dlon(u, yu_ocean))*180/pi,
#                   mag = Mag(v, u)), skip = 3, pivot = 0.5, size=0.1) +
#   scale_mag() +coord_quickmap()+
#   scale_colour_viridis_c() + scale_fill_viridis_c()
# ggsave("Output/Test_map.pdf", units="cm", height=21, width=14.8) 


### Load Australia 


ggplot(full_dat, aes(x=xu_ocean, y=yu_ocean)) +
  geom_tile(data=dat3, aes(x=xt_ocean, y=yt_ocean, col=temp, fill=temp))+
  geom_sf(data=world, col="grey70", fill = "grey80", inherit.aes = FALSE)+
  geom_vector(aes(angle = atan2(dlat(v), dlon(u, yu_ocean))*180/pi,
                  mag = Mag(v, u)), skip = 3, pivot = 0.5, size=0.1) +
  scale_mag(name="Velcocity\n(m/s)", max=1.5) +coord_sf(xlim = c(143, max(dat3$xt_ocean)), ylim = c(-35, -10), expand = FALSE)+
  scale_colour_viridis_c(name="Temperature (°C)", option="inferno") + scale_fill_viridis_c(name="Temperature (°C)", option="inferno") +
  labs(x="Longitude", y="Latitude")+ theme(axis.text = element_text(colour = "black", size=12),
                                           axis.title = element_text(face="bold", size = 14),
                                           legend.title = element_text(face="bold", size=12),
                                           legend.position = c(0.15,0.33),
                                           legend.text = element_text(size=10),
                                           legend.background = element_blank(),
                                           legend.key = element_blank(),
                                           legend.key.height = unit(1.3, "cm"))+
  guides(color = guide_colourbar(order = 2),
         fill = guide_colourbar(order = 2),
         mag = guide_vector(order=1, title.vjust = -5)) +
  ggtitle(paste0(full_dat$Month[1],"/",full_dat$Year[1]))
ggsave(paste0("Output/", full_dat$Month[1],"_",full_dat$Year[1],".pdf"), units="cm", height=21, width=14.8) 

}
