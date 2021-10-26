# Compare Mooring and Bran
# Coffs 100

library(tidyverse)

mdat <- read_csv("imos moorings/velocity/Coffs 100 daily top30 summary.csv") %>% mutate(date=as.Date(date))
udat <- read_csv("imos moorings/Daily U Velocity CH100_BRAN 10_30m.csv")
vdat <- read_csv("imos moorings/Daily V Velocity CH100_BRAN 10_30m.csv")
bran_dat <- left_join(udat, vdat)

bran_dat <- bran_dat %>% mutate(date = as.numeric(str_remove(Date, pattern = "X"))) %>% arrange(date)
bran_dat <- bran_dat %>% mutate(date = as.Date(as.POSIXct(date*24*60*60, origin ="1979-01-01")))

all_dat <- full_join(bran_dat, mdat, by="date", suffix=c("_BRAN", "_Mooring"))

all_dat <- all_dat %>% filter(date >= min(mdat$date)) %>% filter(date <= max(bran_dat$date))

head(all_dat)

ggplot(all_dat, aes(x=date, y=VCUR_Mooring)) + geom_line()+
  geom_line(aes(y=VCUR_BRAN), col="red")

cor.test(all_dat$VCUR_BRAN, all_dat$VCUR_Mooring)


ggplot(all_dat, aes(x=date, y=UCUR_Mooring)) + geom_line()+
  geom_line(aes(y=UCUR_BRAN), col="red")

cor.test(all_dat$UCUR_BRAN, all_dat$UCUR_Mooring)


all_dat <- all_dat %>% mutate(Vel_BRAN = sqrt((VCUR_BRAN^2 + UCUR_BRAN^2)), 
                              Vel_Mooring = sqrt((VCUR_Mooring^2 + UCUR_Mooring^2)))

ggplot(all_dat, aes(x=date, y=Vel_Mooring)) + geom_line()+
  geom_line(aes(y=Vel_BRAN), col="red")

cor.test(all_dat$Vel_BRAN, all_dat$Vel_Mooring)

all_dat$Vel_BRAN_smooth = zoo::rollmean(all_dat$Vel_BRAN, 7, fill=NA)
all_dat$Vel_Mooring_smooth = zoo::rollmean(all_dat$Vel_Mooring, 7, fill=NA)

ggplot(all_dat, aes(x=date, y=Vel_Mooring_smooth)) + geom_line()+
  geom_line(aes(y=Vel_BRAN_smooth), col="red")

cor.test(all_dat$Vel_BRAN_smooth, all_dat$Vel_Mooring_smooth)

all_dat_long <- all_dat %>% select(date, Vel_BRAN_smooth, Vel_Mooring_smooth) %>%
  pivot_longer(cols=2:3, names_to = "Metric", values_to = "Velocity")


ggplot(all_dat_long, aes(x=date, y=Velocity, col=Metric)) + geom_line(size=1.25) + 
  theme_classic() + scale_colour_manual(values=c("blue", "red"))+
  scale_x_date(date_breaks = "1 year", date_minor_breaks = "1 month",
               date_labels = "%Y")+
  theme(legend.position = "bottom",
        legend.title = element_text(size=12, face="bold"),
        legend.text = element_text(size=12),
        axis.title = element_text(size=14, face="bold"),
        axis.text = element_text(size=12, colour="black"))+
  annotate("text", x= as.Date("2010-02-01"), y = 1.2, label = "r = 0.47")

ggsave("BRAN Coffs Comparison.png", dpi=600, width=21, height=14.8, units = "cm")

plot(all_dat$Vel_BRAN, all_dat$Vel_Mooring)

### Attempt taylor diagram

library('plotrix')

taylor.diagram(ref=all_dat$Vel_Mooring_smooth, model = all_dat$Vel_BRAN_smooth, normalize = F, pos.cor=T)
all_dat_Coffs100 <- all_dat
  




### Coffs 70


mdat <- read_csv("imos moorings/velocity/Coffs 70 daily top30 summary.csv") %>% mutate(date=as.Date(date))
udat <- read_csv("imos moorings/Daily U Velocity CH070_BRAN 10_30m.csv")
vdat <- read_csv("imos moorings/Daily V Velocity CH050_BRAN 10_30m.csv")
bran_dat <- left_join(udat, vdat)

bran_dat <- bran_dat %>% mutate(date = as.numeric(str_remove(Date, pattern = "X"))) %>% arrange(date)
bran_dat <- bran_dat %>% mutate(date = as.Date(as.POSIXct(date*24*60*60, origin ="1979-01-01")))

all_dat <- full_join(bran_dat, mdat, by="date", suffix=c("_BRAN", "_Mooring"))

all_dat <- all_dat %>% filter(date >= min(mdat$date)) %>% filter(date <= max(bran_dat$date))

head(all_dat)

ggplot(all_dat, aes(x=date, y=VCUR_Mooring)) + geom_line()+
  geom_line(aes(y=VCUR_BRAN), col="red")

cor.test(all_dat$VCUR_BRAN, all_dat$VCUR_Mooring)


ggplot(all_dat, aes(x=date, y=UCUR_Mooring)) + geom_line()+
  geom_line(aes(y=UCUR_BRAN), col="red")

cor.test(all_dat$UCUR_BRAN, all_dat$UCUR_Mooring)


all_dat <- all_dat %>% mutate(Vel_BRAN = sqrt((VCUR_BRAN^2 + UCUR_BRAN^2)), 
                              Vel_Mooring = sqrt((VCUR_Mooring^2 + UCUR_Mooring^2)))

ggplot(all_dat, aes(x=date, y=Vel_Mooring)) + geom_line()+
  geom_line(aes(y=Vel_BRAN), col="red")

cor.test(all_dat$Vel_BRAN, all_dat$Vel_Mooring)

all_dat$Vel_BRAN_smooth = zoo::rollmean(all_dat$Vel_BRAN, 7, fill=NA)
all_dat$Vel_Mooring_smooth = zoo::rollmean(all_dat$Vel_Mooring, 7, fill=NA)

ggplot(all_dat, aes(x=date, y=Vel_Mooring_smooth)) + geom_line()+
  geom_line(aes(y=Vel_BRAN_smooth), col="red")

cor.test(all_dat$Vel_BRAN_smooth, all_dat$Vel_Mooring_smooth)

all_dat_long <- all_dat %>% select(date, Vel_BRAN_smooth, Vel_Mooring_smooth) %>%
  pivot_longer(cols=2:3, names_to = "Metric", values_to = "Velocity")


