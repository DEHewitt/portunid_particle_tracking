# import the libraries
library(tidyverse)
library(lubridate)
library(ggplot2)
#library(nnet)
library(janitor)
library(ecostats)
#library(scattermore)
library(jpeg)
library(grid)
library(patchwork)

# import functions
source("R/load_data.R")
source("R/import_silhouette.R")

# 1. connectivity matrices
# 2. multinomial logistic regression - predict settlement estuary based on release latitude (and year?)
# 3. relate distance, time to settlement to release latitude and year
# 4. relate cpue from egf regions and estuaries to predicted settlement
# 5. make some of those map plots

# import silhouettes for plotting
gmc.grob <- import_silhouette(species = "gmc")

# import data
particles <- load_data(species = "gmc", direction = "forwards", type = "settled")

# open/bind the logbook files
files <- list.files(path = "C:/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking/Data/gmc_logbook", pattern = ".csv")
path <- "C:/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking/Data/gmc_logbook"
logbook <- data.frame()
for (i in 1:length(files)){
  temp <- read_csv(paste(path, files[i], sep = "/"))
  temp$`Event date Month` <- as.double(temp$`Event date Month`)
  logbook <- bind_rows(temp, logbook)
}

#### reformat some of the columns ####
# make estuary a factor so plots can be prettier
particles <- particles %>%
  mutate(estuary = if_else(estuary == "Maryborough/Hervey Bay", "Maryborough", estuary)) %>%
  mutate(estuary = factor(estuary,
                          levels = c("Hinchinbrook Island", 
                                     "The Narrows", 
                                     "Maryborough", 
                                     "Moreton Bay",
                                     "Tweed River", 
                                     "Richmond River", 
                                     "Clarence River", 
                                     "Macleay River", 
                                     "Camden Haven", 
                                     "Manning River", 
                                     "Wallis Lake", 
                                     "Port Stephens", 
                                     "Hunter River", 
                                     "Hawkesbury River"))) %>%
  mutate(est.abbr = case_when(estuary == "Hinchinbrook Island" ~ "HBI", 
                              estuary == "The Narrows" ~ "NAR", 
                              estuary =="Maryborough" ~ "MRY",
                              estuary == "Moreton Bay" ~ "MB", 
                              estuary == "Tweed River" ~ "TWR", 
                              estuary == "Richmond River" ~ "RMR",
                              estuary == "Clarence River" ~ "CLR", 
                              estuary == "Macleay River" ~ "MLR", 
                              estuary == "Camden Haven" ~ "CHV",
                              estuary == "Manning River" ~ "MMR", 
                              estuary == "Wallis Lake" ~ "WLL", 
                              estuary == "Port Stephens" ~ "PST",
                              estuary == "Hunter River" ~ "HRR", 
                              estuary == "Hawkesbury River" ~ "HBR")) %>%
  mutate(est.lat = case_when(estuary == "Hinchinbrook Island" ~ -18.54, 
                             estuary == "The Narrows" ~ -23.85, 
                             estuary =="Maryborough" ~ -25.82,
                             estuary == "Moreton Bay" ~ -27.34, 
                             estuary == "Tweed River" ~ -28.17, 
                             estuary == "Richmond River" ~ -28.89,
                             estuary == "Clarence River" ~ -29.43, 
                             estuary == "Macleay River" ~ -30.86, 
                             estuary == "Camden Haven" ~ -31.65,
                             estuary == "Manning River" ~ -31.90, 
                             estuary == "Wallis Lake" ~ -32.19, 
                             estuary == "Port Stephens" ~ -32.72,
                             estuary == "Hunter River" ~ -32.92, 
                             estuary == "Hawkesbury River" ~ -33.59))

# reformat some date things
particles <- particles %>%
  # this is a hacky fix - if UWA share 2015 files this can be deleted
  mutate(season = paste(year(particles$rel_date), year(particles$rel_date)+1, sep = "-")) %>%
  # month of settltment
  mutate(month = month(date)) %>%
  mutate(month = if_else(month < 10, paste("0", month, sep = ""), as.character(month))) %>%
  # year of settlement
  mutate(year = year(date)) %>%
  # month and year of settlement
  mutate(month.year = paste(year, month, sep = "-"))

