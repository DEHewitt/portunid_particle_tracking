spawning_season <- function(data){
  if (species == "gmc" & direction == "forwards" | species == "bsc" & direction == "forwards"){
  data <- data %>%
    filter(month(rel_date) != "5")
  } else if (species == "spanner" & direction == "forwards") {
    data <- data %>%
      filter(month(rel_date) != "2")
  }
}
