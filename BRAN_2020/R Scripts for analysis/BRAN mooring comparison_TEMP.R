# Compare Mooring and Bran TEMP
# Coffs 100

library(tidyverse)

mdat <- read_csv("imos moorings/temp/CH050_daily 10_30m summary.csv") %>% mutate(date=as.Date(date))
bran_dat <- read_csv("imos moorings/temp/Daily Temp_CH050_BRAN 10_30m.csv")


bran_dat <- bran_dat %>% mutate(date = as.numeric(str_remove(Date, pattern = "X"))) %>% arrange(date)
bran_dat <- bran_dat %>% mutate(date = as.Date(as.POSIXct(date*24*60*60, origin ="1979-01-01")))

all_dat <- full_join(bran_dat, mdat, by="date", suffix=c("_BRAN", "_Mooring"))

all_dat <- all_dat %>% filter(date >= min(mdat$date)) %>% filter(date <= max(bran_dat$date))

head(all_dat)

ggplot(all_dat, aes(x=date, y=Temp_Mooring)) + geom_line()+
  geom_line(aes(y=Temp_BRAN), col="red")

cor.test(all_dat$Temp_Mooring, all_dat$Temp_BRAN)
range(all_dat$date)


all_dat$Temp_BRAN_smooth = zoo::rollmean(all_dat$Temp_BRAN, 7, fill=NA)
all_dat$Temp_Mooring_smooth = zoo::rollmean(all_dat$Temp_Mooring, 7, fill=NA)

ggplot(all_dat, aes(x=date, y=Temp_Mooring_smooth)) + geom_line()+
  geom_line(aes(y=Temp_BRAN_smooth), col="red")

cor.test(all_dat$Temp_Mooring_smooth, all_dat$Temp_BRAN_smooth)

all_dat_long <- all_dat %>% select(date, Temp_BRAN_smooth, Temp_Mooring_smooth) %>%
  pivot_longer(cols=2:3, names_to = "Metric", values_to = "Velocity")


ggplot(all_dat_long, aes(x=date, y=Velocity, col=Metric)) + geom_line(size=1.25) + 
  theme_classic() + scale_colour_manual(values=c("blue", "red"))+
  scale_x_date(date_breaks = "1 year", date_minor_breaks = "1 month",
               date_labels = "%Y")+
  theme(legend.position = "bottom",
        legend.title = element_text(size=12, face="bold"),
        legend.text = element_text(size=12),
        axis.title = element_text(size=14, face="bold"),
        axis.text = element_text(size=12, colour="black"))

ggsave("BRAN Coffs50 Temp Comparison.png", dpi=600, width=21, height=14.8, units = "cm")


### Attempt taylor diagram

library('plotrix')

taylor.diagram(ref=all_dat$Temp_Mooring_smooth, model = all_dat$Temp_BRAN_smooth, normalize = F, pos.cor=T)
all_dat_Coffs50 <- all_dat


## Coffs70
mdat <- read_csv("imos moorings/temp/CH070_daily 10_30m summary.csv") %>% mutate(date=as.Date(date))
bran_dat <- read_csv("imos moorings/temp/Daily Temp_CH070_BRAN 10_30m.csv")


bran_dat <- bran_dat %>% mutate(date = as.numeric(str_remove(Date, pattern = "X"))) %>% arrange(date)
bran_dat <- bran_dat %>% mutate(date = as.Date(as.POSIXct(date*24*60*60, origin ="1979-01-01")))

all_dat <- full_join(bran_dat, mdat, by="date", suffix=c("_BRAN", "_Mooring"))

all_dat <- all_dat %>% filter(date >= min(mdat$date)) %>% filter(date <= max(bran_dat$date))

head(all_dat)

ggplot(all_dat, aes(x=date, y=Temp_Mooring)) + geom_line()+
  geom_line(aes(y=Temp_BRAN), col="red")

cor.test(all_dat$Temp_Mooring, all_dat$Temp_BRAN)
range(all_dat$date)


all_dat$Temp_BRAN_smooth = zoo::rollmean(all_dat$Temp_BRAN, 7, fill=NA)
all_dat$Temp_Mooring_smooth = zoo::rollmean(all_dat$Temp_Mooring, 7, fill=NA)

ggplot(all_dat, aes(x=date, y=Temp_Mooring_smooth)) + geom_line()+
  geom_line(aes(y=Temp_BRAN_smooth), col="red")

cor.test(all_dat$Temp_Mooring_smooth, all_dat$Temp_BRAN_smooth)

