library(forecast)
library(readxl)
library(plyr)
library(xlsx)

basedir = dirname(rstudioapi::getSourceEditorContext()$path)
inputfile = paste(basedir, '/clean data/morg1979_2016_final.xlsx', sep="")

## Replacing outliers with Kalman filter imputations.

# hrlwage_ed_industry_1

hrlwage_ed_industry_1 <- read_excel(inputfile)
data<-ts(hrlwage_ed_industry_1$hrlwage_ed_industry_1, start=1979, frequency=12) 
data[c(337,455)] <- NA #replacing outliers with missing for the series
arimaModel <- auto.arima(data)
model <- arimaModel$model
#Kalman smoothing
kal <- KalmanSmooth(data, model)
erg <- kal$smooth  
for ( i in 1:length(model$Z)) {
  erg[,i] = erg[,i] * model$Z[i]
}
karima <-rowSums(erg)
for (i in 1:length(data)) {
  if (is.na(data[i])) {
    data[i] <- karima[i]
  }
}
plot(data)
outputfile_1_ed = paste(basedir, '/clean data/hrlwage_ed_industry_1_kalman.xlsx', sep="")

write.xlsx(data, path.expand(outputfile_1_ed)) #Exporting series


# hrlwage_noed_industry_1

hrlwage_noed_industry_1 <- read_excel(inputfile)
data<-ts(hrlwage_noed_industry_1$hrlwage_noed_industry_1, start=1979, frequency=12) 
data[c(339)] <- NA #replacing outliers with missing for the series
arimaModel <- auto.arima(data)
model <- arimaModel$model
#Kalman smoothing
kal <- KalmanSmooth(data, model)
erg <- kal$smooth  
for ( i in 1:length(model$Z)) {
  erg[,i] = erg[,i] * model$Z[i]
}
karima <-rowSums(erg)
for (i in 1:length(data)) {
  if (is.na(data[i])) {
    data[i] <- karima[i]
  }
}
plot(data)
outputfile_1_noed = paste(basedir, '/clean data/hrlwage_noed_industry_1_kalman.xlsx', sep="")

write.xlsx(data, path.expand(outputfile_1_noed))

# hrlwage_ed_industry_2

hrlwage_ed_industry_2 <- read_excel(inputfile)
data<-ts(hrlwage_ed_industry_2$hrlwage_ed_industry_2, start=1979, frequency=12) 
data[c(348)] <- NA #replacing outliers with missing for the series
arimaModel <- auto.arima(data)
model <- arimaModel$model
#Kalman smoothing
kal <- KalmanSmooth(data, model)
erg <- kal$smooth  
for ( i in 1:length(model$Z)) {
  erg[,i] = erg[,i] * model$Z[i]
}
karima <-rowSums(erg)
for (i in 1:length(data)) {
  if (is.na(data[i])) {
    data[i] <- karima[i]
  }
}
plot(data)
outputfile_2_ed = paste(basedir, '/clean data/hrlwage_ed_industry_2_kalman.xlsx', sep="")

write.xlsx(data, path.expand(outputfile_2_ed))


# hrlwage_noed_industry_2

hrlwage_noed_industry_2 <- read_excel(inputfile)
data<-ts(hrlwage_noed_industry_2$hrlwage_noed_industry_2, start=1979, frequency=12) 
data[c(341,342,355)] <- NA #replacing outliers with missing for the series
arimaModel <- auto.arima(data)
model <- arimaModel$model
#Kalman smoothing
kal <- KalmanSmooth(data, model)
erg <- kal$smooth  
for ( i in 1:length(model$Z)) {
  erg[,i] = erg[,i] * model$Z[i]
}
karima <-rowSums(erg)
for (i in 1:length(data)) {
  if (is.na(data[i])) {
    data[i] <- karima[i]
  }
}
plot(data)
outputfile_2_noed = paste(basedir, '/clean data/hrlwage_noed_industry_2_kalman.xlsx', sep="")

write.xlsx(data, path.expand(outputfile_2_noed))


# hrlwage_ed_industry_3

hrlwage_ed_industry_3 <- read_excel(inputfile)
data<-ts(hrlwage_ed_industry_3$hrlwage_ed_industry_3, start=1979, frequency=12) 
data[data>=30]=NA #replacing outliers with missing for the series
arimaModel <- auto.arima(data)
model <- arimaModel$model
#Kalman smoothing
kal <- KalmanSmooth(data, model)
erg <- kal$smooth  
for ( i in 1:length(model$Z)) {
  erg[,i] = erg[,i] * model$Z[i]
}
karima <-rowSums(erg)
for (i in 1:length(data)) {
  if (is.na(data[i])) {
    data[i] <- karima[i]
  }
}
plot(data)
outputfile_3_ed = paste(basedir, '/clean data/hrlwage_ed_industry_3_kalman.xlsx', sep="")

write.xlsx(data, path.expand(outputfile_3_ed))


# hrlwage_noed_industry_3

