# IMOS MOORING CURRENTS

library(tidyverse)
library(tidync)

grid_identifier <- "D1"

mydata <- tidync("imos moorings/velocity/IMOS_ANMN-NSW_VZ_20091216_CH100_FV02_velocity-hourly-timeseries_END-20210302_C-20210427.nc") %>%
  activate(grid_identifier) %>%
  hyper_tibble() #%>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"))

head(mydata)


mydata2 <- tidync("imos moorings/velocity/IMOS_ANMN-NSW_VZ_20091216_CH100_FV02_velocity-hourly-timeseries_END-20210302_C-20210427.nc") %>%
  activate("D0") %>%
  hyper_tibble() %>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"),
                            INSTRUMENT = instrument_index+1,
                            date = as.Date(TIME))

head(mydata2)

full_data <- left_join(mydata2, mydata) %>% filter(DEPTH <= 30) %>% filter(DEPTH >= 10)

small_dat <- full_data %>% filter(date == "2015-11-01")

day_summary <- small_dat %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                          VCUR = mean(VCUR, na.rm=T),
                                                          lat = mean(LATITUDE, na.rm=T),
                                                          lat2 = min(LATITUDE, na.rm=T))

all_summary <-  full_data %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                           VCUR = mean(VCUR, na.rm=T),
                                                           lat = mean(LATITUDE, na.rm=T),
                                                           lon= min(LONGITUDE, na.rm=T)) %>%
  complete(date = seq.Date(min(date), max(date), by="day"), fill=list(NA))

plot(all_summary$date, -all_summary$VCUR, type = "l")

ggplot(all_summary, aes(x=date, y = -VCUR)) + geom_line()

write_csv(all_summary, "imos moorings/velocity/Coffs 100 daily top30 summary.csv")
range(all_summary$date)


### North Stradbroke Mooring

library(tidyverse)
library(tidync)

grid_identifier <- "D1"

mydata <- tidync("imos moorings/velocity/IMOS_ANMN-NRS_VZ_20101213_NRSNSI_FV02_velocity-hourly-timeseries_END-20201028_C-20210222.nc") %>%
  activate(grid_identifier) %>%
  hyper_tibble() #%>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"))

head(mydata)


mydata2 <- tidync("imos moorings/velocity/IMOS_ANMN-NRS_VZ_20101213_NRSNSI_FV02_velocity-hourly-timeseries_END-20201028_C-20210222.nc") %>%
  activate("D0") %>%
  hyper_tibble() %>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"),
                            INSTRUMENT = instrument_index+1,
                            date = as.Date(TIME))

head(mydata2)

full_data <- left_join(mydata2, mydata) %>% filter(DEPTH <= 30) %>% filter(DEPTH >= 10)

small_dat <- full_data %>% filter(date == "2015-11-01")

day_summary <- small_dat %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                          VCUR = mean(VCUR, na.rm=T),
                                                          lat = mean(LATITUDE, na.rm=T),
                                                          lat2 = min(LATITUDE, na.rm=T))

all_summary <-  full_data %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                           VCUR = mean(VCUR, na.rm=T),
                                                           lat = mean(LATITUDE, na.rm=T),
                                                           lon= min(LONGITUDE, na.rm=T)) %>%
  complete(date = seq.Date(min(date), max(date), by="day"), fill=list(NA))

plot(all_summary$date, -all_summary$VCUR, type = "l")

ggplot(all_summary, aes(x=date, y = -VCUR)) + geom_line()

write_csv(all_summary, "imos moorings/velocity/NS NRS daily top30 summary.csv")
range(all_summary$date)


#### COFFS 70m

library(tidyverse)
library(tidync)

grid_identifier <- "D1"

mydata <- tidync("imos moorings/velocity/IMOS_ANMN-NSW_VZ_20091006_CH070_FV02_velocity-hourly-timeseries_END-20210302_C-20210427.nc") %>%
  activate(grid_identifier) %>%
  hyper_tibble() #%>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"))

head(mydata)


mydata2 <- tidync("imos moorings/velocity/IMOS_ANMN-NSW_VZ_20091006_CH070_FV02_velocity-hourly-timeseries_END-20210302_C-20210427.nc") %>%
  activate("D0") %>%
  hyper_tibble() %>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"),
                            INSTRUMENT = instrument_index+1,
                            date = as.Date(TIME))

head(mydata2)

