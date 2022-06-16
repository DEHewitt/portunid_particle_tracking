# Figure 1 - Map
# Want 2 parts, a map of zones and example of oceanography

library(tidyverse)
library(rnaturalearth)
library(rnaturalearthdata)
library(shadowtext)
library(raster)

zones <- read_csv("Spanner Crab Zones.csv")
zones <- read_csv("C:/Users/Dan/Downloads/Spanner Crab Zones.csv")
states <- read_csv("C:/Users/Dan/Downloads/state_labels.csv")

world <- ne_states(country = 'australia', returnclass = "sf")
class(world)

#lakes
#reefs10 <- ne_download(scale = 10, type = 'reefs', category = 'physical', returnclass = "sf")
islands10 <- ne_download(scale = 10, type = 'minor_islands', category = 'physical', returnclass = "sf")
#ocean10 <- ne_download(scale = 10, type = 'OB_LR', category = 'raster') # Ocean relief and depth composite
ocean10 <- raster("C:/Users/Dan/Downloads/OB_LR/OB_LR.tif")
oceandf <- raster::as.data.frame(ocean10, xy=T)
oceandf <- oceandf %>% filter(y < -21 & x >150) %>% filter(y> -31 & x < 157)
ocean_bath10 <- ne_download(scale = 10, type = 'bathymetry_K_200', category = 'physical', returnclass = "sf") # 200m bathymetry contour

#sub_dat <- all_small_2013 %>%  sample_n(10000) # group_by(ocean_zone) %>%
p1 <- ggplot() +  
  geom_tile(data=oceandf, aes(x=x, y=y, fill=OB_LR))+
  geom_hline(data=zones, aes(yintercept =latitude))+
  geom_sf(data=world, col="grey70", fill = "grey80", inherit.aes = FALSE) +
  geom_sf(data=ocean_bath10, col="black", fill = NA, inherit.aes = FALSE,linetype ="dashed", size=1.01)+
  #geom_sf(data=reefs10, col="grey70", fill = "blue", inherit.aes = FALSE)+
  geom_sf(data=islands10, col="grey70", fill = "grey80", inherit.aes = FALSE)+
  coord_sf(xlim = c(150, 156), ylim = c(-30, -22), expand = FALSE)+
  theme_classic() + ylab("Latitude") + xlab("Longitude")+
  geom_shadowtext(data=zones, aes(x=155, y=latitude-0.3, label=Zone)) +
  geom_shadowtext(data = states, aes(x = 151.5, y = lat, label = state.abbreviation)) + # dodgy labelling of states here
  #scale_fill_continuous(guide=F)+
  scale_fill_viridis_c(guide=F, option="mako")+
  theme(axis.title = element_text(face="bold", size = 12),
        axis.ticks = element_line(colour="black"),
        axis.text.y = element_text(colour="black", size=10),
        axis.text.x = element_text(colour="black", size=10, angle=45, vjust=0.6),
        panel.border = element_rect(fill=NA, colour="black")) 

p1
#ggsave("Figure 1.png", dpi=600, units="cm", width=15)
                                                            

###Panel 2 - SST and Velocity 
library(tidync)
library(lubridate)
library(metR)
temp <- tidync("C:/Users/Dan/Downloads/OneDrive_1_11-29-2021/Ocean_temp_1993_01.nc") %>% hyper_filter(st_ocean  = st_ocean  == 2.5) %>%
  hyper_tibble() %>% mutate(Time = as.Date(Time, origin="1979-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>%
  filter(Day == 1 & Month ==1) %>%
  filter(xt_ocean >150 & yt_ocean>-31 & xt_ocean <157 & yt_ocean < -21)
u_dat <- tidync("C:/Users/Dan/Downloads/OneDrive_1_11-29-2021/Ocean_u_1993_01.nc") %>% hyper_filter(st_ocean  = st_ocean  == 2.5) %>%
  hyper_tibble() %>% mutate(Time = as.Date(Time, origin="1979-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>%
  filter(Day == 1 & Month ==1) %>%
  filter(xu_ocean >150 & yu_ocean>-31 & xu_ocean <157 & yu_ocean < -21)
v_dat <- tidync("C:/Users/Dan/Downloads/OneDrive_1_11-29-2021/Ocean_v_1993_01.nc") %>% hyper_filter(st_ocean  = st_ocean  == 2.5) %>%
  hyper_tibble() %>% mutate(Time = as.Date(Time, origin="1979-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>%
  filter(Day == 1 & Month ==1) %>%
  filter(xu_ocean >150 & yu_ocean>-31 & xu_ocean <157 & yu_ocean < -21)

full_dat <- left_join(u_dat, v_dat)

p2 <- ggplot(full_dat)+ geom_tile(data=temp, aes(x=xt_ocean, y=yt_ocean, fill=temp))+
  geom_sf(data=world, col="grey70", fill = "grey80", inherit.aes = FALSE)+
  geom_sf(data=islands10, col="grey70", fill = "grey80", inherit.aes = FALSE)+
  geom_vector(data=full_dat, aes(x= xu_ocean, y= yu_ocean, angle = atan2(dlat(v), dlon(u, yu_ocean))*180/pi, mag = Mag(v, u)),
              skip = 2, pivot = 0.5, size=.4) + #
  scale_mag(name="Velocity\n(m/s)", max=1.5)+
  scale_x_continuous(breaks = seq(151,160,1))+
  coord_sf(xlim = c(150, 156), ylim = c(-30, -22), expand = FALSE)+
  scale_fill_viridis_c(option="magma", name = "Temperature (°C)")+
  theme_classic()+ ylab(NULL) + xlab("Longitude")+
  theme(rect = element_blank(),
        axis.title = element_text(face="bold", size = 12),
        axis.ticks = element_line(colour="black"),
        axis.text.x = element_text(colour="black", size=10, angle=45, vjust=0.6),
        axis.text.y = element_blank(),
        legend.title = element_text(face="bold", size=12),
        legend.position = c(0.25,0.41),
        legend.text = element_text(size=10),
        legend.background = element_blank(),
        legend.key = element_blank(),
        legend.key.height = unit(1.15, "cm"),
        panel.border = element_rect(fill=NA, colour="black"))+
  guides(color = guide_colourbar(order = 2),
         fill = guide_colourbar(order = 2),
         mag = guide_vector(order=1, title.vjust = -5))
p2


library(patchwork)
p1+p2+ plot_annotation(tag_levels = 'a')
#ggsave("Figure 1.png", dpi = 600, units = "cm", width=21, height=14.8)


### Make inset map

p3 <- ggplot()+
  geom_sf(data=world, col="grey50", fill = "grey50", inherit.aes = FALSE)+
  coord_sf(xlim = c(110, 158), ylim = c(-45, -7), expand = FALSE) +
  geom_rect(aes(xmin=150, xmax=156, ymin=-30, ymax=-22), fill=NA, col="black")+
  theme_classic() + labs(x=NULL, y= NULL)+
  theme(axis.text = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        rect=element_blank(),
        axis.line = element_blank(),
        axis.ticks = element_blank())
p3


### INSET MAP CODE
F1 <- p2 + inset_element(p3, 
  left = 0.7, right = 1, # this took some fiddling
  bottom = 0.7, top = 1
)
p1 + F1 +  plot_annotation(tag_levels = list(c('a','b','')))
ggsave("C:/Users/Dan/Documents/PhD/Misc/Figure 1.png", dpi = 600, units = "cm", width=21, height=14.8)
ggsave("Figure 1.pdf", dpi = 600, units = "cm", width=21, height=14.8)
