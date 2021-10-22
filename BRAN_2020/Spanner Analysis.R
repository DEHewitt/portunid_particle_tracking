# Spanner Crab Output

library(tidyverse)

setwd("C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN_2020/")

mydata <- read_csv("Output/spanner_forward_master_settled.csv") # .rds is the older one
mydata <- readRDS("Output/spanner_forwards_master_settled.rds") # .rds is the older one
mydata$age <- mydata$age/86400
mydata$Year <- lubridate::year(mydata$rel_date)
mydata$Month <- lubridate::month(mydata$rel_date)

mydata <- mydata %>% mutate(spawning_year = case_when(Month < 6 ~ Year -1, # identifies year the spawning season begins
                                                      TRUE ~ Year)) %>% 
  filter(bathy <=200 & Month != 3 & Month !=10) %>% filter(spawning_year != 2019)# %>% filter(Month != 1)

head(mydata)
hist(mydata$bathy)
range(mydata$lat)
table(mydata$Month)
table(mydata$age)

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


CPUE <- read_csv("Spanner Crab Annual CPUE.csv")
CPUE <- CPUE %>% rename(Year = `Event date Year`)

CPUE2 <- read_csv("Spanner_for_HS__data_request_01072021.csv")


full_dat <- full_join(CPUE2, nsw_sum) %>% arrange(Year)
extra_year <- data.frame(Year=2020)
extra_year2 <- data.frame(Year=2021)
full_dat <- bind_rows(full_dat,extra_year,extra_year2) # so that we can see the 2021 prediction

full_dat <- full_dat  %>% dplyr::mutate(lagged_Predicted_recruitment = dplyr::lag(x=Predicted_recruitment, n=4))
head(full_dat)

ggplot(full_dat, aes(Year, lagged_Predicted_recruitment)) + geom_point() + geom_line(col="grey40")+
  theme_classic()+ geom_line(data=full_dat, aes(y = `CPUE (kg.FisherDay-1)`*20), col="red")+
  #geom_errorbar(data=full_dat,aes(y = CPUE_mean*2000, ymin=CPUE_mean*2000-se_CPUE*2000, ymax=CPUE_mean*2000+se_CPUE*2000))

str(full_dat)
cor.test(full_dat$lagged_Predicted_recruitment, full_dat$`CPUE (kg.FisherDay-1)`)
#plot(full_dat$lagged_Predicted_recruitment, full_dat$CPUE_mean)
write_csv(full_dat, "Predicted recruitment full season mortalityx1.csv")

### Attempt to standardise things
full_dat_standardised <- full_dat %>% mutate(standardised_lagged_Predicted_recruitment = scales::rescale(lagged_Predicted_recruitment),
                                             CPUE_relative1 = scales::rescale(`CPUE (kg.FisherDay-1)`),
                                             CPUE_relative2 = scales::rescale(`CPUE (kg.NL-1)`))

cor.test(full_dat_standardised$CPUE_relative1, full_dat_standardised$CPUE_relative2)

full_dat_standardised_long <- full_dat_standardised %>% select(Year, standardised_lagged_Predicted_recruitment, CPUE_relative1, CPUE_relative2) %>%
  pivot_longer(2:4)

# full_dat_standardised_long$SE <- as.numeric(0)
# for (i in 1:nrow(full_dat_standardised_long)){
#   if (full_dat_standardised_long$name[i] == "CPUE_relative"){
#     full_dat_standardised_long$SE[i] <- full_dat_standardised_long$CPUE_se_relative[i]
#   }
#   else{
#     full_dat_standardised_long$SE[i] <- NA
#   }
#   
# }


ggplot(full_dat_standardised_long, aes(Year, value, col=name)) + geom_point() + geom_line()+
  theme_classic()+ ylab("Rescaled Value")+ 
  scale_x_continuous(breaks=seq(1998,2020,2), limits = c(1998,2021))+
  #geom_errorbar(aes(ymin=value-SE, ymax=value+SE))+
  theme(axis.text.y = element_text(colour="black", size=12),
        axis.text.x = element_text(colour="black", size=12, angle=45, vjust=0.5),
        axis.title = element_text(face="bold", size=14),
        legend.position = "bottom",
        legend.title = element_text(face="bold",size=14),
        legend.text = element_text(size=12)) +
  scale_color_manual(values=c("red","blue", "black"), name="Data\nSource", labels = c("CPUE\nFisher kg/day","CPUE\nkg/net", "Predicted Recruitment\nto Fishery"))

ggsave("C:/Users/htsch/Desktop/Snapper Crab/Predicted v CPUE.png", dpi=600, units="cm", height = 14.8, width=21)
ggsave("C:/Users/htsch/Desktop/Snapper Crab/Predicted v CPUE.pdf", dpi=600, units="cm", height = 14.8, width=21)

