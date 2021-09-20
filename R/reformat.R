reformat <- function(data, species, direction){
  
  if (direction == "forwards" & species == "gmc"){
    data <- data %>%
      mutate(estuary = if_else(estuary == "Maryborough/Hervey Bay", "Maryborough", estuary)) %>%
      mutate(estuary = factor(estuary,
                              levels = c("Hinchinbrook Island", 
                                         "The Narrows", 
                                         "Maryborough", 
                                         "Moreton Bay",
                                         "Tweed River", 
                                         "Richmond River", 
                                         "Clarence River", 
                                         "Macleay River", 
                                         "Camden Haven", 
                                         "Manning River", 
                                         "Wallis Lake", 
                                         "Port Stephens", 
                                         "Hunter River", 
                                         "Hawkesbury River",
                                         "Lake Illawarra"))) %>%
      mutate(est.abbr = case_when(estuary == "Hinchinbrook Island" ~ "HBI", 
                                  estuary == "The Narrows" ~ "NAR", 
                                  estuary =="Maryborough" ~ "MRY",
                                  estuary == "Moreton Bay" ~ "MB", 
                                  estuary == "Tweed River" ~ "TWR", 
                                  estuary == "Richmond River" ~ "RMR",
                                  estuary == "Clarence River" ~ "CLR", 
                                  estuary == "Macleay River" ~ "MLR", 
                                  estuary == "Camden Haven" ~ "CHV",
                                  estuary == "Manning River" ~ "MMR", 
                                  estuary == "Wallis Lake" ~ "WLL", 
                                  estuary == "Port Stephens" ~ "PST",
                                  estuary == "Hunter River" ~ "HRR", 
                                  estuary == "Hawkesbury River" ~ "HBR")) %>%
      mutate(est.lat = case_when(estuary == "Hinchinbrook Island" ~ -18.54, 
                                 estuary == "The Narrows" ~ -23.85, 
                                 estuary =="Maryborough" ~ -25.82,
                                 estuary == "Moreton Bay" ~ -27.34, 
                                 estuary == "Tweed River" ~ -28.17, 
                                 estuary == "Richmond River" ~ -28.89,
                                 estuary == "Clarence River" ~ -29.43, 
                                 estuary == "Macleay River" ~ -30.86, 
                                 estuary == "Camden Haven" ~ -31.65,
                                 estuary == "Manning River" ~ -31.90, 
                                 estuary == "Wallis Lake" ~ -32.19, 
                                 estuary == "Port Stephens" ~ -32.72,
                                 estuary == "Hunter River" ~ -32.92, 
                                 estuary == "Hawkesbury River" ~ -33.59,
                                 estuary == "Lake Illawarra"  ~ -34.55)) %>%
      mutate(est.label = paste(estuary, " (", est.lat, ")", sep = "")) %>%
      mutate(est.label = factor(est.label,
                                levels = c("Hinchinbrook Island (-18.54)", 
                                           "The Narrows (-23.85)", 
                                           "Maryborough (-25.82)",
                                           "Moreton Bay (-27.34)", 
                                           "Tweed River (-28.17)", 
                                           "Richmond River (-28.89)",
                                           "Clarence River (-29.43)", 
                                           "Macleay River (-30.86)", 
                                           "Camden Haven (-31.65)",
                                           "Manning River (-31.9)", 
                                           "Wallis Lake (-32.19)", 
                                           "Port Stephens (-32.72)",
                                           "Hunter River (-32.92)", 
                                           "Hawkesbury River (-33.59)")))
    
    # reformat some date things
    data <- data %>%
      mutate(season = if_else(month(data$rel_date) < 5, 
                              paste(year(data$rel_date)-1, year(data$rel_date), sep = "-"), 
                              paste(year(data$rel_date), year(data$rel_date)+1, sep = "-"))) %>%
      # month of settltment
      mutate(month = month(date)) %>%
      #mutate(month = if_else(month < 10, paste("0", month, sep = ""), as.character(month))) %>%
      # year of settlement
      mutate(year = year(date)) %>%
      # month and year of settlement
      mutate(month.year = paste(month, year, sep = "/"))
    
  } else if (direction == "forwards" & species == "bsc"){
    data <- data %>%
      mutate(estuary = if_else(estuary == "Maryborough/Hervey Bay", "Maryborough", estuary)) %>%
      mutate(estuary = factor(estuary,
                              levels = c("Maryborough", 
                                         "Moreton Bay",
                                         "Wallis Lake", 
                                         "Port Stephens", 
                                         "Hunter River", 
                                        # "Hawkesbury River",
                                         "Lake Illawarra"))) %>%
      mutate(est.abbr = case_when(estuary =="Maryborough" ~ "MRY",
                                  estuary == "Moreton Bay" ~ "MB", 
                                  estuary == "Wallis Lake" ~ "WLL", 
                                  estuary == "Port Stephens" ~ "PST",
                                  estuary == "Hunter River" ~ "HRR", 
                                  #estuary == "Hawkesbury River" ~ "HBR",
                                  estuary == "Lake Illawarra" ~ "LIL")) %>%
      mutate(est.lat = case_when(estuary =="Maryborough" ~ -25.82,
                                 estuary == "Moreton Bay" ~ -27.34, 
                                 estuary == "Wallis Lake" ~ -32.19, 
                                 estuary == "Port Stephens" ~ -32.72,
                                 estuary == "Hunter River" ~ -32.92, 
                                 #estuary == "Hawkesbury River" ~ -33.59,
                                 estuary == "Lake Illawarra"  ~ -34.55)) %>%
      mutate(est.label = paste(estuary, " (", est.lat, ")", sep = "")) %>%
      mutate(est.label = factor(est.label,
                                levels = c("Maryborough (-25.82)",
                                           "Moreton Bay (-27.34)", 
                                           "Wallis Lake (-32.19)", 
                                           "Port Stephens (-32.72)",
                                           "Hunter River (-32.92)", 
                                           #"Hawkesbury River (-33.59)",
                                           "Lake Illawarra (-34.55)")))
    
    # reformat some date things
    data <- data %>%
      mutate(season = if_else(month(data$rel_date) < 5, 
                              paste(year(data$rel_date)-1, year(data$rel_date), sep = "-"), 
                              paste(year(data$rel_date), year(data$rel_date)+1, sep = "-"))) %>%
      # month of settltment
      mutate(month = month(date)) %>%
      #mutate(month = if_else(month < 10, paste("0", month, sep = ""), as.character(month))) %>%
      # year of settlement
      mutate(year = year(date)) %>%
      # month and year of settlement
      mutate(month.year = paste(month, year, sep = "/"))
    
  } else if (direction == "backwards" & species == "gmc"){
    data <- data %>%
      mutate(rel_lat = round(rel_lat, 3)) %>%
      mutate(rel_est = case_when(rel_lat == -18.541 ~ "Hinchinbrook Island",
                                 rel_lat == -23.850 ~ "The Narrows",
                                 rel_lat == -25.817 ~ "Maryborough/Hervey Bay",
                                 rel_lat == -27.339 ~ "Moreton Bay",
                                 rel_lat == -28.165 ~ "Tweed River",
                                 rel_lat == -28.890 ~ "Richmond River",
                                 rel_lat == -29.432 ~ "Clarence River",
                                 rel_lat == -30.864 ~ "Macleay River",
                                 rel_lat == -31.645 ~ "Camden Haven",
                                 rel_lat == -31.899 ~ "Manning River",
                                 rel_lat == -32.193 ~ "Wallis Lake",
                                 rel_lat == -32.719 ~ "Port Stephens",
                                 rel_lat == -32.917 ~ "Hunter River",
                                 rel_lat == -33.578 ~ "Hawkesbury River",
                                 rel_lat == -34.546 ~ "Lake Illawarra")) %>%
      mutate(rel_est = if_else(rel_est == "Maryborough/Hervey Bay", "Maryborough", rel_est)) %>%
      mutate(season = if_else(month(data$date) < 5, 
                              paste(year(data$date)-1, year(data$date), sep = "-"), 
                              paste(year(data$date), year(data$date)+1, sep = "-")))
    
  } else if (direction == "backwards" & species == "bsc"){
    data <- data %>%
      mutate(rel_lat = round(rel_lat, 3)) %>%
      mutate(rel_est = case_when(rel_lat == -25.817 ~ "Maryborough/Hervey Bay",
                                 rel_lat == -27.339 ~ "Moreton Bay",
                                 rel_lat == -32.193 ~ "Wallis Lake",
                                 rel_lat == -32.719 ~ "Port Stephens",
                                 rel_lat == -32.917 ~ "Hunter River",
                                 #rel_lat == -33.578 ~ "Hawkesbury River",
                                 rel_lat == -34.546 ~ "Lake Illawarra")) %>%
      mutate(rel_est = if_else(rel_est == "Maryborough/Hervey Bay", "Maryborough", rel_est)) %>%
      mutate(season = if_else(month(data$date) < 5, 
                              paste(year(data$date)-1, year(data$date), sep = "-"), 
                              paste(year(data$date), year(data$date)+1, sep = "-")))
  }
  
  data
}