full_data <- left_join(mydata2, mydata) %>% filter(DEPTH <= 30) %>% filter(DEPTH >= 10)

small_dat <- full_data %>% filter(date == "2015-11-01")

day_summary <- small_dat %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                          VCUR = mean(VCUR, na.rm=T),
                                                          lat = mean(LATITUDE, na.rm=T),
                                                          lat2 = min(LATITUDE, na.rm=T))

all_summary <-  full_data %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                           VCUR = mean(VCUR, na.rm=T),
                                                           lat = mean(LATITUDE, na.rm=T),
                                                           lon= min(LONGITUDE, na.rm=T)) %>%
  complete(date = seq.Date(min(date), max(date), by="day"), fill=list(NA))

plot(all_summary$date, -all_summary$VCUR, type = "l")

ggplot(all_summary, aes(x=date, y = -VCUR)) + geom_line()

write_csv(all_summary, "imos moorings/velocity/Coffs 70 daily top30 summary.csv")
range(all_summary$date)





#### SE-QLD 200m

library(tidyverse)
library(tidync)

grid_identifier <- "D1"

mydata <- tidync("imos moorings/velocity/IMOS_ANMN-NRS_VZ_20120401_SEQ200_FV02_velocity-hourly-timeseries_END-20130609_C-20200528.nc") %>%
  activate(grid_identifier) %>%
  hyper_tibble() #%>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"))

head(mydata)


mydata2 <- tidync("imos moorings/velocity/IMOS_ANMN-NRS_VZ_20120401_SEQ200_FV02_velocity-hourly-timeseries_END-20130609_C-20200528.nc") %>%
  activate("D0") %>%
  hyper_tibble() %>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"),
                            INSTRUMENT = instrument_index+1,
                            date = as.Date(TIME))

head(mydata2)

full_data <- left_join(mydata2, mydata) %>% filter(DEPTH <= 30) %>% filter(DEPTH >= 10)

small_dat <- full_data %>% filter(date == "2015-11-01")

day_summary <- small_dat %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                          VCUR = mean(VCUR, na.rm=T),
                                                          lat = mean(LATITUDE, na.rm=T),
                                                          lat2 = min(LATITUDE, na.rm=T))

all_summary <-  full_data %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                           VCUR = mean(VCUR, na.rm=T),
                                                           lat = mean(LATITUDE, na.rm=T),
                                                           lon= min(LONGITUDE, na.rm=T)) %>%
  complete(date = seq.Date(min(date), max(date), by="day"), fill=list(NA))

plot(all_summary$date, -all_summary$VCUR, type = "l")

ggplot(all_summary, aes(x=date, y = -VCUR)) + geom_line()

write_csv(all_summary, "imos moorings/velocity/SE_QLD 200 daily top30 summary.csv")
range(all_summary$date)



#### SE-QLD 400m

library(tidyverse)
library(tidync)

grid_identifier <- "D1"

mydata <- tidync("imos moorings/velocity/IMOS_ANMN-NRS_VZ_20120401_SEQ400_FV02_velocity-hourly-timeseries_END-20130609_C-20200528.nc") %>%
  activate(grid_identifier) %>%
  hyper_tibble() #%>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"))

head(mydata)


mydata2 <- tidync("imos moorings/velocity/IMOS_ANMN-NRS_VZ_20120401_SEQ400_FV02_velocity-hourly-timeseries_END-20130609_C-20200528.nc") %>%
  activate("D0") %>%
  hyper_tibble() %>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"),
                            INSTRUMENT = instrument_index+1,
                            date = as.Date(TIME))

head(mydata2)

full_data <- left_join(mydata2, mydata) %>% filter(DEPTH <= 30) %>% filter(DEPTH >= 10)

small_dat <- full_data %>% filter(date == "2015-11-01")

day_summary <- small_dat %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                          VCUR = mean(VCUR, na.rm=T),
                                                          lat = mean(LATITUDE, na.rm=T),
                                                          lat2 = min(LATITUDE, na.rm=T))

all_summary <-  full_data %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                           VCUR = mean(VCUR, na.rm=T),
                                                           lat = mean(LATITUDE, na.rm=T),
                                                           lon= min(LONGITUDE, na.rm=T)) %>%
  complete(date = seq.Date(min(date), max(date), by="day"), fill=list(NA))

plot(all_summary$date, -all_summary$VCUR, type = "l")

ggplot(all_summary, aes(x=date, y = -VCUR)) + geom_line()

