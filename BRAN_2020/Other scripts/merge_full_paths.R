# merge full paths

library(tidyverse)

#mydata <- readRDS("full_paths/Output_1.rds")

file_list <- list.files("/srv/scratch/z3374139/portunid_particle_tracking/spanner/forwards/full_paths/", pattern = ".rds", full.names = T)

data_list <- list()

for(i in (1:length(file_list))){
  data_list[[i]] <- readRDS(file_list[i])
  data_list[[i]] <- data_list[[i]] %>% mutate(Month = lubridate::month(lubridate::ymd(rel_date))) %>% filter(Month > 10 | Month <2) %>% select(-Month)
}

data_list <- bind_rows(data_list)
saveRDS(data_list, "/srv/scratch/z3374139/portunid_particle_tracking/spanner/forwards/full_paths/All_together_now_paths.rds")

#mydata <- mydata %>% mutate(Month = lubridate::month(lubridate::ymd(rel_date))) %>% filter(Month > 10 | Month <2) %>% select(-Month)
