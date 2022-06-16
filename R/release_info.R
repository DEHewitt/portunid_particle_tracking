release_info <- function(data){
  if (direction == "forwards"){
    
    data <- data %>%
      mutate(rel_lat = if_else(obs == 1, lat, NA_real_)) %>%
      mutate(rel_lon = if_else(obs == 1, lon, NA_real_)) %>%
      mutate(rel_date = if_else(obs == 1, date, as.POSIXct(NA_Date_))) %>%
      mutate(rel_date = as.character(rel_date)) %>%
      mutate(rel_bathy = if_else(obs == 1, bathy, NA_real_))
    
    data$rel_lat <- na.locf(data$rel_lat, na.rm = F) 
    data$rel_lon <- na.locf(data$rel_lon, na.rm = F)
    data$rel_date <- na.locf(data$rel_date, na.rm = F)
    data$rel_bathy <- na.locf(data$rel_bathy, na.rm = F)
    
    data <- data %>% # the regions here are based on ozROMS - not commonly accepted regions (in literature)
      mutate(eac.zone = case_when(rel_lat > -24 ~ "Great Barrier Reef", 
                                  rel_lat <- 24 & rel_lat > -28 ~ "EAC jet",
                                  rel_lat < -28 & rel_lat > -31 ~ "EAC separation",
                                  rel_lat < -31 ~ "Eddy field")) %>%
      mutate(shelf.zone = case_when(rel_bathy < 50 ~ "Inner",
                                    rel_bathy > 50 & rel_bathy < 100 ~ "Mid",
                                    rel_bathy > 100 ~ "Outer"))
    
    data
  } else if (direction == "backwards" & species == "gmc" | direction == "backwards" & species == "bsc"){
    data <- data %>%
      mutate(rel_lat = if_else(obs == 1, lat, NA_real_)) %>%
      mutate(rel_lon = if_else(obs == 1, lon, NA_real_)) %>%
      mutate(rel_date = if_else(obs == 1, date, as.POSIXct(NA_Date_))) %>%
      mutate(rel_date = as.character(rel_date))
    
    data$rel_lat <- na.locf(data$rel_lat, na.rm = F)
    data$rel_lon <- na.locf(data$rel_lon, na.rm = F)
    data$rel_date <- na.locf(data$rel_date, na.rm = F)
    
    data <- data %>%
      mutate(rel_est = case_when(rel_lat == -18.541 ~ "Hinchinbrook Island",
                                 rel_lat == -23.850 ~ "The Narrows",
                                 rel_lat == -25.817 ~ "Maryborough/Hervey Bay",
                                 rel_lat == -26.339 ~ "Moreton Bay",
                                 rel_lat == -27.165 ~ "Tweed River",
                                 rel_lat == -28.890 ~ "Richmond River",
                                 rel_lat == -29.432 ~ "Clarence River",
                                 rel_lat == -30.864 ~ "Macleay River",
                                 rel_lat == -31.645 ~ "Camden Haven",
                                 rel_lat == -31.899 ~ "Manning River",
                                 rel_lat == -32.193 ~ "Wallis Lake",
                                 rel_lat == -32.719 ~ "Port Stephens",
                                 rel_lat == -32.917 ~ "Hunter River",
                                 rel_lat == -33.578 ~ "Hawkesbury River",
                                 rel_lat == -34.546 ~ "Lake Illawarra"))
    
    data
  } 
}