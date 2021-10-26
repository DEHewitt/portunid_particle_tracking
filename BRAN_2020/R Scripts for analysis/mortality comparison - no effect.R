# Comparing 1x and 10x mortality
library(tidyverse)

setwd("C:/Users/htsch/Documents/GitHub/portunid_particle_tracking/BRAN_2020/")

dat1 <- read_csv("Predicted recruitment full season mortalityx1.csv")
dat10 <- read_csv("Predicted recruitment full season mortalityx10.csv")

cor.test(dat1$Predicted_recruitment, dat10$Predicted_recruitment)
