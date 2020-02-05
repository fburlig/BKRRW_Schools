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

setwd("T:/Projects/Schools/Data")
set.seed(12345)

#### SET UP PARALLEL STUFF
myCores <- 6
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
  
  # clean up missing
  missing <- sapply(dataset, function(x) sum(is.na(x)))
  dataset <- dataset[names(dataset)[missing==0]]
  
  # generate additional variables
  dataset$weekday <- weekdays(dataset$date)

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
  
  summary(dataset)
  
  # randomForest
  myvars <- c("qkw_hour", "block", "temp_f", "holiday", "weekday", "month")
  dataset_forest <- dataset[myvars]
  dataset_forest$weekday <- as.numeric(factor(dataset_forest$weekday))
  dataset_forest$holiday <- as.numeric(dataset_forest$holiday)
  
  base_forest <- dataset_forest[trainindex,]
  
  model_forest <- randomForest(qkw_hour ~ .,data=base_forest,na.action=na.omit)
  dataset$prediction8 <- predict(model_forest, dataset_forest)
  
  model_forest_log <- randomForest(log(qkw_hour) ~ .,data=base_forest,na.action=na.omit)
  dataset$prediction_log8 <- predict(model_forest_log, dataset_forest)
  
  
  # store results
  dataset$trainindex <- 0
  dataset$trainindex[trainindex] <- 1
  
  myvars <- c("school_id", "date", "block", "trainindex", "prediction8", "prediction_log8")
  dataset <- dataset[myvars]
  
  write.csv(dataset,file=paste0("Intermediate/School specific/forest/school_data_",i,"_prediction_fix.csv"))
  
  return(i)
  
}

clusterExport(cl, "estimateModel")
clusterExport(cl, "dataset_h")

parSapply(cl, 1:2400, function(i){
  try(estimateModel(i))
}
)

stopCluster(cl)
