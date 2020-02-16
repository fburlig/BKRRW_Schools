# grab the necessary packages
library(stats)
library("crayon", lib="T:/Projects/Schools/RLibraries")
library("lubridate", lib="T:/Projects/Schools/RLibraries")
library("parallel", lib="T:/Projects/Schools/RLibraries")
library("haven", lib="T:/Projects/Schools/RLibraries")
library("dplyr", lib="T:/Projects/Schools/RLibraries")
library("tibble", lib="T:/Projects/Schools/RLibraries")
library("readstata13", lib="T:/Projects/Schools/RLibraries")
library("splines", lib="T:/Projects/Schools/RLibraries")
library("Matrix", lib="T:/Projects/Schools/RLibraries")
library("glmnet", lib="T:/Projects/Schools/RLibraries")
library("randomForest", lib="T:/Projects/Schools/RLibraries")
library("fread", lib="T:/Projects/Schools/RLibraries")

setwd("T:/Projects/Schools/Data")
set.seed(12345)

#### SET UP PARALLEL STUFF
myCores <- 12
cl <- makeCluster(myCores)
clusterEvalQ(cl, library(stats))
clusterEvalQ(cl, library("crayon", lib="T:/Projects/Schools/RLibraries"))
clusterEvalQ(cl, library("lubridate", lib="T:/Projects/Schools/RLibraries"))
clusterEvalQ(cl, library("haven", lib="T:/Projects/Schools/RLibraries"))
clusterEvalQ(cl, library("dplyr", lib="T:/Projects/Schools/RLibraries"))
clusterEvalQ(cl, library("tibble", lib="T:/Projects/Schools/RLibraries"))
clusterEvalQ(cl, library("Matrix", lib="T:/Projects/Schools/RLibraries"))
clusterEvalQ(cl, library("glmnet", lib="T:/Projects/Schools/RLibraries"))
clusterEvalQ(cl, library("splines", lib="T:/Projects/Schools/RLibraries"))
clusterEvalQ(cl, library("readstata13", lib="T:/Projects/Schools/RLibraries"))
clusterEvalQ(cl, library("randomForest", lib="T:/Projects/Schools/RLibraries"))

# set the cluster seed
clusterSetRNGStream(cl, 12345)

dataset_h <- read.csv("Other Data/SunriseSunsetHoliday/holiday.csv")
dataset_h$date <- as.Date(dataset_h$date)
dataset_h$weekid <-paste0(lubridate::isoyear(dataset_h$date),lubridate::isoweek(dataset_h$date))

estimateModel <- function(i) {

  samplesize <- runif(1, 0.2, 0.8)
  
  ### READ DATA
  dataset = read.dta13(paste0("Intermediate/School specific/school_data_block_",i,".dta"))
  
  # cleaning
  dataset <- dataset[dataset$problematic_obs==0,]
  dataset <- dataset[dataset$qkw_hour>0,]
  dataset <- dataset[is.na(dataset$temp_f)==FALSE,]
  dataset <- dataset[is.nan(dataset$temp_f)==FALSE,]
  dataset$date <- as.Date(dataset$date,origin="1960-01-01")

  # merge datasets in
  dataset <- left_join(dataset,dataset_h,by="date")
  
  # generate additional variables
  dataset$weekday <- weekdays(dataset$date)
  dataset$weekday <- as.numeric(factor(dataset$weekday))
  dataset$holiday <- as.numeric(dataset$holiday)
  
  # identify as treatment or control
  dataset$post_treat <- dataset$any_post_treat
  index=1:nrow(dataset)
  if (mean(dataset$post_treat)==0) {
    trainindex <- index[index<nrow(dataset)*samplesize]
    print('control')
  } else {
    trainindex <- index[dataset$post_treat==0]
    print('treatment')
  }
  dataset$post_treat[-trainindex]=1
  summary(dataset)
 
  # clean up missing
  missing <- sapply(dataset, function(x) sum(is.na(x)))
  dataset <- dataset[names(dataset)[missing==0]]
  missing <- sapply(dataset, function(x) sum(is.nan(x)))
  dataset <- dataset[names(dataset)[missing==0]]
  
  dataset$prediction_error9 <- NA
  dataset$prediction_treat_error9 <- NA
  dataset$splitting <- NA
  
  # randomForest
  N = nrow(dataset)
  I=sort(sample(1:N,N/2))
  IC=setdiff(1:N,I)
 
  myvars <- c("qkw_hour", "block", "temp_f", "holiday", "weekday", "month")
  dataset_forest <- dataset[myvars]
  model1 = randomForest(qkw_hour ~ .,data=dataset_forest[IC,],na.action=na.omit, max.nodes=100)
  model2 = randomForest(qkw_hour ~ .,data=dataset_forest[I,],na.action=na.omit, max.nodes=100)
  G1=predict(model1,dataset_forest[I,])
  G2=predict(model2,dataset_forest[IC,])
  dataset$prediction_error9[I] <- dataset_forest$qkw_hour[I] - G1
  dataset$prediction_error9[IC] <- dataset_forest$qkw_hour[IC] - G2
  
  myvars <- c("post_treat", "block", "temp_f", "holiday", "weekday", "month")
  dataset_forest <- dataset[myvars]
  dataset_forest$post_treat <- as.numeric(dataset_forest$post_treat)
  modeld1 = randomForest(post_treat ~ .,data=dataset_forest[IC,],na.action=na.omit, max.nodes=100)
  modeld2 = randomForest(post_treat ~ .,data=dataset_forest[I,],na.action=na.omit, max.nodes=100)
  M1=predict(modeld1,dataset_forest[I,])
  M2=predict(modeld2,dataset_forest[IC,])
  dataset$prediction_treat_error9[I] <-  dataset_forest[I,]$post_treat - M1
  dataset$prediction_treat_error9[IC] <- dataset_forest[IC,]$post_treat - M2
  
  dataset$splitting[I] <- 1
  dataset$splitting[IC] <- 2
  
  myvars <- c("school_id", "date", "block", "post_treat", "splitting", "prediction_error9", "prediction_treat_error9")
  dataset <- dataset[myvars]
  
  write.csv(dataset,file=paste0("Intermediate/School specific/forest/school_data_",i,"_prediction_dl.csv"), row.names=FALSE)
  
  return(i)
  
}

clusterExport(cl, "estimateModel")
clusterExport(cl, "dataset_h")

parSapply(cl, 1:2400, function(i){
  try(estimateModel(i))
}
)

stopCluster(cl)

library(foreign)
setwd("T:/Projects/Schools/Data/Intermediate/School specific/forest/")
files <- list.files(pattern="*_dl.csv")
  combined_files <-  bind_rows(lapply(files, read.table, sep=",", header=TRUE))
  write.dta(combined_files, "T:/Projects/Schools/Data/Intermediate/schools_predictions_forest_dl.dta")
