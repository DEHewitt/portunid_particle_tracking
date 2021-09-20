cpue_corr <- function(data){
  # data is the joined settlement and cpue
  
  corr <- data %>%
    split(.$estuary) %>%  
    map(~ corr.test(.$mean.cpue, .$settlement,
                    use = "pairwise",
                    method = "pearson",
                    adjust = "bonferroni",
                    alpha = 0.05,
                    ci = TRUE))
  
  corr.1 <- data %>%
    split(.$estuary) %>%  
    map(~ corr.test(.$mean.cpue, .$settlement.1,
                    use = "pairwise",
                    method = "pearson",
                    adjust = "bonferroni",
                    alpha = 0.05,
                    ci = TRUE))
  
  corr.2 <- data %>%
    split(.$estuary) %>%  
    map(~ corr.test(.$mean.cpue, .$settlement.2,
                    use = "pairwise",
                    method = "pearson",
                    adjust = "bonferroni",
                    alpha = 0.05,
                    ci = TRUE))
  
  corr.3 <- data %>%
    split(.$estuary) %>%  
    map(~ corr.test(.$mean.cpue, .$settlement.3,
                    use = "pairwise",
                    method = "pearson",
                    adjust = "bonferroni",
                    alpha = 0.05,
                    ci = TRUE))
  r <- NULL
  p <- NULL
  r1 <- NULL
  p1 <- NULL
  r2 <- NULL
  p2 <- NULL
  r3 <- NULL
  p3 <- NULL
  names <- NULL
  
  for (a in 1:length(names(corr.1))){
    temp_name <- data.frame(name = names(corr.1[a]))
    temp_r <- data.frame(r = corr[[a]]$r)
    temp_p <- data.frame(p = corr[[a]]$p.adj)
    temp_r1 <- data.frame(r1 = corr.1[[a]]$r)
    temp_p1 <- data.frame(p1 = corr.1[[a]]$p.adj)
    temp_r2 <- data.frame(r2 = corr.2[[a]]$r)
    temp_p2 <- data.frame(p2 = corr.2[[a]]$p.adj)
    temp_r3 <- data.frame(r3 = corr.3[[a]]$r)
    temp_p3 <- data.frame(p3 = corr.3[[a]]$p.adj)
    
    r <- bind_rows(r, temp_r)
    p <- bind_rows(p, temp_p)
    r1 <- bind_rows(r1, temp_r1)
    p1 <- bind_rows(p1, temp_p1)
    r2 <- bind_rows(r2, temp_r2)
    p2 <- bind_rows(p2, temp_p2)
    r3 <- bind_rows(r3, temp_r3)
    p3 <- bind_rows(p3, temp_p3)
    names <- bind_rows(names, temp_name)
    
    x <- bind_cols(names, r, p, r1, p1, r2, p2, r3, p3)
  }
  x
}
