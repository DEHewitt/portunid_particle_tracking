#### Sensitivity Analysis for spawning biomasses
#### What happens if the ratios are altered
#### Try extreme - remove a whole region

# Spanner Crab Output

library(tidyverse)

setwd("C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN_2020/")

#mydata <- read_csv("Output/spanner_forward_master_settled.csv") # .rds is the older one
mydata <- readRDS("Output/spanner_forwards_master_settled.rds") # .rds is the older one
mydata$age <- mydata$age/86400
mydata$Year <- lubridate::year(mydata$rel_date)
mydata$Month <- lubridate::month(mydata$rel_date)

mydata2 <- mydata %>% mutate(spawning_year = case_when(Month < 6 ~ Year -1, # identifies year the spawning season begins
                                                      TRUE ~ Year)) %>% 
  filter(bathy <=200 & Month != 3 & Month !=10) %>% filter(spawning_year != 2019)# %>% filter(Month != 1)

final_dat <- data.frame(Year = seq(1984,2021))

for(i in seq(1:7)){

mydata <- mydata2 %>% filter(ocean_zone != i)

head(mydata)
#hist(mydata$bathy)
#range(mydata$lat)
#table(mydata$Month)
#table(mydata$age)

dat_sum1 <- mydata %>% filter(Month > 10 | Month <2) %>% group_by(spawning_year) %>% summarise(total = n())

ggplot(dat_sum1,aes(spawning_year, total)) + geom_point() + geom_smooth(method="lm") + geom_line(col="grey40")

### THIS IS THE MONEY SHOT
dat_sum <- mydata %>%  filter(Month > 10 | Month <2) %>% group_by(spawning_year, state) %>% summarise(total = n())
dat_sum2 <- dat_sum %>% mutate(state = case_when(state=="NSW" ~ "b) NSW (Zone 7)",
                                                 state=="QLD" ~ "a) QLD (Zones 2 - 6)"))

ggplot(dat_sum2,aes(spawning_year, total/1000)) + geom_point() + facet_wrap(~state, scales = "free_y", nrow=2) + geom_line(col="grey40")+
  ylab("Relative Predicted Settlement") + xlab("Spawning Season Starting")+
  scale_x_continuous(breaks = seq(1994,2020,2))+
  theme_classic() + theme(axis.text.y = element_text(size=12,colour="black"),
                          axis.text.x = element_text(size=12,colour="black", angle=45, vjust=0.5),
                          axis.title = element_text(size=14, face="bold"),
                          strip.background = element_blank(),
                          strip.text = element_text(face="bold", size=12,hjust=0),
                          panel.border = element_rect(colour="black",fill=NA)) # want to reorder facets
#ggsave("C:/Users/htsch/Desktop/Snapper Crab/Predicted Settlement by State.png", dpi=600, units="cm", width = 21, height=14.8)
#ggsave("C:/Users/htsch/Desktop/Snapper Crab/Predicted Settlement by State.pdf", dpi=600, units="cm", width = 21, height=14.8)


###### NSW ONLY
nsw_sum <- dat_sum %>% filter(state == "NSW")
ggplot(nsw_sum, aes(spawning_year, total)) + geom_point() + geom_line(col="grey40")+
  theme_classic()#+ geom_line(data=mydata3, aes(x=`Event date Year`-4, y = CPUE_mean*2000), col="red")

## Good Years = 2011, 2012, 1998, 1999, 2000
## Bad Years = 2009, 2010, 2001, 2004, 2014

## December only (see later for why)
#dat_sumY <- mydata  %>% group_by(spawning_year, state) %>% summarise(total = n()) #%>%  filter(Month == 12)
#nsw_sum <- dat_sumY %>% filter(state == "NSW")
#ggplot(nsw_sum, aes(spawning_year, total)) + geom_point() + geom_line(col="grey40")+
#  theme_classic()#+ geom_line(data=mydata3, aes(x=`Event date Year`-4, y = CPUE_mean*2000), col="red")

## Good Years = 2012, 2013, 1998, 1999, 2000
## Bad Years = 2003, 2009,2010, 2011


### Moving Average Calculation
library(zoo)
nsw_sum$ma2 <- rollmean(x=nsw_sum$total,k=3, fill=NA)
head(nsw_sum)

nsw_sum <- nsw_sum %>% rename(Year = spawning_year, Predicted_recruitment=ma2)
head(nsw_sum)
write_csv(nsw_sum, "test_out.csv")
nsw_sum <- read_csv("test_out.csv")


CPUE <- read_csv("Other Data/Spanner Crab Annual CPUE.csv")
CPUE <- CPUE %>% rename(Year = `Event date Year`)

CPUE2 <- read_csv("Other Data/Spanner_for_HS__data_request_01072021.csv")
FIS_dat <- read_csv("Other Data/NSW FIS data digitised.csv")

full_dat <- full_join(CPUE2, nsw_sum) %>% arrange(Year) %>% left_join(FIS_dat)
extra_year <- data.frame(Year=2020)
extra_year2 <- data.frame(Year=2021)
full_dat <- bind_rows(full_dat,extra_year,extra_year2) # so that we can see the 2021 prediction

full_dat <- full_dat  %>% dplyr::mutate(lagged_Predicted_recruitment = dplyr::lag(x=Predicted_recruitment, n=4))
head(full_dat)

ggplot(full_dat, aes(Year, lagged_Predicted_recruitment)) + geom_point() + geom_line(col="grey40")+
  theme_classic()+ geom_line(data=full_dat, aes(y = `CPUE (kg.FisherDay-1)`*20), col="red")+
  geom_line(data=full_dat, aes(y = `FIS_CPUE_sublegal`*200), col="green")
#geom_errorbar(data=full_dat,aes(y = CPUE_mean*2000, ymin=CPUE_mean*2000-se_CPUE*2000, ymax=CPUE_mean*2000+se_CPUE*2000))

str(full_dat)
cor.test(full_dat$lagged_Predicted_recruitment, full_dat$`CPUE (kg.FisherDay-1)`)
cor.test(full_dat$lagged_Predicted_recruitment, full_dat$`FIS_CPUE_sublegal`)
cor.test(full_dat$lagged_Predicted_recruitment, full_dat$`FIS_CPUE_legal`)
cor.test(full_dat$lagged_Predicted_recruitment, full_dat$`FIS_CPUE_all`)

### Attempt to standardise things
full_dat_standardised <- full_dat %>% mutate(standardised_lagged_Predicted_recruitment = scales::rescale(lagged_Predicted_recruitment),
                                             CPUE_relative1 = scales::rescale(`CPUE (kg.FisherDay-1)`),
                                             CPUE_relative2 = scales::rescale(`CPUE (kg.NL-1)`),
                                             CPUE_relative3 = scales::rescale(`FIS_CPUE_legal`))

cor.test(full_dat_standardised$CPUE_relative1, full_dat_standardised$CPUE_relative2)
cor.test(full_dat_standardised$CPUE_relative1, full_dat_standardised$CPUE_relative3)
cor.test(full_dat_standardised$CPUE_relative2, full_dat_standardised$CPUE_relative3)


tdat <- as.data.frame(full_dat_standardised$standardised_lagged_Predicted_recruitment) %>%
  rename(removed = `full_dat_standardised$standardised_lagged_Predicted_recruitment`)
final_dat <- bind_cols(final_dat,tdat)
}

psych::pairs.panels(final_dat)

final_dat_long <- final_dat %>% pivot_longer(cols=c(2:8),
                                             names_to = "removed",
                                             values_to = "Proportion") %>%
  drop_na()

ggplot(final_dat_long, aes(x=Year, y = Proportion, col=removed,
                           lty=removed)) + geom_line() +
  scale_colour_viridis_d(name = "Scenario", labels = c("All regions",
                        "No R2", "No R3", "No R4", "No R5",
                        "No R6", "No R7"))+
  scale_linetype_discrete(name = "Scenario", labels = c("All regions",
                                                       "No R2", "No R3", "No R4", "No R5",
                                                       "No R6", "No R7"))+
  theme_classic()+
  ylab("Rescaled Predicted Recruitment to the Fishery")+
  theme(axis.text = element_text(colour="black", size=12),
        axis.title = element_text(face="bold", size=14),
        legend.position = "bottom",
        legend.key.width = unit(1.5,"cm"))

ggsave("C:/Users/htsch/Desktop/Snapper Crab/Sense_test.png", dpi = 600,
       width = 21, height=14.8, units = "cm")