cor.test(full_dat_standardised$standardised_lagged_Predicted_recruitment, full_dat_standardised$CPUE_relative2)
cor.test(full_dat_standardised$standardised_lagged_Predicted_recruitment, full_dat_standardised$CPUE_relative1)


# What months is settlement mostly happening in NSW
mydata_set <- mydata %>% filter(Month >= 10 | Month <2) %>% filter(state == "NSW") %>% group_by(spawning_year, Month) %>%
  summarise(total = n()) %>%
  mutate(Month_name = case_when(Month == 1 ~ "c) January",
                                Month == 11 ~ "a) November",
                                Month == 12 ~ "b) December"))

mydata_set

ggplot(mydata_set, aes(x=as.character(Month), y = total)) + facet_wrap(~spawning_year) + geom_point() # quite variable

ggplot(mydata_set, aes(x=spawning_year, y =total)) + geom_line() + geom_point() + facet_wrap(~Month_name, ncol=1)+
  theme_classic()+ scale_x_continuous(breaks = seq(1994,2020,2))+ ylab("Predicted Larval Settlement\nin NSW (Zone 7)")+
  xlab("Spawning Season Starting")+
  theme(axis.text.y = element_text(size=12,colour="black"),
        axis.text.x = element_text(size=12,colour="black", angle=45, vjust=0.5),
        axis.title = element_text(size=14, face="bold"),
        strip.background = element_blank(),
        strip.text = element_text(face="bold", size=12,hjust=0),
        panel.border = element_rect(colour="black",fill=NA))

ggsave("C:/Users/htsch/Desktop/Snapper Crab/Annual Settlement by Month.png", dpi=600, units="cm", height = 14.8, width=21)
ggsave("C:/Users/htsch/Desktop/Snapper Crab/Annual Settlement by Month.pdf", dpi=600, units="cm", height = 14.8, width=21)


##################################
# By Months

# # correlation with just month 10
# mydata_set2 <- mydata_set %>% filter(Month == 10)
# mydata_set2$ma2 <- rollmean(x=mydata_set2$total,k=3, fill=NA)
# mydata_set2 <- mydata_set2 %>% rename(Year = spawning_year, Predicted_recruitment=ma2)
# write_csv(mydata_set2, "test_out2.csv")
# mydata_set2 <- read_csv("test_out2.csv")
# 
# full_datX <- full_join(CPUE, mydata_set2) %>% arrange(Year)
# 
# extra_year <- data.frame(Year=2021)
# full_datX <- bind_rows(full_datX,extra_year) %>% mutate(Month =10)
# 
# full_datX_Oct <- full_datX  %>% dplyr::mutate(lagged_Predicted_recruitment = dplyr::lag(x=Predicted_recruitment, n=4))
# head(full_datX)
# 
# ggplot(full_datX_Oct, aes(Year, lagged_Predicted_recruitment)) + geom_point() + geom_line(col="grey40")+
#   theme_classic()+ geom_line(data=full_datX, aes(y = CPUE_mean*2000), col="red")+
#   geom_errorbar(data=full_datX,aes(y = CPUE_mean*2000, ymin=CPUE_mean*2000-se_CPUE*2000, ymax=CPUE_mean*2000+se_CPUE*2000))
# 
# 
# cor.test(full_datX$lagged_Predicted_recruitment, full_datX$CPUE_mean)
# 
# 
# 
# ### Standardise using only month 10
# full_dat_standardisedX_Oct <- full_datX_Oct %>% mutate(standardised_lagged_Predicted_recruitment = lagged_Predicted_recruitment/max(lagged_Predicted_recruitment, na.rm=T),
#                                                CPUE_relative = CPUE_mean/max(CPUE_mean, na.rm=T),
#                                                CPUE_se_relative = se_CPUE/max(CPUE_mean, na.rm=T))
# 
# full_dat_standardised_longX_Oct <- full_dat_standardisedX_Oct %>% select(Year,Month, standardised_lagged_Predicted_recruitment, CPUE_relative, CPUE_se_relative) %>%
#   pivot_longer(3:4) %>% mutate(Month=10)
# 
# full_dat_standardised_longX_Oct$SE <- as.numeric(0)
# for (i in 1:nrow(full_dat_standardised_longX_Oct)){
#   if (full_dat_standardised_longX_Oct$name[i] == "CPUE_relative"){
#     full_dat_standardised_longX_Oct$SE[i] <- full_dat_standardised_longX_Oct$CPUE_se_relative[i]
#   }
#   else{
#     full_dat_standardised_longX_Oct$SE[i] <- NA
#   }
#   
# }
# 
# 
# ggplot(full_dat_standardised_longX_Oct, aes(Year, value, col=name)) + geom_point() + geom_line()+
#   theme_classic()+ ylab("Relative Value (±SE)")+ xlim(c(1997,2021))+
#   geom_errorbar(aes(ymin=value-SE, ymax=value+SE))+
#   theme(axis.text = element_text(colour="black", size=12),
#         axis.title = element_text(face="bold", size=14),
#         legend.position = c(0.2,0.3),
#         legend.title = element_text(face="bold",size=14),
#         legend.text = element_text(size=12)) +
#   scale_color_manual(values=c("red","black"), name="Data\nSource", labels = c("Relative CPUE", "Predicted Recruitment\nto Fishery"))
# 
# ggsave("Predicted v CPUE October spawning only.png", dpi=600, units="cm", height = 14.8, width=21)
# cor.test(full_dat_standardisedX_Oct$standardised_lagged_Predicted_recruitment, full_dat_standardisedX_Oct$CPUE_relative)



