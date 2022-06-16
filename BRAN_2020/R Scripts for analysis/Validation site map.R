### Validation Map
library(tidyverse)

pp <- list()

pp[[1]] <- data.frame("lon"=153.3950, "lat"= -30.26683, "label" = "Coffs100") # Coffs 100
pp[[2]] <- data.frame("lon"=153.5602, "lat"= -27.34356, "label" = "NRS NS") # NRS NS
pp[[3]] <- data.frame("lon"=153.3004, "lat"= -30.27487, "label" = "Coffs70") # Coffs 70
pp[[4]] <- data.frame("lon"=153.7748, "lat"= -27.33998, "label" = "SEQ200") # SEQ 200
pp[[5]] <- data.frame("lon"=153.8765, "lat"= -27.33185, "label" = "SEQ400") # SEQ 400
pp[[6]] <- data.frame("lon"=154.0017, "lat"= -27.31750, "label" = "EAC2000") # EAC 2000
pp[[7]] <- data.frame("lon"=154.1301, "lat"= -27.28394, "label" = "EAC3200") # EAC 3200
pp[[8]] <- data.frame("lon"=154.2910, "lat"= -27.23910, "label" = "EAC4200") # EAC 4200
pp[[9]] <- data.frame("lon"=154.6450, "lat"= -27.20889, "label" = "EAC4700") # EAC 4700
pp[[10]] <- data.frame("lon"=151.9548, "lat"= -23.51352, "label" = "GBR HIS") # GBR HIS
pp[[11]] <- data.frame("lon"=151.9871, "lat"= -23.38022, "label" = "GBR HIN") # GBR HIN
pp[[12]] <- data.frame("lon"=152.1753, "lat"= -23.48162, "label" = "GBR OTE") # GBR OTE
pp[[13]] <- data.frame("lon"=151.9933, "lat"= -22.40812, "label" = "GBR CHH") # GBR CHH
pp[[14]] <- data.frame("lon"=153.2290995, "lat"= -30.31047359, "label" = "Coffs50") # Coffs 50

pp <- bind_rows(pp)



library(tidyverse)
library(rnaturalearth)
library(rnaturalearthdata)
library(shadowtext)
library(ggrepel)

zones <- read_csv("Spanner Crab Zones.csv")

world <- ne_countries(country = 'australia',scale = "large", returnclass = "sf")
class(world)

#lakes
#reefs10 <- ne_download(scale = 10, type = 'reefs', category = 'physical', returnclass = "sf")
islands10 <- ne_download(scale = 10, type = 'minor_islands', category = 'physical', returnclass = "sf")
#ocean10 <- ne_download(scale = 10, type = 'OB_LR', category = 'raster') # Ocean relief and depth composite
#oceandf <- raster::as.data.frame(ocean10, xy=T)
#oceandf <- oceandf %>% filter(y < -21 & x >150) %>% filter(y> -31 & x < 157)
ocean_bath10 <- ne_download(scale = 10, type = 'bathymetry_K_200', category = 'physical', returnclass = "sf") # 200m bathymetry contour

#sub_dat <- all_small_2013 %>%  sample_n(10000) # group_by(ocean_zone) %>%
p1 <- ggplot() +  
  #geom_tile(data=oceandf, aes(x=x, y=y, fill=OB_LR))+
  #geom_hline(data=zones, aes(yintercept =latitude))+
  geom_sf(data=world, col="grey70", fill = "grey80", inherit.aes = FALSE)+
  #geom_sf(data=ocean_bath10, col="black", fill = NA, inherit.aes = FALSE,linetype ="dashed", size=1.01)+
  #geom_sf(data=reefs10, col="grey70", fill = "blue", inherit.aes = FALSE)+
  geom_sf(data=islands10, col="grey70", fill = "grey80", inherit.aes = FALSE)+
  coord_sf(xlim = c(150, 156), ylim = c(-31, -22), expand = FALSE)+
  theme_classic() + ylab("Latitude") + xlab("Longitude")+
  geom_point(data=pp, aes(x=lon, y=lat), col="red")+
  geom_text_repel(data=pp, aes(x=lon, y=lat, label=label), max.overlaps = 20)+
  #geom_shadowtext(data=zones, aes(x=155, y=latitude-0.3, label=Zone)) +
  #scale_fill_continuous(guide=F)+
  scale_fill_viridis_c(guide=F, option="mako")+
  theme(axis.title = element_text(face="bold", size = 12),
        axis.ticks = element_line(colour="black"),
        axis.text.y = element_text(colour="black", size=10),
        axis.text.x = element_text(colour="black", size=10, angle=45, vjust=0.6),
        panel.border = element_rect(fill=NA, colour="black"))

p1

ggsave("BRAN Mooring Validation map.png", dpi=600, height=21, width=14.8, units="cm")
ggsave("BRAN Mooring Validation map.pdf", dpi=600, height=21, width = 14.8, units="cm")