all_dat_long <- all_dat %>% select(date, Temp_BRAN_smooth, Temp_Mooring_smooth) %>%
  pivot_longer(cols=2:3, names_to = "Metric", values_to = "Velocity")


ggplot(all_dat_long, aes(x=date, y=Velocity, col=Metric)) + geom_line(size=1.25) + 
  theme_classic() + scale_colour_manual(values=c("blue", "red"))+
  scale_x_date(date_breaks = "1 year", date_minor_breaks = "1 month",
               date_labels = "%Y")+
  theme(legend.position = "bottom",
        legend.title = element_text(size=12, face="bold"),
        legend.text = element_text(size=12),
        axis.title = element_text(size=14, face="bold"),
        axis.text = element_text(size=12, colour="black"))

ggsave("BRAN Coffs70 Temp Comparison.png", dpi=600, width=21, height=14.8, units = "cm")


### Attempt taylor diagram

library('plotrix')

taylor.diagram(ref=all_dat$Temp_Mooring_smooth, model = all_dat$Temp_BRAN_smooth, normalize = F, pos.cor=T)
all_dat_Coffs70 <- all_dat



## Coffs100
mdat <- read_csv("imos moorings/temp/CH100_daily 10_30m summary.csv") %>% mutate(date=as.Date(date))
bran_dat <- read_csv("imos moorings/temp/Daily Temp_CH100_BRAN 10_30m.csv")


bran_dat <- bran_dat %>% mutate(date = as.numeric(str_remove(Date, pattern = "X"))) %>% arrange(date)
bran_dat <- bran_dat %>% mutate(date = as.Date(as.POSIXct(date*24*60*60, origin ="1979-01-01")))

all_dat <- full_join(bran_dat, mdat, by="date", suffix=c("_BRAN", "_Mooring"))

all_dat <- all_dat %>% filter(date >= min(mdat$date)) %>% filter(date <= max(bran_dat$date))

head(all_dat)

ggplot(all_dat, aes(x=date, y=Temp_Mooring)) + geom_line()+
  geom_line(aes(y=Temp_BRAN), col="red")

cor.test(all_dat$Temp_Mooring, all_dat$Temp_BRAN)
range(all_dat$date)


all_dat$Temp_BRAN_smooth = zoo::rollmean(all_dat$Temp_BRAN, 7, fill=NA)
all_dat$Temp_Mooring_smooth = zoo::rollmean(all_dat$Temp_Mooring, 7, fill=NA)

ggplot(all_dat, aes(x=date, y=Temp_Mooring_smooth)) + geom_line()+
  geom_line(aes(y=Temp_BRAN_smooth), col="red")

cor.test(all_dat$Temp_Mooring_smooth, all_dat$Temp_BRAN_smooth)

all_dat_long <- all_dat %>% select(date, Temp_BRAN_smooth, Temp_Mooring_smooth) %>%
  pivot_longer(cols=2:3, names_to = "Metric", values_to = "Temperature")


ggplot(all_dat_long, aes(x=date, y=Temperature, col=Metric)) + geom_line(size=1.25) + 
  theme_classic() + scale_colour_manual(values=c("blue", "red"))+
  scale_x_date(date_breaks = "1 year", date_minor_breaks = "1 month",
               date_labels = "%Y")+
  theme(legend.position = "bottom",
        legend.title = element_text(size=12, face="bold"),
        legend.text = element_text(size=12),
        axis.title = element_text(size=14, face="bold"),
        axis.text = element_text(size=12, colour="black"))

ggsave("BRAN Coffs100 Temp Comparison.png", dpi=600, width=21, height=14.8, units = "cm")


### Attempt taylor diagram

library('plotrix')

taylor.diagram(ref=all_dat$Temp_Mooring_smooth, model = all_dat$Temp_BRAN_smooth, normalize = F, pos.cor=T)
all_dat_Coffs100 <- all_dat


## EAC0500 - No Temp data

## EAC2000 
mdat <- read_csv("imos moorings/temp/EAC2000_daily 10_30m summary.csv") %>% mutate(date=as.Date(date))
bran_dat <- read_csv("imos moorings/temp/Daily Temp_EAC2000_BRAN 10_30m.csv")


bran_dat <- bran_dat %>% mutate(date = as.numeric(str_remove(Date, pattern = "X"))) %>% arrange(date)
bran_dat <- bran_dat %>% mutate(date = as.Date(as.POSIXct(date*24*60*60, origin ="1979-01-01")))

