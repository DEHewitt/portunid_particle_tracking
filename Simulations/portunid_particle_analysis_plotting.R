library(tidyverse)
library(lubridate)
library(ggplot2)
library(nnet)
library(janitor)
library(ecostats)
library(scattermore)

# 1. connectivity matrices
# 2. multinomial logistic regression - predict settlement estuary based on release latitude (and year?)
# 3. relate distance, time to settlement to release latitude and year
# 4. relate cpue from egf regions and estuaries to predicted settlement
# 5. make some of those map plots

###### gmc ######
#### forward ####
# open the parcels output
file.path <- "C:/Users/Dan/Documents/PhD/Dispersal/github/portunid_particle_tracking/Data/Output" 
particles <- readRDS(paste(file.path, paste("gmc", "forwards", "master_settled.rds", sep = "_"), sep = "/"))

# open/bind the logbook files
files <- list.files(path = "C:/Users/Dan/Documents/PhD/Dispersal/data_raw/GMC_Logbook", pattern = ".csv")
path <- "C:/Users/Dan/Documents/PhD/Dispersal/data_raw/GMC_Logbook"
logbook <- data.frame()
for (i in 1:length(files)){
  temp <- read_csv(paste(path, files[i], sep = "/"))
  logbook <- bind_rows(temp, logbook)
}

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
  mutate(season = if_else(year(rel_date) == "2015", "2014-2015", paste(year(particles$rel_date), year(particles$rel_date)+1, sep = "-"))) %>%
  # month of settltment
  mutate(month = month(date)) %>%
  mutate(month = if_else(month < 10, paste("0", month, sep = ""), as.character(month))) %>%
  # year of settlement
  mutate(year = year(date)) %>%
  # month and year of settlement
  mutate(month.year = paste(year, month, sep = "-"))

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
  mutate(est.label = paste(estuary, " (", con.mat.df$est.lat, ")", sep = "")) %>%
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

# plot
con.mat <- ggplot() +
  geom_tile(data = con.mat.df,
            aes(x = rel_lat_round, 
                y = est.label,
                fill = log(count))) +
  scale_fill_viridis_c() +
  theme_bw() +
  theme(panel.grid = element_blank(),
        #axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text = element_text(size = 10, colour = "black"),
        axis.title = element_text(size = 12, colour = "black"),
        strip.background = element_blank(),
        strip.text = element_text(size = 12, colour = "black"),
        legend.text = element_text(size = 10, colour = "black")) +
  #scale_x_continuous() +
  scale_y_discrete(limits = rev(levels(con.mat.df$est.label))) +
  scale_x_reverse(breaks = seq(-15, -33, -3)) +
  ylab("Settlement estuary") +
  xlab("Release latitude (°S)") +
  labs(fill = "Settled larvae")# +
  facet_wrap(vars(season))

ggsave("C:/Users/Dan/Documents/PhD/Dispersal/figures/con_mat_rel_lat_est.jpeg", 
       plot = con.mat, 
       device = "jpeg", 
       width = 29, # a4 dimensions
       height = 20, 
       units = "cm", 
       dpi = 300)

con.mat.df <- particles %>%
  group_by(rel_lat, estuary) %>%
  summarise(count = n()) %>%
  ungroup() %>%
  mutate(total = sum(count),
         percent = count/total) %>%
  mutate(rel_lat_round = round(rel_lat))

# plot
con.mat <- ggplot() +
  geom_tile(data = con.mat.df,
            aes(x = rel_lat_round, 
                y = estuary,
                fill = log(count))) +
  scale_fill_viridis_c() +
  theme_bw() +
  theme(panel.grid = element_blank(),
        #axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        axis.text = element_text(size = 10, colour = "black"),
        axis.title = element_text(size = 12, colour = "black"),
        strip.background = element_blank(),
        strip.text = element_text(size = 12, colour = "black"),
        legend.text = element_text(size = 10, colour = "black")) +
  #scale_x_continuous() +
  scale_y_discrete(limits = rev(levels(con.mat.df$estuary))) +
  scale_x_reverse(breaks = seq(-15, -34, -2),
                  labels = seq(-15, -34, -2)) +
  ylab("Settlement estuary") +
  xlab("Release latitude (°)") +
  labs(fill = "Settled larvae") 

