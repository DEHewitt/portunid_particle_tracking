# NSW Independent survey data
library(digitize)

# Run line below then click on 2 points on the x-axis followed 
# by 2 points on y-axis for calibration
cal <- ReadAndCal("NSW FIS plot.jpg")

# Run line below then click on all points you are interested in 
# then press Esc button
GI <- DigitData(col = 'red') # GI for Gonad Index, change at will

# Run the calibration through the points
data <- Calibrate(GI, cal, 2005, 2018, 0, 50)

# List the y values (eg: if you want to extract them)
write.table(data$y)

# Plot it up!!! - This will do connected line graph
plot(data$x, data$y, pch=20, col='black',
     type = "o",
     xlab ='Year',
     ylab ='CPUE')

export <- data.frame("Year" = seq(2005, 2018,1),
           FIS_CPUE_all = data$y)

# Repeat for legal size only (green)
# Run line below then click on 2 points on the x-axis followed 
# by 2 points on y-axis for calibration
cal <- ReadAndCal("NSW FIS plot.jpg")

# Run line below then click on all points you are interested in 
# then press Esc button
GI <- DigitData(col = 'red') # GI for Gonad Index, change at will

# Run the calibration through the points
data <- Calibrate(GI, cal, 2005, 2018, 0, 50)

# List the y values (eg: if you want to extract them)
write.table(data$y)

export$FIS_CPUE_legal <- data$y

# Repeat for sub-legal size only (brown)
# Run line below then click on 2 points on the x-axis followed 
# by 2 points on y-axis for calibration
cal <- ReadAndCal("NSW FIS plot.jpg")

# Run line below then click on all points you are interested in 
# then press Esc button
GI <- DigitData(col = 'red') # GI for Gonad Index, change at will

# Run the calibration through the points
data <- Calibrate(GI, cal, 2005, 2018, 0, 50)

# List the y values (eg: if you want to extract them)
write.table(data$y)

export$FIS_CPUE_sublegal <- data$y

library(tidyverse)
write_csv(export, "NSW FIS data digitised.csv")
