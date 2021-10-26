# merge all settled files

library(tidyverse)

file_list <- list.files("/srv/scratch/z3374139/portunid_particle_tracking/spanner/forwards/processed", pattern = "settled.rds",
                        full.names = TRUE)

full_dat <- list()

for(i in 1:length(file_list)){
  full_dat[[i]] <- readRDS(file_list[i])
}

full_dat <- bind_rows(full_dat)

write_csv(full_dat, "/srv/scratch/z3374139/portunid_particle_tracking/spanner/forwards/processed/spanner_forward_master_settled.csv")