# round release latitude for plotting purposes
particles <- particles %>%
  mutate(rel_lat_round = round(rel_lat))

# straight-line distance of particles
particles <- particles %>%
  mutate(crow.distance = abs(lat-rel_lat)*111)

particles.sum <- particles %>%
  group_by(rel_lat_round, season) %>%
  summarise(mean_dist = mean(distance),
            sd_dist = sd(distance),
            mean_obs = mean(obs),
            sd_obs = sd(obs),
            mean_crow = mean(crow.distance),
            sd_crow = sd(crow.distance)) %>%
  ungroup()

# add est.label
particles <- particles %>%
  mutate(est.label = paste(estuary, " (", est.lat, ")", sep = "")) %>%
  mutate(est.label = factor(est.label,
                            levels = c("Hinchinbrook Island (-18.54)", 
                                       "The Narrows (-23.85)", 
                                       "Maryborough (-25.82)",
                                       "Moreton Bay (-27.34)", 
                                       "Tweed River (-28.17)", 
                                       "Richmond River (-28.89)",
                                       "Clarence River (-29.43)", 
                                       "Macleay River (-30.86)", 
                                       "Camden Haven (-31.65)",
                                       "Manning River (-31.9)", 
                                       "Wallis Lake (-32.19)", 
                                       "Port Stephens (-32.72)",
                                       "Hunter River (-32.92)", 
                                       "Hawkesbury River (-33.59)")))
########

#### dispersal of larvae ####
# how does dispersal distance vary by year and spawning lat?
gmc.dist.violin <- ggplot() +
  geom_violin(data = particles,
               aes(y = rel_lat_round,
                   x = distance,
                   group = rel_lat_round)) +
  facet_wrap(vars(season)) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        strip.background = element_blank(),
        strip.text = element_text(size = 10, colour = "black"),
        axis.text = element_text(colour = "black", size = 10),
        axis.title = element_text(colour = "black", size = 12)) +
  scale_x_continuous(breaks = seq(0, 4000, 1000),
                     labels = c(0, " ", 2000, " ", 4000)) +
  ylab("Release latitude (?S)") +
  xlab("Dispersal distance (km)") +
  inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)

gmc.dist.violin

ggsave("C:/Users/Dan/Documents/PhD/Dispersal/figures/gmc_dist_violin.png", 
       plot = gmc.dist.violin, 
       device = "png", 
       width = 17, # a4 dimensions
       height = 13, 
       units = "cm", 
       dpi = 600)

# now distance as the crow flies
gmc.crowdist.violin <- ggplot() +
  geom_violin(data = particles,
              aes(y = rel_lat_round,
                  x = crow.distance,
                  group = rel_lat_round)) +
  facet_wrap(vars(season)) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        strip.background = element_blank(),
        strip.text = element_text(size = 10, colour = "black"),
        axis.text = element_text(colour = "black", size = 10),
        axis.title = element_text(colour = "black", size = 12)) +
  #scale_x_continuous(breaks = seq(0, 4000, 1000),
   #                  labels = c(0, " ", 2000, " ", 4000)) +
  ylab("Release latitude (°S)") +
  xlab("Straight-line dispersal distance (km)") +
  inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)

gmc.crowdist.violin

ggsave("C:/Users/Dan/Documents/PhD/Dispersal/figures/gmc_crowdist_violin.png", 
       plot = gmc.crowdist.violin, 
       device = "png", 
       width = 17, # a4 dimensions
       height = 13, 
       units = "cm", 
       dpi = 600)

# how does settlement age (PLD) vary by year and spawning latitude?
gmc.obs.violin <- ggplot() +
  geom_violin(data = particles,
              aes(y = rel_lat_round,
                  x = obs,
                  group = rel_lat_round)) +
  facet_wrap(vars(season)) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        strip.background = element_blank(),
        strip.text = element_text(size = 10, colour = "black"),
        axis.text = element_text(colour = "black", size = 10),
        axis.title = element_text(colour = "black", size = 12)) +
 #scale_x_continuous(breaks = seq(0, 4000, 1000),
  #                   labels = c(0, " ", 2000, " ", 4000)) +
  ylab("Release latitude (°S)") +
  xlab("Settlement age (days)") +
  inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)