# correlation with just month 11
mydata_set2 <- mydata_set %>% filter(Month == 11)
mydata_set2$ma2 <- rollmean(x=mydata_set2$total,k=3, fill=NA)
mydata_set2 <- mydata_set2 %>% rename(Year = spawning_year, Predicted_recruitment=ma2)
write_csv(mydata_set2, "test_out2.csv")
mydata_set2 <- read_csv("test_out2.csv")

full_datX <- full_join(CPUE2, mydata_set2) %>% arrange(Year)
extra_year <- data.frame(Year=2021)
full_datX <- bind_rows(full_datX,extra_year) %>% mutate(Month =11)

full_datX_Nov <- full_datX  %>% dplyr::mutate(lagged_Predicted_recruitment = dplyr::lag(x=Predicted_recruitment, n=4))
head(full_datX_Nov)

ggplot(full_datX_Nov, aes(Year, lagged_Predicted_recruitment)) + geom_point() + geom_line(col="grey40")+
  theme_classic()+ geom_line(data=full_datX_Nov, aes(y = `CPUE (kg.FisherDay-1)`), col="red")+
  geom_line(data=full_datX_Nov, aes(y = `CPUE (kg.NL-1)`*500), col="blue")
  
 # geom_errorbar(data=full_datX_Nov,aes(y = CPUE_mean*2000, ymin=CPUE_mean*2000-se_CPUE*2000, ymax=CPUE_mean*2000+se_CPUE*2000))

cor.test(full_datX_Nov$lagged_Predicted_recruitment, full_datX_Nov$`CPUE (kg.FisherDay-1)`)
cor.test(full_datX_Nov$lagged_Predicted_recruitment, full_datX_Nov$`CPUE (kg.NL-1)`)



### Standardise using only month 11
full_dat_standardisedX_Nov <- full_datX_Nov %>% mutate(standardised_lagged_Predicted_recruitment = scales::rescale(lagged_Predicted_recruitment),
                                                       CPUE_relative1 = scales::rescale(`CPUE (kg.FisherDay-1)`),
                                                       CPUE_relative2 = scales::rescale(`CPUE (kg.NL-1)`))

full_dat_standardised_longX_Nov <- full_dat_standardisedX_Nov %>% select(Year, Month, standardised_lagged_Predicted_recruitment, CPUE_relative1, CPUE_relative2) %>%
  pivot_longer(3:4) %>% mutate(Month=11)

full_dat_standardised_longX_Nov$SE <- as.numeric(0)
for (i in 1:nrow(full_dat_standardised_longX_Nov)){
  if (full_dat_standardised_longX_Nov$name[i] == "CPUE_relative"){
    full_dat_standardised_longX_Nov$SE[i] <- full_dat_standardised_longX_Nov$CPUE_se_relative[i]
  }
  else{
    full_dat_standardised_longX_Nov$SE[i] <- NA
  }
  
}


ggplot(full_dat_standardised_longX_Nov, aes(Year, value, col=name)) + geom_point() + geom_line()+
  theme_classic()+ ylab("Relative Value (±SE)")+ xlim(c(1997,2021))+
  geom_errorbar(aes(ymin=value-SE, ymax=value+SE))+
  theme(axis.text = element_text(colour="black", size=12),
        axis.title = element_text(face="bold", size=14),
        legend.position = c(0.2,0.3),
        legend.title = element_text(face="bold",size=14),
        legend.text = element_text(size=12)) +
  scale_color_manual(values=c("red","black"), name="Data\nSource", labels = c("Relative CPUE", "Predicted Recruitment\nto Fishery"))

ggsave("Predicted v CPUE November spawning only.png", dpi=600, units="cm", height = 14.8, width=21)
cor.test(full_dat_standardisedX_Nov$standardised_lagged_Predicted_recruitment, full_dat_standardisedX_Nov$CPUE_relative)


# correlation with just month 12
mydata_set2 <- mydata_set %>% filter(Month == 12)
mydata_set2$ma2 <- rollmean(x=mydata_set2$total,k=3, fill=NA)
mydata_set2 <- mydata_set2 %>% rename(Year = spawning_year, Predicted_recruitment=ma2)
write_csv(mydata_set2, "test_out2.csv")
mydata_set2 <- read_csv("test_out2.csv")