all_dat <- full_join(bran_dat, mdat, by="date", suffix=c("_BRAN", "_Mooring"))

all_dat <- all_dat %>% filter(date >= min(mdat$date)) %>% filter(date <= max(bran_dat$date))

head(all_dat)

ggplot(all_dat, aes(x=date, y=Temp_Mooring)) + geom_line()+
  geom_line(aes(y=Temp_BRAN), col="red")

cor.test(all_dat$Temp_Mooring, all_dat$Temp_BRAN)
range(all_dat$date)


all_dat$Temp_BRAN_smooth = zoo::rollmean(all_dat$Temp_BRAN, 7, fill=NA)
all_dat$Temp_Mooring_smooth = zoo::rollmean(all_dat$Temp_Mooring, 7, fill=NA)

ggplot(all_dat, aes(x=date, y=Temp_Mooring_smooth)) + geom_line()+
  geom_line(aes(y=Temp_BRAN_smooth), col="red")

cor.test(all_dat$Temp_Mooring_smooth, all_dat$Temp_BRAN_smooth)

all_dat_long <- all_dat %>% select(date, Temp_BRAN_smooth, Temp_Mooring_smooth) %>%
  pivot_longer(cols=2:3, names_to = "Metric", values_to = "Temperature")


ggplot(all_dat_long, aes(x=date, y=Temperature, col=Metric)) + geom_line(size=1.25) + 
  theme_classic() + scale_colour_manual(values=c("blue", "red"))+
  scale_x_date(date_breaks = "1 year", date_minor_breaks = "1 month",
               date_labels = "%Y")+
  theme(legend.position = "bottom",
        legend.title = element_text(size=12, face="bold"),
        legend.text = element_text(size=12),
        axis.title = element_text(size=14, face="bold"),
        axis.text = element_text(size=12, colour="black"))

ggsave("BRAN EAC2000 Temp Comparison.png", dpi=600, width=21, height=14.8, units = "cm")


### Attempt taylor diagram

library('plotrix')

taylor.diagram(ref=all_dat$Temp_Mooring_smooth, model = all_dat$Temp_BRAN_smooth, normalize = F, pos.cor=T)
all_dat_EAC2000 <- all_dat


## GBRCCH
mdat <- read_csv("imos moorings/temp/GBRCCH_daily 10_30m summary.csv") %>% mutate(date=as.Date(date))
bran_dat <- read_csv("imos moorings/temp/Daily Temp_GBRCCH_BRAN 10_30m.csv")


bran_dat <- bran_dat %>% mutate(date = as.numeric(str_remove(Date, pattern = "X"))) %>% arrange(date)
bran_dat <- bran_dat %>% mutate(date = as.Date(as.POSIXct(date*24*60*60, origin ="1979-01-01")))

all_dat <- full_join(bran_dat, mdat, by="date", suffix=c("_BRAN", "_Mooring"))

all_dat <- all_dat %>% filter(date >= min(mdat$date)) %>% filter(date <= max(bran_dat$date))

head(all_dat)

ggplot(all_dat, aes(x=date, y=Temp_Mooring)) + geom_line()+
  geom_line(aes(y=Temp_BRAN), col="red")

cor.test(all_dat$Temp_Mooring, all_dat$Temp_BRAN)
range(all_dat$date)


all_dat$Temp_BRAN_smooth = zoo::rollmean(all_dat$Temp_BRAN, 7, fill=NA)
all_dat$Temp_Mooring_smooth = zoo::rollmean(all_dat$Temp_Mooring, 7, fill=NA)

ggplot(all_dat, aes(x=date, y=Temp_Mooring_smooth)) + geom_line()+
  geom_line(aes(y=Temp_BRAN_smooth), col="red")

cor.test(all_dat$Temp_Mooring_smooth, all_dat$Temp_BRAN_smooth)

all_dat_long <- all_dat %>% select(date, Temp_BRAN_smooth, Temp_Mooring_smooth) %>%
  pivot_longer(cols=2:3, names_to = "Metric", values_to = "Temperature")


ggplot(all_dat_long, aes(x=date, y=Temperature, col=Metric)) + geom_line(size=1.25) + 
  theme_classic() + scale_colour_manual(values=c("blue", "red"))+
  scale_x_date(date_breaks = "1 year", date_minor_breaks = "1 month",
               date_labels = "%Y")+
  theme(legend.position = "bottom",
        legend.title = element_text(size=12, face="bold"),
        legend.text = element_text(size=12),
        axis.title = element_text(size=14, face="bold"),
        axis.text = element_text(size=12, colour="black"))

