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

dataset_controls <- read.csv("Other data/ControlSchoolsLASSO/control_schools.csv")
dataset_controls$date <- as.Date(dataset_controls$date,origin="1960-01-01")

estimateModel <- function(i) {

  samplesize <- runif(1, 0.2, 0.8)
  
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
  
  dataset$trainindex <- 0
  dataset$trainindex[trainindex] <- 1
  test <- dataset[dataset$trainindex==0,]
  base <- dataset[dataset$trainindex==1,]

  # Cross validation fold id block-bootstrapped at week
  if (b==0) {
    week_rnd <- unique(data.frame(weekid=base$weekid))
    fun_fold_id <- function(x) {ceiling(rank(runif(x,0,1),ties.method = "random")/x*10.0)}
    fun_week_id <- function(x) {sample(week_rnd$weekid,x,replace=TRUE)}
    fold_id <- lapply(rep(nrow(week_rnd),100),fun_fold_id)
    week_id <- lapply(rep(nrow(week_rnd),100),fun_week_id)
  }  
  week_rnd$foldid <- fold_id[[1]]
  base <- merge(base,week_rnd,by="weekid")
  
  dataset <- bind_rows(base,test)
  dataset$rowindex <- 1:nrow(dataset)
  test <- dataset[dataset$trainindex==0,]
  base <- dataset[dataset$trainindex==1,]
  
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
  
  # LASSO - dataset
  
  X = Xall[dataset$trainindex==1, ,drop = FALSE]
  Xcontrols = Xallcontrols[dataset$trainindex==1, ,drop = FALSE]
  
  Y = base$qkw_hour
  # Ylog = log(base$qkw_hour)
  
  # Running the model
  prediction.model = cv.glmnet(X,Y,foldid=base$foldid,family="gaussian",alpha=1)
  dataset$prediction1 <- c(predict(prediction.model,Xall,type="link", s = "lambda.min"))
  dataset$prediction2 <- c(predict(prediction.model,Xall,type="link", s = "lambda.1se"))
  
  prediction.modelc = cv.glmnet(Xcontrols,Y,foldid=base$foldid,family="gaussian",alpha=1)
  dataset$prediction3 <- c(predict(prediction.modelc,Xallcontrols,type="link", s = "lambda.min"))
  dataset$prediction4 <- c(predict(prediction.modelc,Xallcontrols,type="link", s = "lambda.1se"))

  # randomForest
  myvars <- c("qkw_hour", "temp_f", "holiday", "weekday", "month")
  dataset_forest <- dataset[myvars]
  dataset_forest$weekday <- as.numeric(factor(dataset_forest$weekday))
  dataset_forest$holiday <- as.numeric(dataset_forest$holiday)
  test_forest <- dataset_forest[dataset$trainindex==0,]
  base_forest <- dataset_forest[dataset$trainindex==1,]
  
  model_forest <- randomForest(qkw_hour ~ .,data=base_forest,na.action=na.omit)
  dataset$prediction7 <- predict(model_forest, dataset_forest)

  #clean up and reduce size
  myvars<-c("school_id","date","qkw_hour","trainindex","prediction1","prediction2","prediction3","prediction4","prediction7")
  dataset <- dataset[,myvars]
  
  write.csv(dataset,file=paste0("Intermediate/School specific/prediction/school_data_",i,"_prediction_block",b,".csv"),row.names=FALSE)
  
  #store picked variables
  varnames1 <- as.data.frame(cbind(coef(prediction.model, s = "lambda.min")@Dimnames[[1]][coef(prediction.model, s = "lambda.min")@i+1],
                                   coef(prediction.model, s = "lambda.min")@x))
  varnames1$model <- "levels_min" 
  
  varnames2 <- as.data.frame(cbind(coef(prediction.model, s = "lambda.1se")@Dimnames[[1]][coef(prediction.model, s = "lambda.1se")@i+1],
                                   coef(prediction.model, s = "lambda.1se")@x))
  varnames2$model <- "levels_se"     
  
  varnames3 <- as.data.frame(cbind(coef(prediction.modelc, s = "lambda.min")@Dimnames[[1]][coef(prediction.modelc, s = "lambda.min")@i+1],
                                   coef(prediction.modelc, s = "lambda.min")@x))
  varnames3$model <- "levels_controls_min" 
  
  varnames4 <- as.data.frame(cbind(coef(prediction.modelc, s = "lambda.1se")@Dimnames[[1]][coef(prediction.modelc, s = "lambda.1se")@i+1],
                                   coef(prediction.modelc, s = "lambda.1se")@x))
  varnames4$model <- "levels_controls_se"

  varnames <- rbind(varnames1, varnames2, varnames3, varnames4)
  colnames(varnames)[colnames(varnames) == "V1"] <- "varname"
  colnames(varnames)[colnames(varnames) == "V2"] <- "coef"
  
  write.csv(varnames,file=paste0("Intermediate/School specific/prediction/school_",i,"_prediction_variables",b,".csv"),row.names=FALSE)

  # bootstrap
  datasetbs <- NULL
  week_bs <- NULL
  for (bs in 2:21) {
    week_bs$weekid <- week_id[[bs]]
    week_bs$foldid <- fold_id[[bs]]
    week_bs <- as.data.frame(week_bs)
    toselect = merge(base %>% select(weekid,rowindex),week_bs %>% select(weekid,foldid),by="weekid")

    Xcontrols = Xallcontrols[toselect$rowindex, ,drop = FALSE]
    Y = base$qkw_hour[toselect$rowindex]

    model.bs <- NULL
    predictionbs <- NULL
    try(model.bs <- cv.glmnet(Xcontrols,Y,foldid=toselect$foldid,family="gaussian",alpha=1))
    try(predictionbs <- c(predict(model.bs,Xallcontrols,type="link", s = "lambda.1se")))
    datasetbs <- cbind(datasetbs, predictionbs)
  }
  datasetbs = as.data.frame(datasetbs)
  for (bs in 1:20) {
    names(datasetbs)[bs] <- paste0("predbs",bs)
  }
  datasetbs$date = dataset$date
  write.csv(datasetbs,file=paste0("Intermediate/School specific/prediction/school_data_",i,"_bootstrap",b,".csv"),row.names=FALSE)
  
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