full_datX <- full_join(CPUE, mydata_set2) %>% arrange(Year)
full_datX <- full_join(CPUE2, mydata_set2) %>% arrange(Year)
extra_year <- data.frame(Year=2020)
extra_year2 <- data.frame(Year=2021)
full_datX <- bind_rows(full_datX,extra_year,extra_year2) %>% mutate(Month =12)

full_datX_Dec <- full_datX  %>% dplyr::mutate(lagged_Predicted_recruitment = dplyr::lag(x=Predicted_recruitment, n=4))
head(full_datX_Dec)

ggplot(full_datX_Dec, aes(Year, lagged_Predicted_recruitment)) + geom_point() + geom_line(col="grey40")+
  theme_classic()+ geom_line(data=full_datX_Dec, aes(y = `CPUE (kg.NL-1)`*600), col="red")+
  geom_line(data=full_datX_Dec, aes(y = `CPUE (kg.FisherDay-1)`*10),col="blue")

cor.test(full_datX_Dec$lagged_Predicted_recruitment, full_datX_Dec$`CPUE (kg.FisherDay-1)`)
cor.test(full_datX_Dec$lagged_Predicted_recruitment, full_datX_Dec$`CPUE (kg.NL-1)`)
cor.test(full_datX_Dec$`CPUE (kg.FisherDay-1)`, full_datX_Dec$`CPUE (kg.NL-1)`)


### Standardise using only month 12
full_dat_standardisedX_Dec <- full_datX_Dec %>% filter(Year >= 1998) %>%
  mutate(standardised_lagged_Predicted_recruitment = scales::rescale(lagged_Predicted_recruitment,to=c(0,1)),
                                                       CPUE_relative1 = scales::rescale(`CPUE (kg.FisherDay-1)`,to=c(0,1)),#`CPUE (kg.FisherDay-1)`/max(`CPUE (kg.FisherDay-1)`, na.rm=T),
                                                       CPUE_relative2 = scales::rescale(`CPUE (kg.NL-1)`,to=c(0,1)))

full_dat_standardised_longX_Dec <- full_dat_standardisedX_Dec %>% select(Year, Month,standardised_lagged_Predicted_recruitment, CPUE_relative1, CPUE_relative2) %>%
  pivot_longer(3:5) %>% mutate(Month = 12)

# full_dat_standardised_longX_Dec$SE <- as.numeric(0)
# for (i in 1:nrow(full_dat_standardised_longX_Dec)){
#   if (full_dat_standardised_longX_Dec$name[i] == "CPUE_relative"){
#     full_dat_standardised_longX_Dec$SE[i] <- full_dat_standardised_longX_Dec$CPUE_se_relative[i]
#   }
#   else{
#     full_dat_standardised_longX_Dec$SE[i] <- NA
#   }
#   
# }


ggplot(full_dat_standardised_longX_Dec, aes(Year, value, col=name)) + geom_point() + geom_line()+
  theme_classic()+ ylab("Rescaled Value")+ #xlim(c(1997,2021))+
  #geom_errorbar(aes(ymin=value-SE, ymax=value+SE))+
  scale_x_continuous(breaks=seq(1998,2020,2))+
  theme(axis.text.y = element_text(colour="black", size=12),
        axis.title = element_text(face="bold", size=14),
        legend.position = "bottom",
        legend.title = element_text(face="bold",size=14),
        legend.text = element_text(size=12),
        axis.text.x = element_text(colour="black", size=12, angle=45, vjust=0.5)) +
  scale_color_manual(values=c("red","blue","black"), name="Data\nSource", labels = c("CPUE\nkg/FisherDay","CPUE\nkg/Net Lift", "Predicted Recruitment\nto Fishery"))

ggsave("C:/Users/htsch/Desktop/Snapper Crab/Predicted v CPUE December spawning only.png", dpi=600, units="cm", height = 14.8, width=21)
ggsave("C:/Users/htsch/Desktop/Snapper Crab/Predicted v CPUE December spawning only.pdf", dpi=600, units="cm", height = 14.8, width=21)
cor.test(full_dat_standardisedX_Dec$standardised_lagged_Predicted_recruitment, full_dat_standardisedX_Dec$CPUE_relative1)
cor.test(full_dat_standardisedX_Dec$standardised_lagged_Predicted_recruitment, full_dat_standardisedX_Dec$CPUE_relative2)
cor.test(full_dat_standardisedX_Dec$CPUE_relative2, full_dat_standardisedX_Dec$CPUE_relative1)

M1 <- full_dat_standardised_longX_Dec


