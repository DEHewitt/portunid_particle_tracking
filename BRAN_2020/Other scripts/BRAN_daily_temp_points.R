# BRAN daily currents
library(tidyverse)

### BRAN Levels: 2.5, 7.5, 12.5, 17.515390396118164, 22.667020797729492, 28.16938018798828, 34.2180061340332
depth_levels <- c(2.5, 7.5, 12.5, 17.515390396118164, 22.667020797729492, 28.16938018798828, 34.2180061340332)
sites <- read_csv("site lat longs.csv")
library(raster)

file_list <- list.files("/srv/scratch/z3374139/BRAN_AUS/", pattern = "Ocean_temp", full.names = T)

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
  
  write_csv(combine_depth_I, paste0("Daily Temp_", sites$site[j], "_BRAN 10_30m.csv"))
}