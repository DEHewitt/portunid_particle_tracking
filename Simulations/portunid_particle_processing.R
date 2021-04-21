library(tidyverse)
library(lubridate)
library(tidync)
library(ncdf4)
library(zoo)

# import variables from .pbs
species <- Sys.getenv("species")
direction <- Sys.getenv("direction")

# point to the portunid_tracking directory
file.path <- "../../srv/scratch/z5278054/portunid_particle_tracking"

# empty dfs to store results of each iteration
# master file that will include everything
#particles.master <- data.frame()
# subset of master include only final (i.e. settled) positions of particles
particles.final <- data.frame()
#files <- "text"
# list all the files in the relevant directory
files <- list.files(paste(file.path, species, direction, sep = "/"), pattern = ".nc")
for (i in 1:length(files)) {
  # load the data
  particles <- hyper_tibble(paste(file.path, species, direction, files[i], sep = "/"))
  particles.info <- nc_open(paste(file.path, species, direction, files[i], sep = "/"))
  
  #particles <- hyper_tibble('C:/Users/Dan/Documents/PhD/Dispersal/temp/gmc_2013_3_forwards.nc')
  #particles.info <- nc_open('C:/Users/Dan/Documents/PhD/Dispersal/temp/gmc_2013_3_forwards.nc')
  
  # extract the time.origin
  time.origin <- ymd(str_sub(particles.info$var$time$units, 15, 24))
  
  # convert time to a readable format (i.e. not in seconds since...)
  particles <- particles %>%
    mutate(date = time.origin + duration(time, units = "seconds"))
  
  particles <- particles %>% # remove columns that are unused
    select(-trajectory, -time, -z, -age, -depth_m)
  
  # back fill missing temperature values
  is.na(particles$temp) <- particles$temp == 0 # change 0 to NA
  particles$temp <- na.locf(particles$temp, na.rm=FALSE) # replace NA with last non-NA observation carried forward
  particles$temp <- na.locf(particles$temp, na.rm=FALSE, fromLast = TRUE)
  
  # calculate temperature values
  particles <- particles %>% 
    group_by(traj) %>% 
    mutate(degree.days = cumsum(temp)) %>%
    ungroup() %>%
    select(-temp) # remove temp now that it isn't being used
  
  # assign release location (lat & lon) and date
  particles <- particles %>%
    mutate(rel_lat = if_else(obs == 1, lat, NA_real_)) %>%
    mutate(rel_lon = if_else(obs == 1, lon, NA_real_)) %>%
    mutate(rel_date = if_else(obs == 1, date, as.POSIXct(NA_Date_))) %>%
    mutate(rel_date = as.character(rel_date))
  particles$rel_lat <- na.locf(particles$rel_lat, na.rm = F) 
  particles$rel_lon <- na.locf(particles$rel_lon, na.rm = F)
  particles$rel_date <- na.locf(particles$rel_date, na.rm = F)
  
  # remove any particles spawned after the spawning season ended (after April 30th)
  particles <- particles %>%
    filter(month(rel_date) != "5")
  
  # apply degree-days filter
  if (species == "gmc"){
    # gmc  from Nurdiani & Zeng (2007), doi:10.1111/j.1365-2109.2007.01810.x
    gmc.init <- 75 # intial number of larvae in experiment
    gmc.survival <- 0.547 # cumulative survival to megalopa
    gmc.n <- round(gmc.init*gmc.survival) # final number of larvae (which I assume mean/se is based on)
    temp <- 25 # experimental temp
    gmc.mean.days <- 21.4 # mean number of days taken to reach settlement stage
    gmc.se.days <- 0.2 # standard error of mean
    gmc.sd.days <- gmc.se.days*sqrt(gmc.n) # convert to sd for sgenerating normal dist.
    
    gmc.dd.mean <- gmc.mean.days*temp # mean degree days
    gmc.dd.sd <- gmc.sd.days*temp # sd of degree days
    gmc.dd.dist <- rnorm(n = 10000, mean = gmc.dd.mean, sd = gmc.dd.sd) # normal distribution
    
    particles <- particles %>%
      group_by(traj) %>%
      mutate(dd.cutoff = sample(gmc.dd.dist, 1)) %>%
      mutate(settlement = if_else(degree.days > dd.cutoff & bathy < 200, "settled", "not settled")) %>%
      ungroup()
  } else {
    # bsc from Bryars & Havenhand (2006), doi:10.1016/j.jembe.2005.09.004
    bsc.init <- 60 # intial number of larvae in experiment
    bsc.survival <- 0.517 # cumulative survival to megalopa
    bsc.n <- round(bsc.init*bsc.survival) # final number of larvae (which I assume mean/se is based on)
    #bsc.temp <- 25 # experimental temp
    bsc.mean.days <- 15.3 # mean number of days taken to reach settlement stage
    bsc.95ci.days <- 0.7 # 95% CI of mean
    bsc.se.days <- bsc.95ci.days/1.96
    bsc.sd.days <- bsc.se.days*sqrt(bsc.n) # convert to sd for generating normal dist.
    
    bsc.dd.mean <- bsc.mean.days*temp # mean degree days
    bsc.dd.sd <- bsc.sd.days*temp # sd of degree days
    bsc.dd.dist <- rnorm(n = 10000, mean = bsc.dd.mean, sd = bsc.dd.sd) # normal distribution
    
    particles <- particles %>%
      group_by(traj) %>%
      mutate(dd.cutoff = sample(bsc.dd.dist, 1)) %>%
      mutate(settlement = if_else(degree.days > dd.cutoff & bathy < 200, "settled", "not settled")) %>%
      ungroup()
  }
  
  # apply mortality
  if (direction == "forwards"){
    particles$status <- "alive" # label all particles as alive
    if (species == "gmc"){
      # gmc taken from Nurdiani & Zeng (2007), doi:10.1111/j.1365-2109.2007.01810.x
      gmc.cum.mortality <- 1-gmc.survival # 1 minus survival rate after 21.4 days (mean) 
      m <- 1-exp((1/gmc.mean.days)*log(1-gmc.cum.mortality)) # instantaneous mortality
    } else {
      bsc.cum.mortality <- 1-bsc.survival
      m <- 1-exp((1/bsc.mean.days)*log(1-bsc.cum.mortality)) # instantaneous mortality
    }
    
    z <- 1-exp(-m) # daily actual mortality
    
    min.settle <- round(min(particles$dd.cutoff)/temp) # minimum number of days before a particle could settle (based on degree days)
    particles.before <- particles %>% filter(obs < min.settle)
    particles.after <- particles %>% filter(obs > min.settle-1)
    
    cohorts <- unique(particles.after$rel_date)
    
    for (j in cohorts) {
      cohort <- particles %>% filter(rel_date == j)
      for (i in min.settle:max(cohort$obs)) {
        alive.particles <- cohort %>% filter(obs == i & status == "alive" & settlement == "not settled")
        particle.list <- as.data.frame(unique(alive.particles$traj))
        die <- sample_frac(particle.list, size = z)
        particles.after$status[particles.after$obs >= i & particles.after$traj %in% die$`unique(alive.particles$traj)`] <- "dead" # label particles as dead
      }
    }
    
    # join the .before and .after dfs back together
    particles <- bind_rows(particles.before, particles.after)
    if (species == "gmc"){
      particles <- particles %>%
        mutate(estuary = case_when(lat < -18.041 & lat > -18.741 ~ "Hinchinbrook Island",
                                   lat < -23.350 & lat > -24.050 ~ "The Narrows",
                                   lat < -25.317 & lat > -26.017 ~ "Maryborough/Hervey Bay",
                                   lat < -26.839 & lat > -27.752 ~ "Moreton Bay",
                                   lat < -27.752 & lat > -28.8275 ~ "Tweed River",
                                   lat < -28.8275 & lat > -29.161 ~ "Richmond River",
                                   lat < -29.161 & lat > -29.632 ~ "Clarence River",
                                   lat < -30.364 & lat > -31.2545 ~ "Macleay River",
                                   lat < -31.2545 & lat > -31.772 ~ "Camden Haven",
                                   lat < -31.772 & lat > -32.046 ~ "Manning River",
                                   lat < -32.046 & lat > -32.456 ~ "Wallis Lake",
                                   lat < -32.456 & lat > -32.818 ~ "Port Stephens",
                                   lat < -32.818 & lat > -33.2475 ~ "Hunter River",
                                   lat < -34.06185 & lat > -34.7457 ~ "Hawkesbury River")) %>%
        mutate(state = case_when(lat > -28.16427 ~ "QLD",
                                 lat < -28.16427 ~ "NSW")) #%>%
        #mutate(mgmt.zone = case_when())
    } else {
      particles <- particles %>%
        mutate(estuary = case_when(#lat < -18.041 & lat > -18.741 ~ "Hinchinbrook Island",
          #lat < -23.350 & lat > -24.050 ~ "The Narrows",
          lat < -25.317 & lat > -26.017 ~ "Maryborough/Hervey Bay",
          lat < -26.839 & lat > -27.752 ~ "Moreton Bay",
          #lat < -27.752 & lat > -28.8275 ~ "Tweed River",
          #lat < -28.8275 & lat > -29.161 ~ "Richmond River",
          #lat < -29.161 & lat > -29.632 ~ "Clarence River",
          #lat < -30.364 & lat > -31.2545 ~ "Macleay River",
          #lat < -31.2545 & lat > -31.772 ~ "Camden Haven",
          #lat < -31.772 & lat > -32.046 ~ "Manning River",
          lat < -32.046 & lat > -32.456 ~ "Wallis Lake",
          lat < -32.456 & lat > -32.818 ~ "Port Stephens",
          lat < -32.818 & lat > -33.2475 ~ "Hunter River",
          lat < -34.06185 & lat > -34.7457 ~ "Hawkesbury River",
          lat < -34.06185 & lat > -34.7457 ~ "Lake Illawarra")) %>%
        mutate(estuary = if_else(is.na(estuary), "ocean", estuary)) %>%
        mutate(state = case_when(lat > -28.16427 ~ "QLD",
                                 lat < -28.16427 ~ "NSW")) #%>%
        #mutate(mgmt.zone = case_when()) # blue swimmer crab will need this if we want to relate dispersal to coastal catch
    }
    #particles.master <- bind_rows(particles.master, particles) # this was taking up too much memory
    # creat a df of final points for each particle
    if (species == "gmc"){
      particles.settled <- particles %>% 
        group_by(traj) %>% 
        filter(settlement == "settled" & status == "alive" & estuary != is.na(estuary)) %>% # only select settled, living particles that made it within range of an estuary
        filter(obs == min(obs)) %>% # only want the first day
        ungroup()
      particles.final <- bind_rows(particles.final, particles.settled)
    } else {
      particles.settled <- particles %>% 
        group_by(traj) %>% 
        filter(settlement == "settled" & status == "alive") %>%
        filter(obs == min(obs)) %>% 
        ungroup()
      particles.final <- bind_rows(particles.final, particles.settled)
    }
  } else {
    # backwards particles
    #particles.master <- bind_rows(particles.master, particles) this was taking up too much memory
    
    # creat a df of final points for each particle
    particles.settled <- particles %>% 
      group_by(traj) %>% 
      filter(settlement == "settled") %>%
      filter(obs == min(obs)) %>% 
      ungroup()
    particles.final <- bind_rows(particles.final, particles.settled)
  }
}

#saveRDS(particles.master, file = paste(file.path, species, direction, "processed", paste(species, direction, "master.rds", sep = "_"), sep = "/"))
saveRDS(particles.final, file = paste(file.path, species, direction, "processed", paste(species, direction, "final_points.rds", sep = "_"), sep = "/"))