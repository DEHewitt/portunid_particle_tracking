# Initial Data Explore
library(tidyverse)

mydata <- read_csv("Spanner_CRAB_2009-2020.csv")

table(mydata$`Grid code`)
table(mydata$`Grid Site code`)
table(mydata$`Endorsement Code`)
table(mydata$`Fishing Method Name`)
hist(mydata$`Catch Effort Quantity`)

mydata2 <- mydata %>% filter(`Catch Effort Quantity` <200 & `Catch Effort Quantity` >5) %>% mutate(CPUE = `Catch Weight`/`Catch Effort Quantity`)
hist(mydata2$`Catch Effort Quantity`)
hist(mydata2$`CPUE`)

mydata3 <- mydata2 %>% group_by(`Event date Year`) %>% summarise(CPUE_mean = mean(CPUE, na.rm=T), sd_CPUE = sd(CPUE, na.rm=T), n=n(), se_CPUE = (sd_CPUE/sqrt(n)))


ggplot(mydata3, aes(`Event date Year`, CPUE_mean)) + geom_line() +
  geom_errorbar(aes(ymin=CPUE_mean-se_CPUE, ymax=CPUE_mean+se_CPUE)) +
  labs(x="Year", y="Mean CPUE (SE)")+
  theme_classic() + theme(axis.text = element_text(colour="black", size=12),
                          axis.title = element_text(face="bold", size=14))

ggsave("Spanner Crab CPUE.png", dpi=600, units = "cm", width=21, height=14.8)
write_csv(mydata3, "Spanner Crab Annual CPUE.csv")


### Other stuff
####
mydata2 <- mydata %>% group_by(`Event date Month`) %>%
  summarise(Total_Effort = sum(`Catch Effort Quantity`, na.rm=T), Total_Catch = sum(`Catch Weight`, na.rm=T),
            )# %>%
  mutate(`Event Date` = lubridate::dmy(`Event Date`))

ggplot(mydata2, aes(x=`Event date Month`, y = log(Total_Catch/Total_Effort))) + geom_point()

hist(mydata2$Total_Effort)
