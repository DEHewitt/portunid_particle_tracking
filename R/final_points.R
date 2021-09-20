final_points <- function(data){
  # create a df of final points (dd = dd.cutoff and alive)
  
  data <- data %>% filter(beached == 0)
  
  if (direction == "forwards"){
    particles.final <- data %>%
      filter(settlement == "settled" & status == "alive") %>%
      filter(degree.days < dd.cutoff + temp) %>%
      group_by(traj) %>%
      filter(obs == min(obs)) %>%
      ungroup()
  } else if (direction == "backwards"){
    particles.final <- data %>%
      filter(settlement == "settled") %>%
      filter(degree.days < dd.cutoff + temp) %>%
      group_by(traj) %>%
      filter(obs == min(obs)) %>%
      ungroup()
  }
}