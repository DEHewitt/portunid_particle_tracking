settlers <- function(data, direction){
  if(direction == "forwards"){
    if (species == "spanner"){
      data <- data %>%
        mutate(settlement = if_else(degree.days > dd.cutoff &
                                      status == "alive" &
                                      beached == 0,
                                    "settled",
                                    "not settled"))}
    else{data <- data %>%
      mutate(settlement = if_else(degree.days > dd.cutoff &
                                    status == "alive" &
                                    beached == 0 &
                                    is.na(estuary) == FALSE,
                                  "settled",
                                  "not settled"))}
  }else if(direction == "backwards"){
    data <- data %>%
      mutate(settlement = if_else(degree.days > dd.cutoff, "settled", "not settled"))
  }
  
}