write_csv(all_summary, "imos moorings/velocity/SE_QLD 400 daily top30 summary.csv")
range(all_summary$date)



#### EAC 500m

library(tidyverse)
library(tidync)

grid_identifier <- "D1"

mydata <- tidync("imos moorings/velocity/IMOS_DWM-DA_VZ_20150524_EAC0500_FV02_velocity-hourly-timeseries_END-20190924_C-20210422.nc") %>%
  activate(grid_identifier) %>%
  hyper_tibble() #%>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"))

head(mydata)


mydata2 <- tidync("imos moorings/velocity/IMOS_DWM-DA_VZ_20150524_EAC0500_FV02_velocity-hourly-timeseries_END-20190924_C-20210422.nc") %>%
  activate("D0") %>%
  hyper_tibble() %>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"),
                            INSTRUMENT = instrument_index+1,
                            date = as.Date(TIME))

head(mydata2)

full_data <- left_join(mydata2, mydata) %>% filter(DEPTH <= 30) %>% filter(DEPTH >= 10)

small_dat <- full_data %>% filter(date == "2015-11-01")

day_summary <- small_dat %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                          VCUR = mean(VCUR, na.rm=T),
                                                          lat = mean(LATITUDE, na.rm=T),
                                                          lat2 = min(LATITUDE, na.rm=T))

all_summary <-  full_data %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                           VCUR = mean(VCUR, na.rm=T),
                                                           lat = mean(LATITUDE, na.rm=T),
                                                           lon= min(LONGITUDE, na.rm=T)) %>%
  complete(date = seq.Date(min(date), max(date), by="day"), fill=list(NA))

plot(all_summary$date, -all_summary$VCUR, type = "l")

ggplot(all_summary, aes(x=date, y = -VCUR)) + geom_line()

write_csv(all_summary, "imos moorings/velocity/EAC 500 daily top30 summary.csv")
range(all_summary$date)






# #### EAC 1520m - NO SURFACE VELOCITIES
# 
# library(tidyverse)
# library(tidync)
# 
# grid_identifier <- "D1"
# 
# mydata <- tidync("imos moorings/velocity/IMOS_DWM-DA_VZ_20120421_EAC1520_FV02_velocity-hourly-timeseries_END-20130828_C-20210422.nc") %>%
#   activate(grid_identifier) %>%
#   hyper_tibble() #%>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"))
# 
# head(mydata)
# 
# 
# mydata2 <- tidync("imos moorings/velocity/IMOS_DWM-DA_VZ_20120421_EAC1520_FV02_velocity-hourly-timeseries_END-20130828_C-20210422.nc") %>%
#   activate("D0") %>%
#   hyper_tibble() %>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"),
#                             INSTRUMENT = instrument_index+1,
#                             date = as.Date(TIME))
# 
# head(mydata2)
# 
# full_data <- left_join(mydata2, mydata) %>% filter(DEPTH <= 30) %>% filter(DEPTH >= 10)
# 
# small_dat <- full_data %>% filter(date == "2012-11-01")
# 
# day_summary <- small_dat %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
#                                                           VCUR = mean(VCUR, na.rm=T),
#                                                           lat = mean(LATITUDE, na.rm=T),
#                                                           lat2 = min(LATITUDE, na.rm=T))
# 
# all_summary <-  full_data %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
#                                                            VCUR = mean(VCUR, na.rm=T),
#                                                            lat = mean(LATITUDE, na.rm=T),
#                                                            lon= min(LONGITUDE, na.rm=T)) %>%
#   complete(date = seq.Date(min(date), max(date), by="day"), fill=list(NA))
# 
# plot(all_summary$date, -all_summary$VCUR, type = "l")
# 
# ggplot(all_summary, aes(x=date, y = -VCUR)) + geom_line()
# 
# write_csv(all_summary, "imos moorings/velocity/EAC 1520m daily top30 summary.csv")
# range(all_summary$date)
# 



#### EAC 2000m 

library(tidyverse)
library(tidync)

grid_identifier <- "D1"

mydata <- tidync("imos moorings/velocity/IMOS_DWM-DA_VZ_20120422_EAC2000_FV02_velocity-hourly-timeseries_END-20190924_C-20210422.nc") %>%
  activate(grid_identifier) %>%
  hyper_tibble() #%>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"))

head(mydata)


