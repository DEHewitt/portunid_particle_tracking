# QLD CPUE
setwd("C:/Users/htsch/Desktop/Snapper Crab")
library(tidyverse)

catch <- read_csv("C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN_2020/Other Data/QLD Catch.csv") %>% pivot_longer(2:8, names_to = "Region", values_to = "Catch_t")
effort <- read_csv("C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN_2020/Other Data/QLD Effort.csv") %>% pivot_longer(2:8, names_to = "Region", values_to = "Effort")

mydat <- left_join(catch, effort) %>% mutate(CPUE = Catch_t/Effort) %>%
  filter(Region != "Region 1" & Region!= "Region 7")

ggplot(mydat, aes(x=Year, y=CPUE)) + geom_line() +
  facet_wrap(~Region) +
  geom_vline(xintercept = 2001-4) +
  geom_vline(xintercept = 2005-4)

ggsave("QLD CPUE line plot.png", dpi = 600, width=21, height=14.8, units="cm")

ggplot(mydat, aes(x=Year, y=Catch_t)) + geom_line() +
  facet_wrap(~Region) +
  geom_vline(xintercept = 2001-4) +
  geom_vline(xintercept = 2005-4)
ggsave("QLD Effort line plot.png", dpi = 600, width=21, height=14.8, units="cm")


ggplot(mydat, aes(x=Year, y=Effort)) + geom_line() +
  facet_wrap(~Region) +
  geom_vline(xintercept = 2001-4) +
  geom_vline(xintercept = 2005-4)
ggsave("QLD Catch_t line plot.png", dpi = 600, width=21, height=14.8, units="cm")


scaling_value <- max(mydat$Catch_t, na.rm = TRUE)/max(mydat$CPUE, na.rm = TRUE)

mydat <- mydat %>% mutate(Region = str_replace(Region, "Region", "Zone"))

ggplot() +
  geom_line(data = mydat, aes(x = Year, y = CPUE)) +
  geom_line(data = mydat, aes(x = Year, y = Catch_t / scaling_value), col="red") +
  facet_wrap(~Region)+
  scale_y_continuous(sec.axis = sec_axis(~ . * scaling_value, name = "Catch (t)")) +
  theme_classic() +
  theme(axis.text = element_text(colour="black", size=10),
        axis.title = element_text(face="bold"),
        axis.title.y.right = element_text(colour="red"),
        axis.text.y.right = element_text(colour="red"),
        strip.text = element_text(face="bold", size=10),
        strip.background = element_blank(),
        panel.border = element_rect(fill=NA)) +
  geom_vline(xintercept = 2001-4, linetype=3) +
  geom_vline(xintercept = 2005-4, linetype=3)
ggsave("QLD CPUE and Catch by region.png", dpi =600, width=21, height=14.8, units="cm")

### Overall catch

catch <- read_csv("C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN_2020/Other Data/QLD Catch.csv") %>% pivot_longer(2:8, names_to = "Region", values_to = "Catch_t")
effort <- read_csv("C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN_2020/Other Data/QLD Effort.csv") %>% pivot_longer(2:8, names_to = "Region", values_to = "Effort")

mydat <- left_join(catch, effort) %>% mutate(CPUE = Catch_t/Effort) %>%
  filter(Region!= "Region 7") %>% group_by(Year) %>% summarise(Catch_t = sum(Catch_t, na.rm=T),
                                                               Effort = sum(Effort, na.rm=T),
                                                               CPUE = Catch_t/Effort)


ggplot(mydat, aes(x=Year, y=Catch_t)) + geom_line()
ggplot(mydat, aes(x=Year, y=Effort)) + geom_line()
ggplot(mydat, aes(x=Year, y=CPUE)) + geom_line()

scaling_value <- max(mydat$Catch_t, na.rm = TRUE)/max(mydat$CPUE, na.rm = TRUE)
ggplot(mydat, aes(x=Year, y=Effort)) + geom_line() +
  facet_wrap(~Region) +
  geom_vline(xintercept = 2001-4) +
  geom_vline(xintercept = 2005-4)
ggsave("QLD Catch_t line plot.png", dpi = 600, width=21, height=14.8, units="cm")


scaling_value <- max(mydat$Catch_t, na.rm = TRUE)/max(mydat$CPUE, na.rm = TRUE)

mydat <- mydat %>% mutate(Region = str_replace(Region, "Region", "Zone"))

ggplot() +
  geom_line(data = mydat, aes(x = Year, y = CPUE)) +
  geom_line(data = mydat, aes(x = Year, y = Catch_t / scaling_value), col="red") +
  #facet_wrap(~Region)+
  scale_y_continuous(sec.axis = sec_axis(~ . * scaling_value, name = "Catch (t)")) +
  theme_classic() +
  theme(axis.text = element_text(colour="black", size=10),
        axis.title = element_text(face="bold"),
        axis.title.y.right = element_text(colour="red"),
        axis.text.y.right = element_text(colour="red"),
        strip.text = element_text(face="bold", size=10),
        strip.background = element_blank(),
        panel.border = element_rect(fill=NA))
ggsave("QLD CPUE and Catch total.png", dpi =600, width=21, height=14.8, units="cm")


### Updated Data from DJ (Figure S2)

dat2 <- read_csv("C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN_2020/Other Data/QLD_NSW_Data_30_11_21.csv")
dat2$QLD_CPUE <- dat2$QLD_catch_t/dat2$QLD_FisherDays

scaling_value <- max(dat2$QLD_catch_t, na.rm = TRUE)/max(dat2$QLD_CPUE, na.rm = TRUE)


ggplot() +
  geom_line(data = dat2, aes(x = Year, y = QLD_CPUE)) +
  geom_line(data = dat2, aes(x = Year, y = QLD_catch_t/ scaling_value), col="red") +
  #facet_wrap(~Region)+
  scale_y_continuous(sec.axis = sec_axis(~ . * scaling_value, name = "Catch (t)")) +
  theme_classic() + ylab("QLD CPUE (t/Fisher Day)")+
  theme(axis.text = element_text(colour="black", size=10),
        axis.title = element_text(face="bold"),
        axis.title.y.right = element_text(colour="red"),
        axis.text.y.right = element_text(colour="red"),
        strip.text = element_text(face="bold", size=10),
        strip.background = element_blank(),
        panel.border = element_rect(fill=NA))
ggsave("C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN_2020/Output/QLD CPUE and Catch total.png", dpi =600, width=21, height=14.8, units="cm")
