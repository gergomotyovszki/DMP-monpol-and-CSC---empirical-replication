library(forecast)
library(readxl)
library(plyr)
library(xlsx)


## Replacing outliers with Kalman filter imputations.

# hrlwage_ed_industry_1
#hrlwage_ed_industry_1 <- read_excel("~/Downloads/replication files/clean data/hrlwage_ed_industry_1.xlsx")
hrlwage_ed_industry_1 <- read_excel("C:/Users/gmotyovs/Downloads/replication files/clean data/morg1979_2016_final.xlsx")
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
#write.xlsx(data, path.expand("~/Downloads/replication files/clean data/hrlwage_ed_industry_1_kalman.xlsx")) #Exporting series
write.xlsx(data, path.expand("C:/Users/gmotyovs/Downloads/replication files/clean data/hrlwage_ed_industry_1_kalman.xlsx")) #Exporting series


# hrlwage_noed_industry_1
# hrlwage_noed_industry_1 <- read_excel("~/Downloads/replication files/clean data/hrlwage_noed_industry_1.xlsx")
hrlwage_noed_industry_1 <- read_excel("C:/Users/gmotyovs/Downloads/replication files/clean data/morg1979_2016_final.xlsx")
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
#write.xlsx(data, path.expand("~/Downloads/replication files/clean data/hrlwage_noed_industry_1_kalman.xlsx")) #Exporting series
write.xlsx(data, path.expand("C:/Users/gmotyovs/Downloads/replication files/clean data/hrlwage_noed_industry_1_kalman.xlsx")) #Exporting series

# hrlwage_ed_industry_2
#hrlwage_ed_industry_2 <- read_excel("~/Downloads/replication files/clean data/hrlwage_ed_industry_2.xlsx")
hrlwage_ed_industry_2 <- read_excel("C:/Users/gmotyovs/Downloads/replication files/clean data/morg1979_2016_final.xlsx")
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
#write.xlsx(data, path.expand("~/Downloads/replication files/clean data/hrlwage_ed_industry_2_kalman.xlsx")) #Exporting series
write.xlsx(data, path.expand("C:/Users/gmotyovs/Downloads/replication files/clean data/hrlwage_ed_industry_2_kalman.xlsx")) #Exporting series


# hrlwage_noed_industry_2
#hrlwage_noed_industry_2 <- read_excel("~/Downloads/replication files/clean data/hrlwage_noed_industry_2.xlsx")
hrlwage_noed_industry_2 <- read_excel("C:/Users/gmotyovs/Downloads/replication files/clean data/morg1979_2016_final.xlsx")
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
#write.xlsx(data, path.expand("~/Downloads/replication files/clean data/hrlwage_noed_industry_2_kalman.xlsx")) #Exporting series
write.xlsx(data, path.expand("C:/Users/gmotyovs/Downloads/replication files/clean data/hrlwage_noed_industry_2_kalman.xlsx")) #Exporting series


# hrlwage_ed_industry_3
#hrlwage_ed_industry_3 <- read_excel("~/Downloads/replication files/clean data/hrlwage_ed_industry_3.xlsx")
hrlwage_ed_industry_3 <- read_excel("C:/Users/gmotyovs/Downloads/replication files/clean data/morg1979_2016_final.xlsx")
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
#write.xlsx(data, path.expand("~/Downloads/replication files/clean data/hrlwage_ed_industry_3_kalman.xlsx")) #Exporting series
write.xlsx(data, path.expand("C:/Users/gmotyovs/Downloads/replication files/clean data/hrlwage_ed_industry_3_kalman.xlsx")) #Exporting series


# hrlwage_noed_industry_3
#hrlwage_noed_industry_3 <- read_excel("~/Downloads/replication files/clean data/hrlwage_noed_industry_3.xlsx")
hrlwage_noed_industry_3 <- read_excel("C:/Users/gmotyovs/Downloads/replication files/clean data/morg1979_2016_final.xlsx")
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
#write.xlsx(data, path.expand("~/Downloads/replication files/clean data/hrlwage_noed_industry_3_kalman.xlsx")) #Exporting series
write.xlsx(data, path.expand("C:/Users/gmotyovs/Downloads/replication files/clean data/hrlwage_noed_industry_3_kalman.xlsx")) #Exporting series


# hrlwage_noed_industry_4
#hrlwage_noed_industry_4 <- read_excel("~/Downloads/replication files/clean data/hrlwage_noed_industry_4.xlsx")
hrlwage_noed_industry_4 <- read_excel("C:/Users/gmotyovs/Downloads/replication files/clean data/morg1979_2016_final.xlsx")
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
#write.xlsx(data, path.expand("~/Downloads/replication files/clean data/hrlwage_noed_industry_4_kalman.xlsx")) #Exporting series
write.xlsx(data, path.expand("C:/Users/gmotyovs/Downloads/replication files/clean data/hrlwage_noed_industry_4_kalman.xlsx")) #Exporting series


# hrlwage_ed_industry_5
#hrlwage_ed_industry_5 <- read_excel("~/Downloads/replication files/clean data/hrlwage_ed_industry_5.xlsx")
hrlwage_ed_industry_5 <- read_excel("C:/Users/gmotyovs/Downloads/replication files/clean data/morg1979_2016_final.xlsx")
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
#write.xlsx(data, path.expand("~/Downloads/replication files/clean data/hrlwage_ed_industry_5_kalman.xlsx")) #Exporting series
write.xlsx(data, path.expand("C:/Users/gmotyovs/Downloads/replication files/clean data/hrlwage_ed_industry_5_kalman.xlsx")) #Exporting series


# hrlwage_noed_industry_5
#hrlwage_noed_industry_5 <- read_excel("~/Downloads/replication files/clean data/hrlwage_noed_industry_5.xlsx")
hrlwage_noed_industry_5 <- read_excel("C:/Users/gmotyovs/Downloads/replication files/clean data/morg1979_2016_final.xlsx")
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
#write.xlsx(data, path.expand("~/Downloads/replication files/clean data/hrlwage_noed_industry_5_kalman.xlsx")) #Exporting series
write.xlsx(data, path.expand("C:/Users/gmotyovs/Downloads/replication files/clean data/hrlwage_noed_industry_5_kalman.xlsx")) #Exporting series


# hrlwage_ed_industry_6
#hrlwage_ed_industry_6 <- read_excel("~/Downloads/replication files/clean data/hrlwage_ed_industry_6.xlsx")
hrlwage_ed_industry_6 <- read_excel("C:/Users/gmotyovs/Downloads/replication files/clean data/morg1979_2016_final.xlsx")
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
#write.xlsx(data, path.expand("~/Downloads/replication files/clean data/hrlwage_ed_industry_6_kalman.xlsx")) #Exporting series
write.xlsx(data, path.expand("C:/Users/gmotyovs/Downloads/replication files/clean data/hrlwage_ed_industry_6_kalman.xlsx")) #Exporting series


# hrlwage_noed_industry_6
#hrlwage_noed_industry_6 <- read_excel("~/Downloads/replication files/clean data/hrlwage_noed_industry_6.xlsx")
hrlwage_noed_industry_6 <- read_excel("C:/Users/gmotyovs/Downloads/replication files/clean data/morg1979_2016_final.xlsx")
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
#write.xlsx(data, path.expand("~/Downloads/replication files/clean data/hrlwage_noed_industry_6_kalman.xlsx")) #Exporting series
write.xlsx(data, path.expand("C:/Users/gmotyovs/Downloads/replication files/clean data/hrlwage_noed_industry_6_kalman.xlsx")) #Exporting series