mydata2 <- tidync("imos moorings/velocity/IMOS_DWM-DA_VZ_20120422_EAC2000_FV02_velocity-hourly-timeseries_END-20190924_C-20210422.nc") %>%
  activate("D0") %>%
  hyper_tibble() %>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"),
                            INSTRUMENT = instrument_index+1,
                            date = as.Date(TIME))

head(mydata2)

full_data <- left_join(mydata2, mydata) %>% filter(DEPTH <= 30) %>% filter(DEPTH >= 10)

small_dat <- full_data %>% filter(date == "2012-11-01")

day_summary <- small_dat %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                          VCUR = mean(VCUR, na.rm=T),
                                                          lat = mean(LATITUDE, na.rm=T),
                                                          lat2 = min(LATITUDE, na.rm=T))

all_summary <-  full_data %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                           VCUR = mean(VCUR, na.rm=T),
                                                           lat = mean(LATITUDE, na.rm=T),
                                                           lon= min(LONGITUDE, na.rm=T)) %>%
  complete(date = seq.Date(min(date), max(date), by="day"), fill=list(NA))

plot(all_summary$date, -all_summary$VCUR, type = "l")

ggplot(all_summary, aes(x=date, y = -VCUR)) + geom_line()

write_csv(all_summary, "imos moorings/velocity/EAC 2000m daily top30 summary.csv")
range(all_summary$date)



#### EAC 3200m

library(tidyverse)
library(tidync)

grid_identifier <- "D1"

mydata <- tidync("imos moorings/velocity/IMOS_DWM-DA_VZ_20150522_EAC3200_FV02_velocity-hourly-timeseries_END-20190921_C-20210422.nc") %>%
  activate(grid_identifier) %>%
  hyper_tibble() #%>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"))

head(mydata)


mydata2 <- tidync("imos moorings/velocity/IMOS_DWM-DA_VZ_20150522_EAC3200_FV02_velocity-hourly-timeseries_END-20190921_C-20210422.nc") %>%
  activate("D0") %>%
  hyper_tibble() %>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"),
                            INSTRUMENT = instrument_index+1,
                            date = as.Date(TIME))

head(mydata2)

full_data <- left_join(mydata2, mydata) %>% filter(DEPTH <= 30) %>% filter(DEPTH >= 10)

small_dat <- full_data %>% filter(date == "2012-11-01")

day_summary <- small_dat %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                          VCUR = mean(VCUR, na.rm=T),
                                                          lat = mean(LATITUDE, na.rm=T),
                                                          lat2 = min(LATITUDE, na.rm=T))

all_summary <-  full_data %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                           VCUR = mean(VCUR, na.rm=T),
                                                           lat = mean(LATITUDE, na.rm=T),
                                                           lon= min(LONGITUDE, na.rm=T)) %>%
  complete(date = seq.Date(min(date), max(date), by="day"), fill=list(NA))

plot(all_summary$date, -all_summary$VCUR, type = "l")

ggplot(all_summary, aes(x=date, y = -VCUR)) + geom_line()

write_csv(all_summary, "imos moorings/velocity/EAC 3200m daily top30 summary.csv")
range(all_summary$date)



#### EAC 4200m

library(tidyverse)
library(tidync)

grid_identifier <- "D1"

mydata <- tidync("imos moorings/velocity/IMOS_DWM-DA_VZ_20120423_EAC4200_FV02_velocity-hourly-timeseries_END-20190918_C-20210422.nc") %>%
  activate(grid_identifier) %>%
  hyper_tibble() #%>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"))

head(mydata)


mydata2 <- tidync("imos moorings/velocity/IMOS_DWM-DA_VZ_20120423_EAC4200_FV02_velocity-hourly-timeseries_END-20190918_C-20210422.nc") %>%
  activate("D0") %>%
  hyper_tibble() %>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"),
                            INSTRUMENT = instrument_index+1,
                            date = as.Date(TIME))

head(mydata2)

full_data <- left_join(mydata2, mydata) %>% filter(DEPTH <= 30) %>% filter(DEPTH >= 10)

small_dat <- full_data %>% filter(date == "2012-11-01")

day_summary <- small_dat %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                          VCUR = mean(VCUR, na.rm=T),
                                                          lat = mean(LATITUDE, na.rm=T),
                                                          lat2 = min(LATITUDE, na.rm=T))

all_summary <-  full_data %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                           VCUR = mean(VCUR, na.rm=T),
                                                           lat = mean(LATITUDE, na.rm=T),
                                                           lon= min(LONGITUDE, na.rm=T)) %>%
  complete(date = seq.Date(min(date), max(date), by="day"), fill=list(NA))