hrlwage_noed_industry_3 <- read_excel(inputfile)
data<-ts(hrlwage_noed_industry_3$hrlwage_noed_industry_3, start=1979, frequency=12) 
data[c(379,396,406,449)] <- NA #replacing outliers with missing for the series
arimaModel <- auto.arima(data)
model <- arimaModel$model
#Kalman smoothing
kal <- KalmanSmooth(data, model)
erg <- kal$smooth  
for ( i in 1:length(model$Z)) {
  erg[,i] = erg[,i] * model$Z[i]
}
karima <-rowSums(erg)
for (i in 1:length(data)) {
  if (is.na(data[i])) {
    data[i] <- karima[i]
  }
}
plot(data)
outputfile_3_noed = paste(basedir, '/clean data/hrlwage_noed_industry_3_kalman.xlsx', sep="")

write.xlsx(data, path.expand(outputfile_3_noed))


# hrlwage_noed_industry_4

hrlwage_noed_industry_4 <- read_excel(inputfile)
data<-ts(hrlwage_noed_industry_4$hrlwage_noed_industry_4, start=1979, frequency=12) 
data[c(181,321,350,442)] <- NA #replacing outliers with missing for the series
arimaModel <- auto.arima(data)
model <- arimaModel$model
#Kalman smoothing
kal <- KalmanSmooth(data, model)
erg <- kal$smooth  
for ( i in 1:length(model$Z)) {
  erg[,i] = erg[,i] * model$Z[i]
}
karima <-rowSums(erg)
for (i in 1:length(data)) {
  if (is.na(data[i])) {
    data[i] <- karima[i]
  }
}
plot(data)
outputfile_4_noed = paste(basedir, '/clean data/hrlwage_noed_industry_4_kalman.xlsx', sep="")

write.xlsx(data, path.expand(outputfile_4_noed))


# hrlwage_ed_industry_5

hrlwage_ed_industry_5 <- read_excel(inputfile)
data<-ts(hrlwage_ed_industry_5$hrlwage_ed_industry_5, start=1979, frequency=12) 
data[c(359)] <- NA #replacing outliers with missing for the series
arimaModel <- auto.arima(data)
model <- arimaModel$model
#Kalman smoothing
kal <- KalmanSmooth(data, model)
erg <- kal$smooth  
for ( i in 1:length(model$Z)) {
  erg[,i] = erg[,i] * model$Z[i]
}
karima <-rowSums(erg)
for (i in 1:length(data)) {
  if (is.na(data[i])) {
    data[i] <- karima[i]
  }
}
plot(data)
outputfile_5_ed = paste(basedir, '/clean data/hrlwage_ed_industry_5_kalman.xlsx', sep="")

write.xlsx(data, path.expand(outputfile_5_ed))


# hrlwage_noed_industry_5

hrlwage_noed_industry_5 <- read_excel(inputfile)
data<-ts(hrlwage_noed_industry_5$hrlwage_noed_industry_5, start=1979, frequency=12) 
data[c(176,194,226,427,455)] <- NA #replacing outliers with missing for the series
arimaModel <- auto.arima(data)
model <- arimaModel$model
#Kalman smoothing
kal <- KalmanSmooth(data, model)
erg <- kal$smooth  
for ( i in 1:length(model$Z)) {
  erg[,i] = erg[,i] * model$Z[i]
}
karima <-rowSums(erg)
for (i in 1:length(data)) {
  if (is.na(data[i])) {
    data[i] <- karima[i]
  }
}
plot(data)
outputfile_5_noed = paste(basedir, '/clean data/hrlwage_noed_industry_5_kalman.xlsx', sep="")

write.xlsx(data, path.expand(outputfile_5_noed))


# hrlwage_ed_industry_6

hrlwage_ed_industry_6 <- read_excel(inputfile)
data<-ts(hrlwage_ed_industry_6$hrlwage_ed_industry_6, start=1979, frequency=12) 
data[c(409)] <- NA #replacing outliers with missing for the series
arimaModel <- auto.arima(data)
model <- arimaModel$model
#Kalman smoothing
kal <- KalmanSmooth(data, model)
erg <- kal$smooth  
for ( i in 1:length(model$Z)) {
  erg[,i] = erg[,i] * model$Z[i]
}
karima <-rowSums(erg)
for (i in 1:length(data)) {
  if (is.na(data[i])) {
    data[i] <- karima[i]
  }
}
plot(data)
outputfile_6_ed = paste(basedir, '/clean data/hrlwage_ed_industry_6_kalman.xlsx', sep="")

write.xlsx(data, path.expand(outputfile_6_ed))


# hrlwage_noed_industry_6

hrlwage_noed_industry_6 <- read_excel(inputfile)
data<-ts(hrlwage_noed_industry_6$hrlwage_noed_industry_6, start=1979, frequency=12) 
data[c(165)] <- NA #replacing outliers with missing for the series
arimaModel <- auto.arima(data)
model <- arimaModel$model
#Kalman smoothing
kal <- KalmanSmooth(data, model)
erg <- kal$smooth  
for ( i in 1:length(model$Z)) {
  erg[,i] = erg[,i] * model$Z[i]
}
karima <-rowSums(erg)
for (i in 1:length(data)) {
  if (is.na(data[i])) {
    data[i] <- karima[i]
  }
}
plot(data)
outputfile_6_noed = paste(basedir, '/clean data/hrlwage_noed_industry_6_kalman.xlsx', sep="")

write.xlsx(data, path.expand(outputfile_6_noed))