ggplot(all_dat_long, aes(x=date, y=Velocity, col=Metric)) + geom_line(size=1.25) + 
  theme_classic() + scale_colour_manual(values=c("blue", "red"))+
  scale_x_date(date_breaks = "1 year", date_minor_breaks = "1 month",
               date_labels = "%Y")+
  theme(legend.position = "bottom",
        legend.title = element_text(size=12, face="bold"),
        legend.text = element_text(size=12),
        axis.title = element_text(size=14, face="bold"),
        axis.text = element_text(size=12, colour="black"))+
  annotate("text", x= as.Date("2010-02-01"), y = 1.2, label = "r = 0.47")

ggsave("BRAN Coffs 70 Comparison.png", dpi=600, width=21, height=14.8, units = "cm")

plot(all_dat$Vel_BRAN, all_dat$Vel_Mooring)

### Attempt taylor diagram

library('plotrix')

taylor.diagram(ref=all_dat$Vel_Mooring_smooth, model = all_dat$Vel_BRAN_smooth, normalize = F, pos.cor=T)
all_dat_Coffs70 <- all_dat


############# North Stradbroke
  ## Waiting for BRAN
library(tidyverse)
  
  mdat <- read_csv("imos moorings/velocity/NS NRS daily top30 summary.csv") %>% mutate(date=as.Date(date))
  udat <- read_csv("imos moorings/Daily U Velocity NRSNSI_BRAN 10_30m.csv")
  vdat <- read_csv("imos moorings/Daily V Velocity NRSNSI_BRAN 10_30m.csv")
  bran_dat <- left_join(udat, vdat)
  
  bran_dat <- bran_dat %>% mutate(date = as.numeric(str_remove(Date, pattern = "X"))) %>% arrange(date)
  bran_dat <- bran_dat %>% mutate(date = as.Date(as.POSIXct(date*24*60*60, origin ="1979-01-01")))
  
  all_dat <- full_join(bran_dat, mdat, by="date", suffix=c("_BRAN", "_Mooring"))
  
  all_dat <- all_dat %>% filter(date >= min(mdat$date)) %>% filter(date <= max(bran_dat$date))
  
  head(all_dat)
  
  ggplot(all_dat, aes(x=date, y=VCUR_Mooring)) + geom_line()+
    geom_line(aes(y=VCUR_BRAN), col="red")
  
  cor.test(all_dat$VCUR_BRAN, all_dat$VCUR_Mooring)
  
  
  ggplot(all_dat, aes(x=date, y=UCUR_Mooring)) + geom_line()+
    geom_line(aes(y=UCUR_BRAN), col="red")
  
  cor.test(all_dat$UCUR_BRAN, all_dat$UCUR_Mooring)
  
  
  all_dat <- all_dat %>% mutate(KE_BRAN = sqrt(VCUR_BRAN^2 + UCUR_BRAN^2), 
                                KE_Mooring = sqrt(VCUR_Mooring^2 + UCUR_Mooring^2))
  
  ggplot(all_dat, aes(x=date, y=KE_Mooring)) + geom_line()+
    geom_line(aes(y=KE_BRAN), col="red")
  
  cor.test(all_dat$KE_BRAN, all_dat$KE_Mooring)
  
  all_dat$KE_BRAN_smooth = zoo::rollmean(all_dat$KE_BRAN, 7, fill=NA)
  all_dat$KE_Mooring_smooth = zoo::rollmean(all_dat$KE_Mooring, 7, fill=NA)
  
  ggplot(all_dat, aes(x=date, y=KE_Mooring_smooth)) + geom_line()+
    geom_line(aes(y=KE_BRAN_smooth), col="red")
  
  cor.test(all_dat$KE_BRAN_smooth, all_dat$KE_Mooring_smooth)
  
  all_dat_long <- all_dat %>% select(date, KE_BRAN_smooth, KE_Mooring_smooth) %>%
    pivot_longer(cols=2:3, names_to = "Metric", values_to = "KE")
  
  
  ggplot(all_dat_long, aes(x=date, y=KE, col=Metric)) + geom_line(size=1.25) + 
    theme_classic() + scale_colour_manual(values=c("blue", "red"))+
    scale_x_date(date_breaks = "1 year", date_minor_breaks = "1 month",
                 date_labels = "%Y")+
    ylab("Velocity m/s")+
    theme(legend.position = "bottom",
          legend.title = element_text(size=12, face="bold"),
          legend.text = element_text(size=12),
          axis.title = element_text(size=14, face="bold"),
          axis.text = element_text(size=12, colour="black"))+
    annotate("text", x= as.Date("2010-02-01"), y = 0.3, label = "r = 0.36")
  
  ggsave("BRAN NS Comparison.png", dpi=600, width=21, height=14.8, units = "cm")
  taylor.diagram(ref=all_dat$KE_Mooring_smooth, model = all_dat$KE_BRAN_smooth, normalize = F, pos.cor=T)
  all_dat_NRS_NS <- all_dat
  
  

  ############# EAC 500

  library(tidyverse)
  
  mdat <- read_csv("imos moorings/velocity/EAC 500 daily top30 summary.csv") %>% mutate(date=as.Date(date))
  udat <- read_csv("imos moorings/Daily U Velocity EAC0500_BRAN 10_30m.csv")
  vdat <- read_csv("imos moorings/Daily V Velocity EAC0500_BRAN 10_30m.csv")
  bran_dat <- left_join(udat, vdat)
  
  bran_dat <- bran_dat %>% mutate(date = as.numeric(str_remove(Date, pattern = "X"))) %>% arrange(date)
  bran_dat <- bran_dat %>% mutate(date = as.Date(as.POSIXct(date*24*60*60, origin ="1979-01-01")))
  
  all_dat <- full_join(bran_dat, mdat, by="date", suffix=c("_BRAN", "_Mooring"))
  
  all_dat <- all_dat %>% filter(date >= min(mdat$date)) %>% filter(date <= max(bran_dat$date))
  
  head(all_dat)
  
  ggplot(all_dat, aes(x=date, y=VCUR_Mooring)) + geom_line()+
    geom_line(aes(y=VCUR_BRAN), col="red")
  
  cor.test(all_dat$VCUR_BRAN, all_dat$VCUR_Mooring)
  
  
  ggplot(all_dat, aes(x=date, y=UCUR_Mooring)) + geom_line()+
    geom_line(aes(y=UCUR_BRAN), col="red")
  
  cor.test(all_dat$UCUR_BRAN, all_dat$UCUR_Mooring)
  
  
  all_dat <- all_dat %>% mutate(KE_BRAN = sqrt(VCUR_BRAN^2 + UCUR_BRAN^2), 
                                KE_Mooring = sqrt(VCUR_Mooring^2 + UCUR_Mooring^2))
  
  ggplot(all_dat, aes(x=date, y=KE_Mooring)) + geom_line()+
    geom_line(aes(y=KE_BRAN), col="red")
  
  cor.test(all_dat$KE_BRAN, all_dat$KE_Mooring)
  
  all_dat$KE_BRAN_smooth = zoo::rollmean(all_dat$KE_BRAN, 7, fill=NA)
  all_dat$KE_Mooring_smooth = zoo::rollmean(all_dat$KE_Mooring, 7, fill=NA)
  
  ggplot(all_dat, aes(x=date, y=KE_Mooring_smooth)) + geom_line()+
    geom_line(aes(y=KE_BRAN_smooth), col="red")
  
  cor.test(all_dat$KE_BRAN_smooth, all_dat$KE_Mooring_smooth)
  
  all_dat_long <- all_dat %>% select(date, KE_BRAN_smooth, KE_Mooring_smooth) %>%
    pivot_longer(cols=2:3, names_to = "Metric", values_to = "KE")
  
  
  ggplot(all_dat_long, aes(x=date, y=KE, col=Metric)) + geom_line(size=1.25) + 
    theme_classic() + scale_colour_manual(values=c("blue", "red"))+
    scale_x_date(date_breaks = "1 year", date_minor_breaks = "1 month",
                 date_labels = "%Y")+
    ylab("Velocity m/s")+
    theme(legend.position = "bottom",
          legend.title = element_text(size=12, face="bold"),
          legend.text = element_text(size=12),
          axis.title = element_text(size=14, face="bold"),
          axis.text = element_text(size=12, colour="black"))+
    annotate("text", x= as.Date("2010-02-01"), y = 0.3, label = "r = 0.36")
  
  ggsave("BRAN EAC 500 Comparison.png", dpi=600, width=21, height=14.8, units = "cm")
  taylor.diagram(ref=all_dat$KE_Mooring_smooth, model = all_dat$KE_BRAN_smooth, normalize = F, pos.cor=T)
  all_dat_EAC500 <- all_dat
  

  ############# EAC 2000

  library(tidyverse)
  
  mdat <- read_csv("imos moorings/velocity/EAC 2000m daily top30 summary.csv") %>% mutate(date=as.Date(date))
  udat <- read_csv("imos moorings/Daily U Velocity EAC2000_BRAN 10_30m.csv")
  vdat <- read_csv("imos moorings/Daily V Velocity EAC2000_BRAN 10_30m.csv")
  bran_dat <- left_join(udat, vdat)
  
  bran_dat <- bran_dat %>% mutate(date = as.numeric(str_remove(Date, pattern = "X"))) %>% arrange(date)
  bran_dat <- bran_dat %>% mutate(date = as.Date(as.POSIXct(date*24*60*60, origin ="1979-01-01")))
  
  all_dat <- full_join(bran_dat, mdat, by="date", suffix=c("_BRAN", "_Mooring"))
  
  all_dat <- all_dat %>% filter(date >= min(mdat$date)) %>% filter(date <= max(bran_dat$date))
  
  head(all_dat)
  
  ggplot(all_dat, aes(x=date, y=VCUR_Mooring)) + geom_line()+
    geom_line(aes(y=VCUR_BRAN), col="red")
  
  cor.test(all_dat$VCUR_BRAN, all_dat$VCUR_Mooring)
  
  
  ggplot(all_dat, aes(x=date, y=UCUR_Mooring)) + geom_line()+
    geom_line(aes(y=UCUR_BRAN), col="red")
  
  cor.test(all_dat$UCUR_BRAN, all_dat$UCUR_Mooring)
  
  
  all_dat <- all_dat %>% mutate(KE_BRAN = sqrt(VCUR_BRAN^2 + UCUR_BRAN^2), 
                                KE_Mooring = sqrt(VCUR_Mooring^2 + UCUR_Mooring^2))
  
  ggplot(all_dat, aes(x=date, y=KE_Mooring)) + geom_line()+
    geom_line(aes(y=KE_BRAN), col="red")
  
  cor.test(all_dat$KE_BRAN, all_dat$KE_Mooring)
  
  all_dat$KE_BRAN_smooth = zoo::rollmean(all_dat$KE_BRAN, 7, fill=NA)
  all_dat$KE_Mooring_smooth = zoo::rollmean(all_dat$KE_Mooring, 7, fill=NA)
  
  ggplot(all_dat, aes(x=date, y=KE_Mooring_smooth)) + geom_line()+
    geom_line(aes(y=KE_BRAN_smooth), col="red")
  
  cor.test(all_dat$KE_BRAN_smooth, all_dat$KE_Mooring_smooth)
  
  all_dat_long <- all_dat %>% select(date, KE_BRAN_smooth, KE_Mooring_smooth) %>%
    pivot_longer(cols=2:3, names_to = "Metric", values_to = "KE")
  
  
  ggplot(all_dat_long, aes(x=date, y=KE, col=Metric)) + geom_line(size=1.25) + 
    theme_classic() + scale_colour_manual(values=c("blue", "red"))+
    scale_x_date(date_breaks = "1 year", date_minor_breaks = "1 month",
                 date_labels = "%Y")+
    ylab("Velocity m/s")+
    theme(legend.position = "bottom",
          legend.title = element_text(size=12, face="bold"),
          legend.text = element_text(size=12),
          axis.title = element_text(size=14, face="bold"),
          axis.text = element_text(size=12, colour="black"))+
    annotate("text", x= as.Date("2010-02-01"), y = 0.3, label = "r = 0.36")
  
  ggsave("BRAN EAC 2000 Comparison.png", dpi=600, width=21, height=14.8, units = "cm")
  taylor.diagram(ref=all_dat$KE_Mooring_smooth, model = all_dat$KE_BRAN_smooth, normalize = F, pos.cor=T)
  all_dat_EAC2000 <- all_dat
  
  
  ############# EAC 3200
  
  library(tidyverse)
  
  mdat <- read_csv("imos moorings/velocity/EAC 3200m daily top30 summary.csv") %>% mutate(date=as.Date(date))
  udat <- read_csv("imos moorings/Daily U Velocity EAC3200_BRAN 10_30m.csv")
  vdat <- read_csv("imos moorings/Daily V Velocity EAC3200_BRAN 10_30m.csv")
  bran_dat <- left_join(udat, vdat)
  
  bran_dat <- bran_dat %>% mutate(date = as.numeric(str_remove(Date, pattern = "X"))) %>% arrange(date)
  bran_dat <- bran_dat %>% mutate(date = as.Date(as.POSIXct(date*24*60*60, origin ="1979-01-01")))
  
  all_dat <- full_join(bran_dat, mdat, by="date", suffix=c("_BRAN", "_Mooring"))
  
  all_dat <- all_dat %>% filter(date >= min(mdat$date)) %>% filter(date <= max(bran_dat$date))
  
  head(all_dat)
  
  ggplot(all_dat, aes(x=date, y=VCUR_Mooring)) + geom_line()+
    geom_line(aes(y=VCUR_BRAN), col="red")
  
  cor.test(all_dat$VCUR_BRAN, all_dat$VCUR_Mooring)
  
  
  ggplot(all_dat, aes(x=date, y=UCUR_Mooring)) + geom_line()+
    geom_line(aes(y=UCUR_BRAN), col="red")
  
  cor.test(all_dat$UCUR_BRAN, all_dat$UCUR_Mooring)
  
  
  all_dat <- all_dat %>% mutate(KE_BRAN = sqrt(VCUR_BRAN^2 + UCUR_BRAN^2), 
                                KE_Mooring = sqrt(VCUR_Mooring^2 + UCUR_Mooring^2))
  
  ggplot(all_dat, aes(x=date, y=KE_Mooring)) + geom_line()+
    geom_line(aes(y=KE_BRAN), col="red")
  
  cor.test(all_dat$KE_BRAN, all_dat$KE_Mooring)
  
  all_dat$KE_BRAN_smooth = zoo::rollmean(all_dat$KE_BRAN, 7, fill=NA)
  all_dat$KE_Mooring_smooth = zoo::rollmean(all_dat$KE_Mooring, 7, fill=NA)
  
  ggplot(all_dat, aes(x=date, y=KE_Mooring_smooth)) + geom_line()+
    geom_line(aes(y=KE_BRAN_smooth), col="red")
  
  cor.test(all_dat$KE_BRAN_smooth, all_dat$KE_Mooring_smooth)
  
  all_dat_long <- all_dat %>% select(date, KE_BRAN_smooth, KE_Mooring_smooth) %>%
    pivot_longer(cols=2:3, names_to = "Metric", values_to = "KE")
  
  
  ggplot(all_dat_long, aes(x=date, y=KE, col=Metric)) + geom_line(size=1.25) + 
    theme_classic() + scale_colour_manual(values=c("blue", "red"))+
    scale_x_date(date_breaks = "1 year", date_minor_breaks = "1 month",
                 date_labels = "%Y")+
    ylab("Velocity m/s")+
    theme(legend.position = "bottom",
          legend.title = element_text(size=12, face="bold"),
          legend.text = element_text(size=12),
          axis.title = element_text(size=14, face="bold"),
          axis.text = element_text(size=12, colour="black"))+
    annotate("text", x= as.Date("2010-02-01"), y = 0.3, label = "r = 0.36")
  
  ggsave("BRAN EAC 3200 Comparison.png", dpi=600, width=21, height=14.8, units = "cm")
  taylor.diagram(ref=all_dat$KE_Mooring_smooth, model = all_dat$KE_BRAN_smooth, normalize = F, pos.cor=T)
  all_dat_EAC3200 <- all_dat
  
  
  ############# EAC 4700
  
  library(tidyverse)
  
  mdat <- read_csv("imos moorings/velocity/EAC 4700m daily top30 summary.csv") %>% mutate(date=as.Date(date))
  udat <- read_csv("imos moorings/Daily U Velocity EAC4700_BRAN 10_30m.csv")
  vdat <- read_csv("imos moorings/Daily V Velocity EAC4700_BRAN 10_30m.csv")
  bran_dat <- left_join(udat, vdat)
  
  bran_dat <- bran_dat %>% mutate(date = as.numeric(str_remove(Date, pattern = "X"))) %>% arrange(date)
  bran_dat <- bran_dat %>% mutate(date = as.Date(as.POSIXct(date*24*60*60, origin ="1979-01-01")))
  
  all_dat <- full_join(bran_dat, mdat, by="date", suffix=c("_BRAN", "_Mooring"))
  
  all_dat <- all_dat %>% filter(date >= min(mdat$date)) %>% filter(date <= max(bran_dat$date))
  
  head(all_dat)
  
  ggplot(all_dat, aes(x=date, y=VCUR_Mooring)) + geom_line()+
    geom_line(aes(y=VCUR_BRAN), col="red")
  
  cor.test(all_dat$VCUR_BRAN, all_dat$VCUR_Mooring)
  
  
  ggplot(all_dat, aes(x=date, y=UCUR_Mooring)) + geom_line()+
    geom_line(aes(y=UCUR_BRAN), col="red")
  
  cor.test(all_dat$UCUR_BRAN, all_dat$UCUR_Mooring)
  
  
  all_dat <- all_dat %>% mutate(KE_BRAN = sqrt(VCUR_BRAN^2 + UCUR_BRAN^2), 
                                KE_Mooring = sqrt(VCUR_Mooring^2 + UCUR_Mooring^2))
  
  ggplot(all_dat, aes(x=date, y=KE_Mooring)) + geom_line()+
    geom_line(aes(y=KE_BRAN), col="red")
  
  cor.test(all_dat$KE_BRAN, all_dat$KE_Mooring)
  
  all_dat$KE_BRAN_smooth = zoo::rollmean(all_dat$KE_BRAN, 7, fill=NA)
  all_dat$KE_Mooring_smooth = zoo::rollmean(all_dat$KE_Mooring, 7, fill=NA)
  
  ggplot(all_dat, aes(x=date, y=KE_Mooring_smooth)) + geom_line()+
    geom_line(aes(y=KE_BRAN_smooth), col="red")
  
  cor.test(all_dat$KE_BRAN_smooth, all_dat$KE_Mooring_smooth)
  
  all_dat_long <- all_dat %>% select(date, KE_BRAN_smooth, KE_Mooring_smooth) %>%
    pivot_longer(cols=2:3, names_to = "Metric", values_to = "KE")
  
  
  ggplot(all_dat_long, aes(x=date, y=KE, col=Metric)) + geom_line(size=1.25) + 
    theme_classic() + scale_colour_manual(values=c("blue", "red"))+
    scale_x_date(date_breaks = "1 year", date_minor_breaks = "1 month",
                 date_labels = "%Y")+
    ylab("Velocity m/s")+
    theme(legend.position = "bottom",
          legend.title = element_text(size=12, face="bold"),
          legend.text = element_text(size=12),
          axis.title = element_text(size=14, face="bold"),
          axis.text = element_text(size=12, colour="black"))+
    annotate("text", x= as.Date("2010-02-01"), y = 0.3, label = "r = 0.36")
  
  ggsave("BRAN EAC 4700 Comparison.png", dpi=600, width=21, height=14.8, units = "cm")
  taylor.diagram(ref=all_dat$KE_Mooring_smooth, model = all_dat$KE_BRAN_smooth, normalize = F, pos.cor=T)
  all_dat_EAC4700 <- all_dat
  
  
  ############# GBR CCH
  
  library(tidyverse)
  
  mdat <- read_csv("imos moorings/velocity/GBR CCH daily top30 summary.csv") %>% mutate(date=as.Date(date))
  udat <- read_csv("imos moorings/Daily U Velocity GBRCCH_BRAN 10_30m.csv")
  vdat <- read_csv("imos moorings/Daily V Velocity GBRCCH_BRAN 10_30m.csv")
  bran_dat <- left_join(udat, vdat)
  
  bran_dat <- bran_dat %>% mutate(date = as.numeric(str_remove(Date, pattern = "X"))) %>% arrange(date)
  bran_dat <- bran_dat %>% mutate(date = as.Date(as.POSIXct(date*24*60*60, origin ="1979-01-01")))
  
  all_dat <- full_join(bran_dat, mdat, by="date", suffix=c("_BRAN", "_Mooring"))
  
  all_dat <- all_dat %>% filter(date >= min(mdat$date)) %>% filter(date <= max(bran_dat$date))
  
  head(all_dat)
  
  ggplot(all_dat, aes(x=date, y=VCUR_Mooring)) + geom_line()+
    geom_line(aes(y=VCUR_BRAN), col="red")
  
  cor.test(all_dat$VCUR_BRAN, all_dat$VCUR_Mooring)
  
  
  ggplot(all_dat, aes(x=date, y=UCUR_Mooring)) + geom_line()+
    geom_line(aes(y=UCUR_BRAN), col="red")
  
  cor.test(all_dat$UCUR_BRAN, all_dat$UCUR_Mooring)
  
  
  all_dat <- all_dat %>% mutate(KE_BRAN = sqrt(VCUR_BRAN^2 + UCUR_BRAN^2), 
                                KE_Mooring = sqrt(VCUR_Mooring^2 + UCUR_Mooring^2))
  
  ggplot(all_dat, aes(x=date, y=KE_Mooring)) + geom_line()+
    geom_line(aes(y=KE_BRAN), col="red")
  
  cor.test(all_dat$KE_BRAN, all_dat$KE_Mooring)
  
  all_dat$KE_BRAN_smooth = zoo::rollmean(all_dat$KE_BRAN, 7, fill=NA)
  all_dat$KE_Mooring_smooth = zoo::rollmean(all_dat$KE_Mooring, 7, fill=NA)
  
  ggplot(all_dat, aes(x=date, y=KE_Mooring_smooth)) + geom_line()+
    geom_line(aes(y=KE_BRAN_smooth), col="red")
  
  cor.test(all_dat$KE_BRAN_smooth, all_dat$KE_Mooring_smooth)
  
  all_dat_long <- all_dat %>% select(date, KE_BRAN_smooth, KE_Mooring_smooth) %>%
    pivot_longer(cols=2:3, names_to = "Metric", values_to = "KE")
  
  
  ggplot(all_dat_long, aes(x=date, y=KE, col=Metric)) + geom_line(size=1.25) + 
    theme_classic() + scale_colour_manual(values=c("blue", "red"))+
    scale_x_date(date_breaks = "1 year", date_minor_breaks = "1 month",
                 date_labels = "%Y")+
    ylab("Velocity m/s")+
    theme(legend.position = "bottom",
          legend.title = element_text(size=12, face="bold"),
          legend.text = element_text(size=12),
          axis.title = element_text(size=14, face="bold"),
          axis.text = element_text(size=12, colour="black"))+
    annotate("text", x= as.Date("2010-02-01"), y = 0.3, label = "r = 0.36")
  
  ggsave("BRAN GBR CCH Comparison.png", dpi=600, width=21, height=14.8, units = "cm")
  taylor.diagram(ref=all_dat$KE_Mooring_smooth, model = all_dat$KE_BRAN_smooth, normalize = F, pos.cor=T)
  all_dat_GBE_CCH <- all_dat
  
  
  ############# GBR HIN
  
  library(tidyverse)
  
  mdat <- read_csv("imos moorings/velocity/GBR HIN daily top30 summary.csv") %>% mutate(date=as.Date(date))
  udat <- read_csv("imos moorings/Daily U Velocity GBRHIN_BRAN 10_30m.csv")
  vdat <- read_csv("imos moorings/Daily V Velocity GBRHIN_BRAN 10_30m.csv")
  bran_dat <- left_join(udat, vdat)
  
  bran_dat <- bran_dat %>% mutate(date = as.numeric(str_remove(Date, pattern = "X"))) %>% arrange(date)
  bran_dat <- bran_dat %>% mutate(date = as.Date(as.POSIXct(date*24*60*60, origin ="1979-01-01")))
  
  all_dat <- full_join(bran_dat, mdat, by="date", suffix=c("_BRAN", "_Mooring"))
  
  all_dat <- all_dat %>% filter(date >= min(mdat$date)) %>% filter(date <= max(bran_dat$date))
  
  head(all_dat)
  
  ggplot(all_dat, aes(x=date, y=VCUR_Mooring)) + geom_line()+
    geom_line(aes(y=VCUR_BRAN), col="red")
  
  cor.test(all_dat$VCUR_BRAN, all_dat$VCUR_Mooring)
  
  
  ggplot(all_dat, aes(x=date, y=UCUR_Mooring)) + geom_line()+
    geom_line(aes(y=UCUR_BRAN), col="red")
  
  cor.test(all_dat$UCUR_BRAN, all_dat$UCUR_Mooring)
  
  
  all_dat <- all_dat %>% mutate(KE_BRAN = sqrt(VCUR_BRAN^2 + UCUR_BRAN^2), 
                                KE_Mooring = sqrt(VCUR_Mooring^2 + UCUR_Mooring^2))
  
  ggplot(all_dat, aes(x=date, y=KE_Mooring)) + geom_line()+
    geom_line(aes(y=KE_BRAN), col="red")
  
  cor.test(all_dat$KE_BRAN, all_dat$KE_Mooring)
  
  all_dat$KE_BRAN_smooth = zoo::rollmean(all_dat$KE_BRAN, 7, fill=NA)
  all_dat$KE_Mooring_smooth = zoo::rollmean(all_dat$KE_Mooring, 7, fill=NA)
  
  ggplot(all_dat, aes(x=date, y=KE_Mooring_smooth)) + geom_line()+
    geom_line(aes(y=KE_BRAN_smooth), col="red")
  
  cor.test(all_dat$KE_BRAN_smooth, all_dat$KE_Mooring_smooth)
  
  all_dat_long <- all_dat %>% select(date, KE_BRAN_smooth, KE_Mooring_smooth) %>%
    pivot_longer(cols=2:3, names_to = "Metric", values_to = "KE")
  
  
  ggplot(all_dat_long, aes(x=date, y=KE, col=Metric)) + geom_line(size=1.25) + 
    theme_classic() + scale_colour_manual(values=c("blue", "red"))+
    scale_x_date(date_breaks = "1 year", date_minor_breaks = "1 month",
                 date_labels = "%Y")+
    ylab("Velocity m/s")+
    theme(legend.position = "bottom",
          legend.title = element_text(size=12, face="bold"),
          legend.text = element_text(size=12),
          axis.title = element_text(size=14, face="bold"),
          axis.text = element_text(size=12, colour="black"))+
    annotate("text", x= as.Date("2010-02-01"), y = 0.3, label = "r = 0.36")
  
  ggsave("BRAN GBR HIN Comparison.png", dpi=600, width=21, height=14.8, units = "cm")
  taylor.diagram(ref=all_dat$KE_Mooring_smooth, model = all_dat$KE_BRAN_smooth, normalize = F, pos.cor=T)
  all_dat_GBE_HIN <- all_dat
  
 
  ############# GBR HIS
  
  library(tidyverse)
  
  mdat <- read_csv("imos moorings/velocity/GBR HIS daily top30 summary.csv") %>% mutate(date=as.Date(date))
  udat <- read_csv("imos moorings/Daily U Velocity GBRHIS_BRAN 10_30m.csv")
  vdat <- read_csv("imos moorings/Daily V Velocity GBRHIS_BRAN 10_30m.csv")
  bran_dat <- left_join(udat, vdat)
  
  bran_dat <- bran_dat %>% mutate(date = as.numeric(str_remove(Date, pattern = "X"))) %>% arrange(date)
  bran_dat <- bran_dat %>% mutate(date = as.Date(as.POSIXct(date*24*60*60, origin ="1979-01-01")))
  
  all_dat <- full_join(bran_dat, mdat, by="date", suffix=c("_BRAN", "_Mooring"))
  
  all_dat <- all_dat %>% filter(date >= min(mdat$date)) %>% filter(date <= max(bran_dat$date))
  
  head(all_dat)
  
  ggplot(all_dat, aes(x=date, y=VCUR_Mooring)) + geom_line()+
    geom_line(aes(y=VCUR_BRAN), col="red")
  
  cor.test(all_dat$VCUR_BRAN, all_dat$VCUR_Mooring)
  
  
  ggplot(all_dat, aes(x=date, y=UCUR_Mooring)) + geom_line()+
    geom_line(aes(y=UCUR_BRAN), col="red")
  
  cor.test(all_dat$UCUR_BRAN, all_dat$UCUR_Mooring)
  
  
  all_dat <- all_dat %>% mutate(KE_BRAN = sqrt(VCUR_BRAN^2 + UCUR_BRAN^2), 
                                KE_Mooring = sqrt(VCUR_Mooring^2 + UCUR_Mooring^2))
  
  ggplot(all_dat, aes(x=date, y=KE_Mooring)) + geom_line()+
    geom_line(aes(y=KE_BRAN), col="red")
  
  cor.test(all_dat$KE_BRAN, all_dat$KE_Mooring)
  
  all_dat$KE_BRAN_smooth = zoo::rollmean(all_dat$KE_BRAN, 7, fill=NA)
  all_dat$KE_Mooring_smooth = zoo::rollmean(all_dat$KE_Mooring, 7, fill=NA)
  
  ggplot(all_dat, aes(x=date, y=KE_Mooring_smooth)) + geom_line()+
    geom_line(aes(y=KE_BRAN_smooth), col="red")
  
  cor.test(all_dat$KE_BRAN_smooth, all_dat$KE_Mooring_smooth)
  
  all_dat_long <- all_dat %>% select(date, KE_BRAN_smooth, KE_Mooring_smooth) %>%
    pivot_longer(cols=2:3, names_to = "Metric", values_to = "KE")
  
  
  ggplot(all_dat_long, aes(x=date, y=KE, col=Metric)) + geom_line(size=1.25) + 
    theme_classic() + scale_colour_manual(values=c("blue", "red"))+
    scale_x_date(date_breaks = "1 year", date_minor_breaks = "1 month",
                 date_labels = "%Y")+
    ylab("Velocity m/s")+
    theme(legend.position = "bottom",
          legend.title = element_text(size=12, face="bold"),
          legend.text = element_text(size=12),
          axis.title = element_text(size=14, face="bold"),
          axis.text = element_text(size=12, colour="black"))+
    annotate("text", x= as.Date("2010-02-01"), y = 0.3, label = "r = 0.36")
  
  ggsave("BRAN GBR HIS Comparison.png", dpi=600, width=21, height=14.8, units = "cm")
  taylor.diagram(ref=all_dat$KE_Mooring_smooth, model = all_dat$KE_BRAN_smooth, normalize = F, pos.cor=T)
  all_dat_GBE_HIS <- all_dat
  
  
  
  
  ############# GBR OTE
  
  library(tidyverse)
  
  mdat <- read_csv("imos moorings/velocity/GBR OTE daily top30 summary.csv") %>% mutate(date=as.Date(date))
  udat <- read_csv("imos moorings/Daily U Velocity GBROTE_BRAN 10_30m.csv")
  vdat <- read_csv("imos moorings/Daily V Velocity GBROTE_BRAN 10_30m.csv")
  bran_dat <- left_join(udat, vdat)
  
  bran_dat <- bran_dat %>% mutate(date = as.numeric(str_remove(Date, pattern = "X"))) %>% arrange(date)
  bran_dat <- bran_dat %>% mutate(date = as.Date(as.POSIXct(date*24*60*60, origin ="1979-01-01")))
  
  all_dat <- full_join(bran_dat, mdat, by="date", suffix=c("_BRAN", "_Mooring"))
  
  all_dat <- all_dat %>% filter(date >= min(mdat$date)) %>% filter(date <= max(bran_dat$date))
  
  head(all_dat)
  
  ggplot(all_dat, aes(x=date, y=VCUR_Mooring)) + geom_line()+
    geom_line(aes(y=VCUR_BRAN), col="red")
  
  cor.test(all_dat$VCUR_BRAN, all_dat$VCUR_Mooring)
  
  
  ggplot(all_dat, aes(x=date, y=UCUR_Mooring)) + geom_line()+
    geom_line(aes(y=UCUR_BRAN), col="red")
  
  cor.test(all_dat$UCUR_BRAN, all_dat$UCUR_Mooring)
  
  
  all_dat <- all_dat %>% mutate(KE_BRAN = sqrt(VCUR_BRAN^2 + UCUR_BRAN^2), 
                                KE_Mooring = sqrt(VCUR_Mooring^2 + UCUR_Mooring^2))
  
  ggplot(all_dat, aes(x=date, y=KE_Mooring)) + geom_line()+
    geom_line(aes(y=KE_BRAN), col="red")
  
  cor.test(all_dat$KE_BRAN, all_dat$KE_Mooring)
  
  all_dat$KE_BRAN_smooth = zoo::rollmean(all_dat$KE_BRAN, 7, fill=NA)
  all_dat$KE_Mooring_smooth = zoo::rollmean(all_dat$KE_Mooring, 7, fill=NA)
  
  ggplot(all_dat, aes(x=date, y=KE_Mooring_smooth)) + geom_line()+
    geom_line(aes(y=KE_BRAN_smooth), col="red")
  
  cor.test(all_dat$KE_BRAN_smooth, all_dat$KE_Mooring_smooth)
  
  all_dat_long <- all_dat %>% select(date, KE_BRAN_smooth, KE_Mooring_smooth) %>%
    pivot_longer(cols=2:3, names_to = "Metric", values_to = "KE")
  
  
  ggplot(all_dat_long, aes(x=date, y=KE, col=Metric)) + geom_line(size=1.25) + 
    theme_classic() + scale_colour_manual(values=c("blue", "red"))+
    scale_x_date(date_breaks = "1 year", date_minor_breaks = "1 month",
                 date_labels = "%Y")+
    ylab("Velocity m/s")+
    theme(legend.position = "bottom",
          legend.title = element_text(size=12, face="bold"),
          legend.text = element_text(size=12),
          axis.title = element_text(size=14, face="bold"),
          axis.text = element_text(size=12, colour="black"))+
    annotate("text", x= as.Date("2010-02-01"), y = 0.3, label = "r = 0.36")
  
  ggsave("BRAN GBR OTE Comparison.png", dpi=600, width=21, height=14.8, units = "cm")
  taylor.diagram(ref=all_dat$KE_Mooring_smooth, model = all_dat$KE_BRAN_smooth, normalize = F, pos.cor=T)
  all_dat_GBE_OTE <- all_dat
  
  
  ############# SEQ 200
  
  library(tidyverse)
  
  mdat <- read_csv("imos moorings/velocity/SE_QLD 200 daily top30 summary.csv") %>% mutate(date=as.Date(date))
  udat <- read_csv("imos moorings/Daily U Velocity SEQ200_BRAN 10_30m.csv")
  vdat <- read_csv("imos moorings/Daily V Velocity SEQ200_BRAN 10_30m.csv")
  bran_dat <- left_join(udat, vdat)
  
  bran_dat <- bran_dat %>% mutate(date = as.numeric(str_remove(Date, pattern = "X"))) %>% arrange(date)
  bran_dat <- bran_dat %>% mutate(date = as.Date(as.POSIXct(date*24*60*60, origin ="1979-01-01")))
  
  all_dat <- full_join(bran_dat, mdat, by="date", suffix=c("_BRAN", "_Mooring"))
  
  all_dat <- all_dat %>% filter(date >= min(mdat$date)) %>% filter(date <= max(bran_dat$date))
  
  head(all_dat)
  
  ggplot(all_dat, aes(x=date, y=VCUR_Mooring)) + geom_line()+
    geom_line(aes(y=VCUR_BRAN), col="red")
  
  cor.test(all_dat$VCUR_BRAN, all_dat$VCUR_Mooring)
  
  
  ggplot(all_dat, aes(x=date, y=UCUR_Mooring)) + geom_line()+
    geom_line(aes(y=UCUR_BRAN), col="red")
  
  cor.test(all_dat$UCUR_BRAN, all_dat$UCUR_Mooring)
  
  
  all_dat <- all_dat %>% mutate(KE_BRAN = sqrt(VCUR_BRAN^2 + UCUR_BRAN^2), 
                                KE_Mooring = sqrt(VCUR_Mooring^2 + UCUR_Mooring^2))
  
  ggplot(all_dat, aes(x=date, y=KE_Mooring)) + geom_line()+
    geom_line(aes(y=KE_BRAN), col="red")
  
  cor.test(all_dat$KE_BRAN, all_dat$KE_Mooring)
  
  all_dat$KE_BRAN_smooth = zoo::rollmean(all_dat$KE_BRAN, 7, fill=NA)
  all_dat$KE_Mooring_smooth = zoo::rollmean(all_dat$KE_Mooring, 7, fill=NA)
  
  ggplot(all_dat, aes(x=date, y=KE_Mooring_smooth)) + geom_line()+
    geom_line(aes(y=KE_BRAN_smooth), col="red")
  
  cor.test(all_dat$KE_BRAN_smooth, all_dat$KE_Mooring_smooth)
  
  all_dat_long <- all_dat %>% select(date, KE_BRAN_smooth, KE_Mooring_smooth) %>%
    pivot_longer(cols=2:3, names_to = "Metric", values_to = "KE")
  
  
  ggplot(all_dat_long, aes(x=date, y=KE, col=Metric)) + geom_line(size=1.25) + 
    theme_classic() + scale_colour_manual(values=c("blue", "red"))+
    scale_x_date(date_breaks = "1 year", date_minor_breaks = "1 month",
                 date_labels = "%Y")+
    ylab("Velocity m/s")+
    theme(legend.position = "bottom",
          legend.title = element_text(size=12, face="bold"),
          legend.text = element_text(size=12),
          axis.title = element_text(size=14, face="bold"),
          axis.text = element_text(size=12, colour="black"))+
    annotate("text", x= as.Date("2010-02-01"), y = 0.3, label = "r = 0.36")
  
  ggsave("BRAN SEQ 200 Comparison.png", dpi=600, width=21, height=14.8, units = "cm")
  taylor.diagram(ref=all_dat$KE_Mooring_smooth, model = all_dat$KE_BRAN_smooth, normalize = F, pos.cor=T)
  all_dat_SEQ200 <- all_dat
  
  
  ############# SEQ 400
  
  library(tidyverse)
  
  mdat <- read_csv("imos moorings/velocity/SE_QLD 400 daily top30 summary.csv") %>% mutate(date=as.Date(date))
  udat <- read_csv("imos moorings/Daily U Velocity SEQ400_BRAN 10_30m.csv")
  vdat <- read_csv("imos moorings/Daily V Velocity SEQ400_BRAN 10_30m.csv")
  bran_dat <- left_join(udat, vdat)
  
  bran_dat <- bran_dat %>% mutate(date = as.numeric(str_remove(Date, pattern = "X"))) %>% arrange(date)
  bran_dat <- bran_dat %>% mutate(date = as.Date(as.POSIXct(date*24*60*60, origin ="1979-01-01")))
  
  all_dat <- full_join(bran_dat, mdat, by="date", suffix=c("_BRAN", "_Mooring"))
  
  all_dat <- all_dat %>% filter(date >= min(mdat$date)) %>% filter(date <= max(bran_dat$date))
  
  head(all_dat)
  
  ggplot(all_dat, aes(x=date, y=VCUR_Mooring)) + geom_line()+
    geom_line(aes(y=VCUR_BRAN), col="red")
  
  cor.test(all_dat$VCUR_BRAN, all_dat$VCUR_Mooring)
  
  
  ggplot(all_dat, aes(x=date, y=UCUR_Mooring)) + geom_line()+
    geom_line(aes(y=UCUR_BRAN), col="red")
  
  cor.test(all_dat$UCUR_BRAN, all_dat$UCUR_Mooring)
  
  
  all_dat <- all_dat %>% mutate(KE_BRAN = sqrt(VCUR_BRAN^2 + UCUR_BRAN^2), 
                                KE_Mooring = sqrt(VCUR_Mooring^2 + UCUR_Mooring^2))
  
  ggplot(all_dat, aes(x=date, y=KE_Mooring)) + geom_line()+
    geom_line(aes(y=KE_BRAN), col="red")
  
  cor.test(all_dat$KE_BRAN, all_dat$KE_Mooring)
  
  all_dat$KE_BRAN_smooth = zoo::rollmean(all_dat$KE_BRAN, 7, fill=NA)
  all_dat$KE_Mooring_smooth = zoo::rollmean(all_dat$KE_Mooring, 7, fill=NA)
  
  ggplot(all_dat, aes(x=date, y=KE_Mooring_smooth)) + geom_line()+
    geom_line(aes(y=KE_BRAN_smooth), col="red")
  
  cor.test(all_dat$KE_BRAN_smooth, all_dat$KE_Mooring_smooth)
  
  all_dat_long <- all_dat %>% select(date, KE_BRAN_smooth, KE_Mooring_smooth) %>%
    pivot_longer(cols=2:3, names_to = "Metric", values_to = "KE")
  
  
  ggplot(all_dat_long, aes(x=date, y=KE, col=Metric)) + geom_line(size=1.25) + 
    theme_classic() + scale_colour_manual(values=c("blue", "red"))+
    scale_x_date(date_breaks = "1 year", date_minor_breaks = "1 month",
                 date_labels = "%Y")+
    ylab("Velocity m/s")+
    theme(legend.position = "bottom",
          legend.title = element_text(size=12, face="bold"),
          legend.text = element_text(size=12),
          axis.title = element_text(size=14, face="bold"),
          axis.text = element_text(size=12, colour="black"))+
    annotate("text", x= as.Date("2010-02-01"), y = 0.3, label = "r = 0.36")
  
  ggsave("BRAN SEQ 400 Comparison.png", dpi=600, width=21, height=14.8, units = "cm")
  taylor.diagram(ref=all_dat$KE_Mooring_smooth, model = all_dat$KE_BRAN_smooth, normalize = F, pos.cor=T)
  all_dat_SEQ400 <- all_dat
  
  