ggsave("BRAN GBRCCH Temp Comparison.png", dpi=600, width=21, height=14.8, units = "cm")


### Attempt taylor diagram

library('plotrix')

taylor.diagram(ref=all_dat$Temp_Mooring_smooth, model = all_dat$Temp_BRAN_smooth, normalize = F, pos.cor=T)
all_dat_GBRCCH <- all_dat



## GBRHIN
mdat <- read_csv("imos moorings/temp/GBRHIN_daily 10_30m summary.csv") %>% mutate(date=as.Date(date))
bran_dat <- read_csv("imos moorings/temp/Daily Temp_GBRHIN_BRAN 10_30m.csv")


bran_dat <- bran_dat %>% mutate(date = as.numeric(str_remove(Date, pattern = "X"))) %>% arrange(date)
bran_dat <- bran_dat %>% mutate(date = as.Date(as.POSIXct(date*24*60*60, origin ="1979-01-01")))

all_dat <- full_join(bran_dat, mdat, by="date", suffix=c("_BRAN", "_Mooring"))

all_dat <- all_dat %>% filter(date >= min(mdat$date)) %>% filter(date <= max(bran_dat$date))

head(all_dat)

ggplot(all_dat, aes(x=date, y=Temp_Mooring)) + geom_line()+
  geom_line(aes(y=Temp_BRAN), col="red")

cor.test(all_dat$Temp_Mooring, all_dat$Temp_BRAN)
range(all_dat$date)


all_dat$Temp_BRAN_smooth = zoo::rollmean(all_dat$Temp_BRAN, 7, fill=NA)
all_dat$Temp_Mooring_smooth = zoo::rollmean(all_dat$Temp_Mooring, 7, fill=NA)

ggplot(all_dat, aes(x=date, y=Temp_Mooring_smooth)) + geom_line()+
  geom_line(aes(y=Temp_BRAN_smooth), col="red")

cor.test(all_dat$Temp_Mooring_smooth, all_dat$Temp_BRAN_smooth)

all_dat_long <- all_dat %>% select(date, Temp_BRAN_smooth, Temp_Mooring_smooth) %>%
  pivot_longer(cols=2:3, names_to = "Metric", values_to = "Temperature")


ggplot(all_dat_long, aes(x=date, y=Temperature, col=Metric)) + geom_line(size=1.25) + 
  theme_classic() + scale_colour_manual(values=c("blue", "red"))+
  scale_x_date(date_breaks = "1 year", date_minor_breaks = "1 month",
               date_labels = "%Y")+
  theme(legend.position = "bottom",
        legend.title = element_text(size=12, face="bold"),
        legend.text = element_text(size=12),
        axis.title = element_text(size=14, face="bold"),
        axis.text = element_text(size=12, colour="black"))

ggsave("BRAN GBRHIN Temp Comparison.png", dpi=600, width=21, height=14.8, units = "cm")


### Attempt taylor diagram

library('plotrix')

taylor.diagram(ref=all_dat$Temp_Mooring_smooth, model = all_dat$Temp_BRAN_smooth, normalize = F, pos.cor=T)
all_dat_GBRHIN <- all_dat



## GBRHIS
mdat <- read_csv("imos moorings/temp/GBRHIS_daily 10_30m summary.csv") %>% mutate(date=as.Date(date))
bran_dat <- read_csv("imos moorings/temp/Daily Temp_GBRHIS_BRAN 10_30m.csv")


bran_dat <- bran_dat %>% mutate(date = as.numeric(str_remove(Date, pattern = "X"))) %>% arrange(date)
bran_dat <- bran_dat %>% mutate(date = as.Date(as.POSIXct(date*24*60*60, origin ="1979-01-01")))

all_dat <- full_join(bran_dat, mdat, by="date", suffix=c("_BRAN", "_Mooring"))

all_dat <- all_dat %>% filter(date >= min(mdat$date)) %>% filter(date <= max(bran_dat$date))

head(all_dat)

ggplot(all_dat, aes(x=date, y=Temp_Mooring)) + geom_line()+
  geom_line(aes(y=Temp_BRAN), col="red")

cor.test(all_dat$Temp_Mooring, all_dat$Temp_BRAN)
range(all_dat$date)


all_dat$Temp_BRAN_smooth = zoo::rollmean(all_dat$Temp_BRAN, 7, fill=NA)
all_dat$Temp_Mooring_smooth = zoo::rollmean(all_dat$Temp_Mooring, 7, fill=NA)

