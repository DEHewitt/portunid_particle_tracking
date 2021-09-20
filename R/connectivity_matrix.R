connectivity_matrix <- function(data, species, direction, facet){
  # data is the parcels output
  # species is either "gmc" or "bsc"
  # direction is either "forwards" or "backwards"
  # facet: logical indicating if you want the plot to be faceted by year
  if (facet == TRUE){
    if (species == "gmc" & direction == "forwards"){
      # create the data frame
      x <- data %>%
        group_by(rel_lat, estuary, season) %>%
        summarise(count = n()) %>%
        ungroup() %>%
        mutate(total = sum(count), percent = count/total) %>%
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
      
      # make the plot
      plot <- ggplot(data = x,
                     aes(x = rel_lat_round, 
                         y = est.label,
                         fill = count,
                         group = est.label)) +
        geom_tile() +
        geom_point(data = x,
                   aes(x = est.lat,
                       y = est.label),
                   colour = "white", 
                   shape = 4,
                   size = 2) +
        scale_fill_viridis_c(trans = "log10") +
        theme_bw() +
        theme(panel.grid = element_blank(),
              axis.text = element_text(size = 10, colour = "black"),
              axis.title = element_text(size = 12, colour = "black"),
              strip.background = element_blank(),
              strip.text = element_text(size = 10, colour = "black"),
              legend.text = element_text(size = 10, colour = "black")) +
        scale_y_discrete(limits = rev(levels(x$est.label))) +
        scale_x_reverse() +
        ylab(expression("Settlement estuary ("*degree*"; sink)")) +
        xlab(expression("Release latitude ("*degree*"; source)")) +
        labs(fill = "Relative larval supply") +
        facet_wrap(vars(season))# +
        #inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)
      
    } else if (species == "bsc" & direction == "forwards"){
      # create the dataframe
      x <- data %>%
        group_by(rel_lat, estuary, season) %>%
        summarise(count = n()) %>%
        ungroup() %>%
        mutate(total = sum(count), percent = count/total) %>%
        mutate(rel_lat_round = round(rel_lat)) %>%
        mutate(est.lat = case_when(estuary =="Maryborough" ~ -25.82,
                                   estuary == "Moreton Bay" ~ -27.34, 
                                   estuary == "Wallis Lake" ~ -32.19, 
                                   estuary == "Port Stephens" ~ -32.72,
                                   estuary == "Hunter River" ~ -32.92, 
                                   #estuary == "Hawkesbury River" ~ -33.59,
                                   estuary == "Lake Illawarra" ~ -34.55)) %>%
        mutate(est.label = paste(estuary, " (", est.lat, ")", sep = "")) %>%
        mutate(est.label = factor(est.label,
                                  levels = c("Maryborough (-25.82)",
                                             "Moreton Bay (-27.34)", 
                                             "Wallis Lake (-32.19)", 
                                             "Port Stephens (-32.72)",
                                             "Hunter River (-32.92)", 
                                             #"Hawkesbury River (-33.59)",
                                             "Lake Illawarra (-34.55)")))
      
      # make the plot
      plot <- ggplot(data = x,
                     aes(x = rel_lat_round, 
                         y = est.label,
                         fill = count,
                         group = est.label)) +
        geom_tile() +
        geom_point(data = x,
                   aes(x = est.lat,
                       y = est.label),
                   colour = "white", 
                   shape = 4,
                   size = 2) +
        scale_fill_viridis_c(trans = "log10") +
        theme_bw() +
        theme(panel.grid = element_blank(),
              axis.text = element_text(size = 10, colour = "black"),
              axis.title = element_text(size = 12, colour = "black"),
              strip.background = element_blank(),
              strip.text = element_text(size = 10, colour = "black"),
              legend.text = element_text(size = 10, colour = "black")) +
        scale_y_discrete(limits = rev(levels(x$est.label))) +
        scale_x_reverse() +
        ylab(expression("Settlement estuary ("*degree*"; sink)")) +
        xlab(expression("Release latitude ("*degree*"; source)")) +
        labs(fill = "Relative larval supply") +
        facet_wrap(vars(season))# +
        #inset_element(bsc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)
      
    } else if (species == "gmc" & direction == "backwards"){
      x <- data %>%
        mutate(lat_round = round(lat)) %>%
        group_by(rel_est, lat_round, season) %>%
        summarise(count = n()) %>%
        ungroup() %>%
        mutate(total = sum(count), percent = count/total) %>%
        mutate(est.lat = case_when(rel_est == "Hinchinbrook Island" ~ -18.54, 
                                   rel_est == "The Narrows" ~ -23.85, 
                                   rel_est =="Maryborough" ~ -25.82,
                                   rel_est == "Moreton Bay" ~ -27.34, 
                                   rel_est == "Tweed River" ~ -28.17, 
                                   rel_est == "Richmond River" ~ -28.89,
                                   rel_est == "Clarence River" ~ -29.43, 
                                   rel_est == "Macleay River" ~ -30.86, 
                                   rel_est == "Camden Haven" ~ -31.65,
                                   rel_est == "Manning River" ~ -31.90, 
                                   rel_est == "Wallis Lake" ~ -32.19, 
                                   rel_est == "Port Stephens" ~ -32.72,
                                   rel_est == "Hunter River" ~ -32.92, 
                                   rel_est == "Hawkesbury River" ~ -33.59)) %>%
        mutate(est.label = paste(rel_est, " (", est.lat, ")", sep = "")) %>%
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
      
      plot <- ggplot(data = x,
                     aes(x = lat_round, 
                         y = est.label,
                         fill = count,
                         group = est.label)) +
        geom_tile() +
        geom_point(data = x,
                   aes(x = est.lat,
                       y = est.label),
                   colour = "white", 
                   shape = 4,
                   size = 2) +
        scale_fill_viridis_c(trans = "log10") +
        theme_bw() +
        theme(panel.grid = element_blank(),
              axis.text = element_text(size = 10, colour = "black"),
              axis.title = element_text(size = 12, colour = "black"),
              strip.background = element_blank(),
              strip.text = element_text(size = 10, colour = "black"),
              legend.text = element_text(size = 10, colour = "black")) +
        scale_y_discrete(limits = rev(levels(x$est.label))) +
        scale_x_reverse() +
        ylab(expression("Settlement estuary ("*degree*"; sink)")) +
        xlab(expression("Putative spawning latitude ("*degree*"; source)")) +
        labs(fill = "Relative larval supply") +
        facet_wrap(vars(season)) #+
        #inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)
      
    } else if (species == "bsc" & direction == "backwards"){
      x <- data %>%
        mutate(lat_round = round(lat)) %>%
        group_by(rel_est, lat_round, season) %>%
        summarise(count = n()) %>%
        ungroup() %>%
        mutate(total = sum(count), percent = count/total) %>%
        mutate(est.lat = case_when(rel_est == "Maryborough" ~ -25.82,
                                   rel_est == "Moreton Bay" ~ -27.34,
                                   rel_est == "Wallis Lake" ~ -32.19, 
                                   rel_est == "Port Stephens" ~ -32.72,
                                   rel_est == "Hunter River" ~ -32.92, 
                                   #rel_est == "Hawkesbury River" ~ -33.59,
                                   rel_est == "Lake Illawarra" ~ -34.55)) %>%
        mutate(est.label = paste(rel_est, " (", est.lat, ")", sep = "")) %>%
        mutate(est.label = factor(est.label,
                                  levels = c("Maryborough (-25.82)",
                                             "Moreton Bay (-27.34)", 
                                             "Wallis Lake (-32.19)", 
                                             "Port Stephens (-32.72)",
                                             "Hunter River (-32.92)", 
                                             #"Hawkesbury River (-33.59)",
                                             "Lake Illawarra (-34.55)")))
      
      plot <- ggplot(data = x,
                     aes(x = lat_round, 
                         y = est.label,
                         fill = count,
                         group = est.label)) +
        geom_tile() +
        geom_point(data = x,
                   aes(x = est.lat,
                       y = est.label),
                   colour = "white", 
                   shape = 4,
                   size = 2) +
        scale_fill_viridis_c(trans = "log10") +
        theme_bw() +
        theme(panel.grid = element_blank(),
              axis.text = element_text(size = 10, colour = "black"),
              axis.title = element_text(size = 12, colour = "black"),
              strip.background = element_blank(),
              strip.text = element_text(size = 10, colour = "black"),
              legend.text = element_text(size = 10, colour = "black")) +
        scale_y_discrete(limits = rev(levels(x$est.label))) +
        scale_x_reverse() +
        ylab(expression("Settlement estuary ("*degree*"; sink)")) +
        xlab(expression("Putative spawning latitude ("*degree*"; source)")) +
        labs(fill = "Relative larval supply") +
        facet_wrap(vars(season))# +
        #inset_element(bsc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)
    }
    plot
  } else {
    if (species == "gmc" & direction == "forwards"){
      # create the data frame
      x <- data %>%
        group_by(rel_lat, estuary, season) %>%
        summarise(count = n()) %>%
        ungroup() %>%
        mutate(total = sum(count), percent = count/total) %>%
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
      
      # make the plot
      plot <- ggplot(data = x,
                     aes(x = rel_lat_round, 
                         y = est.label,
                         fill = count,
                         group = est.label)) +
        geom_tile() +
        geom_point(data = x,
                   aes(x = est.lat,
                       y = est.label),
                   colour = "white", 
                   shape = 4,
                   size = 6) +
        scale_fill_viridis_c(trans = "log10") +
        theme_bw() +
        theme(panel.grid = element_blank(),
              axis.text = element_text(size = 12, colour = "black"),
              axis.title = element_text(size = 12, colour = "black"),
              legend.text = element_text(size = 12, colour = "black")) +
        scale_y_discrete(limits = rev(levels(x$est.label))) +
        ylab(expression("Settlement estuary ("*degree*"; sink)")) +
        xlab(expression("Release latitude ("*degree*"; source)")) +
        labs(fill = "Relative larval supply")# + +
        #inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)
      
    } else if (species == "bsc" & direction == "forwards"){
      # create the dataframe
      x <- data %>%
        group_by(rel_lat, estuary, season) %>%
        summarise(count = n()) %>%
        ungroup() %>%
        mutate(total = sum(count), percent = count/total) %>%
        mutate(rel_lat_round = round(rel_lat)) %>%
        mutate(est.lat = case_when(estuary =="Maryborough" ~ -25.82,
                                   estuary == "Moreton Bay" ~ -27.34, 
                                   estuary == "Wallis Lake" ~ -32.19, 
                                   estuary == "Port Stephens" ~ -32.72,
                                   estuary == "Hunter River" ~ -32.92, 
                                   #estuary == "Hawkesbury River" ~ -33.59,
                                   estuary == "Lake Illawarra" ~ -34.55)) %>%
        mutate(est.label = paste(estuary, " (", est.lat, ")", sep = "")) %>%
        mutate(est.label = factor(est.label,
                                  levels = c("Maryborough (-25.82)",
                                             "Moreton Bay (-27.34)", 
                                             "Wallis Lake (-32.19)", 
                                             "Port Stephens (-32.72)",
                                             "Hunter River (-32.92)", 
                                             #"Hawkesbury River (-33.59)",
                                             "Lake Illawarra (-34.55)")))
      
      # make the plot
      plot <- ggplot(data = x,
                     aes(x = rel_lat_round, 
                         y = est.label,
                         fill = count,
                         group = est.label)) +
        geom_tile() +
        geom_point(data = x,
                   aes(x = est.lat,
                       y = est.label),
                   colour = "white", 
                   shape = 4,
                   size = 2) +
        scale_fill_viridis_c(trans = "log10") +
        theme_bw() +
        theme(panel.grid = element_blank(),
              axis.text = element_text(size = 12, colour = "black"),
              axis.title = element_text(size = 12, colour = "black"),
              legend.text = element_text(size = 12, colour = "black")) +
        scale_y_discrete(limits = rev(levels(x$est.label))) +
        ylab(expression("Settlement estuary ("*degree*"; sink)")) +
        xlab(expression("Release latitude ("*degree*"; source)")) +
        labs(fill = "Relative larval supply")# +
        #inset_element(bsc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)
      
    } else if (species == "gmc" & direction == "backwards"){
      x <- data %>%
        mutate(lat_round = round(lat)) %>%
        group_by(rel_est, lat_round, season) %>%
        summarise(count = n()) %>%
        ungroup() %>%
        mutate(total = sum(count), percent = count/total) %>%
        mutate(est.lat = case_when(rel_est == "Hinchinbrook Island" ~ -18.54, 
                                   rel_est == "The Narrows" ~ -23.85, 
                                   rel_est =="Maryborough" ~ -25.82,
                                   rel_est == "Moreton Bay" ~ -27.34, 
                                   rel_est == "Tweed River" ~ -28.17, 
                                   rel_est == "Richmond River" ~ -28.89,
                                   rel_est == "Clarence River" ~ -29.43, 
                                   rel_est == "Macleay River" ~ -30.86, 
                                   rel_est == "Camden Haven" ~ -31.65,
                                   rel_est == "Manning River" ~ -31.90, 
                                   rel_est == "Wallis Lake" ~ -32.19, 
                                   rel_est == "Port Stephens" ~ -32.72,
                                   rel_est == "Hunter River" ~ -32.92, 
                                   rel_est == "Hawkesbury River" ~ -33.59)) %>%
        mutate(est.label = paste(rel_est, " (", est.lat, ")", sep = "")) %>%
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
      
      plot <- ggplot(data = x,
                     aes(x = lat_round, 
                         y = est.label,
                         fill = count,
                         group = est.label)) +
        geom_tile() +
        geom_point(data = x,
                   aes(x = est.lat,
                       y = est.label),
                   colour = "white", 
                   shape = 4,
                   size = 2) +
        scale_fill_viridis_c(trans = "log10") +
        theme_bw() +
        theme(panel.grid = element_blank(),
              axis.text = element_text(size = 12, colour = "black"),
              axis.title = element_text(size = 12, colour = "black"),
              legend.text = element_text(size = 12, colour = "black")) +
        scale_y_discrete(limits = rev(levels(x$est.label))) +
        ylab(expression("Settlement estuary ("*degree*"; sink)")) +
        xlab(expression("Putative spawning latitude ("*degree*"; source)")) +
        labs(fill = "Relative larval supply") #+
        #inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)
      
    } else if (species == "bsc" & direction == "backwards"){
      x <- data %>%
        mutate(lat_round = round(lat)) %>%
        group_by(rel_est, lat_round, season) %>%
        summarise(count = n()) %>%
        ungroup() %>%
        mutate(total = sum(count), percent = count/total) %>%
        mutate(est.lat = case_when(rel_est == "Maryborough" ~ -25.82,
                                   rel_est == "Moreton Bay" ~ -27.34,
                                   rel_est == "Wallis Lake" ~ -32.19, 
                                   rel_est == "Port Stephens" ~ -32.72,
                                   rel_est == "Hunter River" ~ -32.92, 
                                   #rel_est == "Hawkesbury River" ~ -33.59,
                                   rel_est == "Lake Illawarra" ~ -34.55)) %>%
        mutate(est.label = paste(rel_est, " (", est.lat, ")", sep = "")) %>%
        mutate(est.label = factor(est.label,
                                  levels = c("Maryborough (-25.82)",
                                             "Moreton Bay (-27.34)", 
                                             "Wallis Lake (-32.19)", 
                                             "Port Stephens (-32.72)",
                                             "Hunter River (-32.92)", 
                                             #"Hawkesbury River (-33.59)",
                                             "Lake Illawarra (-34.55)")))
      
      plot <- ggplot(data = x,
                     aes(x = lat_round, 
                         y = est.label,
                         fill = count,
                         group = est.label)) +
        geom_tile() +
        geom_point(data = x,
                   aes(x = est.lat,
                       y = est.label),
                   colour = "white", 
                   shape = 4,
                   size = 2) +
        scale_fill_viridis_c(trans = "log10") +
        theme_bw() +
        theme(panel.grid = element_blank(),
              axis.text = element_text(size = 12, colour = "black"),
              axis.title = element_text(size = 12, colour = "black"),
              legend.text = element_text(size = 12, colour = "black")) +
        scale_y_discrete(limits = rev(levels(x$est.label))) +
        ylab(expression("Settlement estuary ("*degree*"; sink)")) +
        xlab(expression("Putative spawning latitude ("*degree*"; source)")) +
        labs(fill = "Relative larval supply")# +
        #inset_element(bsc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)
    }
    plot
  }
  
}