plot(all_summary$date, -all_summary$VCUR, type = "l")

ggplot(all_summary, aes(x=date, y = -VCUR)) + geom_line()

write_csv(all_summary, "imos moorings/velocity/EAC 4200m daily top30 summary.csv")
range(all_summary$date)



#### EAC 4700m

library(tidyverse)
library(tidync)

grid_identifier <- "D1"

mydata <- tidync("imos moorings/velocity/IMOS_DWM-DA_VZ_20120425_EAC4700_FV02_velocity-hourly-timeseries_END-20190915_C-20210422.nc") %>%
  activate(grid_identifier) %>%
  hyper_tibble() #%>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"))

head(mydata)


mydata2 <- tidync("imos moorings/velocity/IMOS_DWM-DA_VZ_20120425_EAC4700_FV02_velocity-hourly-timeseries_END-20190915_C-20210422.nc") %>%
  activate("D0") %>%
  hyper_tibble() %>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"),
                            INSTRUMENT = instrument_index+1,
                            date = as.Date(TIME))

head(mydata2)

full_data <- left_join(mydata2, mydata) %>% filter(DEPTH <= 30) %>% filter(DEPTH >= 10)

small_dat <- full_data %>% filter(date == "2012-11-01")

day_summary <- small_dat %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                          VCUR = mean(VCUR, na.rm=T),
                                                          lat = mean(LATITUDE, na.rm=T),
                                                          lat2 = min(LATITUDE, na.rm=T))

all_summary <-  full_data %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                           VCUR = mean(VCUR, na.rm=T),
                                                           lat = mean(LATITUDE, na.rm=T),
                                                           lon= min(LONGITUDE, na.rm=T)) %>%
  complete(date = seq.Date(min(date), max(date), by="day"), fill=list(NA))

plot(all_summary$date, -all_summary$VCUR, type = "l")

ggplot(all_summary, aes(x=date, y = -VCUR)) + geom_line()

write_csv(all_summary, "imos moorings/velocity/EAC 4700m daily top30 summary.csv")
range(all_summary$date)

# 
# #### EAC 4800m -- NO good surface data
# 
# library(tidyverse)
# library(tidync)
# 
# grid_identifier <- "D1"
# 
# mydata <- tidync("imos moorings/velocity/IMOS_DWM-DA_VZ_20120426_EAC4800_FV02_velocity-hourly-timeseries_END-20190913_C-20210422.nc") %>%
#   activate(grid_identifier) %>%
#   hyper_tibble() #%>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"))
# 
# head(mydata)
# 
# 
# mydata2 <- tidync("imos moorings/velocity/IMOS_DWM-DA_VZ_20120426_EAC4800_FV02_velocity-hourly-timeseries_END-20190913_C-20210422.nc") %>%
#   activate("D0") %>%
#   hyper_tibble() %>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"),
#                             INSTRUMENT = instrument_index+1,
#                             date = as.Date(TIME))
# 
# head(mydata2)
# 
# full_data <- left_join(mydata2, mydata) %>% filter(DEPTH <= 30) %>% filter(DEPTH >= 10)
# 
# small_dat <- full_data %>% filter(date == "2012-11-01")
# 
# day_summary <- small_dat %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
#                                                           VCUR = mean(VCUR, na.rm=T),
#                                                           lat = mean(LATITUDE, na.rm=T),
#                                                           lat2 = min(LATITUDE, na.rm=T))
# 
# all_summary <-  full_data %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
#                                                            VCUR = mean(VCUR, na.rm=T),
#                                                            lat = mean(LATITUDE, na.rm=T),
#                                                            lon= min(LONGITUDE, na.rm=T)) %>%
#   complete(date = seq.Date(min(date), max(date), by="day"), fill=list(NA))
# 
# plot(all_summary$date, -all_summary$VCUR, type = "l")
# 
# ggplot(all_summary, aes(x=date, y = -VCUR)) + geom_line()
# 
# write_csv(all_summary, "imos moorings/velocity/EAC 4800m daily top30 summary.csv")
# range(all_summary$date)
# 
# 
# 

### GBR HIS

library(tidyverse)
library(tidync)

grid_identifier <- "D1"

mydata <- tidync("imos moorings/velocity/IMOS_ANMN-QLD_VZ_20070912_GBRHIS_FV02_velocity-hourly-timeseries_END-20201217_C-20210428.nc") %>%
  activate(grid_identifier) %>%
  hyper_tibble() #%>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"))

