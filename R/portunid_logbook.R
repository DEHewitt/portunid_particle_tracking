portunid_logbook <- function(species){
  # open/bind the logbook files
  
  path <- paste("C:/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking/Data/", species, "_logbook", sep = "")
  
  files <- list.files(path = path, pattern = ".csv")
  
  logbook <- data.frame()
  
  for (i in 1:length(files)){
    temp <- read_csv(paste(path, files[i], sep = "/"))
    
    temp$`Event date Month` <- as.double(temp$`Event date Month`)
    
    logbook <- bind_rows(temp, logbook)
  }
  logbook
}
