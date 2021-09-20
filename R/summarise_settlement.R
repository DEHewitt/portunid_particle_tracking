summarise_settlement <- function(data, logbook, species, group, timespan){
  # data is the parcels output
  # logbook is the summarised logbook data (output of summarise_logbook())
  # species is either "gmc" or "bsc"
  # group is the spatial grouping, either "estuary" or "egf"
  
  if (group == "estuary"){
    # extract the estuaries we have catch data for
    estuaries <- logbook$estuary %>% unique()
    
    data <- data %>%
      filter(estuary %in% estuaries)
    
    if (timespan == "year"){
      # summarize the settlement
      data <- data %>%
        group_by(estuary, year) %>%
        dplyr::summarise(settlement = n()) %>%
        ungroup()
    } else if (timespan == "month"){
      data <- data %>%
        group_by(estuary, month.year) %>%
        dplyr::summarise(settlement = n()) %>%
        ungroup() %>%
        mutate(date = dmy(paste("1", month.year, sep = "/")))
    }
    
    
  } else if (group == "egf"){
    # extract the mgmt.zones we have catch data for
    mgmt.zones <- logbook$mgmt.zone %>% unique()
    
    data <- data %>%
      filter(mgmt.zone %in% mgmt.zones)
    
    data <- data %>%
      group_by(mgmt.zone, year) %>%
      dplyr::summarise(settlement = n()) %>%
      ungroup()
  }
  data
}