head(mydata)


mydata2 <- tidync("imos moorings/velocity/IMOS_ANMN-QLD_VZ_20070912_GBRHIS_FV02_velocity-hourly-timeseries_END-20201217_C-20210428.nc") %>%
  activate("D0") %>%
  hyper_tibble() %>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"),
                            INSTRUMENT = instrument_index+1,
                            date = as.Date(TIME))

head(mydata2)

full_data <- left_join(mydata2, mydata) %>% filter(DEPTH <= 30) %>% filter(DEPTH >= 10)

small_dat <- full_data %>% filter(date == "2012-11-01")

day_summary <- small_dat %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                          VCUR = mean(VCUR, na.rm=T),
                                                          lat = mean(LATITUDE, na.rm=T),
                                                          lat2 = min(LATITUDE, na.rm=T))

all_summary <-  full_data %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                           VCUR = mean(VCUR, na.rm=T),
                                                           lat = mean(LATITUDE, na.rm=T),
                                                           lon= min(LONGITUDE, na.rm=T)) %>%
  complete(date = seq.Date(min(date), max(date), by="day"), fill=list(NA))

plot(all_summary$date, -all_summary$VCUR, type = "l")

ggplot(all_summary, aes(x=date, y = -VCUR)) + geom_line()

write_csv(all_summary, "imos moorings/velocity/GBR HIS daily top30 summary.csv")
range(all_summary$date)


### GBR HIN

library(tidyverse)
library(tidync)

grid_identifier <- "D1"

mydata <- tidync("imos moorings/velocity/IMOS_ANMN-QLD_VZ_20070912_GBRHIN_FV02_velocity-hourly-timeseries_END-20121007_C-20201008.nc") %>%
  activate(grid_identifier) %>%
  hyper_tibble() #%>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"))

head(mydata)


mydata2 <- tidync("imos moorings/velocity/IMOS_ANMN-QLD_VZ_20070912_GBRHIN_FV02_velocity-hourly-timeseries_END-20121007_C-20201008.nc") %>%
  activate("D0") %>%
  hyper_tibble() %>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"),
                            INSTRUMENT = instrument_index+1,
                            date = as.Date(TIME))

head(mydata2)

full_data <- left_join(mydata2, mydata) %>% filter(DEPTH <= 30) %>% filter(DEPTH >= 10)

small_dat <- full_data %>% filter(date == "2012-11-01")

day_summary <- small_dat %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                          VCUR = mean(VCUR, na.rm=T),
                                                          lat = mean(LATITUDE, na.rm=T),
                                                          lat2 = min(LATITUDE, na.rm=T))

all_summary <-  full_data %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                           VCUR = mean(VCUR, na.rm=T),
                                                           lat = mean(LATITUDE, na.rm=T),
                                                           lon= min(LONGITUDE, na.rm=T)) %>%
  complete(date = seq.Date(min(date), max(date), by="day"), fill=list(NA))

plot(all_summary$date, -all_summary$VCUR, type = "l")

ggplot(all_summary, aes(x=date, y = -VCUR)) + geom_line()

write_csv(all_summary, "imos moorings/velocity/GBR HIN daily top30 summary.csv")
range(all_summary$date)


### GBR OTE

library(tidyverse)
library(tidync)

grid_identifier <- "D1"

mydata <- tidync("imos moorings/velocity/IMOS_ANMN-QLD_VZ_20070915_GBROTE_FV02_velocity-hourly-timeseries_END-20201217_C-20210428.nc") %>%
  activate(grid_identifier) %>%
  hyper_tibble() #%>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"))

head(mydata)


mydata2 <- tidync("imos moorings/velocity/IMOS_ANMN-QLD_VZ_20070915_GBROTE_FV02_velocity-hourly-timeseries_END-20201217_C-20210428.nc") %>%
  activate("D0") %>%
  hyper_tibble() %>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"),
                            INSTRUMENT = instrument_index+1,
                            date = as.Date(TIME))

head(mydata2)

full_data <- left_join(mydata2, mydata) %>% filter(DEPTH <= 30) %>% filter(DEPTH >= 10)

small_dat <- full_data %>% filter(date == "2012-11-01")

day_summary <- small_dat %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                          VCUR = mean(VCUR, na.rm=T),
                                                          lat = mean(LATITUDE, na.rm=T),
                                                          lat2 = min(LATITUDE, na.rm=T))

