settlers <- function(data, direction){
  if(direction == "forwards"){
    data <- data %>%
      mutate(settlement = if_else(degree.days > dd.cutoff &
                                    status == "alive" &
                                    beached == 0 &
                                    is.na(estuary) == FALSE,
                                  "settled",
                                  "not settled"))
  } else if(direction == "backwards"){
    data <- data %>%
      mutate(settlement = if_else(degree.days > dd.cutoff, "settled", "not settled"))
  }
  
}