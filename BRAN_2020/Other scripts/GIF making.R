### Demonstration GIF

library(tidync)
library(tidyverse)

setwd("C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN_2020/Output/")
mydata <- tidync("spanner_1993_forward_2.nc") %>% hyper_tibble()
head(mydata)
n_distinct(mydata$trajectory)

single <- mydata %>% filter(trajectory == 114273) %>% arrange(time) %>% mutate(Time=as.Date(as.POSIXct(time, origin="1993-01-01"))) %>%
  slice_head(n=(nrow(single)-1))
 

library("rnaturalearth")
library("rnaturalearthdata")

world <- ne_states(country = 'australia', returnclass = "sf")
class(world)

#sub_dat <- all_small_2013 %>%  sample_n(10000) # group_by(ocean_zone) %>%
ggplot(single, aes(x=lon, y=lat)) +  #facet_wrap(~spawning_year)+
  geom_sf(data=world, col="grey70", fill = "grey80", inherit.aes = FALSE)+
  coord_sf(xlim = c(147, 156), ylim = c(-38, -22), expand = FALSE)+
  scale_color_discrete(name="Release\nZone")+
  geom_path() + theme_classic()

library(gganimate)

ggplot(single, aes(x=lon, y=lat)) +  #facet_wrap(~spawning_year)+
  geom_sf(data=world, col="grey70", fill = "grey80", inherit.aes = FALSE)+
  coord_sf(xlim = c(147, 158), ylim = c(-38, -22), expand = FALSE)+
  scale_color_discrete(name="Release\nZone")+
  geom_point() + theme_classic() + transition_time(Time) +
  labs(title = 'Date: {frame_time}')


