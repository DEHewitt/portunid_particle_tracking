library(tidyverse)
library(lubridate)
library(tidync)
library(ncdf4)
library(zoo)

if (Sys.info()[6] == "Dan"){
  species <- "gmc"
  direction <- "forwards"
  file.path <- "C:/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking/Data/output_testing"
  files <- list.files(file.path, pattern = ".nc")
} else {
  # import variables from .pbs
  species <- Sys.getenv("species")
  direction <- Sys.getenv("direction")
  
  # point to the portunid_tracking directory
  file.path <- "../../srv/scratch/z5278054/portunid_particle_tracking"
  
  # list all the files in the relevant directory
  files <- list.files(paste(file.path, species, direction, sep = "/"), pattern = ".nc")
}

# empty dfs to store results of each iteration
# master file that will include everything
# particles.master <- data.frame()
# subset of master include only final (i.e. settled) positions of particles
particles.final <- data.frame()

for (i in 1:length(files)) {
  # load the data
  if (Sys.info()[6] == "Dan"){
    particles <- hyper_tibble(paste(file.path, files[i], sep = "/"))
    particles.info <- nc_open(paste(file.path, files[i], sep = "/"))
  } else {
    particles <- hyper_tibble(paste(file.path, species, direction, files[i], sep = "/"))
    particles.info <- nc_open(paste(file.path, species, direction, files[i], sep = "/"))
  }
  
  # extract the time.origin
  time.origin <- ymd(str_sub(particles.info$var$time$units, 15, 24))
  
  # convert time to a readable format (i.e. not in seconds since...)
  particles <- particles %>%
    mutate(date = time.origin + duration(time, units = "seconds"))
  
  # remove columns that are unused
  particles <- particles %>% 
    select(-trajectory, -time, -z, -age, -depth_m)
  
  # back fill missing temperature values
  is.na(particles$temp) <- particles$temp == 0 # change 0 to NA
  particles$temp <- na.locf(particles$temp, na.rm=FALSE) # replace NA with last non-NA observation carried forward
  particles$temp <- na.locf(particles$temp, na.rm=FALSE, fromLast = TRUE)
  
  # calculate degree-days for each particle
  particles <- particles %>% 
    group_by(traj) %>% 
    mutate(degree.days = cumsum(temp)) %>%
    ungroup() %>%
    # remove temp now that it isn't being used
    select(-temp) 
  
  # assign release location (lat & lon) and date
  particles <- particles %>%
    mutate(rel_lat = if_else(obs == 1, lat, NA_real_)) %>%
    mutate(rel_lon = if_else(obs == 1, lon, NA_real_)) %>%
    mutate(rel_date = if_else(obs == 1, date, as.POSIXct(NA_Date_))) %>%
    mutate(rel_date = as.character(rel_date))
  particles$rel_lat <- na.locf(particles$rel_lat, na.rm = F) 
  particles$rel_lon <- na.locf(particles$rel_lon, na.rm = F)
  particles$rel_date <- na.locf(particles$rel_date, na.rm = F)
  
  # remove any particles spawned after the spawning season ended
  if (species == "gmc" & direction == "forwards" | species == "bsc" & direction == "forwards"){
    particles <- particles %>%
      filter(month(rel_date) != "5")
  } else if (species == "spanner" & direction == "forwards") {
    particles <- particles %>%
      filter(month(rel_date) != "2") %>% 
      filter(month(rel_date) != "3")
  }
  # what to do about backwards dates?
  
  # apply degree-days filter
  if (species == "gmc"){
    # gmc  from Nurdiani & Zeng (2007), doi:10.1111/j.1365-2109.2007.01810.x
    # intial number of larvae in experiment
    gmc.init <- 75 
    # cumulative survival to megalopa
    gmc.survival <- 0.547 
    # final number of larvae (which I assume mean/se is based on)
    gmc.n <- round(gmc.init*gmc.survival)
    # experimental temp
    temp <- 25 
    # mean number of days taken to reach settlement stage
    gmc.mean.days <- 21.4
    # standard error of mean
    gmc.se.days <- 0.2
    # convert to sd for sgenerating normal dist.
    gmc.sd.days <- gmc.se.days*sqrt(gmc.n) 
    
    # mean degree days
    gmc.dd.mean <- gmc.mean.days*temp
    # sd of degree days
    gmc.dd.sd <- gmc.sd.days*temp 
    # normal distribution to sample dd cutoff from for each particles
    gmc.dd.dist <- rnorm(n = 10000, mean = gmc.dd.mean, sd = gmc.dd.sd) 
    
    particles <- particles %>%
      group_by(traj) %>%
      mutate(dd.cutoff = sample(gmc.dd.dist, 1)) %>%
      mutate(settlement = if_else(degree.days > dd.cutoff & bathy < 200, "settled", "not settled")) %>%
      ungroup()
  } else if (species == "bsc"){
    # bsc from Bryars & Havenhand (2006), doi:10.1016/j.jembe.2005.09.004
    # intial number of larvae in experiment
    bsc.init <- 60 
    # cumulative survival to megalopa
    bsc.survival <- 0.517 
    # final number of larvae (which I assume mean/se is based on)
    bsc.n <- round(bsc.init*bsc.survival) 
    # experimental temp
    temp <- 25 
    # mean number of days taken to reach settlement stage
    bsc.mean.days <- 15.3 
    # 95% CI of mean
    bsc.95ci.days <- 0.7
    # se
    bsc.se.days <- bsc.95ci.days/1.96
    # sd
    bsc.sd.days <- bsc.se.days*sqrt(bsc.n) # convert to sd for generating normal dist.
    
    # mean degree days
    bsc.dd.mean <- bsc.mean.days*temp 
    # sd of degree days
    bsc.dd.sd <- bsc.sd.days*temp 
    # normal distribution
    bsc.dd.dist <- rnorm(n = 10000, mean = bsc.dd.mean, sd = bsc.dd.sd) 
    
    particles <- particles %>%
      group_by(traj) %>%
      mutate(dd.cutoff = sample(bsc.dd.dist, 1)) %>%
      mutate(settlement = if_else(degree.days > dd.cutoff & bathy < 200, "settled", "not settled")) %>%
      ungroup()
  } else if (species == "spanner"){
    # spanner taken form Minagawa 1990 doi:10.2331/suisan.56.755
    # means not given so will have to use a hard cut-off
    spanner.days <- 41.3
    temp <- 25
    particles$dd.cutoff <- spanner.days*temp
    
    particles <- particles %>%
      mutate(settlement = if_else(degree.days > dd.cutoff, "settled", "not settled"))
  }
  
  # apply mortality
  if (direction == "forwards"){
    # label all particles as alive
    particles$status <- "alive" 
    if (species == "gmc"){
      # cumulative mortality
      # 1 minus survival rate after 21.4 days (mean)
      gmc.cum.mortality <- 1-gmc.survival  
      # instantaneous mortality
      m <- 1-exp((1/gmc.mean.days)*log(1-gmc.cum.mortality)) 
    } else if (species == "bsc") {
      # bsc from Bryars & Havenhand (2006), doi:10.1016/j.jembe.2005.09.004
      bsc.cum.mortality <- 1-bsc.survival
      m <- 1-exp((1/bsc.mean.days)*log(1-bsc.cum.mortality)) # instantaneous mortality
    } else if (species == "spanner"){
      # spanner taken form Minagawa 1990 doi:10.2331/suisan.56.755
      spanner.survival <- 0.31
      spanner.cum.mortality <- 1-spanner.survival
      m <- 1-exp((1/spanner.days)*log(1-spanner.cum.mortality)) # instantaneous mortality
    }
    
    # convert to actual daily mortality
    if (Sys.info()[6] == "Dan"){
      # just so testing on small datasets works
      z <- 0.2
    } else {
      # actul daily mortality
      z <- 1-exp(-m)
    }
    
    # minimum number of days before a particle could settle (based on degree days)
    min.settle <- round(min(particles$dd.cutoff)/temp)
    # data from before particles begin to settle
    particles.before <- particles %>% filter(obs < min.settle)
    # data from after particles begin to settle
    particles.after <- particles %>% filter(obs > min.settle-1)
    
    # daily cohorts
    cohorts <- unique(particles.after$rel_date)
    
    for (j in cohorts) {
      cohort <- particles %>% filter(rel_date == j)
      for (i in min.settle:max(cohort$obs)) {
        # which particles are alive and haven't settled (i.e. reach their DD)
        alive.particles <- cohort %>% filter(obs == i & status == "alive" & settlement == "not settled")
        particle.list <- as.data.frame(unique(alive.particles$traj))
        # select the particles to die
        die <- sample_frac(particle.list, size = z)
        # label particles as dead
        particles.after$status[particles.after$obs >= i & particles.after$traj %in% die$`unique(alive.particles$traj)`] <- "dead" 
      }
    }
    
    # join the .before and .after dfs back together
    particles <- bind_rows(particles.before, particles.after)
    
    # assign particles spatially (i.e. to estuaries, mgmt zones, etc.,)
    if (species == "gmc"){
      particles <- particles %>%
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
      particles <- particles %>%
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
      particles <- particles %>%
        mutate(state = case_when(lat > -28.16427 ~ "QLD",
                                 lat < -28.16427 ~ "NSW")) %>%
        mutate(region = if_else(lat < -23 & lat > -24, 2,
                                if_else(lat < -24 & lat > -25, 3,
                                        if_else(lat < -25 & lat > -26.5, 4,
                                                if_else(lat < -26.5 & lat > -27.5, 5,
                                                        if_else(lat < -27.5 & lat > -28.1643, 6,
                                                                if_else(lat < -28.1643 & lat > -29.428612, 7, 9999)))))))
    }
  }
  particles.final <- bind_rows(particles.final, particles)
}
    
