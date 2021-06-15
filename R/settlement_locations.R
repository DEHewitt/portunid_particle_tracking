settlement_locations <- function(data){
  if (direction == "forwards"){
    if (species == "gmc"){
      data <- data %>%
        mutate(estuary = case_when(lat < -18.441 & lat > -18.641 ~ "Hinchinbrook Island",
                                   lat < -23.750 & lat > -23.950 ~ "The Narrows",
                                   lat < -25.717 & lat > -25.917 ~ "Maryborough/Hervey Bay",
                                   lat < -26.239 & lat > -27.439 ~ "Moreton Bay",
                                   lat < -27.065 & lat > -28.265 ~ "Tweed River",
                                   lat < -28.790 & lat > -28.990 ~ "Richmond River",
                                   lat < -29.332 & lat > -29.532 ~ "Clarence River",
                                   lat < -30.764 & lat > -30.964 ~ "Macleay River",
                                   lat < -31.545 & lat > -31.745 ~ "Camden Haven",
                                   lat < -31.799 & lat > -31.999 ~ "Manning River",
                                   lat < -32.093 & lat > -32.293 ~ "Wallis Lake",
                                   lat < -32.619 & lat > -32.816 ~ "Port Stephens",
                                   lat < -32.817 & lat > -33.017 ~ "Hunter River",
                                   lat < -33.478 & lat > -33.678 ~ "Hawkesbury River")) %>%
        mutate(state = case_when(lat > -28.16427 ~ "QLD",
                                 lat < -28.16427 ~ "NSW")) %>%
        mutate(mgmt.zone = if_else(state == "QLD", "C1", 
                                   if_else(estuary %in% c("Tweed River", "Richmond River"), "EGF1", 
                                           if_else(estuary %in% c("Clarence River", "Macleay River"),"EGF2",
                                                   if_else(estuary == "Camden Haven", "EGF3",
                                                           if_else(estuary %in% c("Manning River", "Wallis Lake", "Port Stephens", "Hunter River"), "EGF4", 
                                                                   if_else(estuary == "Hawkesbury River", "EGF5", "FALSE")))))))
    } else if (species == "bsc"){
      data <- data %>%
        mutate(estuary = case_when(lat < -25.717 & lat > -25.917 ~ "Maryborough/Hervey Bay",
                                   lat < -26.239 & lat > -27.439 ~ "Moreton Bay",
                                   lat < -32.093 & lat > -32.293 ~ "Wallis Lake",
                                   lat < -32.619 & lat > -32.816 ~ "Port Stephens",
                                   lat < -32.817 & lat > -33.017 ~ "Hunter River",
                                   lat < -34.4457 & lat > -34.6457 ~ "Lake Illawarra"))  %>%
        mutate(state = case_when(lat > -28.16427 ~ "QLD",
                                 lat < -28.16427 ~ "NSW")) %>%
        mutate(mgmt.zone = if_else(state == "QLD", "C1",
                                   if_else(estuary %in% c("Manning River", "Wallis Lake", "Port Stephens", "Hunter River"), "EGF4", 
                                           if_else(estuary == "Hawkesbury River", "EGF5", 
                                                   if_else(estuary == "Lake Illawarra", "EGF6", "FALSE")))))
    } else if (species == "spanner"){
      data <- data %>%
        mutate(state = case_when(lat > -28.16427 ~ "QLD",
                                 lat < -28.16427 ~ "NSW")) %>%
        mutate(region = if_else(lat < -23 & lat > -24, 2,
                                if_else(lat < -24 & lat > -25, 3,
                                        if_else(lat < -25 & lat > -26.5, 4,
                                                if_else(lat < -26.5 & lat > -27.5, 5,
                                                        if_else(lat < -27.5 & lat > -28.1643, 6,
                                                                if_else(lat < -28.1643 & lat > -29.428612, 7, NA_real_)))))))
    }
  }
}
