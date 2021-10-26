# DD Sensitivity plots

library(tidyverse)

file_list <- list.files("DD sensitivity/", pattern = ".csv", full.names = TRUE)
mydata <- list()

for (i in (1:length(file_list))){
  mydata[[i]] <- read_csv(file_list[i])
}

mydata <- bind_rows(mydata)

ggplot(mydata, aes(spawning_year, total, col=as.character(DD), 
                   linetype=as.character(DD),
                   group = DD)) + geom_point() + geom_line(col="grey40")+
  theme_classic() + scale_colour_viridis_d(name = "Degree\nDays") +
  scale_linetype_discrete(name="Degree\nDays") +
  scale_x_continuous(breaks=seq(1996, 2020, 4))+
  labs(y = "Relative Settlement in Zone 7", x = "Spawning Season Beginning") +
  theme(axis.text = element_text(colour="black", size=12),
        axis.title = element_text(size=14, face="bold"),
        axis.ticks = element_line(colour = "black"),
        legend.title = element_text(face="bold", size=14))
ggsave("Degree Days sensitivity plot.png", dpi=600, width =21, height=14.8, units="cm")


mydata800 <- read_csv("DD sensitivity/NSW DD Settlement 800DD.csv")
mydata1000 <- read_csv("DD sensitivity/NSW DD Settlement 1000DD.csv")
mydata1200 <- read_csv("DD sensitivity/NSW DD Settlement 1200DD.csv")
mydata1400 <- read_csv("DD sensitivity/NSW DD Settlement 1400DD.csv")

all_dat <- data.frame(DD800 = mydata800$total, DD1000 = mydata1000$total,
                      DD1200 = mydata1200$total, DD1400 = mydata1400$total)

psych::pairs.panels(all_dat)
