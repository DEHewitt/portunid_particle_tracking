# CPUE Data comparison
library(tidyverse)
mydata <- read_csv("Spanner_for_HS__data_request_01072021.csv")
cor.test(mydata$`CPUE (kg.NL-1)`, mydata$`CPUE (kg.FisherDay-1)`)

mydata <- mydata %>% mutate(CPUE_net_stand = `CPUE (kg.NL-1)`/max(`CPUE (kg.NL-1)`, na.rm=T), # make standardised variables
                            CPUE_Kg_FishDay_stand = `CPUE (kg.FisherDay-1)`/max(`CPUE (kg.FisherDay-1)`, na.rm=T),
                            Catch_stand = `Catch (t)`/max(`Catch (t)`, na.rm=T))

mydata_long <- mydata %>% pivot_longer(cols=c(7,8,9), values_to = "value", names_to = "Metric")
unique(mydata_long$Metric)

ggplot(mydata_long, aes(x=Year, y = value, col=Metric, linetype=Metric)) + geom_line(size=1.5, alpha=0.6) + theme_classic() + # plot all standardised variables
  scale_x_continuous(breaks=seq(1984,2020,4))+ ylab("Rescaled CPUE")+
  scale_y_continuous(sec.axis = sec_axis(~ . *max(mydata$`Catch (t)`), name = "Catch (t)"))+ # this is where the right side axis is put in, so plot as standardised but the labels are showing unstandardised.
  theme(axis.text = element_text(colour="black", size=10),
        axis.text.y.right = element_text(color = "red"),
        axis.title.y.right = element_text(colour="red"),
        axis.line.y.right = element_line(colour="red"),
        legend.title = element_text(face="bold", size=14),
        axis.title = element_text(face="bold", size=12),
        legend.text = element_text(size=10),
        legend.position = c(0.3,0.2),
        legend.key.width = unit(2, units="cm"))+
  scale_color_manual(labels = c("Total Catch", "CPUE_kg/Fisher Day", "CPUE_kg/Net Lift"), values = c("red", "blue", "brown"))+ # redo legend
  scale_linetype_manual(labels = c("Total Catch", "CPUE_kg/Fisher Day", "CPUE_kg/Net Lift"), values = c(1, 2, 4))

  #scale_colour_viridis_d(option="C")
ggsave("Metrics over time2.png", dpi=600, units="cm", width = 21, height = 14.8)
ggsave("Metrics over time2.pdf", dpi=600, units="cm", width = 21, height = 14.8)