all_summary <-  full_data %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                           VCUR = mean(VCUR, na.rm=T),
                                                           lat = mean(LATITUDE, na.rm=T),
                                                           lon= min(LONGITUDE, na.rm=T)) %>%
  complete(date = seq.Date(min(date), max(date), by="day"), fill=list(NA))

plot(all_summary$date, -all_summary$VCUR, type = "l")

ggplot(all_summary, aes(x=date, y = -VCUR)) + geom_line()

write_csv(all_summary, "imos moorings/velocity/GBR OTE daily top30 summary.csv")
range(all_summary$date)


### GBR CCH

library(tidyverse)
library(tidync)

grid_identifier <- "D1"

mydata <- tidync("imos moorings/velocity/IMOS_ANMN-QLD_VZ_20070910_GBRCCH_FV02_velocity-hourly-timeseries_END-20201215_C-20210218.nc") %>%
  activate(grid_identifier) %>%
  hyper_tibble() #%>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"))

head(mydata)


mydata2 <- tidync("imos moorings/velocity/IMOS_ANMN-QLD_VZ_20070910_GBRCCH_FV02_velocity-hourly-timeseries_END-20201215_C-20210218.nc") %>%
  activate("D0") %>%
  hyper_tibble() %>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"),
                            INSTRUMENT = instrument_index+1,
                            date = as.Date(TIME))

head(mydata2)

full_data <- left_join(mydata2, mydata) %>% filter(DEPTH <= 30) %>% filter(DEPTH >= 10)

small_dat <- full_data %>% filter(date == "2012-11-01")

day_summary <- small_dat %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                          VCUR = mean(VCUR, na.rm=T),
                                                          lat = mean(LATITUDE, na.rm=T),
                                                          lat2 = min(LATITUDE, na.rm=T))

all_summary <-  full_data %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
                                                           VCUR = mean(VCUR, na.rm=T),
                                                           lat = mean(LATITUDE, na.rm=T),
                                                           lon= min(LONGITUDE, na.rm=T)) %>%
  complete(date = seq.Date(min(date), max(date), by="day"), fill=list(NA))

plot(all_summary$date, -all_summary$VCUR, type = "l")

ggplot(all_summary, aes(x=date, y = -VCUR)) + geom_line()

write_csv(all_summary, "imos moorings/velocity/GBR CCH daily top30 summary.csv")
range(all_summary$date)



# ### GBR ELR - output looks dodgy, exclude
# 
# library(tidyverse)
# library(tidync)
# 
# grid_identifier <- "D1"
# 
# mydata <- tidync("imos moorings/velocity/IMOS_ANMN-QLD_VZ_20080505_GBRELR_FV02_velocity-hourly-timeseries_END-20141015_C-20201008.nc") %>%
#   activate(grid_identifier) %>%
#   hyper_tibble() #%>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"))
# 
# head(mydata)
# 
# 
# mydata2 <- tidync("imos moorings/velocity/IMOS_ANMN-QLD_VZ_20080505_GBRELR_FV02_velocity-hourly-timeseries_END-20141015_C-20201008.nc") %>%
#   activate("D0") %>%
#   hyper_tibble() %>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"),
#                             INSTRUMENT = instrument_index+1,
#                             date = as.Date(TIME))
# 
# head(mydata2)
# 
# full_data <- left_join(mydata2, mydata) %>% filter(DEPTH <= 30) %>% filter(DEPTH >= 10)
# 
# small_dat <- full_data %>% filter(date == "2012-11-01")
# 
# day_summary <- small_dat %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
#                                                           VCUR = mean(VCUR, na.rm=T),
#                                                           lat = mean(LATITUDE, na.rm=T),
#                                                           lat2 = min(LATITUDE, na.rm=T))
# 
# all_summary <-  full_data %>% group_by(date) %>% summarise(UCUR = mean(UCUR, na.rm=T),
#                                                            VCUR = mean(VCUR, na.rm=T),
#                                                            lat = mean(LATITUDE, na.rm=T),
#                                                            lon= min(LONGITUDE, na.rm=T)) %>%
#   complete(date = seq.Date(min(date), max(date), by="day"), fill=list(NA))
# 
# plot(all_summary$date, -all_summary$VCUR, type = "l")
# 
# ggplot(all_summary, aes(x=date, y = -VCUR)) + geom_line()
# 
# write_csv(all_summary, "imos moorings/velocity/GBR ELR daily top30 summary.csv")
# range(all_summary$date)






