degree_days <- function(data){
  data <- data %>% 
    group_by(particle.id) %>% 
    mutate(degree.days = cumsum(replace_na(temp, 0))) %>%
    ungroup()
  
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
    # convert to sd for generating normal dist.
    gmc.sd.days <- gmc.se.days*sqrt(gmc.n) 
    
    # mean degree days
    gmc.dd.mean <- gmc.mean.days*temp
    # sd of degree days
    gmc.dd.sd <- gmc.sd.days*temp 
    # normal distribution to sample dd cutoff from for each particles
    gmc.dd.dist <- rnorm(n = 10000, mean = gmc.dd.mean, sd = gmc.dd.sd) 
    
    data <- data %>%
      group_by(particle.id) %>%
      mutate(dd.cutoff = sample(gmc.dd.dist, 1)) %>%
      mutate(stage = if_else(degree.days > dd.cutoff, "megalopa", "larvae")) %>% # eligible to settle, not actually settled
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
    
    data <- data %>%
      group_by(particle.id) %>%
      mutate(dd.cutoff = sample(bsc.dd.dist, 1)) %>%
      mutate(stage = if_else(degree.days > dd.cutoff, "megalopa", "larvae")) %>%
      ungroup()
  } else if (species == "spanner"){
    # spanner taken form Minagawa 1990 doi:10.2331/suisan.56.755
    # means not given so will have to use a hard cut-off
    if (Sys.info()[6] != "Dan"){
      spanner.days <- 41.3
    } else {
      spanner.days <- 21.4
    }
    
    temp <- 25
    data$dd.cutoff <- spanner.days*temp
    
    data <- data %>%
      group_by(particle.id) %>%
      mutate(stage = if_else(degree.days > dd.cutoff, "megalopa", "larvae"))
  }
}