# remove prediction for presentation only
ggplot(full_dat_standardised_longX_Dec, aes(Year, value, col=name)) + geom_point() + geom_line()+
  theme_classic()+ ylab("Rescaled Value")+ #xlim(c(1997,2021))+
  #geom_errorbar(aes(ymin=value-SE, ymax=value+SE))+
  scale_x_continuous(breaks=seq(1998,2020,2))+
  theme(axis.text.y = element_text(colour="black", size=12),
        axis.title = element_text(face="bold", size=14),
        legend.position = "bottom",
        legend.title = element_text(face="bold",size=14),
        legend.text = element_text(size=12),
        axis.text.x = element_text(colour="black", size=12, angle=45, vjust=0.5)) +
  scale_color_manual(values=c("red","blue","white"), name="Data\nSource", labels = c("CPUE\nkg/FisherDay","CPUE\nkg/Net Lift", "Predicted Recruitment\nto Fishery"))

ggsave("C:/Users/htsch/Desktop/Snapper Crab/Predicted v CPUE December spawning only_no larvae.png", dpi=600, units="cm", height = 14.8, width=21)

### compare results from differing mortality
#M1$Mortality <- 1
#M2$Mortality <- 2
#M10$Mortality <- 10


#M_compare <- bind_rows(M1,M2,M10) %>% filter(name=="standardised_lagged_Predicted_recruitment")
#write_csv(M_compare, "Mortality Comparison.csv")
M_compare <- read_csv("Mortality Comparison.csv")

ggplot(M_compare, aes(Year, value, col=as.character(Mortality), linetype=as.character(Mortality))) + geom_line(size=1.2, alpha=0.5)+
  theme_classic()+ ylab("Rescaled Value")+ #xlim(c(1997,2021))+
  #geom_errorbar(aes(ymin=value-SE, ymax=value+SE))+
  scale_x_continuous(breaks=seq(1998,2020,2))+
  theme(axis.text.y = element_text(colour="black", size=12),
        axis.title = element_text(face="bold", size=14),
        legend.position = "bottom",
        legend.title = element_text(face="bold",size=14),
        legend.text = element_text(size=12),
        axis.text.x = element_text(colour="black", size=12, angle=45, vjust=0.5))+
  scale_colour_manual(values=c("black","red","blue"), name="Mortality x")+
  scale_linetype_discrete(name="Mortality x")+
  ylab("Rescaled Lagged Predicted Recruitment\nin Zone 7 from December Spawning")

ggsave("Mortality comparison.png", dpi=600, width=21, height=14.8, units="cm")
# correlation with just month 1
mydata_set2 <- mydata_set %>% filter(Month == 1)
mydata_set2$ma2 <- rollmean(x=mydata_set2$total,k=3, fill=NA)
mydata_set2 <- mydata_set2 %>% rename(Year = spawning_year, Predicted_recruitment=ma2)
write_csv(mydata_set2, "test_out2.csv")
mydata_set2 <- read_csv("test_out2.csv")

full_datX <- full_join(CPUE, mydata_set2) %>% arrange(Year)
extra_year <- data.frame(Year=2021)
full_datX <- bind_rows(full_datX,extra_year) %>% mutate(Month =1)

full_datX_Jan <- full_datX  %>% dplyr::mutate(lagged_Predicted_recruitment = dplyr::lag(x=Predicted_recruitment, n=4))
head(full_datX_Jan)

ggplot(full_datX_Jan, aes(Year, lagged_Predicted_recruitment)) + geom_point() + geom_line(col="grey40")+
  theme_classic()+ geom_line(data=full_datX_Jan, aes(y = CPUE_mean*2000), col="red")+
  geom_errorbar(data=full_datX_Jan,aes(y = CPUE_mean*2000, ymin=CPUE_mean*2000-se_CPUE*2000, ymax=CPUE_mean*2000+se_CPUE*2000))


cor.test(full_datX_Jan$lagged_Predicted_recruitment, full_datX_Jan$CPUE_mean)



### Standardise using only month 1
full_dat_standardisedX_Jan <- full_datX_Jan %>% mutate(standardised_lagged_Predicted_recruitment = lagged_Predicted_recruitment/max(lagged_Predicted_recruitment, na.rm=T),
                                               CPUE_relative = CPUE_mean/max(CPUE_mean, na.rm=T),
                                               CPUE_se_relative = se_CPUE/max(CPUE_mean, na.rm=T))

full_dat_standardised_longX_Jan <- full_dat_standardisedX_Jan %>% select(Year,Month, standardised_lagged_Predicted_recruitment, CPUE_relative, CPUE_se_relative) %>%
  pivot_longer(3:4) %>% mutate(Month = 1)

full_dat_standardised_longX_Jan$SE <- as.numeric(0)
for (i in 1:nrow(full_dat_standardised_longX_Jan)){
  if (full_dat_standardised_longX_Jan$name[i] == "CPUE_relative"){
    full_dat_standardised_longX_Jan$SE[i] <- full_dat_standardised_longX_Jan$CPUE_se_relative[i]
  }
  else{
    full_dat_standardised_longX_Jan$SE[i] <- NA
  }
  
}