### TAYLOR DIAGRAM ALL TOGETHER NOW
  taylor.diagram(ref=all_dat_Coffs100$Vel_Mooring_smooth, model = all_dat_Coffs100$Vel_BRAN_smooth, normalize = F, pos.cor=F, add=F)
  taylor.diagram(ref=all_dat_GBE_HIS$KE_Mooring_smooth, model = all_dat_GBE_HIS$KE_BRAN_smooth, normalize = F, pos.cor=F, add=T)
  taylor.diagram(ref=all_dat_GBE_OTE$KE_Mooring_smooth, model = all_dat_GBE_OTE$KE_BRAN_smooth, normalize = F, pos.cor=F, add=T)
  taylor.diagram(ref=all_dat_GBE_HIN$KE_Mooring_smooth, model = all_dat_GBE_HIN$KE_BRAN_smooth, normalize = F, pos.cor=F, add=T)
  taylor.diagram(ref=all_dat_GBE_CCH$KE_Mooring_smooth, model = all_dat_GBE_CCH$KE_BRAN_smooth, normalize = F, pos.cor=F, add=T)
  taylor.diagram(ref=all_dat_EAC2000$KE_Mooring_smooth, model = all_dat_EAC2000$KE_BRAN_smooth, normalize = F, pos.cor=F, add=T)
  taylor.diagram(ref=all_dat_EAC3200$KE_Mooring_smooth, model = all_dat_EAC3200$KE_BRAN_smooth, normalize = F, pos.cor=F, add=T)
  taylor.diagram(ref=all_dat_EAC4700$KE_Mooring_smooth, model = all_dat_EAC4700$KE_BRAN_smooth, normalize = F, pos.cor=F, add=T)
  taylor.diagram(ref=all_dat_EAC500$KE_Mooring_smooth, model = all_dat_EAC500$KE_BRAN_smooth, normalize = F, pos.cor=F, add=T)
  taylor.diagram(ref=all_dat_Coffs70$Vel_Mooring_smooth, model = all_dat_Coffs70$Vel_BRAN_smooth, normalize = F, pos.cor=F, add=T)
  taylor.diagram(ref=all_dat_NRS_NS$KE_Mooring_smooth, model = all_dat_NRS_NS$KE_BRAN_smooth, normalize = F, pos.cor=F, add=T)
  taylor.diagram(ref=all_dat_SEQ200$KE_Mooring_smooth, model = all_dat_SEQ200$KE_BRAN_smooth, normalize = F, pos.cor=F, add=T)
  taylor.diagram(ref=all_dat_SEQ400$KE_Mooring_smooth, model = all_dat_SEQ400$KE_BRAN_smooth, normalize = F, pos.cor=F, add=T)
  # Export as pdf and edit/tidy

  