# create a df of final points for each particle
if (direction == "forwards"){
  if (species == "gmc" | species == "bsc"){
    particles.settled <- particles.final %>% 
      group_by(traj) %>% 
      # only select settled, living particles that made it within range of an estuary
      filter(settlement == "settled" & status == "alive" & estuary != is.na(estuary)) %>% 
      filter(obs == min(obs)) %>% # only want the first day
      ungroup()
  } else if (species == "spanner"){
    particles.settled <- particles.final %>% 
      group_by(traj) %>% 
      filter(settlement == "settled" & status == "alive" & region != is.na(region)) %>%
      filter(obs == min(obs)) %>% 
      ungroup()
  }
} else if (direction == "backwards"){
  # backwards particles
  if (species == "gmc" | species == "bsc"){
    particles.settled <- particles.final %>% 
      group_by(traj) %>% 
      filter(settlement == "settled" & status == "alive") %>%
      filter(obs == min(obs)) %>% 
      ungroup()
  } else if (species == "spanner"){
    particles.settled <- particles.final %>% 
      group_by(traj) %>% 
      filter(settlement == "settled" & status == "alive" & region != is.na(region)) %>%
      filter(obs == min(obs)) %>% 
      ungroup()
  }
}

# save the output
saveRDS(particles.final, file = paste(file.path, species, direction, "processed", paste(species, direction, "final_points.rds", sep = "_"), sep = "/"))
saveRDS(particles.settled, file = paste(file.path, species, direction, "processed", paste(species, direction, "settled.rds", sep = "_"), sep = "/"))