ggplot(full_dat_standardised_longX_Jan, aes(Year, value, col=name)) + geom_point() + geom_line()+
  theme_classic()+ ylab("Relative Value (±SE)")+ xlim(c(1997,2021))+
  geom_errorbar(aes(ymin=value-SE, ymax=value+SE))+
  theme(axis.text = element_text(colour="black", size=12),
        axis.title = element_text(face="bold", size=14),
        legend.position = c(0.2,0.3),
        legend.title = element_text(face="bold",size=14),
        legend.text = element_text(size=12)) +
  scale_color_manual(values=c("red","black"), name="Data\nSource", labels = c("Relative CPUE", "Predicted Recruitment\nto Fishery"))

ggsave("Predicted v CPUE January spawning only.png", dpi=600, units="cm", height = 14.8, width=21)
cor.test(full_dat_standardisedX_Jan$standardised_lagged_Predicted_recruitment, full_dat_standardisedX_Jan$CPUE_relative)


months_full_long <- bind_rows(full_dat_standardised_longX_Nov, full_dat_standardised_longX_Oct, full_dat_standardised_longX_Dec, full_dat_standardised_longX_Jan)

ggplot(months_full_long, aes(Year, value, col=name)) + geom_point() + geom_line()+
  theme_classic()+ ylab("Relative Value (±SE)")+ xlim(c(1997,2021))+ facet_wrap(~Month)+
  geom_errorbar(aes(ymin=value-SE, ymax=value+SE))+
  theme(axis.text = element_text(colour="black", size=12),
        axis.title = element_text(face="bold", size=14),
        legend.position = "bottom",
        legend.title = element_text(face="bold",size=14),
        legend.text = element_text(size=12)) +
  scale_color_manual(values=c("red","black"), name="Data\nSource", labels = c("Relative CPUE", "Predicted Recruitment\nto Fishery"))

months_full <- bind_rows(full_dat_standardisedX_Nov, full_dat_standardisedX_Oct, full_dat_standardisedX_Dec, full_dat_standardisedX_Jan)

head(months_full)

ggplot(months_full, aes(x=lagged_Predicted_recruitment, y = CPUE_mean)) + geom_point() + facet_wrap(~Month) + geom_smooth(method="lm")

#### Attempt to do multiple regression
full_dat_standardisedX_Nov$November <- full_dat_standardisedX_Nov$lagged_Predicted_recruitment
full_dat_standardisedX_Nov$October <- full_dat_standardisedX_Oct$lagged_Predicted_recruitment
full_dat_standardisedX_Nov$December <- full_dat_standardisedX_Dec$lagged_Predicted_recruitment
full_dat_standardisedX_Nov$January <- full_dat_standardisedX_Jan$lagged_Predicted_recruitment

fit1 <- lm(CPUE_mean~ December, data = full_dat_standardisedX_Nov)
summary(fit1)
plot(fit1)
AIC(fit1)

fit2 <- lm(CPUE_mean~ October + November + December + January, data = full_dat_standardisedX_Nov)
summary(fit2)
plot(fit2)
AIC(fit2)

X <- step(fit2)

fit3 <- lm(CPUE_mean~ November + December, data = full_dat_standardisedX_Nov)
summary(fit3)
plot(fit3)
AIC(fit3)

## December only model is the best - this suggests The oceanography in Dec/Jan could be important.

## Compare whole spawning season with December
ggplot(full_dat, aes(Year, total)) + geom_point() + geom_line(col="grey40")+  geom_line(data=full_datX, col="blue") + geom_point(data=full_datX, col="blue")
cor.test(full_dat$total, full_datX$total) # r = 0.80, p < 0.001


#### Where do the december spawned particles orgininate

Dec <- mydata %>% filter(Month == 12)

head(Dec)

library("rnaturalearth")
library("rnaturalearthdata")

world <- ne_countries(country = 'australia',scale = "large", returnclass = "sf")
class(world)

sub_dat <- mydata %>%  sample_n(1000) # group_by(ocean_zone) %>%
ggplot(sub_dat, aes(lon, lat, col=as.factor(as.character(ocean_zone)))) + # facet_wrap(~spawning_year)+
  geom_sf(data=world, col="grey70", fill = "grey80", inherit.aes = FALSE)+
  coord_sf(xlim = c(147, 160), ylim = c(-30, -22), expand = FALSE)+
  scale_color_discrete(name="Release\nZone")+
  geom_point(alpha=0.5)











### Conntectivity Matrix time

con_dat <- mydata %>% filter(Month < 2| Month > 10) %>% filter(lon <156)
head(con_dat)
hist(con_dat$age)

# released in ocean zone, end in region
con_dat2 <- con_dat %>% group_by(ocean_zone, region, spawning_year) %>% summarise(number = n())
head(con_dat2)

