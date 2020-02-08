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

dataset_controls <- read.csv("Other data/ControlSchoolsLASSO/control_schools.csv")
dataset_controls$date <- as.Date(dataset_controls$date,origin="1960-01-01")

estimateModel <- function(i) {
  
  for (b in 0:23) {

    ### READ DATA
    dataset = read.dta13(paste0("Intermediate/School specific/school_data_block_",i,".dta"))
    dataset = merge(dataset,setNames(aggregate(temp_f~date,dataset,FUN=max),c("date","temp_max")),by="date")
    dataset = merge(dataset,setNames(aggregate(temp_f~date,dataset,FUN=min),c("date","temp_min")),by="date")
    
    # cleaning
    dataset <- dataset[dataset$problematic_obs==0,]
    dataset <- dataset[dataset$block==b,]
    dataset <- dataset[dataset$qkw_hour>0,]
    dataset <- dataset[is.na(dataset$temp_f)==FALSE,]
    dataset <- dataset[is.nan(dataset$temp_f)==FALSE,]
    dataset$date <- as.Date(dataset$date,origin="1960-01-01")
    
    # merge datasets in
    dataset <- left_join(dataset,dataset_h,by="date")
    dataset <- left_join(dataset,dataset_controls,by=c("date","block"))
    
    # remove own school
    drops <- paste0("cqkw_hour",i)
    dataset <- dataset[,!(names(dataset) %in% drops)]
    
    # clean up missing
    missing <- sapply(dataset, function(x) sum(is.na(x)))
    dataset <- dataset[names(dataset)[missing==0]]
    
    # generate additional variables
    #dataset$weekday <- weekdays(dataset$date)
    weekdays1 <- c('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday')
    dataset$weekday <- c('weekend', 'weekday')[(weekdays(dataset$date) %in% weekdays1)+1L]
    
    summary(dataset)
    
    
    ### PREDICTION MODEL
    dataset <- cbind(dataset,as.data.frame(bs(dataset$month,knots=c(3,6,9),Boundary.knots=c(1,12))))
    for (s in 1:6) { 
      colnames(dataset)[colnames(dataset) == s] <- paste0("splineSeason",s)
    }
    splineSeason <- paste0("splineSeason",1:6)
    dataset <- cbind(dataset,as.data.frame(bs(dataset$temp_f,knots=quantile(dataset$temp_f, probs = c(.05,.25,.45,.55,.75,.95)),Boundary.knots=c(min(dataset$temp_f),max(dataset$temp_f)))))
    for (s in 1:9) { 
      colnames(dataset)[colnames(dataset) == s] <- paste0("splineTemp",s)
    }  
    splineTemp <- paste0("splineTemp",1:9)
    
    controls <- ""
    if (length(names(dataset[grep("cqkw",names(dataset))])) > 0) {
      controls <- paste(" + ", names(dataset[grep("cqkw",names(dataset))]),collapse=" + ")
    }
    
    
    # LASSO - dataset
    Xall = sparse.model.matrix(formula(paste("~ splineTemp1 + splineTemp2 + splineTemp3 + splineTemp4 + splineTemp5",
                                             "+ splineTemp6 + splineTemp7 + splineTemp8 + splineTemp9 + temp_min + temp_max",
                                             "+ factor(month) + factor(month)*temp_min + factor(month)*temp_max",
                                             "+ factor(holiday) + factor(holiday)*temp_min + factor(holiday)*temp_max",
                                             "+ factor(weekday) + factor(weekday)*temp_min + factor(weekday)*temp_max",
                                             "+ factor(weekday)*factor(holiday) + factor(month)*factor(holiday) + factor(month)*factor(weekday)",
                                             "+ factor(weekday)*splineTemp1 + factor(weekday)*splineTemp2", 
                                             "+ factor(weekday)*splineTemp3 + factor(weekday)*splineTemp4", 
                                             "+ factor(weekday)*splineTemp5 + factor(weekday)*splineTemp6",                                              
                                             "+ factor(weekday)*splineTemp7 + factor(weekday)*splineTemp8 + factor(weekday)*splineTemp9",   
                                             "+ factor(holiday)*splineTemp1 + factor(holiday)*splineTemp2", 
                                             "+ factor(holiday)*splineTemp3 + factor(holiday)*splineTemp4", 
                                             "+ factor(holiday)*splineTemp5 + factor(holiday)*splineTemp6",                                              
                                             "+ factor(holiday)*splineTemp7 + factor(holiday)*splineTemp8 + factor(holiday)*splineTemp9",         
                                             "+ factor(month)*splineTemp1 + factor(month)*splineTemp2", 
                                             "+ factor(month)*splineTemp3 + factor(month)*splineTemp4", 
                                             "+ factor(month)*splineTemp5 + factor(month)*splineTemp6",                                              
                                             "+ factor(month)*splineTemp7 + factor(month)*splineTemp8 + factor(month)*splineTemp9",                                                                                 
                                             "+ factor(weekday)*factor(month)*splineTemp1 + factor(weekday)*factor(month)*splineTemp2",
                                             "+ factor(weekday)*factor(month)*splineTemp3 + factor(weekday)*factor(month)*splineTemp4",
                                             "+ factor(weekday)*factor(month)*splineTemp5 + factor(weekday)*factor(month)*splineTemp6",
                                             "+ factor(weekday)*factor(month)*splineTemp7 + factor(weekday)*factor(month)*splineTemp8",
                                             "+ factor(weekday)*factor(month)*splineTemp9")),data=dataset)
    
    # LASSO - dataset
    Xallcontrols = sparse.model.matrix(formula(paste("~ splineTemp1 + splineTemp2 + splineTemp3 + splineTemp4 + splineTemp5",
                                                     "+ splineTemp6 + splineTemp7 + splineTemp8 + splineTemp9 + temp_min + temp_max",
                                                     "+ factor(month) + factor(month)*temp_min + factor(month)*temp_max",
                                                     "+ factor(holiday) + factor(holiday)*temp_min + factor(holiday)*temp_max",
                                                     "+ factor(weekday) + factor(weekday)*temp_min + factor(weekday)*temp_max",
                                                     "+ factor(weekday)*factor(holiday) + factor(month)*factor(holiday) + factor(month)*factor(weekday)",
                                                     "+ factor(weekday)*splineTemp1 + factor(weekday)*splineTemp2", 
                                                     "+ factor(weekday)*splineTemp3 + factor(weekday)*splineTemp4", 
                                                     "+ factor(weekday)*splineTemp5 + factor(weekday)*splineTemp6",                                              
                                                     "+ factor(weekday)*splineTemp7 + factor(weekday)*splineTemp8 + factor(weekday)*splineTemp9",   
                                                     "+ factor(holiday)*splineTemp1 + factor(holiday)*splineTemp2", 
                                                     "+ factor(holiday)*splineTemp3 + factor(holiday)*splineTemp4", 
                                                     "+ factor(holiday)*splineTemp5 + factor(holiday)*splineTemp6",                                              
                                                     "+ factor(holiday)*splineTemp7 + factor(holiday)*splineTemp8 + factor(holiday)*splineTemp9",         
                                                     "+ factor(month)*splineTemp1 + factor(month)*splineTemp2", 
                                                     "+ factor(month)*splineTemp3 + factor(month)*splineTemp4", 
                                                     "+ factor(month)*splineTemp5 + factor(month)*splineTemp6",                                              
                                                     "+ factor(month)*splineTemp7 + factor(month)*splineTemp8 + factor(month)*splineTemp9",                                                                                 
                                                     "+ factor(weekday)*factor(month)*splineTemp1 + factor(weekday)*factor(month)*splineTemp2",
                                                     "+ factor(weekday)*factor(month)*splineTemp3 + factor(weekday)*factor(month)*splineTemp4",
                                                     "+ factor(weekday)*factor(month)*splineTemp5 + factor(weekday)*factor(month)*splineTemp6",
                                                     "+ factor(weekday)*factor(month)*splineTemp7 + factor(weekday)*factor(month)*splineTemp8",
                                                     "+ factor(weekday)*factor(month)*splineTemp9", 
                                                     controls)),data=dataset)
    
    # Cross validation fold id block-bootstrapped at week
    if (b==0) {
      week_rnd <- unique(data.frame(weekid=dataset$weekid))
      week_rnd$foldid <- ceiling(rank(runif(nrow(week_rnd),0,1),ties.method = "random")/nrow(week_rnd)*10.0)
    }  
    dataset <- merge(dataset,week_rnd,by="weekid")
    
    Y = dataset$qkw_hour
    
    prediction.model = cv.glmnet(Xall,Y,foldid=dataset$foldid,family="gaussian",alpha=1)
    dataset$prediction_dl1 <- c(predict(prediction.model,Xall,type="link", s = "lambda.min"))
    dataset$prediction_dl2 <- c(predict(prediction.model,Xall,type="link", s = "lambda.1se"))
    
    prediction.modelc = cv.glmnet(Xallcontrols,Y,foldid=dataset$foldid,family="gaussian",alpha=1)
    dataset$prediction_dl3 <- c(predict(prediction.modelc,Xallcontrols,type="link", s = "lambda.min"))
    dataset$prediction_dl4 <- c(predict(prediction.modelc,Xallcontrols,type="link", s = "lambda.1se"))
    
    #reduce size
    dataset <- dataset[,c("date", "qkw_hour", "prediction_dl1",  "prediction_dl2",  "prediction_dl3", "prediction_dl4")]
    
    write.csv(dataset,file=paste0("Intermediate/School specific/double lasso/school_data_",i,"_prediction_dl_block",b,".csv"))
    
  }
  return(i)
  
}

clusterExport(cl, "estimateModel")
clusterExport(cl, "dataset_h")
clusterExport(cl, "dataset_controls")

parSapply(cl, 1:2400, function(i){
  try(estimateModel(i))
}
)

stopCluster(cl)