gmc.obs.violin

ggsave("C:/Users/Dan/Documents/PhD/Dispersal/figures/gmc_obs_violin.png", 
       plot = gmc.obs.violin, 
       device = "png", 
       width = 17, # a4 dimensions
       height = 13, 
       units = "cm", 
       dpi = 600)

#### plot connectivity matrices ####
# first relate spawning latitude to settlement estuary
con.mat.df <- particles %>%
  group_by(rel_lat, estuary, season) %>%
  summarise(count = n()) %>%
  ungroup() %>%
  mutate(total = sum(count),
         percent = count/total) %>%
  mutate(rel_lat_round = round(rel_lat)) %>%
  mutate(est.lat = case_when(estuary == "Hinchinbrook Island" ~ -18.54, 
                             estuary == "The Narrows" ~ -23.85, 
                             estuary =="Maryborough" ~ -25.82,
                             estuary == "Moreton Bay" ~ -27.34, 
                             estuary == "Tweed River" ~ -28.17, 
                             estuary == "Richmond River" ~ -28.89,
                             estuary == "Clarence River" ~ -29.43, 
                             estuary == "Macleay River" ~ -30.86, 
                             estuary == "Camden Haven" ~ -31.65,
                             estuary == "Manning River" ~ -31.90, 
                             estuary == "Wallis Lake" ~ -32.19, 
                             estuary == "Port Stephens" ~ -32.72,
                             estuary == "Hunter River" ~ -32.92, 
                             estuary == "Hawkesbury River" ~ -33.59)) %>%
  mutate(est.label = paste(estuary, " (", est.lat, ")", sep = "")) %>%
  mutate(est.label = factor(est.label,
                            levels = c("Hinchinbrook Island (-18.54)", 
                                       "The Narrows (-23.85)", 
                                       "Maryborough (-25.82)",
                                       "Moreton Bay (-27.34)", 
                                       "Tweed River (-28.17)", 
                                       "Richmond River (-28.89)",
                                       "Clarence River (-29.43)", 
                                       "Macleay River (-30.86)", 
                                       "Camden Haven (-31.65)",
                                       "Manning River (-31.9)", 
                                       "Wallis Lake (-32.19)", 
                                       "Port Stephens (-32.72)",
                                       "Hunter River (-32.92)", 
                                       "Hawkesbury River (-33.59)")))

# gmc connectivity of each estuary to each degree of latitude
gmc.con.mat <- ggplot() +
  geom_tile(data = con.mat.df,
            aes(x = rel_lat_round, 
                y = est.label,
                fill = count)) +
  scale_fill_viridis_c(trans = "log10") +
  theme_bw() +
  theme(panel.grid = element_blank(),
        #axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text = element_text(size = 10, colour = "black"),
        axis.title = element_text(size = 12, colour = "black"),
        strip.background = element_blank(),
        strip.text = element_text(size = 10, colour = "black"),
        legend.text = element_text(size = 10, colour = "black")) +
 # geom_point(data = con.mat.df,
  #           aes(x = rel_lat_round,
   #              y = est.lat),
    #         colour = "white",
     #        shape = 4) +
  #scale_x_continuous() +
  scale_y_discrete(limits = rev(levels(con.mat.df$est.label))) +
  scale_x_reverse(breaks = seq(-15, -33, -3)) +
  ylab("Settlement estuary") +
  xlab("Release latitude (°S)") +
  labs(fill = "Relative settlement") +
facet_wrap(vars(season)) +
  inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)

gmc.con.mat

ggsave("C:/Users/Dan/Documents/PhD/Dispersal/figures/gmc_con_mat_rel_lat_est.png", 
       plot = gmc.con.mat, 
       device = "png", 
       width = 29, # a4 dimensions
       height = 20, 
       units = "cm", 
       dpi = 600)