con_dat3 <- con_dat2 %>% group_by(ocean_zone, region) %>% summarise(Settlement_Mean = mean(number), Settlement_sd = sd(number))
ggplot(con_dat3, aes(region, ocean_zone, fill = Settlement_Mean)) + geom_tile(col="black") + scale_y_reverse(expand=c(0,0), breaks=seq(2:8)) + 
  scale_fill_viridis_c(trans="log10", name="Relative\nSettlement\n(SD)")+
  scale_x_continuous(expand=c(0,0), breaks=seq(2:8)) + labs(y= "Spawning Zone", x= "Settlement Zone") + 
  geom_text(aes(label=paste0(round(Settlement_Mean),"\n(",round(Settlement_sd),")"))) +
  theme_bw() + theme(axis.text = element_text(colour="black", size=12),
                          axis.title = element_text(face="bold", size=14),
                          legend.title = element_text(face="bold",size=14),
                          legend.text = element_text(size=12),
                     panel.grid.minor = element_blank(),
                     panel.grid.major = element_blank())

ggsave("Connectivity Matrix.png", dpi = 600, units="cm", height = 17, width=20)



### TRY SOI as an indicator - No good
soi <- read_csv("SOI Monthly.csv")
soi_Dec <- soi %>% filter(Month ==12) %>% rename(spawning_year = Year)
head(soi_Dec)

nsw_soi_dec <- left_join(nsw_sum, soi_Dec)

ggplot(nsw_soi_dec, aes(spawning_year, SOI)) + geom_line() + geom_line(aes(y=total/100))
cor.test(nsw_soi_dec$SOI, nsw_soi_dec$total)

soi <- read_csv("SOI Monthly.csv")
soi_Jan <- soi %>% filter(Month ==1) %>% mutate(Year = Year+1) %>% rename(spawning_year = Year)
head(soi_Jan)

nsw_soi_Jan <- left_join(nsw_sum, soi_Jan)

ggplot(nsw_soi_Jan, aes(spawning_year, SOI)) + geom_line() + geom_line(aes(y=total/100))
cor.test(nsw_soi_Jan$SOI, nsw_soi_Jan$total)