ggplot(all_dat, aes(x=date, y=Temp_Mooring_smooth)) + geom_line()+
  geom_line(aes(y=Temp_BRAN_smooth), col="red")

cor.test(all_dat$Temp_Mooring_smooth, all_dat$Temp_BRAN_smooth)

all_dat_long <- all_dat %>% select(date, Temp_BRAN_smooth, Temp_Mooring_smooth) %>%
  pivot_longer(cols=2:3, names_to = "Metric", values_to = "Temperature")


ggplot(all_dat_long, aes(x=date, y=Temperature, col=Metric)) + geom_line(size=1.25) + 
  theme_classic() + scale_colour_manual(values=c("blue", "red"))+
  scale_x_date(date_breaks = "1 year", date_minor_breaks = "1 month",
               date_labels = "%Y")+
  theme(legend.position = "bottom",
        legend.title = element_text(size=12, face="bold"),
        legend.text = element_text(size=12),
        axis.title = element_text(size=14, face="bold"),
        axis.text = element_text(size=12, colour="black"))

ggsave("BRAN GBRHIS Temp Comparison.png", dpi=600, width=21, height=14.8, units = "cm")


### Attempt taylor diagram

library('plotrix')

taylor.diagram(ref=all_dat$Temp_Mooring_smooth, model = all_dat$Temp_BRAN_smooth, normalize = F, pos.cor=T)
all_dat_GBRHIS <- all_dat


## GBROTE
mdat <- read_csv("imos moorings/temp/GBROTE_daily 10_30m summary.csv") %>% mutate(date=as.Date(date))
bran_dat <- read_csv("imos moorings/temp/Daily Temp_GBROTE_BRAN 10_30m.csv")


bran_dat <- bran_dat %>% mutate(date = as.numeric(str_remove(Date, pattern = "X"))) %>% arrange(date)
bran_dat <- bran_dat %>% mutate(date = as.Date(as.POSIXct(date*24*60*60, origin ="1979-01-01")))

all_dat <- full_join(bran_dat, mdat, by="date", suffix=c("_BRAN", "_Mooring"))

all_dat <- all_dat %>% filter(date >= min(mdat$date)) %>% filter(date <= max(bran_dat$date))

head(all_dat)

ggplot(all_dat, aes(x=date, y=Temp_Mooring)) + geom_line()+
  geom_line(aes(y=Temp_BRAN), col="red")

cor.test(all_dat$Temp_Mooring, all_dat$Temp_BRAN)
range(all_dat$date)


all_dat$Temp_BRAN_smooth = zoo::rollmean(all_dat$Temp_BRAN, 7, fill=NA)
all_dat$Temp_Mooring_smooth = zoo::rollmean(all_dat$Temp_Mooring, 7, fill=NA)

ggplot(all_dat, aes(x=date, y=Temp_Mooring_smooth)) + geom_line()+
  geom_line(aes(y=Temp_BRAN_smooth), col="red")

cor.test(all_dat$Temp_Mooring_smooth, all_dat$Temp_BRAN_smooth)

all_dat_long <- all_dat %>% select(date, Temp_BRAN_smooth, Temp_Mooring_smooth) %>%
  pivot_longer(cols=2:3, names_to = "Metric", values_to = "Temperature")


ggplot(all_dat_long, aes(x=date, y=Temperature, col=Metric)) + geom_line(size=1.25) + 
  theme_classic() + scale_colour_manual(values=c("blue", "red"))+
  scale_x_date(date_breaks = "1 year", date_minor_breaks = "1 month",
               date_labels = "%Y")+
  theme(legend.position = "bottom",
        legend.title = element_text(size=12, face="bold"),
        legend.text = element_text(size=12),
        axis.title = element_text(size=14, face="bold"),
        axis.text = element_text(size=12, colour="black"))

ggsave("BRAN GBROTE Temp Comparison.png", dpi=600, width=21, height=14.8, units = "cm")


### Attempt taylor diagram

library('plotrix')

taylor.diagram(ref=all_dat$Temp_Mooring_smooth, model = all_dat$Temp_BRAN_smooth, normalize = F, pos.cor=T)
all_dat_GBROTE <- all_dat



## NRSNSI
mdat <- read_csv("imos moorings/temp/NRSNSI_daily 10_30m summary.csv") %>% mutate(date=as.Date(date))
bran_dat <- read_csv("imos moorings/temp/Daily Temp_NRSNSI_BRAN 10_30m.csv")


