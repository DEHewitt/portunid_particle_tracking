### BRAN MAPPING LOOP

# BRAN Output plotting test

setwd("C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN_2020/")

library(tidyverse)
library(tidync)
library(lubridate)
library(metR)

library(stringr)

u_files <- list.files("Aus/", pattern="Ocean_u_", full.names = T)
u_files_1 <- str_extract(u_files, pattern=".+_02.nc") %>% na.omit() # Feb files only
u_files_2 <- str_extract(u_files, pattern=".+_03.nc") %>% na.omit() # March files only

v_files <- list.files("Aus/", pattern="Ocean_v_", full.names = T)
v_files_1 <- str_extract(v_files, pattern=".+_02.nc") %>% na.omit() # Feb files only
v_files_2 <- str_extract(v_files, pattern=".+_03.nc") %>% na.omit() # March files only

temp_files <- list.files("Aus/", pattern="Ocean_temp_", full.names = T)
temp_files_1 <- str_extract(temp_files, pattern=".+_02.nc") %>% na.omit() # Feb files only
temp_files_2 <- str_extract(temp_files, pattern=".+_03.nc") %>% na.omit() # March files only

library("rnaturalearth")
library("rnaturalearthdata")

world <- ne_countries(country = 'australia',scale = "large", returnclass = "sf")
class(world)

#x <- ncmeta::nc_atts("AUS/Ocean_u_1994_01.nc", "Time")
#x$value[2]

for (i in (1:length(u_files_1))) {
  dat1a <- tidync(u_files_1[i]) %>% hyper_filter(st_ocean  = st_ocean  == 2.5) %>%
  hyper_tibble() %>% mutate(Time = as.Date(Time, origin="1979-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>% 
  group_by(Month,xu_ocean ,yu_ocean ) %>% summarise(across(where(is.double),~ mean(.x, na.rm = TRUE))) %>%
  filter(xu_ocean >150 & yu_ocean>-31 & xu_ocean <160 & yu_ocean < -20)
  
  dat1b <- tidync(u_files_2[i]) %>% hyper_filter(st_ocean  = st_ocean  == 2.5) %>%
    hyper_tibble() %>% mutate(Time = as.Date(Time, origin="1979-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>% 
    group_by(Month,xu_ocean ,yu_ocean ) %>% summarise(across(where(is.double),~ mean(.x, na.rm = TRUE))) %>%
    filter(xu_ocean >150 & yu_ocean>-31 & xu_ocean <160 & yu_ocean < -20)
  
  dat1 <- bind_rows(dat1a, dat1b)
  dat1 <- dat1 %>% group_by(xu_ocean ,yu_ocean) %>% summarise(across(where(is.double),~ mean(.x, na.rm = TRUE)))
#head(dat1)
#range(dat1$Time)

dat2a <- tidync(v_files_1[i]) %>% hyper_filter(st_ocean  = st_ocean  == 2.5) %>%
  hyper_tibble() %>% mutate(Time = as.Date(Time, origin="1979-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>% 
  group_by(Month,xu_ocean ,yu_ocean ) %>% summarise(across(where(is.double),~ mean(.x, na.rm = TRUE))) %>%
  filter(xu_ocean >150 & yu_ocean>-31 & xu_ocean <160 & yu_ocean < -20)

dat2b <- tidync(v_files_2[i]) %>% hyper_filter(st_ocean  = st_ocean  == 2.5) %>%
  hyper_tibble() %>% mutate(Time = as.Date(Time, origin="1979-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>% 
  group_by(Month,xu_ocean ,yu_ocean ) %>% summarise(across(where(is.double),~ mean(.x, na.rm = TRUE))) %>%
  filter(xu_ocean >150 & yu_ocean>-31 & xu_ocean <160 & yu_ocean < -20)

dat2 <- bind_rows(dat2a, dat2b)
dat2 <- dat2 %>% group_by(xu_ocean ,yu_ocean) %>% summarise(across(where(is.double),~ mean(.x, na.rm = TRUE)))
#head(dat2)

dat3a <- tidync(temp_files_1[i]) %>% hyper_filter(st_ocean  = st_ocean  == 2.5) %>%
  hyper_tibble() %>% mutate(Time = as.Date(Time, origin="1979-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>% 
  group_by(Month,xt_ocean ,yt_ocean ) %>% summarise(across(where(is.double),~ mean(.x, na.rm = TRUE))) %>%
  filter(xt_ocean >150 & yt_ocean>-31 & xt_ocean <160 & yt_ocean < -20)

dat3b <- tidync(temp_files_2[i]) %>% hyper_filter(st_ocean  = st_ocean  == 2.5) %>%
  hyper_tibble() %>% mutate(Time = as.Date(Time, origin="1979-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>% 
  group_by(Month,xt_ocean ,yt_ocean ) %>% summarise(across(where(is.double),~ mean(.x, na.rm = TRUE))) %>%
  filter(xt_ocean >150 & yt_ocean>-31 & xt_ocean <160 & yt_ocean < -20)

dat3 <- bind_rows(dat3a, dat3b)
dat3 <- dat3 %>% group_by(xt_ocean ,yt_ocean) %>% summarise(across(where(is.double),~ mean(.x, na.rm = TRUE)))
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
                  mag = Mag(v, u)), skip = 2, pivot = 0.5, size=.4) + #
  scale_mag(name="Velocity\n(m/s)", max=1.5) +coord_sf(xlim = c(150, max(dat3$xt_ocean)), ylim = c(-31, -20), expand = FALSE)+
  scale_colour_viridis_c(name="Temperature (?C)", option="inferno", limits=c(23,29)) + 
  scale_fill_viridis_c(name="Temperature (?C)", option="inferno", limits=c(23,29)) +
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
ggsave(paste0("Output/Smaller/", full_dat$Month[1],"_",full_dat$Year[1],".pdf"), units="cm", height=21, width=14.8) 

}