# now plot the relative settlements per estuary
gmc.est.settle <- ggplot() +
  geom_density(data = particles,
                 aes(x = rel_lat),
               bw = 0.5) +
  geom_vline(data = particles, aes(xintercept = est.lat), linetype = "dashed") +
  coord_flip() +
  facet_wrap(vars(estuary)) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        strip.background = element_blank(),
        strip.text = element_text(size = 10, colour = "black"),
        axis.text = element_text(colour = "black", size = 10),
        axis.title = element_text(colour = "black", size = 12)) +
  #scale_x_reverse() +
  xlab("Release latitude (°S)") +
  ylab("Relative larval settlement") +
  inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.20)

gmc.est.settle

ggsave("C:/Users/Dan/Documents/PhD/Dispersal/figures/gmc_est_settle.png", 
       plot = gmc.est.settle, 
       device = "png", 
       width = 17, # a4 dimensions
       height = 13, 
       units = "cm", 
       dpi = 600)

# now compare settlement at each estuary each year
settlement <- particles %>%
  group_by(estuary, season, est.lat) %>%
  summarise(settlement = n()) %>%
  ungroup()

ggplot() +
  geom_bar(data = settlement,
           aes(x = season,
               y = settlement),
           stat = "identity") +
  facet_wrap(vars(estuary)) +
  scale_y_continuous(trans = "log10")

gmc.lat.settle <- ggplot() +
  geom_path(data = settlement,
             aes(y = est.lat,
                 x = settlement/1000)) +
  geom_rug(data = settlement,
           aes(y = est.lat)) +
  facet_wrap(vars(season)) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        strip.background = element_blank(),
        strip.text = element_text(size = 10, colour = "black"),
        axis.text = element_text(colour = "black", size = 10),
        axis.title = element_text(colour = "black", size = 12)) +
  xlab("Predicted larval settlement (000's)") +
  ylab("Settlement latitude (°S)")+
  inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.20)

gmc.lat.settle

ggsave("C:/Users/Dan/Documents/PhD/Dispersal/figures/gmc_lat_settle.png", 
       plot = gmc.lat.settle, 
       device = "png", 
       width = 17, # a4 dimensions
       height = 13, 
       units = "cm", 
       dpi = 600)

m1 <- lm(settlement ~ est.lat * season, data = settlement)
plotenvelope(m1)
plot(m1)
summary(m1)
(exp(coef(m1)["est.lat"]) - 1) * 100

#### predicted settlement and cpue ####
# tidy up the column names of cpue
logbook <- logbook %>% clean_names()

# rename the estuaries in logbook
p.estuaries <- unique(particles$estuary)
l.estuaries <- unique(logbook$estuaryname)

logbook <- logbook %>%
  mutate(estuary = case_when(estuaryname == "Tweed River" ~ "Tweed River",
                             estuaryname == "Richmond River" ~ "Richmond River",
                             estuaryname == "Clarence River" ~ "Clarence River",
                             estuaryname == "Lake Wooloweyah" ~ "Clarence River",
                             estuaryname == "Macleay River" ~ "Macleay River",
                             estuaryname == "Camden Have River" ~ "Camden Haven",
                             estuaryname == "Manning River" ~ "Manning River",
                             estuaryname == "Myall River" ~ "Port Stephens",
                             estuaryname == "Wallis Lake" ~ "Wallis Lake",
                             estuaryname == "Karuah River" ~ "Port Stephens",
                             estuaryname == "Port Stephens" ~ "Port Stephens",
                             estuaryname == "Hunter River" ~ "Hunter River",
                             estuaryname == "Hawkesbury River" ~ "Hawkesbury River",
                             estuaryname == "Lake Illawarra" ~ "Lake Illawarra"))

# back fill data from pre-2018 with estuaries based on the grid and/or site code
est.codes <- data.frame()
for (i in 1:length(p.estuaries)) {
  temp <- logbook %>% 
    select(estuary, grid_site_code) %>%
    filter(estuary == p.estuaries[i]) %>%
    group_by(estuary) %>%
    distinct(grid_site_code)
  est.codes <- bind_rows(est.codes, temp)
}

est <- est.codes$estuary
code <- est.codes$grid_site_code

