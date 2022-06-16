# Connectivity Matrices

library(tidyverse)
#install.packages("viridis")
#library(viridis)
setwd("C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN_2020/")

mydata <- readRDS("Output/spanner_forwards_master_settled.rds")
mydata$age <- mydata$age/86400
mydata$Year <- lubridate::year(mydata$rel_date)
mydata$Month <- lubridate::month(mydata$rel_date)

mydata <- mydata %>% mutate(spawning_year = case_when(Month < 6 ~ Year -1, # identifies year the spawning season begins
                                                      TRUE ~ Year)) %>% 
  filter(bathy <=200 & Month != 3) %>% filter(spawning_year != 2019)# %>% filter(Month != 1)

head(mydata)
hist(mydata$bathy)
range(mydata$lat)
table(mydata$Month)
table(mydata$age)

con_dat <- mydata %>% filter(Month < 2| Month > 10) %>% filter(lon <156) # this lon filter gets rid of some islands
head(con_dat)
hist(con_dat$age)

# released in ocean zone, end in region
con_dat2 <- con_dat %>% group_by(ocean_zone, region, spawning_year) %>% summarise(number = n())
head(con_dat2)

con_dat3 <- con_dat2 %>% group_by(ocean_zone, region) %>% summarise(Settlement_Mean = mean(number), Settlement_sd = sd(number))
p1 <- ggplot(con_dat3, aes(region, ocean_zone, fill = Settlement_Mean)) + geom_tile(col="black") + scale_y_reverse(expand=c(0,0), breaks=seq(2:8)) + 
  scale_fill_viridis_c(trans="log10", name="Relative\nSettlement\n(SD)")+
  scale_x_continuous(expand=c(0,0), breaks=seq(2:8)) + labs(y= "Spawning Zone", x= "Settlement Zone") + 
  geom_text(aes(label=paste0(round(Settlement_Mean),"\n(",round(Settlement_sd),")"))) +
  theme_bw() + theme(axis.text = element_text(colour="black", size=12),
                     axis.title = element_text(face="bold", size=14),
                     legend.title = element_text(face="bold",size=14),
                     legend.text = element_text(size=12),
                     panel.grid.minor = element_blank(),
                     panel.grid.major = element_blank())
p1
ggsave("C:/Users/htsch/Desktop/Snapper Crab/Connectivity Matrix total relative settlement.png", dpi = 600, units="cm", height = 17, width=20)


### Now as a percentage of particles settled in each zone
head(con_dat2)
con_dat4 <- con_dat2 %>% group_by(region,spawning_year) %>% summarise(Total_settlement = sum(number))
head(con_dat4)

con_dat5 <- con_dat2 %>% left_join(con_dat4) %>% mutate(`Settlement %` = 100*number/Total_settlement)
head(con_dat5)

tester <- con_dat5 %>% filter(spawning_year == 1995) %>% group_by(region) %>% summarise(total_percent = sum(`Settlement %`))
### region percentages sum to 100 - this is the columns in the below plot

con_dat6 <- con_dat5 %>% ungroup() %>%
  complete(ocean_zone, region,spawning_year, fill=list(number =0, Total_settlement=0, `Settlement %`=0)) %>%
  group_by(ocean_zone, region) %>%
  summarise(Settlement_Mean_Percent = mean(`Settlement %`, na.rm = T), Settlement_sd = sd(`Settlement %`, na.rm = T)) %>%
  filter(Settlement_Mean_Percent != 0)

table(con_dat5$ocean_zone, con_dat5$region)

library(shadowtext)
p2 <- ggplot(con_dat6, aes(region, ocean_zone, fill = Settlement_Mean_Percent)) + geom_tile(col="black") + scale_y_reverse(expand=c(0,0), breaks=seq(2:8)) + 
  scale_fill_viridis_c( name="Percentage\n(SD)", option="mako", direction = -1)+
  scale_x_continuous(expand=c(0,0), breaks=seq(2:8)) + labs(y= "Spawning Zone", x= "Settlement Zone") + 
  geom_shadowtext(aes(label=paste0(round(Settlement_Mean_Percent,1),"\n(",round(Settlement_sd,1),")"))) +
  theme_bw() + theme(axis.text = element_text(colour="black", size=12),
                     axis.title = element_text(face="bold", size=14),
                     legend.title = element_text(face="bold",size=14),
                     legend.text = element_text(size=12,angle=45, vjust = .8),
                     legend.position = "bottom",
                     legend.key.width = unit(1, units= "cm"),
                     panel.grid.minor = element_blank(),
                     panel.grid.major = element_blank())+
  #ggtitle("a) Spawning zones of particles settling \nin each zones")
  ggtitle("a) Where do particles settling\nin each zone originate?")

p2

### Now as a percentage of particles Spawned in each zone
head(con_dat2)
con_dat14 <- con_dat2 %>% group_by(ocean_zone,spawning_year) %>% summarise(Total_spawning = sum(number))
head(con_dat14)

con_dat15 <- con_dat2 %>% left_join(con_dat14) %>% ungroup() %>%
  complete(ocean_zone, region,spawning_year, fill=list(number =0, Total_settlement=0)) %>%
  mutate(`Settlement %` = 100*number/((31+30+31+31)*2626)) # this number comes from Excel
head(con_dat5)

#tester <- con_dat15 %>% filter(spawning_year == 1995) %>% group_by(ocean_zone) %>% summarise(total_percent = sum(`Settlement %`))
### region percentages sum to 100 - this is the columns in the below plot

con_dat16 <- con_dat15 %>% group_by(ocean_zone, region) %>%
  summarise(Settlement_Mean_Percent = mean(`Settlement %`, na.rm=T), Settlement_sd = sd(`Settlement %`, na.rm=T)) %>%
  filter(Settlement_Mean_Percent != 0) # drop combinations where settlement never occured

library(shadowtext)

library(scales)
p3 <- ggplot(con_dat16, aes(region, ocean_zone, fill = Settlement_Mean_Percent)) + geom_tile(col="black") + scale_y_reverse(expand=c(0,0), breaks=seq(2:8)) + 
  scale_fill_viridis_c(name="Percentage\n(SD)", option="mako", direction = -1)+
  scale_x_continuous(expand=c(0,0), breaks=seq(2:8)) + labs(y= NULL, x= "Settlement Zone") + 
  geom_shadowtext(aes(label=paste0(round(Settlement_Mean_Percent,2),"\n(",round(Settlement_sd,2),")"))) +
  theme_bw() + theme(axis.text = element_text(colour="black", size=12),
                     axis.title = element_text(face="bold", size=14),
                     legend.title = element_text(face="bold",size=14),
                     legend.text = element_text(size=12,angle=45, vjust = .8),
                     legend.position = "bottom",
                     legend.key.width = unit(1, units= "cm"),
                     panel.grid.minor = element_blank(),
                     panel.grid.major = element_blank())+
  #ggtitle("b) Settling zones of particles spawned\nby zones")
  ggtitle("b) Where do particles spawned in\neach zone settle?")

p3

### merge plots
library(patchwork)
p2 + p3
ggsave("C:/Users/htsch/Desktop/Snapper Crab/Two panel connectivity Matrix_29_11_21.png", dpi=600, units="cm", width=21, height=14.8)
ggsave("C:/Users/htsch/Desktop/Snapper Crab/Two panel connectivity Matrixx_29_11_21.pdf", dpi=600, units="cm", width=21, height=14.8)