# Get ocean data
library(lubridate)
temp1 <- tidync("../AUS/Ocean_temp_1994_01.nc") %>% hyper_filter(st_ocean  = st_ocean  == 2.5) %>%
  hyper_tibble() %>% mutate(Time = as.Date(Time, origin="1979-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>% 
  group_by(Month,xt_ocean ,yt_ocean ) %>% 
  filter(xt_ocean >150 & yt_ocean>-38 & xt_ocean <158 & yt_ocean < -22)
temp2 <- tidync("../AUS/Ocean_temp_1994_02.nc") %>% hyper_filter(st_ocean  = st_ocean  == 2.5) %>%
  hyper_tibble() %>% mutate(Time = as.Date(Time, origin="1979-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>% 
  group_by(Month,xt_ocean ,yt_ocean )  %>%
  filter(xt_ocean >150 & yt_ocean>-38 & xt_ocean <158 & yt_ocean < -22)
temp3 <- tidync("../AUS/Ocean_temp_1994_03.nc") %>% hyper_filter(st_ocean  = st_ocean  == 2.5) %>%
  hyper_tibble() %>% mutate(Time = as.Date(Time, origin="1979-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>% 
  group_by(Month,xt_ocean ,yt_ocean )  %>%
  filter(xt_ocean >150 & yt_ocean>-38 & xt_ocean <158 & yt_ocean < -22)
temp <- bind_rows(temp1, temp2,temp3)       


u1 <- tidync("../AUS/Ocean_u_1994_01.nc") %>% hyper_filter(st_ocean  = st_ocean  == 2.5) %>%
  hyper_tibble() %>% mutate(Time = as.Date(Time, origin="1979-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>% 
  group_by(Month,xu_ocean ,yu_ocean )  %>%
  filter(xu_ocean >150 & yu_ocean>-38 & xu_ocean <158 & yu_ocean < -22)
u2 <- tidync("../AUS/Ocean_u_1994_02.nc") %>% hyper_filter(st_ocean  = st_ocean  == 2.5) %>%
  hyper_tibble() %>% mutate(Time = as.Date(Time, origin="1979-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>% 
  group_by(Month,xu_ocean ,yu_ocean )  %>%
  filter(xu_ocean >150 & yu_ocean>-38 & xu_ocean <158 & yu_ocean < -22)
u3 <- tidync("../AUS/Ocean_u_1994_03.nc") %>% hyper_filter(st_ocean  = st_ocean  == 2.5) %>%
  hyper_tibble() %>% mutate(Time = as.Date(Time, origin="1979-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>% 
  group_by(Month,xu_ocean ,yu_ocean )  %>%
  filter(xu_ocean >150 & yu_ocean>-38 & xu_ocean <158 & yu_ocean < -22)
U_data <- bind_rows(u1, u2,u3)  

v1 <- tidync("../AUS/Ocean_v_1994_01.nc") %>% hyper_filter(st_ocean  = st_ocean  == 2.5) %>%
  hyper_tibble() %>% mutate(Time = as.Date(Time, origin="1979-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>% 
  group_by(Month,xu_ocean ,yu_ocean )  %>%
  filter(xu_ocean >150 & yu_ocean>-38 & xu_ocean <158 & yu_ocean < -22)
v2 <- tidync("../AUS/Ocean_v_1994_02.nc") %>% hyper_filter(st_ocean  = st_ocean  == 2.5) %>%
  hyper_tibble() %>% mutate(Time = as.Date(Time, origin="1979-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>% 
  group_by(Month,xu_ocean ,yu_ocean )  %>%
  filter(xu_ocean >150 & yu_ocean>-38 & xu_ocean <158 & yu_ocean < -22)
v3 <- tidync("../AUS/Ocean_v_1994_03.nc") %>% hyper_filter(st_ocean  = st_ocean  == 2.5) %>%
  hyper_tibble() %>% mutate(Time = as.Date(Time, origin="1979-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>% 
  group_by(Month,xu_ocean ,yu_ocean )  %>%
  filter(xu_ocean >150 & yu_ocean>-38 & xu_ocean <158 & yu_ocean < -22)
V_data <- bind_rows(v1, v2,v3) 

UV_data <- left_join(U_data, V_data)

library(metR)

#Animate
ggplot(temp, aes(x=xt_ocean, y=yt_ocean, fill=temp, col=temp)) +  #facet_wrap(~spawning_year)+
  geom_sf(data=world, col="grey70", fill = "grey80", inherit.aes = FALSE)+
  coord_sf(xlim = c(147, 158), ylim = c(-38, -22), expand = FALSE)+
  scale_color_viridis_c(option="turbo")+
  scale_fill_viridis_c(option="turbo")+
  geom_tile() + theme_classic() + transition_time(Time) +
  labs(title = 'Date: {frame_time}') + 
  theme(legend.position=c(0.1,0.5),
        axis.text = element_text(colour="black", size= 10))
anim_save("temp.gif", animation = last_animation())

# add points, need to have same times...
tempX <- temp %>% filter(Time >= min(single$Time)-1 & Time <= max(single$Time)+1)
UV_dataX <- UV_data %>% filter(Time >= min(single$Time)-1 & Time <= max(single$Time)+1)

# with vectors
ggplot(UV_dataX, aes(x=xu_ocean, y=yu_ocean)) +  #facet_wrap(~spawning_year)+
  geom_sf(data=world, col="grey70", fill = "grey80", inherit.aes = FALSE)+
  coord_sf(xlim = c(147, 158), ylim = c(-38, -22), expand = FALSE)+
  scale_color_viridis_c(option="turbo", name="Temperature")+
  scale_fill_viridis_c(option="turbo", name="Temperature")+
  geom_tile(data=tempX, aes(x=xt_ocean, y = yt_ocean, fill=temp, col=temp)) + theme_classic() + transition_time(Time) +
  labs(title = 'Date: {frame_time}', x="Longitude", y="Latitude") + 
  theme(legend.position=c(0.2,0.5),
        legend.title = element_text(face="bold", size=12),
        axis.title = element_text(size=12, face="bold"),
        axis.text = element_text(colour="black", size= 10),
        legend.text = element_text(size=10),
        legend.background = element_blank(),
        legend.key = element_blank(),
        legend.key.height = unit(1.3, "cm"),
        plot.title = element_text(face="bold"))+
  geom_vector(aes(angle = atan2(dlat(v), dlon(u, yu_ocean))*180/pi,
                  mag = Mag(v, u)), skip = 3, pivot = 0.5, size=.4) + #
  scale_mag(name="Velocity\n(m/s)", max=1.5)#+
  #geom_point(data=single, aes(x=lon, y=lat), col="white", fill="black", shape=21, size=3)
anim_save("temp with vectors.gif", animation = last_animation(), dpi=600)




ggplot(UV_dataX, aes(x=xu_ocean, y=yu_ocean)) +  #facet_wrap(~spawning_year)+
  geom_sf(data=world, col="grey70", fill = "grey80", inherit.aes = FALSE)+
  coord_sf(xlim = c(147, 158), ylim = c(-38, -22), expand = FALSE)+
  scale_color_viridis_c(option="turbo", name="Temperature")+
  scale_fill_viridis_c(option="turbo", name="Temperature")+
  geom_tile(data=tempX, aes(x=xt_ocean, y = yt_ocean, fill=temp, col=temp)) + theme_classic() + transition_time(Time) +
  labs(title = 'Date: {frame_time}', x="Longitude", y="Latitude") + 
  theme(legend.position=c(0.2,0.5),
        legend.title = element_text(face="bold", size=12),
        axis.title = element_text(size=12, face="bold"),
        axis.text = element_text(colour="black", size= 10),
        legend.text = element_text(size=10),
        legend.background = element_blank(),
        legend.key = element_blank(),
        legend.key.height = unit(1.3, "cm"),
        plot.title = element_text(face="bold"))+
  geom_vector(aes(angle = atan2(dlat(v), dlon(u, yu_ocean))*180/pi,
                  mag = Mag(v, u)), skip = 3, pivot = 0.5, size=.4) + #
  scale_mag(name="Velocity\n(m/s)", max=1.5)+
  geom_point(data=single, aes(x=lon, y=lat), col="white", fill="black", shape=21, size=3)
anim_save("temp with vectors and particle.gif", animation = last_animation(), res=600)