for (i in 1:length(est)){
  for (j in 1:length(code)) {
    logbook <- logbook %>%
      mutate(estuary = if_else(is.na(estuary), # if the estuary == NA
                               case_when(is.na(estuary) & grid_site_code == code[j] ~ est[i]), # then assign it based on the grid codes list
                               estuary)) # but if not, then leave it as is
  }
}

# create an event code column
logbook$event_code <- group_indices(logbook, fishing_business_owner_name, event_date, grid_site_code)

# select the variables needed
cpue <- logbook %>%
  select(date = event_date,
         year = event_date_year,
         year.month = event_date_year_month,
         mgmt.zone = endorsement_code,
         estuary = estuaryname,
         effort = catch_effort_quantity,
         catch = catch_weight,
         event_code) %>%
  distinct(event_code, .keep_all = T) %>%
  filter(estuary %in% est)

# check out the data
summary(cpue)

# find and remove missing values (i.e., catch = NA)
cpue[!complete.cases(cpue),]
cpue <- na.omit(cpue)

# remove cases where effort = 0
length(which(cpue$effort==0))
cpue <- cpue %>% filter(effort != 0)

# check a summary again
summary(cpue)
hist(cpue$effort)

# remove catch > 100kg and effort > 50
cpue <- cpue %>%
  filter(catch < 100) %>%
  filter(effort < 50)

summary(cpue)

# change the names of the mgmt.zones
cpue <- cpue %>% 
  mutate(mgmt.zone = case_when(mgmt.zone == "EGMC1" ~ "EGF1",
                               mgmt.zone == "EGMC2" ~ "EGF2",
                               mgmt.zone == "EGMC3" ~ "EGF3",
                               mgmt.zone == "EGMC4" ~ "EGF4",
                               mgmt.zone == "EGMC5" ~ "EGF5"))

# remove mgmt.zones (EGF 6 & 7)
cpue <- na.omit(cpue)

# now summarise the df
cpue <- cpue %>%
  group_by(event_code, year, estuary) %>%
  summarise(effort = max(effort),
            catch = sum(catch)) %>%
  ungroup() %>%
  group_by(year, estuary) %>%
  summarise(effort = sum(effort),
            catch = sum(catch),
            n.trips = length(event_code)) %>%
  ungroup() %>%
  mutate(cpue = catch/effort) %>%
  filter(n.trips > 50)

ggplot() +
  geom_point(data = cpue,
           aes(x = year,
               y = cpue),
           stat = "identity") +
  #geom_line(data = cpue,
   #         aes(x = year,
    #            y = cpue*max(catch),
     #           group = 1)) +
  facet_wrap(vars(estuary)) +
  scale_y_continuous(sec.axis = sec_axis(~ . / max(cpue$catch)))

# now get the predicted settlement values
settlement <- particles %>%
  group_by(year, estuary) %>%
  summarise(pred.settle = n()) %>%
  ungroup() %>%
  mutate(total = sum(pred.settle),
         percent = pred.settle/total)

# remove qld zone since we don't have that data
settlement <- settlement %>%
  filter(estuary %in% est)

ggplot() + 
  geom_point(data = settlement,
             aes(x = year,
                 y = pred.settle)) +
  facet_wrap(vars(estuary))

# join cpue and settlement dfs
cpue <- cpue %>%
  left_join(settlement)

# lag the settlement by 1 & 2 years
cpue <- cpue %>%
  group_by(estuary) %>%
  mutate(pred.settle.1 = lag(pred.settle, n = 1, order_by = year)) %>%
  mutate(pred.settle.2 = lag(pred.settle, n = 2, order_by = year)) %>%
  ungroup()

#summary(m1 <- lm(cpue ~ pred.settle * mgmt.zone, data = cpue))
summary(m2 <- lm(cpue ~ pred.settle.1*mgmt.zone, data = cpue))
summary(m3 <- lm(cpue ~ pred.settle.2*mgmt.zone, data = cpue))

plot(m1)
plot(m2)
plot(m3)
plotenvelope(m3)