ggsave("C:/Users/Dan/Documents/PhD/Dispersal/figures/con_mat_rel_lat_est_no_facet.jpeg", 
       plot = con.mat, 
       device = "jpeg", 
       width = 29, # a4 dimensions
       height = 20, 
       units = "cm", 
       dpi = 300)

# spawning latitude to mgmt.zone
con.mat.df <- particles %>%
  group_by(rel_lat, mgmt.zone, season) %>%
  summarise(count = n()) %>%
  ungroup() %>%
  mutate(total = sum(count),
         percent = count/total) %>%
  mutate(rel_lat_round = round(rel_lat))

# plot connectivity matrix
con.mat <- ggplot() +
  geom_tile(data = con.mat.df,
            aes(x = mgmt.zone, 
                y = rel_lat_round,
                fill = log(count))) +
  scale_fill_viridis_c() +
  theme_bw() +
  theme(panel.grid = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text = element_text(size = 10, colour = "black"),
        axis.title = element_text(size = 12, colour = "black"),
        strip.background = element_blank(),
        strip.text = element_text(size = 12, colour = "black"),
        legend.text = element_text(size = 10, colour = "black")) +
  scale_y_continuous(breaks = seq(-16, -34, -2),
                     labels = seq(-16, -34, -2)) +
  xlab("Settlement zone") +
  ylab("Release latitude (°)") +
  labs(fill = "Settled larvae") +
  facet_wrap(vars(season))

ggsave("C:/Users/Dan/Documents/PhD/Dispersal/figures/con_mat_rel_lat_mgmt.jpeg", 
       plot = con.mat, 
       device = "jpeg", 
       width = 29, # a4 dimensions
       height = 20, 
       units = "cm", 
       dpi = 300)

# spawning latitude to estuary (no round of lats, no faceting)
con.mat.df <- particles %>%
  group_by(rel_lat, estuary, season) %>%
  summarise(count = n()) %>%
  ungroup() %>%
  mutate(total = sum(count),
         percent = count/total)

# plot connectivity matrix
con.mat <- ggplot() +
  geom_tile(data = con.mat.df,
            aes(x = estuary, 
                y = rel_lat,
                fill = log(count))) +
  scale_fill_viridis_c() +
  theme_bw() +
  theme(panel.grid = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        axis.text = element_text(size = 10, colour = "black"),
        axis.title = element_text(size = 12, colour = "black"),
        strip.background = element_blank(),
        strip.text = element_text(size = 12, colour = "black"),
        legend.text = element_text(size = 10, colour = "black")) +
  scale_y_continuous(breaks = seq(-16, -34, -2),
                     labels = seq(-16, -34, -2)) +
  xlab("Settlement estuary") +
  ylab("Release latitude (°)") +
  labs(fill = "Settled larvae")

ggsave("C:/Users/Dan/Documents/PhD/Dispersal/figures/con_mat_rel_lat_est_no_facet.jpeg", 
       plot = con.mat, 
       device = "jpeg", 
       width = 29, # a4 dimensions
       height = 20, 
       units = "cm", 
       dpi = 300)

# spawning lat to estuary with facets
con.mat.df <- particles %>%
  group_by(rel_lat, estuary, season) %>%
  summarise(count = n()) %>%
  ungroup() %>%
  mutate(total = sum(count),
         percent = count/total)

# plot connectivity matrix
con.mat <- ggplot() +
  geom_tile(data = con.mat.df,
            aes(x = estuary, 
                y = rel_lat,
                fill = log(count))) +
  scale_fill_viridis_c() +
  theme_bw() +
  theme(panel.grid = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        axis.text = element_text(size = 10, colour = "black"),
        axis.title = element_text(size = 12, colour = "black"),
        strip.background = element_blank(),
        strip.text = element_text(size = 12, colour = "black"),
        legend.text = element_text(size = 10, colour = "black")) +
  scale_y_continuous(breaks = seq(-16, -34, -2),
                     labels = seq(-16, -34, -2)) +
  xlab("Settlement estuary") +
  ylab("Release latitude (°)") +
  labs(fill = "Settled larvae") +
  facet_wrap(vars(season))

