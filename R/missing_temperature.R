missing_temperature <- function(data){
  # back fill missing temperature values
  
  # if temp == 0 make it an NA
  is.na(data$temp) <- data$temp == 0
  
  # replace NA with last non-NA observation carried forward - not sure we need both of these lines
  data$temp <- na.locf(data$temp, na.rm = F) 
  data$temp <- na.locf(data$temp, na.rm = F, fromLast = T)
  data
}