# no lag
ggplot() + 
  geom_line(data = cpue,
            aes(x = year,
                y = pred.settle),
            colour = "red",
            linetype = "dashed") +
  facet_wrap(vars(estuary)) +
  geom_path(data = cpue,
            aes(x = year,
                y = cpue*max(pred.settle, na.rm = T))) +
  scale_y_continuous(sec.axis = sec_axis(~ . / max(cpue$pred.settle, na.rm = T))) #+
#scale_x_continuous(breaks = seq(min(x$year), max(x$year), 1)) 

# 1 year lag
ggplot() + 
  geom_path(data = cpue,
            aes(x = year,
                y = pred.settle.1,
                group = 1),
            colour = "red",
            linetype = "dashed") +
  facet_wrap(vars(estuary)) +
  geom_line(data = cpue,
            aes(x = year,
                y = cpue*max(pred.settle.1, na.rm = T))) +
  scale_y_continuous(sec.axis = sec_axis(~ . / max(cpue$pred.settle, na.rm = T))) #+
  #scale_x_continuous(breaks = seq(min(x$year), max(x$year), 1))



#########################################################
#########################################################
#########################################################


# multinomial logistic regression to predict settlement estuary by release latitude
# reduced dataset so toy plots are possible
reduced <- particles %>%
  filter(ocean_zone == 1 | ocean_zone == 5 | ocean_zone == 10 | ocean_zone == 19) %>%
  filter(year(rel_date) == "2010")
start <- Sys.time()
m1 <- multinom(estuary ~ rel_lat, data = particles)
summary(m1)
z <- summary(m1)$coefficients/summary(m1)$standard.errors
z
p <- (1 - pnorm(abs(z), 0, 1)) * 2
p
exp(coef(m1))
#head(pp <- fitted(m1))
end <- Sys.time() # 29 mins
rel_lat <- data.frame(rel_lat = particles[,12])

## store the predicted probabilities for each release latitude
pp.rel_lat <- cbind(rel_lat, predict(m1, newdata = rel_lat, type = "probs", se = TRUE))

pp.rel_lat <- pp.rel_lat %>% 
  pivot_longer(cols = !rel_lat,
               names_to = "estuary",
               values_to = "probability")

pp.rel_lat <- pp.rel_lat %>%
  mutate(rel_lat_round = round(rel_lat)) %>%
  mutate(estuary = factor(estuary,
                          levels = c("Hinchinbrook Island", 
                                     "The Narrows", 
                                     "Maryborough", 
                                     "Moreton Bay",
                                     "Tweed River", 
                                     "Richmond River", 
                                     "Clarence River", 
                                     "Macleay River", 
                                     "Camden Haven", 
                                     "Manning River", 
                                     "Wallis Lake", 
                                     "Port Stephens", 
                                     "Hunter River", 
                                     "Hawkesbury River"))) %>%
  mutate(est.lat = case_when(estuary == "Hinchinbrook Island" ~ -18.54, 
                             estuary == "The Narrows" ~ -23.85, 
                             estuary =="Maryborough" ~ -25.82,
                             estuary == "Moreton Bay" ~ -27.34, 
                             estuary == "Tweed River" ~ -28.17, 
                             estuary == "Richmond River" ~ -28.89,
                             estuary == "Clarence River" ~ -29.43, 
                             estuary == "Macleay River" ~ -30.86, 
                             estuary == "Camden Haven" ~ -31.65,
                             estuary == "Manning River" ~ -31.90, 
                             estuary == "Wallis Lake" ~ -32.19, 
                             estuary == "Port Stephens" ~ -32.72,
                             estuary == "Hunter River" ~ -32.92, 
                             estuary == "Hawkesbury River" ~ -33.59))



# plot predictions
start <- Sys.time()
ggplot() +
  geom_line(data = pp.rel_lat,
            aes(x = rel_lat,
                y = probability)) +
  facet_wrap(vars(estuary)) +
  scale_x_reverse() +
  geom_vline(data = pp.rel_lat, 
             aes(xintercept = est.lat), 
             colour = "red", 
             linetype = "dashed") +
  theme_bw() + 
  theme(panel.grid = element_blank(),
        strip.background = element_blank(),
        strip.text = element_text(size = 12, colour = "black"),
        axis.text = element_text(size = 10, colour = "black"),
        axis.title = element_text(size = 12, colour = "black")) +
  ylab("Probability of settlement") +
  xlab("Release latitude")