ggsave("C:/Users/Dan/Documents/PhD/Dispersal/figures/con_mat_rel_lat_est_with_facet.jpeg", 
       plot = con.mat, 
       device = "jpeg", 
       width = 29, # a4 dimensions
       height = 20, 
       units = "cm", 
       dpi = 300)

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
#### predicted settlement and cpue ####
# tidy up the column names of cpue
logbook <- logbook %>% clean_names()

# create an event code column
logbook$event_code <- group_indices(logbook, fishing_business_owner_name, event_date, grid_site_code)

# select the variables needed
cpue <- logbook %>%
  select(date = event_date,
         year = event_date_year,
         year.month = event_date_year_month,
         mgmt.zone = endorsement_code,
         effort = catch_effort_quantity,
         catch = catch_weight,
         event_code)

# check out the data
summary(cpue)

# find and remove missing values (i.e., catch = NA)
cpue[!complete.cases(cpue),] # 163
cpue <- na.omit(cpue)

# remove cases where effort = 0
length(which(cpue$effort==0)) # 3332
cpue <- cpue %>% filter(effort != 0)

# check a summary again
summary(cpue)
hist(cpue$effort)

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
  group_by(event_code, year, mgmt.zone) %>%
  summarise(effort = max(effort),
            catch = sum(catch)) %>%
  ungroup() %>%
  group_by(year, mgmt.zone) %>%
  summarise(effort = sum(effort),
            catch = sum(catch)) %>%
  ungroup() %>%
  mutate(cpue = catch/effort)

ggplot() +
  geom_bar(data = cpue,
           aes(x = year,
               y = catch),
           stat = "identity") +
  geom_line(data = cpue,
            aes(x = year,
                y = cpue*max(catch),
                group = 1)) +
  facet_wrap(vars(mgmt.zone)) +
  scale_y_continuous(sec.axis = sec_axis(~ . / max(cpue$catch)))

# now get the predicted settlement values
settlement <- particles %>%
  group_by(year, mgmt.zone) %>%
  summarise(pred.settle = n()) %>%
  ungroup() %>%
  mutate(total = sum(pred.settle),
         percent = pred.settle/total)

# remove qld zone since we don't have that data
settlement <- settlement %>%
  filter(mgmt.zone != "C1")

# join cpue and settlement dfs
cpue <- cpue %>%
  full_join(settlement)

# lag the settlement by 1 & 2 years
cpue <- cpue %>%
  group_by(mgmt.zone) %>%
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
  facet_wrap(vars(mgmt.zone)) +
  geom_line(data = cpue,
            aes(x = year,
                y = cpue*max(pred.settle, na.rm = T))) +
  scale_y_continuous(sec.axis = sec_axis(~ . / max(cpue$pred.settle, na.rm = T))) #+
#scale_x_continuous(breaks = seq(min(x$year), max(x$year), 1)) 


# 1 year lag
ggplot() + 
  geom_line(data = cpue,
            aes(x = year,
                y = pred.settle.1),
            colour = "red",
            linetype = "dashed") +
  facet_wrap(vars(mgmt.zone)) +
  geom_line(data = cpue,
            aes(x = year,
                y = cpue*max(pred.settle, na.rm = T))) +
  scale_y_continuous(sec.axis = sec_axis(~ . / max(cpue$pred.settle, na.rm = T))) #+
  #scale_x_continuous(breaks = seq(min(x$year), max(x$year), 1))

# 2 year lag
ggplot() + 
  geom_line(data = cpue,
            aes(x = year,
                y = pred.settle.2),
            colour = "red",
            linetype = "dashed") +
  facet_wrap(vars(mgmt.zone)) +
  geom_line(data = cpue,
            aes(x = year,
                y = cpue*max(pred.settle, na.rm = T))) +
  scale_y_continuous(sec.axis = sec_axis(~ . / max(cpue$pred.settle, na.rm = T))) + #+
  #scale_x_continuous(breaks = seq(min(x$year), max(x$year), 1))
  coord_cartesian(xlim = c(2008, 2018))
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
