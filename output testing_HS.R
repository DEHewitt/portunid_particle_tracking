setwd("~/GitHub/portunid_particle_tracking")

library(tidync)
library(tidyverse)
library(ggplot2)

mydata <- hyper_tibble("3d_advect.nc")

ggplot(mydata, aes(x=obs, y = depth_m)) + geom_point() + geom_point(aes(y=-bathy),col="red")+ geom_line(aes(group=traj))

ggplot(mydata, aes(x=obs, y = z)) + geom_point() + geom_line(aes(group=traj))


# 3D plot of trajectory
library(plotly)

mydata2 <- mydata %>% filter(trajectory == 340)

plot_ly(mydata2, y=~lon, z=~depth_m, x=~-lat,color=~bathy, type="scatter3d", mode="lines")
