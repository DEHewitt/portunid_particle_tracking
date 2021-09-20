plot_cpue <- function(data, species, lag, group){
  # data is the joined settlement and cpue
  # species is either "gmc" or "bsc"
  # lag is the numberof years you want settlement to be lagged by (0-3)
  # group is either estuary or egf
  
  if (group == "estuary"){
    if (species == "gmc"){
      scaling_value <- max(data$settlement, na.rm = T)/max(data$mean.cpue, na.rm = T)
      
      if (lag == 0){
        p <- ggplot() + 
          geom_path(data = data,
                    aes(x = year,
                        y = mean.cpue)) +
          geom_point(data = data,
                     aes(x = year,
                         y = mean.cpue)) +
          geom_errorbar(data = data,
                        aes(x = year,
                            ymin = mean.cpue-se.cpue,
                            ymax = mean.cpue+se.cpue)) +
          geom_path(data = data,
                    aes(x = year,
                        y = settlement / scaling_value),
                    colour = "red",
                    linetype = "dashed") +
          geom_point(data = data,
                     aes(x = year,
                         y = settlement / scaling_value),
                     colour = "red",
                     shape = 17) +
          scale_y_continuous(sec.axis = sec_axis(~ . * scaling_value, name = "Relative larval settlement")) +
          scale_x_continuous(breaks = seq(2008, 2018, 2),
                             labels = c("2008", "", "2012", "", "2016", "")) +
          facet_wrap(vars(estuary.1)) +
          theme_bw() +
          theme(panel.grid = element_blank(),
                axis.text = element_text(size = 10, colour = "black"),
                axis.title = element_text(size = 12, colour = "black"),
                strip.background = element_blank(),
                strip.text = element_text(size = 10, colour = "black"),
                legend.text = element_text(size = 10, colour = "black"),
                axis.title.y.right = element_text(colour = "red")) +
          xlab("Year") +
          ylab(expression(paste("Mean catch-per-unit-effort (kg trap"^-1, ")"))) +
          inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)
        
        p
        
      } else if (lag == 1){
        p <- ggplot() + 
          geom_path(data = data,
                    aes(x = year,
                        y = mean.cpue)) +
          geom_point(data = data,
                     aes(x = year,
                         y = mean.cpue)) +
          geom_errorbar(data = data,
                        aes(x = year,
                            ymin = mean.cpue-se.cpue,
                            ymax = mean.cpue+se.cpue)) +
          geom_path(data = data,
                    aes(x = year,
                        y = settlement.1 / scaling_value),
                    colour = "red",
                    linetype = "dashed") +
          geom_point(data = data,
                     aes(x = year,
                         y = settlement.1 / scaling_value),
                     colour = "red",
                     shape = 17) +
          scale_y_continuous(sec.axis = sec_axis(~ . * scaling_value, name = "Lagged relative larval settlement")) +
          scale_x_continuous(breaks = seq(2008, 2018, 2)) +
          facet_wrap(vars(estuary.1)) +
          theme_bw() +
          theme(panel.grid = element_blank(),
                axis.text = element_text(size = 10, colour = "black"),
                axis.title = element_text(size = 12, colour = "black"),
                strip.background = element_blank(),
                strip.text = element_text(size = 10, colour = "black"),
                legend.text = element_text(size = 10, colour = "black"),
                axis.title.y.right = element_text(colour = "red")) +
          xlab("Year") +
          ylab(expression(paste("Mean catch-per-unit-effort (kg trap"^-1, ")"))) +
          inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)
        
        p
        
      } else if (lag == 2){
        p <- ggplot() + 
          geom_path(data = data,
                    aes(x = year,
                        y = mean.cpue)) +
          geom_point(data = data,
                     aes(x = year,
                         y = mean.cpue)) +
          geom_errorbar(data = data,
                        aes(x = year,
                            ymin = mean.cpue-se.cpue,
                            ymax = mean.cpue+se.cpue)) +
          geom_path(data = data,
                    aes(x = year,
                        y = settlement.2 / scaling_value),
                    colour = "red",
                    linetype = "dashed") +
          geom_point(data = data,
                     aes(x = year,
                         y = settlement.2 / scaling_value),
                     colour = "red",
                     shape = 17) +
          scale_y_continuous(sec.axis = sec_axis(~ . * scaling_value, name = "Lagged relative larval settlement")) +
          scale_x_continuous(breaks = seq(2008, 2018, 2)) +
          facet_wrap(vars(estuary.1)) +
          theme_bw() +
          theme(panel.grid = element_blank(),
                axis.text = element_text(size = 10, colour = "black"),
                axis.title = element_text(size = 12, colour = "black"),
                strip.background = element_blank(),
                strip.text = element_text(size = 10, colour = "black"),
                legend.text = element_text(size = 10, colour = "black"),
                axis.title.y.right = element_text(colour = "red")) +
          xlab("Year") +
          ylab(expression(paste("Mean catch-per-unit-effort (kg trap"^-1, ")"))) +
          inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)
        
        p
        
      } else if (lag == 3){
        p <- ggplot() + 
          geom_path(data = data,
                    aes(x = year,
                        y = mean.cpue)) +
          geom_point(data = data,
                     aes(x = year,
                         y = mean.cpue)) +
          geom_errorbar(data = data,
                        aes(x = year,
                            ymin = mean.cpue-se.cpue,
                            ymax = mean.cpue+se.cpue)) +
          geom_path(data = data,
                    aes(x = year,
                        y = settlement.3 / scaling_value),
                    colour = "red",
                    linetype = "dashed") +
          geom_point(data = data,
                     aes(x = year,
                         y = settlement.3 / scaling_value),
                     colour = "red",
                     shape = 17) +
          scale_y_continuous(sec.axis = sec_axis(~ . * scaling_value, name = "Lagged relative larval settlement")) +
          scale_x_continuous(breaks = seq(2008, 2018, 2)) +
          facet_wrap(vars(estuary.1)) +
          theme_bw() +
          theme(panel.grid = element_blank(),
                axis.text = element_text(size = 10, colour = "black"),
                axis.title = element_text(size = 12, colour = "black"),
                strip.background = element_blank(),
                strip.text = element_text(size = 10, colour = "black"),
                legend.text = element_text(size = 10, colour = "black"),
                axis.title.y.right = element_text(colour = "red")) +
          xlab("Year") +
          ylab(expression(paste("Mean catch-per-unit-effort (kg trap"^-1, ")"))) +
          inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)
        
        p
        
      }
      
    } else if (species == "bsc"){
      scaling_value <- max(data$settlement, na.rm = T)/max(data$mean.cpue, na.rm = T)
      
      if (lag == 0){
        p <- ggplot() + 
          geom_path(data = data,
                    aes(x = year,
                        y = mean.cpue)) +
          geom_point(data = data,
                     aes(x = year,
                         y = mean.cpue)) +
          geom_errorbar(data = data,
                        aes(x = year,
                            ymin = mean.cpue-se.cpue,
                            ymax = mean.cpue+se.cpue)) +
          geom_path(data = data,
                    aes(x = year,
                        y = settlement / scaling_value),
                    colour = "red",
                    linetype = "dashed") +
          geom_point(data = data,
                     aes(x = year,
                         y = settlement / scaling_value),
                     colour = "red",
                     shape = 17) +
          scale_y_continuous(sec.axis = sec_axis(~ . * scaling_value, name = "Relative larval settlement")) +
          scale_x_continuous(breaks = seq(2008, 2018, 2),
                             labels = c("2008", "", "2012", "", "2016", "")) +
          facet_wrap(vars(estuary.1)) +
          theme_bw() +
          theme(panel.grid = element_blank(),
                axis.text = element_text(size = 10, colour = "black"),
                axis.title = element_text(size = 12, colour = "black"),
                strip.background = element_blank(),
                strip.text = element_text(size = 10, colour = "black"),
                legend.text = element_text(size = 10, colour = "black"),
                axis.title.y.right = element_text(colour = "red")) +
          xlab("Year") +
          ylab(expression(paste("Mean catch-per-unit-effort (kg trap"^-1, ")"))) 
        
        patch <- plot_spacer()/plot_spacer()/plot_spacer()/bsc.grob
        p <- p + patch + plot_layout(widths = c(4, 1))
        
        p
        
      } else if (lag == 1){
        p <- ggplot() + 
          geom_path(data = data,
                    aes(x = year,
                        y = mean.cpue)) +
          geom_point(data = data,
                     aes(x = year,
                         y = mean.cpue)) +
          geom_errorbar(data = data,
                        aes(x = year,
                            ymin = mean.cpue-se.cpue,
                            ymax = mean.cpue+se.cpue)) +
          geom_path(data = data,
                    aes(x = year,
                        y = settlement.1 / scaling_value),
                    colour = "red",
                    linetype = "dashed") +
          geom_point(data = data,
                     aes(x = year,
                         y = settlement.1 / scaling_value),
                     colour = "red",
                     shape = 17) +
          scale_y_continuous(sec.axis = sec_axis(~ . * scaling_value, name = "Lagged relative larval settlement")) +
          scale_x_continuous(breaks = seq(2008, 2018, 2)) +
          facet_wrap(vars(estuary.1)) +
          theme_bw() +
          theme(panel.grid = element_blank(),
                axis.text = element_text(size = 10, colour = "black"),
                axis.title = element_text(size = 12, colour = "black"),
                strip.background = element_blank(),
                strip.text = element_text(size = 10, colour = "black"),
                legend.text = element_text(size = 10, colour = "black"),
                axis.title.y.right = element_text(colour = "red")) +
          xlab("Year") +
          ylab(expression(paste("Mean catch-per-unit-effort (kg trap"^-1, ")"))) 
        
        patch <- plot_spacer()/plot_spacer()/plot_spacer()/bsc.grob
        p <- p + patch + plot_layout(widths = c(4, 1))
        
        p
        
      } else if (lag == 2){
        p <- ggplot() + 
          geom_path(data = data,
                    aes(x = year,
                        y = mean.cpue)) +
          geom_point(data = data,
                     aes(x = year,
                         y = mean.cpue)) +
          geom_errorbar(data = data,
                        aes(x = year,
                            ymin = mean.cpue-se.cpue,
                            ymax = mean.cpue+se.cpue)) +
          geom_path(data = data,
                    aes(x = year,
                        y = settlement.2 / scaling_value),
                    colour = "red",
                    linetype = "dashed") +
          geom_point(data = data,
                     aes(x = year,
                         y = settlement.2 / scaling_value),
                     colour = "red",
                     shape = 17) +
          scale_y_continuous(sec.axis = sec_axis(~ . * scaling_value, name = "Lagged relative larval settlement")) +
          scale_x_continuous(breaks = seq(2008, 2018, 2)) +
          facet_wrap(vars(estuary.1)) +
          theme_bw() +
          theme(panel.grid = element_blank(),
                axis.text = element_text(size = 10, colour = "black"),
                axis.title = element_text(size = 12, colour = "black"),
                strip.background = element_blank(),
                strip.text = element_text(size = 10, colour = "black"),
                legend.text = element_text(size = 10, colour = "black"),
                axis.title.y.right = element_text(colour = "red")) +
          xlab("Year") +
          ylab(expression(paste("Mean catch-per-unit-effort (kg trap"^-1, ")"))) 
        
        patch <- plot_spacer()/plot_spacer()/plot_spacer()/bsc.grob
        p <- p + patch + plot_layout(widths = c(4, 1))
        
        p
        
      } else if (lag == 3){
        p <- ggplot() + 
          geom_path(data = data,
                    aes(x = year,
                        y = mean.cpue)) +
          geom_point(data = data,
                     aes(x = year,
                         y = mean.cpue)) +
          geom_errorbar(data = data,
                        aes(x = year,
                            ymin = mean.cpue-se.cpue,
                            ymax = mean.cpue+se.cpue)) +
          geom_path(data = data,
                    aes(x = year,
                        y = settlement.3 / scaling_value),
                    colour = "red",
                    linetype = "dashed") +
          geom_point(data = data,
                     aes(x = year,
                         y = settlement.3 / scaling_value),
                     colour = "red",
                     shape = 17) +
          scale_y_continuous(sec.axis = sec_axis(~ . * scaling_value, name = "Lagged relative larval settlement")) +
          scale_x_continuous(breaks = seq(2008, 2018, 2)) +
          facet_wrap(vars(estuary.1)) +
          theme_bw() +
          theme(panel.grid = element_blank(),
                axis.text = element_text(size = 10, colour = "black"),
                axis.title = element_text(size = 12, colour = "black"),
                strip.background = element_blank(),
                strip.text = element_text(size = 10, colour = "black"),
                legend.text = element_text(size = 10, colour = "black"),
                axis.title.y.right = element_text(colour = "red")) +
          xlab("Year") +
          ylab(expression(paste("Mean catch-per-unit-effort (kg trap"^-1, ")"))) 
        
        patch <- plot_spacer()/plot_spacer()/plot_spacer()/bsc.grob
        p <- p + patch + plot_layout(widths = c(4, 1))
        
        p
      }
    }
  } else if (group == "egf"){
    if (species == "gmc"){
      scaling_value <- max(data$settlement, na.rm = T)/max(data$mean.cpue, na.rm = T)
      
      if (lag == 0){
        p <- ggplot() + 
          geom_path(data = data,
                    aes(x = year,
                        y = mean.cpue)) +
          geom_point(data = data,
                     aes(x = year,
                         y = mean.cpue)) +
          geom_errorbar(data = data,
                        aes(x = year,
                            ymin = mean.cpue-se.cpue,
                            ymax = mean.cpue+se.cpue)) +
          geom_path(data = data,
                    aes(x = year,
                        y = settlement / scaling_value),
                    colour = "red",
                    linetype = "dashed") +
          geom_point(data = data,
                     aes(x = year,
                         y = settlement / scaling_value),
                     colour = "red",
                     shape = 17) +
          scale_y_continuous(sec.axis = sec_axis(~ . * scaling_value, name = "Relative larval settlement")) +
          scale_x_continuous(breaks = seq(2008, 2018, 2),
                             labels = c("2008", "", "2012", "", "2016", "")) +
          facet_wrap(vars(mgmt.zone)) +
          theme_bw() +
          theme(panel.grid = element_blank(),
                axis.text = element_text(size = 10, colour = "black"),
                axis.title = element_text(size = 12, colour = "black"),
                strip.background = element_blank(),
                strip.text = element_text(size = 10, colour = "black"),
                legend.text = element_text(size = 10, colour = "black"),
                axis.title.y.right = element_text(colour = "red")) +
          xlab("Year") +
          ylab(expression(paste("Mean catch-per-unit-effort (kg trap"^-1, ")"))) +
          inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)
        
        p
        
      } else if (lag == 1){
        p <- ggplot() + 
          geom_path(data = data,
                    aes(x = year,
                        y = mean.cpue)) +
          geom_point(data = data,
                     aes(x = year,
                         y = mean.cpue)) +
          geom_errorbar(data = data,
                        aes(x = year,
                            ymin = mean.cpue-se.cpue,
                            ymax = mean.cpue+se.cpue)) +
          geom_path(data = data,
                    aes(x = year,
                        y = settlement.1 / scaling_value),
                    colour = "red",
                    linetype = "dashed") +
          geom_point(data = data,
                     aes(x = year,
                         y = settlement.1 / scaling_value),
                     colour = "red",
                     shape = 17) +
          scale_y_continuous(sec.axis = sec_axis(~ . * scaling_value, name = "Lagged relative larval settlement")) +
          scale_x_continuous(breaks = seq(2008, 2018, 2)) +
          facet_wrap(vars(mgmt.zone)) +
          theme_bw() +
          theme(panel.grid = element_blank(),
                axis.text = element_text(size = 10, colour = "black"),
                axis.title = element_text(size = 12, colour = "black"),
                strip.background = element_blank(),
                strip.text = element_text(size = 10, colour = "black"),
                legend.text = element_text(size = 10, colour = "black"),
                axis.title.y.right = element_text(colour = "red")) +
          xlab("Year") +
          ylab(expression(paste("Mean catch-per-unit-effort (kg trap"^-1, ")"))) +
          inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)
        
        p
        
      } else if (lag == 2){
        p <- ggplot() + 
          geom_path(data = data,
                    aes(x = year,
                        y = mean.cpue)) +
          geom_point(data = data,
                     aes(x = year,
                         y = mean.cpue)) +
          geom_errorbar(data = data,
                        aes(x = year,
                            ymin = mean.cpue-se.cpue,
                            ymax = mean.cpue+se.cpue)) +
          geom_path(data = data,
                    aes(x = year,
                        y = settlement.2 / scaling_value),
                    colour = "red",
                    linetype = "dashed") +
          geom_point(data = data,
                     aes(x = year,
                         y = settlement.2 / scaling_value),
                     colour = "red",
                     shape = 17) +
          scale_y_continuous(sec.axis = sec_axis(~ . * scaling_value, name = "Lagged relative larval settlement")) +
          scale_x_continuous(breaks = seq(2008, 2018, 2)) +
          facet_wrap(vars(mgmt.zone)) +
          theme_bw() +
          theme(panel.grid = element_blank(),
                axis.text = element_text(size = 10, colour = "black"),
                axis.title = element_text(size = 12, colour = "black"),
                strip.background = element_blank(),
                strip.text = element_text(size = 10, colour = "black"),
                legend.text = element_text(size = 10, colour = "black"),
                axis.title.y.right = element_text(colour = "red")) +
          xlab("Year") +
          ylab(expression(paste("Mean catch-per-unit-effort (kg trap"^-1, ")"))) +
          inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)
        
        p
        
      } else if (lag == 3){
        p <- ggplot() + 
          geom_path(data = data,
                    aes(x = year,
                        y = mean.cpue)) +
          geom_point(data = data,
                     aes(x = year,
                         y = mean.cpue)) +
          geom_errorbar(data = data,
                        aes(x = year,
                            ymin = mean.cpue-se.cpue,
                            ymax = mean.cpue+se.cpue)) +
          geom_path(data = data,
                    aes(x = year,
                        y = settlement.3 / scaling_value),
                    colour = "red",
                    linetype = "dashed") +
          geom_point(data = data,
                     aes(x = year,
                         y = settlement.3 / scaling_value),
                     colour = "red",
                     shape = 17) +
          scale_y_continuous(sec.axis = sec_axis(~ . * scaling_value, name = "Lagged relative larval settlement")) +
          scale_x_continuous(breaks = seq(2008, 2018, 2)) +
          facet_wrap(vars(mgmt.zone)) +
          theme_bw() +
          theme(panel.grid = element_blank(),
                axis.text = element_text(size = 10, colour = "black"),
                axis.title = element_text(size = 12, colour = "black"),
                strip.background = element_blank(),
                strip.text = element_text(size = 10, colour = "black"),
                legend.text = element_text(size = 10, colour = "black"),
                axis.title.y.right = element_text(colour = "red")) +
          xlab("Year") +
          ylab(expression(paste("Mean catch-per-unit-effort (kg trap"^-1, ")"))) +
          inset_element(gmc.grob, left = 0.75, bottom = 0, right = 1, top = 0.3)
        
        p
        
      }
      
    } else if (species == "bsc"){
      scaling_value <- max(data$settlement, na.rm = T)/max(data$mean.cpue, na.rm = T)
      
      if (lag == 0){
        p <- ggplot() + 
          geom_path(data = data,
                    aes(x = year,
                        y = mean.cpue)) +
          geom_point(data = data,
                     aes(x = year,
                         y = mean.cpue)) +
          geom_errorbar(data = data,
                        aes(x = year,
                            ymin = mean.cpue-se.cpue,
                            ymax = mean.cpue+se.cpue)) +
          geom_path(data = data,
                    aes(x = year,
                        y = settlement / scaling_value),
                    colour = "red",
                    linetype = "dashed") +
          geom_point(data = data,
                     aes(x = year,
                         y = settlement / scaling_value),
                     colour = "red",
                     shape = 17) +
          scale_y_continuous(sec.axis = sec_axis(~ . * scaling_value, name = "Relative larval settlement")) +
          scale_x_continuous(breaks = seq(2008, 2018, 2),
                             labels = c("2008", "", "2012", "", "2016", "")) +
          facet_wrap(vars(mgmt.zone)) +
          theme_bw() +
          theme(panel.grid = element_blank(),
                axis.text = element_text(size = 10, colour = "black"),
                axis.title = element_text(size = 12, colour = "black"),
                strip.background = element_blank(),
                strip.text = element_text(size = 10, colour = "black"),
                legend.text = element_text(size = 10, colour = "black"),
                axis.title.y.right = element_text(colour = "red")) +
          xlab("Year") +
          ylab(expression(paste("Mean catch-per-unit-effort (kg trap"^-1, ")"))) 
        
        patch <- plot_spacer()/plot_spacer()/plot_spacer()/bsc.grob
        p <- p + patch + plot_layout(widths = c(4, 1))
        
        p
        
      } else if (lag == 1){
        p <- ggplot() + 
          geom_path(data = data,
                    aes(x = year,
                        y = mean.cpue)) +
          geom_point(data = data,
                     aes(x = year,
                         y = mean.cpue)) +
          geom_errorbar(data = data,
                        aes(x = year,
                            ymin = mean.cpue-se.cpue,
                            ymax = mean.cpue+se.cpue)) +
          geom_path(data = data,
                    aes(x = year,
                        y = settlement.1 / scaling_value),
                    colour = "red",
                    linetype = "dashed") +
          geom_point(data = data,
                     aes(x = year,
                         y = settlement.1 / scaling_value),
                     colour = "red",
                     shape = 17) +
          scale_y_continuous(sec.axis = sec_axis(~ . * scaling_value, name = "Lagged relative larval settlement")) +
          scale_x_continuous(breaks = seq(2008, 2018, 2)) +
          facet_wrap(vars(mgmt.zone)) +
          theme_bw() +
          theme(panel.grid = element_blank(),
                axis.text = element_text(size = 10, colour = "black"),
                axis.title = element_text(size = 12, colour = "black"),
                strip.background = element_blank(),
                strip.text = element_text(size = 10, colour = "black"),
                legend.text = element_text(size = 10, colour = "black"),
                axis.title.y.right = element_text(colour = "red")) +
          xlab("Year") +
          ylab(expression(paste("Mean catch-per-unit-effort (kg trap"^-1, ")"))) 
        
        patch <- plot_spacer()/plot_spacer()/plot_spacer()/bsc.grob
        p <- p + patch + plot_layout(widths = c(4, 1))
        
        p
        
      } else if (lag == 2){
        p <- ggplot() + 
          geom_path(data = data,
                    aes(x = year,
                        y = mean.cpue)) +
          geom_point(data = data,
                     aes(x = year,
                         y = mean.cpue)) +
          geom_errorbar(data = data,
                        aes(x = year,
                            ymin = mean.cpue-se.cpue,
                            ymax = mean.cpue+se.cpue)) +
          geom_path(data = data,
                    aes(x = year,
                        y = settlement.2 / scaling_value),
                    colour = "red",
                    linetype = "dashed") +
          geom_point(data = data,
                     aes(x = year,
                         y = settlement.2 / scaling_value),
                     colour = "red",
                     shape = 17) +
          scale_y_continuous(sec.axis = sec_axis(~ . * scaling_value, name = "Lagged relative larval settlement")) +
          scale_x_continuous(breaks = seq(2008, 2018, 2)) +
          facet_wrap(vars(mgmt.zone)) +
          theme_bw() +
          theme(panel.grid = element_blank(),
                axis.text = element_text(size = 10, colour = "black"),
                axis.title = element_text(size = 12, colour = "black"),
                strip.background = element_blank(),
                strip.text = element_text(size = 10, colour = "black"),
                legend.text = element_text(size = 10, colour = "black"),
                axis.title.y.right = element_text(colour = "red")) +
          xlab("Year") +
          ylab(expression(paste("Mean catch-per-unit-effort (kg trap"^-1, ")"))) 
        
        patch <- plot_spacer()/plot_spacer()/plot_spacer()/bsc.grob
        p <- p + patch + plot_layout(widths = c(4, 1))
        
        p
        
      } else if (lag == 3){
        p <- ggplot() + 
          geom_path(data = data,
                    aes(x = year,
                        y = mean.cpue)) +
          geom_point(data = data,
                     aes(x = year,
                         y = mean.cpue)) +
          geom_errorbar(data = data,
                        aes(x = year,
                            ymin = mean.cpue-se.cpue,
                            ymax = mean.cpue+se.cpue)) +
          geom_path(data = data,
                    aes(x = year,
                        y = settlement.3 / scaling_value),
                    colour = "red",
                    linetype = "dashed") +
          geom_point(data = data,
                     aes(x = year,
                         y = settlement.3 / scaling_value),
                     colour = "red",
                     shape = 17) +
          scale_y_continuous(sec.axis = sec_axis(~ . * scaling_value, name = "Lagged relative larval settlement")) +
          scale_x_continuous(breaks = seq(2008, 2018, 2)) +
          facet_wrap(vars(mgmt.zone)) +
          theme_bw() +
          theme(panel.grid = element_blank(),
                axis.text = element_text(size = 10, colour = "black"),
                axis.title = element_text(size = 12, colour = "black"),
                strip.background = element_blank(),
                strip.text = element_text(size = 10, colour = "black"),
                legend.text = element_text(size = 10, colour = "black"),
                axis.title.y.right = element_text(colour = "red")) +
          xlab("Year") +
          ylab(expression(paste("Mean catch-per-unit-effort (kg trap"^-1, ")"))) 
        
        patch <- plot_spacer()/plot_spacer()/plot_spacer()/bsc.grob
        p <- p + patch + plot_layout(widths = c(4, 1))
        
        p
      }
    }
  }
  
}
  