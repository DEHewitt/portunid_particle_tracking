convert_time <- function(particles, particles.info) {
  
  # particles is the actual data
  # particles.info is the link to the netcdf
  
  # extract the time.origin
  time.origin <- ymd(str_sub(particles.info$var$time$units, 15, 24))
  
  # convert time to a readable format (i.e. not in seconds since...)
  particles <- particles %>%
    mutate(date = time.origin + duration(time, units = "seconds"))
}