# GSLA 
library(lubridate)
GSLA <- tidync::tidync("IMOS_GSLA.nc") %>% tidync::hyper_tibble() %>% mutate(Time = as.Date(TIME, origin="1985-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>%
  filter(Month ==12 | Month ==1) %>% filter(LATITUDE < -27) %>%
  group_by(Year, Month,LONGITUDE ,LATITUDE) %>% summarise(across(where(is.double),~ mean(.x, na.rm = TRUE)))
head(GSLA)

#x <- ncmeta::nc_atts("IMOS_GSLA.nc", "TIME")
library("rnaturalearth")
library("rnaturalearthdata")

world <- ne_countries(country = 'australia',scale = "large", returnclass = "sf")
class(world)

GSLA2 <- GSLA %>% filter(Month==12 & Year == 2011)
ggplot(GSLA2, aes(LONGITUDE, LATITUDE, fill=GSLA)) + 
  geom_sf(data=world, col="grey70", fill = "grey80", inherit.aes = FALSE)+
  coord_sf(xlim = c(147, 160), ylim = c(-30, -22), expand = FALSE)+
  geom_tile()

GSLA_timeD <- GSLA %>% group_by(Time, Month, Year) %>% summarise(GSLA_mean = mean(GSLA, na.rm=T))

ggplot(GSLA_timeD, aes(x=Time, y = GSLA_mean)) + geom_line() + facet_wrap(~Month)

GSLA_timeD <- GSLA_timeD %>% rename(spawning_year=Year) %>% filter((Month==12))
GSLA_nsw <- left_join(nsw_sum, GSLA_timeD)
ggplot(GSLA_nsw, aes(spawning_year, GSLA_mean)) + geom_line() + geom_line(aes(y=total/10000), col="red")

# UCUR (also no good)
library(lubridate)
UCUR <- tidync::tidync("IMOS_GSLA.nc") %>% tidync::hyper_tibble() %>% mutate(Time = as.Date(TIME, origin="1985-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>%
  filter(Month ==12 | Month ==1) %>% filter(LATITUDE < -27) %>%
  group_by(Year, Month,LONGITUDE ,LATITUDE) %>% summarise(across(where(is.double),~ mean(.x, na.rm = TRUE)))
head(UCUR)

#x <- ncmeta::nc_atts("IMOS_UCUR.nc", "TIME")
library("rnaturalearth")
library("rnaturalearthdata")

world <- ne_countries(country = 'australia',scale = "large", returnclass = "sf")
class(world)

UCUR2 <- UCUR %>% filter(Month==12 & Year == 2011)
ggplot(UCUR2, aes(LONGITUDE, LATITUDE, fill=UCUR)) + 
  geom_sf(data=world, col="grey70", fill = "grey80", inherit.aes = FALSE)+
  coord_sf(xlim = c(147, 160), ylim = c(-30, -22), expand = FALSE)+
  geom_tile()

UCUR_timeD <- UCUR %>% group_by(Time, Month, Year) %>% summarise(UCUR_mean = mean(UCUR, na.rm=T))

ggplot(UCUR_timeD, aes(x=Time, y = UCUR_mean)) + geom_line() + facet_wrap(~Month)

UCUR_timeD <- UCUR_timeD %>% mutate(Year=Year-1) %>% rename(spawning_year=Year) %>% filter((Month==1))
UCUR_nsw <- left_join(nsw_sum, UCUR_timeD)
ggplot(UCUR_nsw, aes(spawning_year, UCUR_mean)) + geom_line() + geom_line(aes(y=total/10000), col="red")

cor.test(UCUR_nsw$total, UCUR_nsw$UCUR_mean)


# TEMPERATURE
library(lubridate)
TEMP <- tidync::tidync("IMOS_SST.nc") %>% tidync::hyper_tibble() %>% mutate(Time = as.POSIXct(time, origin="1981-01-01"), Day = day(Time), Month = month(Time), Year=year(Time)) %>%
  filter(Month ==12 | Month ==1) %>% filter(lat < -27) %>%
  group_by(Year, Month,lon ,lat) %>% summarise(across(where(is.double),~ mean(.x, na.rm = TRUE)))
head(TEMP)

#x <- ncmeta::nc_atts("IMOS_SST.nc", "time")
library("rnaturalearth")
library("rnaturalearthdata")

world <- ne_countries(country = 'australia',scale = "large", returnclass = "sf")
class(world)

TEMP2 <- TEMP %>% filter(Month==12 & Year == 2011)
ggplot(TEMP2, aes(lon, lat, fill=sea_surface_temperature)) + 
  geom_sf(data=world, col="grey70", fill = "grey80", inherit.aes = FALSE)+
  coord_sf(xlim = c(147, 160), ylim = c(-30, -22), expand = FALSE)+
  geom_tile()

TEMP_timeJ <- TEMP %>% group_by(Time, Month, Year) %>% summarise(SST_mean = mean(sea_surface_temperature-273.15, na.rm=T))

ggplot(TEMP_timeD, aes(x=Time, y = SST_mean)) + geom_line() + facet_wrap(~Month)

TEMP_timeJ <- TEMP_timeJ %>% mutate(Year=Year-1) %>% rename(spawning_year=Year) %>% filter((Month==1))
TEMP_nsw <- left_join(nsw_sum, TEMP_timeJ)
ggplot(TEMP_nsw, aes(spawning_year, SST_mean)) + geom_line() + geom_line(aes(y=total/500), col="red")

cor.test(TEMP_nsw$total, TEMP_nsw$SST_mean)

TEMP_timeD <- TEMP %>% group_by(Time, Month, Year) %>% summarise(SST_mean = mean(sea_surface_temperature-273.15, na.rm=T))
TEMP_timeD <- TEMP_timeD %>% mutate(Year=Year) %>% rename(spawning_year=Year) %>% filter((Month==12))
TEMP_nsw <- left_join(nsw_sum, TEMP_timeD)
ggplot(TEMP_nsw, aes(spawning_year, SST_mean*100)) + geom_line() + geom_line(aes(y=total), col="red")

cor.test(TEMP_nsw$total, TEMP_nsw$SST_mean)

#### Other stuff





dat_sum3 <- mydata %>%  filter(Month >= 10 | Month <2) %>% group_by(spawning_year, ocean_zone) %>% summarise(total = n())

ggplot(dat_sum3,aes(spawning_year, total)) + geom_point() + geom_smooth(method="lm") + facet_wrap(~ocean_zone, scales = "free_y") + geom_line(col="grey40")

table(mydata$state)
table(mydata$ocean_zone)

dat_sum2 <- filter(dat_sum, ocean_zone == 7)
fit1 <- lm(total ~ spawning_year, data = dat_sum2)
summary(fit1)



ggplot(mydata, aes(age)) + geom_histogram(binwidth = 1) + facet_wrap(~ocean_zone, scales = "free_y")

dat_age_sum <- mydata %>% group_by(ocean_zone) %>% summarise(mean_age = mean(age, na.rm=T), sd_age = sd(age, na.rm=T))
dat_age_sum


ggplot(mydata, aes(region)) + geom_histogram(binwidth = 1) + facet_grid(spawning_year~ocean_zone, scales = "free_y")


NSW_dat <- mydata %>% filter(state=="NSW")
ggplot(NSW_dat, aes(lon, lat)) + geom_point(alpha=0.5)


library("rnaturalearth")
library("rnaturalearthdata")

world <- ne_countries(country = 'australia',scale = "large", returnclass = "sf")
class(world)

sub_dat <- mydata %>% group_by(ocean_zone) %>% sample_n(1000)
ggplot(sub_dat, aes(lon, lat, col=as.factor(as.character(ocean_zone)))) + 
  geom_sf(data=world, col="grey70", fill = "grey80", inherit.aes = FALSE)+
  coord_sf(xlim = c(147, 160), ylim = c(-30, -22), expand = FALSE)+
  scale_color_discrete(name="Release\nZone")+
  geom_point(alpha=0.5)
  