end <- Sys.time()
########################################
x <- pp.rel_lat %>%
  group_by(rel_lat_round, estuary) %>%
  summarise(pp.mean = mean(probability),
            pp.se = sd(probability)/sqrt(length(probability))) %>%
  ungroup() %>%
  mutate(pp.mean = paste(round(pp.mean, 2), " (", round(pp.se, 2), ")", sep = "")) %>%
  select(!pp.se)

x.table <- x %>%
  pivot_wider(names_from = rel_lat_round,
              values_from = pp.mean)



ggplot() +
  geom_tile(data = x,
            aes(x = rel_lat_round,
                y = estuary, 
                fill = pp.mean)) +
  scale_fill_viridis_c() +
  scale_y_discrete(limits = rev(levels(x$estuary)))
###################################################

cpue <- cpue %>%
  select(year = event_date_year, 
         mgmt.zone = endorsement_code,
         effort = catch_effort_quantity,
         catch = catch_weight) %>%
  group_by(year, mgmt.zone) %>%
  summarise(effort = sum(effort),
            catch = sum(catch)) %>%
  ungroup() %>%
  filter(effort > 0) %>%
  mutate(catch = replace_na(catch, 0)) %>%
  mutate(cpue = catch/effort) %>%
  

cpue <- cpue %>%
  #mutate(year = substr(month.year, 1, 4)) %>%
  mutate(year.adv = as.numeric(year)+1)

cpue <- cpue %>%
  full_join(cpue.settlement)

ggplot() +
  geom_bar(data = cpue,
            aes(x = year,
                y = cpue,
                group = 1),
            colour = "black",
           stat = "identity") +
  facet_wrap(vars(mgmt.zone)) +
  geom_line(data = cpue,
            aes(x = year.adv,
                y = count/max(count),
                group = 1),
            colour = "red",
            linetype = "dashed") +
  scale_y_continuous(sec.axis = sec_axis(~ . * max(cpue.settlement$count)))


#cpue <- cpue[complete.cases(cpue$mgmt.zone),]
cpue <- cpue[complete.cases(cpue$count),]

# plot predicted settlement


ggplot() +
  geom_line(data = cpue,
            aes(x = event_date_year_month,
                y = catch_weight)) +
  facet_wrap(vars(endorsement_code))

# plot dispersal distances
ggplot() +
  geom_point(data = reduced,
             aes(x = rel_lat,
                 y = distance)) 




##############################
obs.mean <- particles %>%
  group_by(ocean_zone) %>%
  summarise(mean.obs = mean(obs)) %>%
  ungroup()

ggplot() +
  geom_histogram(data = particles,
                 aes(x = obs),
                 binwidth = 1) +
  geom_vline(data = obs.mean, 
             aes(xintercept = mean.obs),
             colour = "red",
             linetype = "dashed") +
  facet_wrap(vars(ocean_zone))


dist.mean <- particles %>%
  group_by(ocean_zone) %>%
  summarise(mean.dist = mean(distance)) %>%
  ungroup()

ggplot() +
  geom_histogram(data = particles,
                 aes(x = distance),
                 binwidth = 1) +
  geom_vline(data = dist.mean, 
             aes(xintercept = mean.dist),
             colour = "red",
             linetype = "dashed") +
  facet_wrap(vars(ocean_zone))

summary(dist.mod <- lm(distance ~ rel_lat + year, data = particles))
plot(dist.mod)



ggplot() +
  geom_scattermore(data = particles,
                   aes(x = rel_lat,
                       y = distance)) +
  facet_wrap(vars(season))


# naive bayes classifier
library(e1071)
nb.data <- particles %>% select(rel_lat, obs, estuary)
m1 <- naiveBayes(estuary ~ rel_lat + obs, data = nb.data)
m1
start <- Sys.time()
m1.predict <- predict(m1, nb.data) # this bit takes a while
end <- Sys.time()
end-start
conf.mat <- as.data.frame.matrix(table(m1.predict, nb.data$estuary))
