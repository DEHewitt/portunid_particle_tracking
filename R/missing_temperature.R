missing_temperature <- function(data){
  # back fill missing temperature values
  
  # if temp == 0 make it an NA
  is.na(data$temp) <- data$temp == 0
  
  # replace NA with last non-NA observation carried forward - not sure we need both of these lines
  #data <- data %>%
    #group_by(particle.id) %>%
    #arrange(obs) %>%
    #fill(temp) %>%
    #ungroup()
  
  data <- data %>%
    group_by(particle.id) %>%
    arrange(obs) %>%
    mutate(temp = zoo::na.locf(temp, na.rm = FALSE)) %>%
    ungroup()
}
