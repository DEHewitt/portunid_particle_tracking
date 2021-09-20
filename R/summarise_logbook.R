summarise_logbook <- function(data, particles, species, group, timespan){
  # data is the logbook data
  # particles is the parcels output for the species
  # species is either "gmc" or "bsc"
  # group is the spatial grouping, either "estuary" or "egf"
  # timespan refers to yearly or monthly grouping
  
  data <- data %>%
    # make all columns lower case
    clean_names() %>%
    # create estuary column
    mutate(estuary = case_when(estuaryname == "Tweed River" ~ "Tweed River",
                               estuaryname == "Richmond River" ~ "Richmond River",
                               estuaryname == "Clarence River" ~ "Clarence River",
                               estuaryname == "Lake Wooloweyah" ~ "Clarence River",
                               estuaryname == "Macleay River" ~ "Macleay River",
                               estuaryname == "Camden Haven River" ~ "Camden Haven",
                               estuaryname == "Manning River" ~ "Manning River",
                               estuaryname == "Myall River" ~ "Port Stephens",
                               estuaryname == "Wallis Lake" ~ "Wallis Lake",
                               estuaryname == "Karuah River" ~ "Port Stephens",
                               estuaryname == "Port Stephens" ~ "Port Stephens",
                               estuaryname == "Hunter River" ~ "Hunter River",
                               estuaryname == "Hawkesbury River" ~ "Hawkesbury River",
                               estuaryname == "Lake Illawarra" ~ "Lake Illawarra"))
  
  # change name of endorsement code
  data <- data %>% rename(mgmt.zone = endorsement_code)
  
  # change the naming of egf zones
  if (species == "gmc"){
    data <- data %>%
      mutate(mgmt.zone = case_when(mgmt.zone == "EGMC1" ~ "EGF1",
                                   mgmt.zone == "EGMC2" ~ "EGF2",
                                   mgmt.zone == "EGMC3" ~ "EGF3",
                                   mgmt.zone == "EGMC4" ~ "EGF4",
                                   mgmt.zone == "EGMC5" ~ "EGF5"))
  } else if (species == "bsc"){
    data <- data %>%
      mutate(mgmt.zone = case_when(mgmt.zone == "EGMC1" ~ "EGF1",
                                   mgmt.zone == "EGMC2" ~ "EGF2",
                                   mgmt.zone == "EGMC3" ~ "EGF3",
                                   mgmt.zone == "EGMC4" ~ "EGF4",
                                   mgmt.zone == "EGMC5" ~ "EGF5",
                                   mgmt.zone == "EGMC6" ~ "EGF6",
                                   mgmt.zone == "EGT1" ~ "EGF1",
                                   mgmt.zone == "EGT2" ~ "EGF2",
                                   mgmt.zone == "EGT3" ~ "EGF3",
                                   mgmt.zone == "EGT4" ~ "EGF4",
                                   mgmt.zone == "EGT5" ~ "EGF5",
                                   mgmt.zone == "EGT6" ~ "EGF6"))
  }
  
  if (group == "estuary"){
    # extract estuaries we have settlement estimates for
    estuaries <- particles$estuary %>% unique()
    
    data <- data %>%
      filter(estuary %in% estuaries)
    
    # create an 'event code'
    data$event_code <- data %>% 
      group_indices(fishing_business_owner_name, 
                    event_date, 
                    estuary, 
                    logsheet_number)
    
    # get only the variables we care about
    data <- data %>%
      select(event_date, event_code, estuary, effort = catch_effort_quantity, catch_weight, event_date_year_month)
    
    if (timespan == "year"){
      # summarize the logbook
      data <- data %>% 
        group_by(event_code, estuary, event_date) %>%
        dplyr::summarise(catch = sum(catch_weight), effort = effort) %>%
        ungroup() %>%
        distinct(event_code, .keep_all = TRUE) %>%
        mutate(event_date = dmy(event_date)) %>%
        mutate(year = year(event_date)) %>%
        filter(!is.na(catch)) %>%
        filter(catch < 100) %>%
        filter(effort > 0 & effort < 50) %>%
        group_by(event_code, estuary) %>%
        mutate(cpue = catch/effort) %>%
        group_by(year, estuary) %>%
        summarise(mean.cpue = mean(cpue),
                  se.cpue = sd(cpue)/sqrt(length(cpue)),
                  landings = sum(catch)) %>%
        ungroup()
    } else if (timespan == "month"){
      data <- data %>% 
        group_by(event_code, estuary, event_date) %>%
        dplyr::summarise(catch = sum(catch_weight), effort = effort) %>%
        ungroup() %>%
        distinct(event_code, .keep_all = TRUE) %>%
        mutate(event_date = dmy(event_date)) %>%
        mutate(month = month(event_date)) %>%
        mutate(year = year(event_date)) %>%
        filter(!is.na(catch)) %>%
        filter(catch < 100) %>%
        filter(effort > 0 & effort < 50) %>%
        group_by(event_code, estuary) %>%
        mutate(cpue = catch/effort) %>%
        group_by(month, year, estuary) %>%
        summarise(mean.cpue = mean(cpue),
                  se.cpue = sd(cpue)/sqrt(length(cpue)),
                  landings = sum(catch)) %>%
        ungroup() %>%
        mutate(date = dmy(paste("1", month, year, sep = "/")))
    }
    
    
  } else if (group == "egf"){
    # extract estuaries we have settlement estimates for
    estuaries <- particles$estuary %>% unique()
    
    data <- data %>%
      filter(estuary %in% estuaries)
    
    # create an 'event code'
    data$event_code <- data %>% 
      group_indices(fishing_business_owner_name, 
                    event_date, 
                    estuary, 
                    logsheet_number)
    
    # get only the variables we care about
    data <- data %>%
      select(event_date, event_code, mgmt.zone, effort = catch_effort_quantity, catch_weight, event_date_year_month)
    
    # summarize the logbook
    data <- data %>% 
      group_by(event_code, mgmt.zone, event_date) %>%
      dplyr::summarise(catch = sum(catch_weight), effort = effort) %>%
      ungroup() %>%
      distinct(event_code, .keep_all = TRUE) %>%
      mutate(event_date = dmy(event_date)) %>%
      mutate(year = year(event_date)) %>%
      filter(!is.na(catch)) %>%
      filter(catch < 100) %>%
      filter(effort > 0 & effort < 50) %>%
      group_by(event_code, mgmt.zone) %>%
      mutate(cpue = catch/effort) %>%
      group_by(year, mgmt.zone) %>%
      summarise(mean.cpue = mean(cpue),
                se.cpue = sd(cpue)/sqrt(length(cpue)),
                landings = sum(catch)) %>%
      ungroup()
    
  }
  data
}