#### Can i get a BRAN DAILY CURRENT SUMMARY

### BRAN Levels: 2.5, 7.5, 12.5, 17.515390396118164, 22.667020797729492, 28.16938018798828, 34.2180061340332
depth_levels <- c(2.5, 7.5, 12.5, 17.515390396118164, 22.667020797729492, 28.16938018798828, 34.2180061340332)
sites <- read_csv("imos moorings/temp/site lat longs.csv")
library(raster)

file_list <- list.files("C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN_2020/AUS/", pattern = "Ocean_temp", full.names = T)

for(j in (1:nrow(sites))){

full_data <- data.frame()
pp <- data.frame("lon"=sites$LONGITUDE[j], "lat"= sites$LATITUDE[j])
pp <- SpatialPoints(coords = pp)

for(f in file_list){
for ( i in (1:7)){
BRAN <- brick(f, level = i)
#plot(BRAN)
pq <- as.data.frame(t(extract(BRAN, pp, method = "bilinear")))
pq$date <- row.names(pq)
pq$depth_level <- depth_levels[i]
full_data <- bind_rows(full_data, pq)
}
}




#small_dat2 <- full_data %>% filter(date == "X5114.5")
date_list <- unique(full_data$date)
full_data_I <- data.frame()


for(d in date_list){
  small_dat2 <- full_data %>% filter(date == d)
  linear_v <- approx(x=small_dat2$depth_level, y = small_dat2$V1)
  linear2 <- as.data.frame(linear_v)
  linear2$Date <- small_dat2$date[1]
  linear2 <- linear2 %>% rename(Depth = x, TEMP = y) %>% filter(Depth <=30) %>% filter(Depth >= 10)
  full_data_I <- bind_rows(full_data_I, linear2)
}

# linear_v <- approx(x=small_dat2$depth_level, y = small_dat2$V1)
# linear2 <- as.data.frame(linear_v)
# linear2$Date <- small_dat2$date[1]
# linear2 <- linear2 %>% rename(Depth = x, VCUR = y)
# 
# plot(small_dat2$V1~small_dat2$depth_level, col="red")
# points(linear_v$x, linear_v$y)

combine_depth_I <- full_data_I %>% group_by(Date) %>% summarise(Temp = mean(TEMP, na.rm=T))

write_csv(combine_depth_I, paste0("imos moorings/temp/Daily Temp_", sites$site[j], "_BRAN 10_30m.csv"))
}
#######################################################################################################
####### Now for Temperature
#################################################################################
library(tidyverse)
library(tidync)

file_list <- list.files("imos moorings/temp/", pattern = ".nc", full.names = T)
sites <- data.frame()

for(i in (1:length(file_list))){
mydata <- tidync(file_list[i]) %>%
  activate("S") %>%
  hyper_tibble() #%>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC"))

sites <- bind_rows(sites, mydata)


sites$site[i] <- read.table(text = as.character(file_list[i]), sep = "_")$V5


mydata2 <- tidync(file_list[i]) %>%
  hyper_tibble() %>% mutate(TIME = as.POSIXct(TIME*24*60*60, origin = "1950-01-01", tz="UTC")) %>%
  mutate(date = as.Date(TIME))
head(mydata2)

mydata2

head(mydata2)

mydata2 <- mydata2 %>% filter(DEPTH <= 30) %>% filter(DEPTH >= 10)

if (nrow(mydata2) > 0){

#small_dat <- mydata2 %>% filter(date == "2015-11-01")
#
#day_summary <- small_dat %>% group_by(date) %>% summarise(Temp = mean(TEMP, na.rm=T))

all_summary <-  mydata2 %>% group_by(date) %>% summarise(Temp = mean(TEMP, na.rm=T)) %>%
  complete(date = seq.Date(min(date), max(date), by="day"), fill=list(NA)) %>% mutate(Latitude = sites$LATITUDE[i],
                                                                                      Longitude = sites$LONGITUDE[i],
                                                                                      site = sites$site[i])

plot(all_summary$date, all_summary$Temp, type = "l")

ggplot(all_summary, aes(x=date, y = Temp)) + geom_line()

write_csv(all_summary, paste0("imos moorings/temp/", sites$site[i], "_daily 10_30m summary.csv"))
}
}
write_csv(sites, "imos moorings/temp/site lat longs.csv")

