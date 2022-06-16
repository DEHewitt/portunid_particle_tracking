# import the libraries
library(tidyverse)
library(lubridate)
library(ggplot2)
library(janitor)
library(jpeg)
library(grid)
library(patchwork)
library(rnaturalearth)
library(psych)
library(ggridges)
library(lemon)
library(fy)

# import functions
source("R/load_data.R")
source("R/import_silhouette.R")
source("R/portunid_logbook.R")
source("R/reformat.R")
source("R/plot_distance.R")
source("R/plot_pld.R")
#source("R/connectivity_matrix.R")
source("R/plot_sources.R")
source("R/summary_plot.R")
source("R/summarise_logbook.R")
source("R/summarise_settlement.R")
source("R/plot_cpue.R")
source("R/plot_landings.R")
source("R/settlement_corr.R")
source("R/histogram.R")
source("R/ridgeline_plot.R")

# import silhouettes for plotting
#gmc.grob <- import_silhouette(species = "gmc")
#bsc.grob <- import_silhouette(species = "bsc")

species <- c("gmc", "bsc")
direction <- c("forwards", "backwards")

for (i in 1:length(species)){
  for (j in 1:length(direction)){
    
    # load the data
    particles <- load_data(species = species[i], direction = direction[j], type = "settled") 
    
    # reformat the data
    particles <- particles %>% reformat(species = species[i], direction = direction[j]) 
    
    # round release latitude for plotting purposes
    if (direction[j] == "forwards"){
      particles <- particles %>% mutate(rel_lat_round = round(rel_lat))
      
      # remove particles released too far north
      #particles <- particles %>% filter(rel_lat_round < -18)
      
      # latitudinal distance of particles
      particles <- particles %>% mutate(lat.distance = (lat-rel_lat)*111)
      
      # estuary contribution summary
      estuary.summary <- particles %>%
        group_by(estuary, season) %>%
        mutate(northern.contribution = length(which(rel_lat > lat)),
               southern.contribution = length(which(rel_lat < lat)),
               north.cont.perc = northern.contribution/n()*100,
               south.cont.perc = southern.contribution/n()*100) %>%
        ungroup() %>%
        group_by(estuary) %>%
        arrange(desc(lat)) %>%
        summarise(northern.contribution = mean(northern.contribution),
                  southern.contribution = mean(southern.contribution),
                  mean.north.perc = mean(north.cont.perc),
                  mean.south.perc = mean(south.cont.perc),
                  sd.north.perc = sd(north.cont.perc),
                  sd.south.perc = sd(south.cont.perc)) %>%
        select(estuary, northern.contribution, southern.contribution, mean.north.perc, sd.north.perc, mean.south.perc, sd.south.perc)
      
      write_csv(estuary.summary, paste0("output/", species[i], "_direction_contribution_summary_total.csv"))
      
      # state contribution summary
      state_border <- -28.16
      
      state.summary <- particles %>%
        group_by(estuary, season) %>%
        mutate(qld.contribution = length(which(rel_lat > state_border)),
               nsw.contribution = length(which(rel_lat < state_border)),
               qld.cont.perc = qld.contribution/n()*100,
               nsw.cont.perc = nsw.contribution/n()*100) %>%
        ungroup() %>%
        group_by(estuary) %>%
        arrange(desc(lat)) %>%
        summarise(qld.contribution = mean(qld.contribution),
                  nsw.contribution = mean(nsw.contribution),
                  mean.qld.perc = mean(qld.cont.perc),
                  mean.nsw.perc = mean(nsw.cont.perc),
                  sd.qld.perc = sd(qld.cont.perc),
                  sd.nsw.perc = sd(nsw.cont.perc)) %>%
        select(estuary, qld.contribution, nsw.contribution, mean.qld.perc, sd.qld.perc, mean.nsw.perc, sd.nsw.perc)
      
      write_csv(state.summary, paste0("output/", species[i], "_state_contribution_summary_total.csv"))
      
      # estuary contribution summary
      #estuary.summary <- particles %>%
       # group_by(estuary, year) %>%
        #mutate(northern.contribution = length(which(rel_lat > lat)),
         #      southern.contribution = length(which(rel_lat < lat)),
          #     north.cont.perc = northern.contribution/n()*100,
           #    south.cont.perc = southern.contribution/n()*100) %>%
        #ungroup() %>%
        #distinct(estuary, year, .keep_all = TRUE) %>%
        #arrange(desc(lat)) %>%
        #select(estuary, year, northern.contribution, southern.contribution, north.cont.perc, south.cont.perc)
      
      #write_csv(estuary.summary, paste0("output/", species[i], "_direction_contribution_summary_year.csv"))
      
      # state contribution summary
      #state_border <- -28.16
      
      #state.summary <- particles %>%
       # group_by(estuary, year) %>%
        #mutate(qld.contribution = length(which(rel_lat > state_border)),
         #      nsw.contribution = length(which(rel_lat < state_border)),
          #     qld.cont.perc = qld.contribution/n()*100,
           #    nsw.cont.perc = nsw.contribution/n()*100) %>%
        #ungroup() %>%
        #distinct(estuary, year, .keep_all = TRUE) %>%
        #arrange(desc(lat)) %>%
        #select(estuary, year, qld.contribution, nsw.contribution, qld.cont.perc, nsw.cont.perc)
      
      #write_csv(state.summary, paste0("output/", species[i], "_state_contribution_summary_year.csv"))
      
      # plot combo histogram of larval duration, dispersal distance and latitudinal dispersal
      histogram(data = particles)
      
      # save the plot
      ggsave(paste0("figures/", species[i], "_", direction[j], "_histogram.png"), device = "png", width = 29, height = 20, units = "cm", dpi = 600)
    
      # load the logbook data
      logbook <- portunid_logbook(species = species[i])
      
      group <- c("estuary", "egf")
      
      for (x in 1:length(group)){
        if (group[x] == "estuary"){
          # tidy up and summarise the logbook
          logbook.est <- logbook %>% summarise_logbook(particles = particles, species = species[i], group = group[x], timespan = "year", seasonal = TRUE)
          
          # tidy up and summarise the settlement
          settlement <- particles %>% summarise_settlement(logbook = logbook.est, group = group[x], timespan = "year")
          
          # join the two
          settlement <- settlement %>% left_join(logbook.est)
          
          # lag the settlement estimates
          settlement <- settlement %>%
            group_by(estuary) %>%
            mutate(settlement.1 = lag(settlement, n = 1, order_by = year)) %>%
            mutate(settlement.2 = lag(settlement, n = 2, order_by = year)) %>%
            mutate(settlement.3 = lag(settlement, n = 3, order_by = year)) %>%
            ungroup()
          
          if (species[i] == "gmc"){
            settlement <- settlement %>%
              mutate(estuary.1 = factor(estuary,
                                        levels = c("Tweed River",
                                                   "Richmond River",
                                                   "Clarence River",
                                                   "Macleay River",
                                                   "Camden Haven",
                                                   "Manning River",
                                                   "Wallis Lake",
                                                   "Port Stephens",
                                                   "Hunter River",
                                                   "Hawkesbury River")))
          } else if (species[i] == "bsc"){
            settlement <- settlement %>%
              mutate(estuary.1 = factor(estuary,
                                        levels = c("Wallis Lake",
                                                   "Port Stephens",
                                                   "Hunter River",
                                                   "Lake Illawarra")))
          }
          
          # what's the relationship to cpue?
          cpue_corr <- settlement %>% settlement_corr("cpue", group = group[x])
          
          file <- paste0("output/", species[i], "_", group[x], "_cpue_corr.csv")
          
          write_csv(cpue_corr, file = file)
          
          landings_corr <- settlement %>% settlement_corr("landings", group = group[x])
          
          file <- paste0("output/", species[i], "_", group[x], "_landings_corr.csv")
          
          write_csv(landings_corr, file = file)
          
          lag <- c(0, 1, 2, 3)
          
          for (b in 1:length(lag)) {
            # plot it and have a look
            p <- plot_cpue(data = settlement, species = species[i], lag = lag[b], group = group[x])
            
            ggsave(paste0("figures/", species[i], "_", group[x], "_cpue_lag_", lag[b],".png"), device = "png", width = 17, height = 13, units = "cm", dpi = 600)
            
            #p <- plot_landings(data = settlement, species = species[i], lag = lag[b], group = group[x])
            
            #ggsave(paste0("figures/", species[i], "_", group[x], "_landings_lag_", lag[b],".png"), device = "png", width = 17, height = 13, units = "cm", dpi = 600)
          }
          
        } else if (group[x] == "egf"){
          # tidy up and summarise the logbook
          logbook.egf <- logbook %>% summarise_logbook(particles = particles, species = species[i], group = group[x], seasonal = TRUE)
          
          # tidy up and summarise the settlement
          settlement <- particles %>% summarise_settlement(logbook = logbook.egf, group = group[x])
          
          # join the two
          settlement <- settlement %>% left_join(logbook.egf)
          
          # lag the settlement estimates
          settlement <- settlement %>%
            group_by(mgmt.zone) %>%
            mutate(settlement.1 = lag(settlement, n = 1, order_by = year)) %>%
            mutate(settlement.2 = lag(settlement, n = 2, order_by = year)) %>%
            mutate(settlement.3 = lag(settlement, n = 3, order_by = year)) %>%
            ungroup()
          
          # what's the relationship to cpue?
          cpue_corr <- settlement %>% settlement_corr("cpue", group = group[x])
          
          file <- paste0("output/", species[i], "_", group[x], "_cpue_corr.csv")
          
          write_csv(cpue_corr, file = file)
          
          landings_corr <- settlement %>% settlement_corr("landings", group = group[x])
          
          file <- paste0("output/", species[i], "_", group[x], "_landings_corr.csv")
          
          write_csv(landings_corr, file = file)
          
          lag <- c(0, 1, 2, 3)
          for (b in 1:length(lag)) {
            # plot it and have a look
            p <- plot_cpue(data = settlement, species = species[i], lag = lag[b], group = group[x])
            
            ggsave(paste0("figures/", species[i], "_", group[x], "_cpue_lag_", lag[b],".png"), device = "png", width = 17, height = 13, units = "cm", dpi = 600)
            
            #p <- plot_landings(data = settlement, species = species[i], lag = lag[b], group = group[x])
            
            #ggsave(paste0("figures/", species[i], "_", group[x], "_landings_lag_", lag[b],".png"), device = "png", width = 17, height = 13, units = "cm", dpi = 600)
          }
        }
      }

      # summary table 
      sum <- particles %>%
        group_by(eac.zone, shelf.zone) %>%
        summarise(mean_dist = mean(distance),
                  sd_dist = sd(distance),
                  median_dist = median(distance),
                  mean_obs = mean(obs),
                  sd_obs = sd(obs),
                  median_obs = median(obs),
                  mean_latdist = mean(lat.distance),
                  sd_latdist = sd(lat.distance),
                  median_latdist = median(lat.distance)) %>%
        ungroup()
      
      file <- paste0("output/", species[i], "_summary.csv")
      
      if (file.exists(file)){
        file.remove(file)
      }
      
      write_csv(sum, file = file)
    
    }
    # connectivity matrix - relating spawning (release) latitude to settlement estuary
    #connectivity_matrix(data = particles, species = species[i], direction = direction[j], facet = FALSE)
    
    # save the plot
    #ggsave(paste0("figures/", species[i], "_", direction[j], "_con_mat.png"), device = "png", width = 29, height = 20, units = "cm", dpi = 600)
    
    # connectivity matrix - relating spawning (release) latitude to settlement estuary
    #connectivity_matrix(data = particles, species = species[i], direction = direction[j], facet = TRUE)
    
    # save the plot
    #ggsave(paste0("figures/", species[i], "_", direction[j], "facet_con_mat.png"), device = "png", width = 29, height = 20, units = "cm", dpi = 600)
    
    # ridegline plots
    ridgeline_plot(data = particles, facet = TRUE)
    
    # save the plot
    ggsave(paste0("figures/", species[i], "_", direction[j], "_facet_ridgeline.png"), device = "png", width = 29, height = 20, units = "cm", dpi = 600)
    
    ridgeline_plot(data = particles, facet = FALSE)
    
    # save the plot
    ggsave(paste0("figures/", species[i], "_", direction[j], "_ridgeline.png"), device = "png", width = 29, height = 20, units = "cm", dpi = 600)
    
  }
}

# summarised mortality
for (i in 1:length(species)){
  mortality <- readRDS(paste0("github/portunid_particle_tracking/Data/Output/", species[i], "_forwards_summarised_mortality.rds"))
  
  mortality <- mortality %>%
    clean_names() %>%
   # mutate(total = total/10) %>%
    mutate(mean_disp_perc = n_disp_mort/total*100,
           #sd_disp_perc = sd_disp_mort/total*100,
           n_nat_perc = n_nat_mort/total*100,
           #sd_nat_perc = sd_nat_mort/total*100,
           n_beached_perc = n_beached_mortality/total*100,
           #sd_beached_perc = sd_beached_mortality/total*100,
           n_settle_perc = n_settlement/total*100)#,
           #sd_settle_perc = sd_settlement/total*100)
  
  write_csv(mortality, paste0("output/", species[i], "_mortality.csv"))
}