bran_dat <- bran_dat %>% mutate(date = as.numeric(str_remove(Date, pattern = "X"))) %>% arrange(date)
bran_dat <- bran_dat %>% mutate(date = as.Date(as.POSIXct(date*24*60*60, origin ="1979-01-01")))

all_dat <- full_join(bran_dat, mdat, by="date", suffix=c("_BRAN", "_Mooring"))

all_dat <- all_dat %>% filter(date >= min(mdat$date)) %>% filter(date <= max(bran_dat$date))

head(all_dat)

ggplot(all_dat, aes(x=date, y=Temp_Mooring)) + geom_line()+
  geom_line(aes(y=Temp_BRAN), col="red")

cor.test(all_dat$Temp_Mooring, all_dat$Temp_BRAN)
range(all_dat$date)



all_dat$Temp_BRAN_smooth = zoo::rollmean(all_dat$Temp_BRAN, 7, fill=NA)
all_dat$Temp_Mooring_smooth = zoo::rollmean(all_dat$Temp_Mooring, 7, fill=NA)

ggplot(all_dat, aes(x=date, y=Temp_Mooring_smooth)) + geom_line()+
  geom_line(aes(y=Temp_BRAN_smooth), col="red")

cor.test(all_dat$Temp_Mooring_smooth, all_dat$Temp_BRAN_smooth)

all_dat_long <- all_dat %>% select(date, Temp_BRAN_smooth, Temp_Mooring_smooth) %>%
  pivot_longer(cols=2:3, names_to = "Metric", values_to = "Temperature")


ggplot(all_dat_long, aes(x=date, y=Temperature, col=Metric)) + geom_line(size=1.25) + 
  theme_classic() + scale_colour_manual(values=c("blue", "red"))+
  scale_x_date(date_breaks = "1 year", date_minor_breaks = "1 month",
               date_labels = "%Y")+
  theme(legend.position = "bottom",
        legend.title = element_text(size=12, face="bold"),
        legend.text = element_text(size=12),
        axis.title = element_text(size=14, face="bold"),
        axis.text = element_text(size=12, colour="black"))

ggsave("BRAN NRSNSI Temp Comparison.png", dpi=600, width=21, height=14.8, units = "cm")


### Attempt taylor diagram

library('plotrix')

taylor.diagram(ref=all_dat$Temp_Mooring_smooth, model = all_dat$Temp_BRAN_smooth, normalize = F, pos.cor=T)
all_dat_NRSNSI <- all_dat


### TAYLOR DIAGRAM ALL TOGETHER NOW
taylor.diagram(ref=all_dat_Coffs100$Temp_Mooring_smooth, model = all_dat_Coffs100$Temp_BRAN_smooth, normalize = F, pos.cor=F, add=F)
taylor.diagram(ref=all_dat_Coffs70$Temp_Mooring_smooth, model = all_dat_Coffs70$Temp_BRAN_smooth, normalize = F, pos.cor=F, add=T)
taylor.diagram(ref=all_dat_Coffs50$Temp_Mooring_smooth, model = all_dat_Coffs50$Temp_BRAN_smooth, normalize = F, pos.cor=F, add=T)
taylor.diagram(ref=all_dat_EAC2000$Temp_Mooring_smooth, model = all_dat_EAC2000$Temp_BRAN_smooth, normalize = F, pos.cor=F, add=T)
taylor.diagram(ref=all_dat_GBRCCH$Temp_Mooring_smooth, model = all_dat_GBRCCH$Temp_BRAN_smooth, normalize = F, pos.cor=F, add=T)
taylor.diagram(ref=all_dat_GBRHIN$Temp_Mooring_smooth, model = all_dat_GBRHIN$Temp_BRAN_smooth, normalize = F, pos.cor=F, add=T)
taylor.diagram(ref=all_dat_GBRHIS$Temp_Mooring_smooth, model = all_dat_GBRHIS$Temp_BRAN_smooth, normalize = F, pos.cor=F, add=T)
taylor.diagram(ref=all_dat_GBROTE$Temp_Mooring_smooth, model = all_dat_GBROTE$Temp_BRAN_smooth, normalize = F, pos.cor=F, add=T)
taylor.diagram(ref=all_dat_NRSNSI$Temp_Mooring_smooth, model = all_dat_NRSNSI$Temp_BRAN_smooth, normalize = F, pos.cor=F, add=T)

# Export as pdf and edit/tidy

