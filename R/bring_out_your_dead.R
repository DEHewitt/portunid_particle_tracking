bring_out_your_dead <- function(data){
  # this is a function for calculating sources of mortality for particles
  
  total.part <- data$particle.id %>% unique() %>% length()
  if(species == "snapper"){
  out <- data %>%
    mutate(beached = 0) %>% # remove if using this properly (currently removed beaching counts)
    group_by(particle.id) %>%
    filter(degree.days > dd.cutoff) %>%
    filter(obs == min(obs)) %>% 
    mutate(mortality = case_when(stage == "megalopa" &
                                   status == "alive" &
                                   beached == 0 &
                                   is.na(region) == FALSE ~ "no mortality",
                                 stage == "megalopa" &
                                   status == "alive" &
                                   beached == 0 &
                                   is.na(region) == TRUE ~ "dispersal mortality",
                                 stage == "megalopa" &
                                   status == "dead" ~ "natural mortality",
                                 stage == "megalopa" &
                                   status == "alive" &
                                   beached == 1 ~ "dispersal mortality")) %>%
    ungroup() %>%
    mutate(year = min(year(rel_date))) %>%
    group_by(mortality, ocean_zone, year) %>%
    summarise(n = n()) %>%
    ungroup() %>%
    mutate(n = if_else(mortality == "dispersal mortality", n + (total.part-sum(n)), n)) %>%
    add_column(total = total.part) %>%
    mutate(beaching = total.part-sum(n))
  }
  else if (species != "spanner"){
  out <- data %>%
  group_by(particle.id) %>%
  filter(degree.days > dd.cutoff) %>%
  filter(obs == min(obs)) %>% 
  mutate(mortality = case_when(stage == "megalopa" &
                                 status == "alive" &
                                 beached == 0 &
                                 is.na(estuary) == FALSE ~ "no mortality",
                               stage == "megalopa" &
                                 status == "alive" &
                                 beached == 0 &
                                 is.na(estuary) == TRUE ~ "dispersal mortality",
                               stage == "megalopa" &
                                 status == "dead" ~ "natural mortality",
                               stage == "megalopa" &
                                 status == "alive" &
                                 beached == 1 ~ "dispersal mortality")) %>%
  ungroup() %>%
  mutate(year = min(year(rel_date))) %>%
  group_by(mortality, eac.zone, shelf.zone, year) %>%
  summarise(n = n()) %>%
  ungroup() %>%
  mutate(n = if_else(mortality == "dispersal mortality", n + (total.part-sum(n)), n)) %>%
  add_column(total = total.part) %>%
  mutate(beaching = total.part-sum(n))
}}