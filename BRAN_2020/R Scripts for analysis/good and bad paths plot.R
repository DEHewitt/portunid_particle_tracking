library(tidyverse)

mydata <- read_csv("full_paths/Many paths small.csv", lazy = F)

# mydata <- mydata %>% mutate(Region7 = case_when(((shelf == "Success" & lat >= -29.428612 & lat <= -28.1643) ~ "zone 7 landed"),
#                                                 TRUE ~ shelf))
# -28.1643
# -29.428612
# 
table(mydata$zone7_landed)

mydata2 <- mydata %>% distinct_all()
# 
# dat <- mydata2 %>% group_by(ParticleID) %>% filter(obs == max(obs)) %>%
#   mutate(zone7_landed = case_when(((shelf == "Success" & lat >= -29.428612 & lat <= -28.1643) ~ "zone 7 landed"),
#                                   TRUE ~ shelf)) %>%
#   filter(zone7_landed == "zone 7 landed")
# 
# mydata2 <- mydata2 %>% mutate(zone7_landed = case_when(ParticleID %in% dat$zone7_landed ~ "NSW GOOD",
#                                                        TRUE ~ shelf))
# 


library("rnaturalearth")
library("rnaturalearthdata")

table(mydata$shelf, mydata$region)
table(mydata2$zone7_landed)


mydata2 <- mydata2 %>% mutate(zone7_landed = case_when(zone7_landed == "Fail" ~ "a) Failed Settlement",
                                                       zone7_landed == "Success" ~ "b) Successful Settlement"))

world <- ne_countries(country = 'australia',scale = "large", returnclass = "sf")

ggplot(mydata2, aes(x=lon, y=lat, group=ParticleID)) + geom_path(alpha=0.03, col="black") + 
  facet_wrap(~zone7_landed) + xlab("Longitude") + ylab("Latitude")+
  geom_sf(data=world, col="grey80", fill = "grey80", inherit.aes = FALSE)+
  coord_sf(xlim=c(149,160), ylim = c(-40,-20)) + theme_classic()+ 
  scale_x_continuous(breaks=c(152,156))+
  theme(axis.text = element_text(colour="black", size=12),
        axis.title = element_text(face="bold", size=14),
        strip.text = element_text(face="bold", size=10,hjust=0),
        strip.background = element_blank(),
        panel.border = element_rect(fill=NA))


ggsave("BRAN All Paths subset.png", dpi = 600, width = 14.8, height=21, units="cm")
ggsave("BRAN All Paths subset.pdf", dpi = 600, width = 14.8, height=21, units="cm")
