library(dplyr)
library(tidyr)

species <- Sys.getenv("species")
direction <- Sys.getenv("direction")
file.path <- paste("../../srv/scratch/z5278054/portunid_particle_tracking",
                   species, direction, "processed", sep = "/")

if (species == "spanner"){
  files <- list.files(file.path, pattern = "settled.rds")
  
  particles <- data.frame()
  for (i in 1:length(files)){
    temp <- readRDS(paste(file.path, files[i], sep = "/"))
    particles <- bind_rows(particles, temp)
  }
  
  saveRDS(particles, paste(file.path, paste(species, direction, "master_settled.rds", sep = "_"), sep = "/"))
  
  files <- list.files(file.path, pattern = "final_points.rds")
  
  particles <- data.frame()
  for (i in 1:length(files)){
    temp <- readRDS(paste(file.path, files[i], sep = "/"))
    particles <- bind_rows(particles, temp)
  }
  
  saveRDS(particles, paste(file.path, paste(species, direction, "master_final.rds", sep = "_"), sep = "/"))
  
  #############
  
  files <- list.files(file.path, pattern = "2_settled.rds")
  
  particles <- data.frame()
  for (i in 1:length(files)){
    temp <- readRDS(paste(file.path, files[i], sep = "/"))
    particles <- bind_rows(particles, temp)
  }
  
  saveRDS(particles, paste(file.path, paste(species, direction, "2_master_settled.rds", sep = "_"), sep = "/"))
  
  files <- list.files(file.path, pattern = "2_final_points.rds")
  
  particles <- data.frame()
  for (i in 1:length(files)){
    temp <- readRDS(paste(file.path, files[i], sep = "/"))
    particles <- bind_rows(particles, temp)
  }
  
  saveRDS(particles, paste(file.path, paste(species, direction, "2_master_final.rds", sep = "_"), sep = "/"))
  
  #############
  
  files <- list.files(file.path, pattern = "10_settled.rds")
  
  particles <- data.frame()
  for (i in 1:length(files)){
    temp <- readRDS(paste(file.path, files[i], sep = "/"))
    particles <- bind_rows(particles, temp)
  }
  
  saveRDS(particles, paste(file.path, paste(species, direction, "10_master_settled.rds", sep = "_"), sep = "/"))
  
  files <- list.files(file.path, pattern = "10_final_points.rds")
  
  particles <- data.frame()
  for (i in 1:length(files)){
    temp <- readRDS(paste(file.path, files[i], sep = "/"))
    particles <- bind_rows(particles, temp)
  }
  
  saveRDS(particles, paste(file.path, paste(species, direction, "10_master_final.rds", sep = "_"), sep = "/"))
} else {
  files <- list.files(file.path, pattern = "settled.rds")
  
  particles <- data.frame()
  for (i in 1:length(files)){
    temp <- readRDS(paste(file.path, files[i], sep = "/"))
    particles <- bind_rows(particles, temp)
  }
  
  saveRDS(particles, paste(file.path, paste(species, direction, "master_settled.rds", sep = "_"), sep = "/"))
  
  files <- list.files(file.path, pattern = "final_points.rds")
  
  particles <- data.frame()
  for (i in 1:length(files)){
    temp <- readRDS(paste(file.path, files[i], sep = "/"))
    particles <- bind_rows(particles, temp)
  }
  
  saveRDS(particles, paste(file.path, paste(species, direction, "master_final.rds", sep = "_"), sep = "/"))
  
  files <- list.files(file.path, pattern = "mortality.rds")
  
  particles <- data.frame()
  for (i in 1:length(files)){
    temp <- readRDS(paste(file.path, files[i], sep = "/"))
    particles <- bind_rows(particles, temp)
  }
  
  saveRDS(particles, paste(file.path, paste(species, direction, "master_mortality.rds", sep = "_"), sep = "/"))
  
  mortality <- particles %>%
    group_by(mortality, shelf.zone, eac.zone, year) %>%
    summarise(n = sum(n),
              total = total) %>% 
    ungroup() %>%
    group_by(mortality, eac.zone, shelf.zone) %>%
    summarise(mean = mean(n),
              sd = sd(n),
              total = sum(total)) %>% 
    ungroup() %>% 
    pivot_wider(names_from = mortality, values_from = c(mean, sd)) %>%
    rename(mean_disp_mort = `mean_dispersal mortality`,
           sd_disp_mort = `sd_dispersal mortality`,
           mean_nat_mort = `mean_natural mortality`,
           sd_nat_mort = `sd_natural mortality`,
           mean_settlement = `mean_no mortality`,
           sd_settlement = `sd_no mortality`) %>%
    relocate(eac.zone, shelf.zone, mean_disp_mort, sd_disp_mort, 
             mean_nat_mort, sd_nat_mort, mean_settlement, sd_settlement) %>%
    mutate(perc_disp_mort = mean_disp_mort/total,
           perc_sd_disp_mort = sd_disp_mort/total,
           perc_nat_mort = mean_nat_mort/total,
           perc_sd_nat_mort = sd_nat_mort/total,
           perc_settlement = mean_settlement/total,
           perc_sd_settlement = sd_settlement/total)
  
  saveRDS(mortality, paste(file.path, paste(species, direction, "summarised_mortality.rds", sep = "_"), sep = "/"))
}
