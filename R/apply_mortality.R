apply_mortality <- function(data){
  if (direction == "forwards"){
    # label all particles as alive
    data$status <- "alive" 
    if (species == "gmc"){
      # gmc survival
      gmc.survival <- 0.547 
      # length of experiment
      gmc.mean.days <- 21.4
      # cumulative mortality
      # 1 minus survival rate after 21.4 days (mean)
      gmc.cum.mortality <- 1-gmc.survival  
      # instantaneous mortality
      m <- 1-exp((1/gmc.mean.days)*log(1-gmc.cum.mortality)) 
    } else if (species == "bsc") {
      # bsc from Bryars & Havenhand (2006), doi:10.1016/j.jembe.2005.09.004
      bsc.survival <- 0.517
      bsc.cum.mortality <- 1-bsc.survival
      bsc.mean.days <- 15.3 
      m <- 1-exp((1/bsc.mean.days)*log(1-bsc.cum.mortality)) # instantaneous mortality
    } else if (species == "spanner"){
      # spanner taken form Minagawa 1990 doi:10.2331/suisan.56.755
      spanner.survival <- 0.31
      spanner.days <- 41.3
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
    x <- data %>% filter(degree.days > dd.cutoff)
    min.settle <- min(x$obs)
    # data from before particles begin to settle
    particles.before <- data %>% filter(obs < min.settle)
    # data from after particles begin to settle
    particles.after <- data %>% filter(obs > min.settle-1)
    
    # daily cohorts
    cohorts <- unique(particles.after$rel_date)
    
    for (j in cohorts) {
      cohort <- data %>% filter(rel_date == j) # for every release day (i.e., cohort)
      for (i in min.settle:max(data$obs)) { # for every day from the first settlemenet day until the last tracking day 
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
    data <- bind_rows(particles.before, particles.after)
  }
}
