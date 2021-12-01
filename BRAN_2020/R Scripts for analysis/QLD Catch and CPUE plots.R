# QLD CPUE
#setwd("C:/Users/htsch/Desktop/Snapper Crab")
library(tidyverse)

### Updated Data from DJ (Figure S2)

dat2 <- read_csv("C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN_2020/Other Data/QLD_NSW_Data_30_11_21v3.csv")
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
