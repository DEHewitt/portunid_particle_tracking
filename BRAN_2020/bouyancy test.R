# test BRAN dispersal output

library(tidync)

mydata <- hyper_tibble("C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN/Output/BRAN_Test_output.nc")

mydata2 <- mydata %>% filter(traj==10)

ggplot(mydata, aes(age/86400, depthA, col=as.character(traj))) + geom_line()
 
