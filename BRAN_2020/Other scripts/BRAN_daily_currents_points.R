# BRAN daily currents
library(tidyverse)
library(raster)

depth_levels <- c(2.5, 7.5, 12.5, 17.515390396118164, 22.667020797729492, 28.16938018798828, 34.2180061340332)
sites <- read_csv("site lat longs2.csv")


for(j in (1:nrow(sites))){
  file_list <- list.files("/srv/scratch/z3374139/BRAN_AUS/", pattern = "Ocean_v", full.names = T)
full_data <- data.frame()

pp <- data.frame("lon"=sites$LONGITUDE[j], "lat"= sites$LATITUDE[j])
#pp <- data.frame("lon"=153.3950, "lat"= -30.26683) # Coffs 100
#pp <- data.frame("lon"=153.5602, "lat"= -27.34356) # NRS NS
#pp <- data.frame("lon"=153.3004, "lat"= -30.27487) # Coffs 70
#pp <- data.frame("lon"=153.7748, "lat"= -27.33998) # SEQ 200
#pp <- data.frame("lon"=153.8765, "lat"= -27.33185) # SEQ 400
#pp <- data.frame("lon"=153.8989, "lat"= -27.32913) # EAC 500
#pp <- data.frame("lon"=154.0017, "lat"= -27.31750) # EAC 2000
#pp <- data.frame("lon"=154.1301, "lat"= -27.28394) # EAC 3200
#pp <- data.frame("lon"=154.2910, "lat"= -27.23910) # EAC 4200
#pp <- data.frame("lon"=154.6450, "lat"= -27.20889) # EAC 4700
#pp <- data.frame("lon"=151.9548, "lat"= -23.51352) # GBR HIS
#pp <- data.frame("lon"=151.9871, "lat"= -23.38022) # GBR HIN
#pp <- data.frame("lon"=152.1753, "lat"= -23.48162) # GBR OTE
#pp <- data.frame("lon"=151.9933, "lat"= -22.40812) # GBR CHH





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
  linear2 <- linear2 %>% rename(Depth = x, VCUR = y) %>% filter(Depth <=30) %>% filter(Depth >= 10)
  full_data_I <- bind_rows(full_data_I, linear2)
}

# linear_v <- approx(x=small_dat2$depth_level, y = small_dat2$V1)
# linear2 <- as.data.frame(linear_v)
# linear2$Date <- small_dat2$date[1]
# linear2 <- linear2 %>% rename(Depth = x, VCUR = y)
# 
# plot(small_dat2$V1~small_dat2$depth_level, col="red")
# points(linear_v$x, linear_v$y)

combine_depth_I <- full_data_I %>% group_by(Date) %>% summarise(VCUR = mean(VCUR, na.rm=T))

write_csv(combine_depth_I, paste0("Daily V Velocity ", sites$site[j],"_BRAN 10_30m.csv"))


file_list <- list.files("/srv/scratch/z3374139/BRAN_AUS/", pattern = "Ocean_u", full.names = T)

full_data <- data.frame()

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
  linear2 <- linear2 %>% rename(Depth = x, UCUR = y) %>% filter(Depth <=30)  %>% filter(Depth >= 10)
  full_data_I <- bind_rows(full_data_I, linear2)
}

# linear_v <- approx(x=small_dat2$depth_level, y = small_dat2$V1)
# linear2 <- as.data.frame(linear_v)
# linear2$Date <- small_dat2$date[1]
# linear2 <- linear2 %>% rename(Depth = x, VCUR = y)
# 
# plot(small_dat2$V1~small_dat2$depth_level, col="red")
# points(linear_v$x, linear_v$y)

combine_depth_I <- full_data_I %>% group_by(Date) %>% summarise(UCUR = mean(UCUR, na.rm=T))
write_csv(combine_depth_I, paste0("Daily U Velocity ", sites$site[j],"_BRAN 10_30m.csv"))

}
