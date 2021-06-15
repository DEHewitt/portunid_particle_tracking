settlement_points <- function(data){
  if (direction == "forwards"){
    if (species == "gmc" | species == "bsc"){
      particles.settled <- data %>% 
        group_by(traj) %>% 
        # only select settled, living particles that made it within range of an estuary
        filter(settlement == "settled" & status == "alive" & estuary != is.na(estuary) & bathy < 200) %>% 
        filter(obs == min(obs)) %>% # only want the first day
        ungroup()
    } else if (species == "spanner"){
      particles.settled <- data %>% 
        group_by(traj) %>% 
        filter(settlement == "settled" & status == "alive" & region != is.na(region)) %>%
        filter(obs == min(obs)) %>% 
        ungroup()
    }
  } else if (direction == "backwards"){
    # backwards particles
    if (species == "gmc" | species == "bsc"){
      particles.settled <- data %>% 
        group_by(traj) %>% 
        filter(settlement == "settled" & bathy < 200 & month(date) %in% c(1, 2, 3, 4, 9, 10, 11, 12)) %>%
        filter(obs == min(obs)) %>% 
        ungroup()
    } else if (species == "spanner"){
      particles.settled <- data %>% 
        group_by(traj) %>% 
        filter(settlement == "settled" & region != is.na(region) & month(date) %in% c(1, 2, 3, 10, 11, 12)) %>%
        filter(obs == min(obs)) %>% 
        ungroup()
    }
  }
}

