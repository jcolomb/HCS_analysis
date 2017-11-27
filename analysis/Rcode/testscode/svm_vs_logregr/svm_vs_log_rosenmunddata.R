#this script will compare the resluts of the SVM and the L1-logistic regresssion, using the 2out strategy of the Steele 2007 paper, on rosenmund data (wt tested twice)
tune.svm3 <- function(trainset,groupingvar){
  #objS <- tune.svm(groupingvar~., data = trainset, gamma = 4^(-5:5), cost = 4^(-5:5),
  #                 tune.control(sampling = "cross"),kernel = "sigmoid")
  #S=min(objS$performances$error)
  
  objR <- tune.svm(groupingvar~., data = trainset, gamma = 4^(-5:5), cost = 4^(-5:5),
                   tune.control(sampling = "cross"),kernel = "radial")
  R=min(objR$performances$error)
  
  #objP <- tune.svm(groupingvar~., data = trainset, gamma = 4^(-5:5), cost = 4^(-5:5),
  #                 tune.control(sampling = "cross"),kernel = "polynomial")
  #P=min(objP$performances$error)
  
  objL <- tune.svm(groupingvar~., data = trainset, gamma = 4^(-5:5), cost = 4^(-5:5),
                   tune.control(sampling = "cross"),kernel = "linear")
  L=min(objL$performances$error)
  
  #choice=data.frame ("S"=S, "R"=R, "P"=P, "L"=L)
  #Min =choice %>% transmute (C=min(S,R,P,L))
  #choice=cbind(data.frame (t(choice)), kernel=c("sigmoid","radial","polynomial","linear"))
  
  #choice %>% filter (t.choice. ==Min [1,1])
  # KERNEL=as.character(choice [choice$t.choice ==Min [1,1],2])[1]
  # obj=NA
  # obj= ifelse (KERNEL == "sigmoid",objS, obj)
  # obj= ifelse (KERNEL == "radial",objR, obj)
  # obj= ifelse (KERNEL == "polynomial",objP, obj)
  # obj= ifelse (KERNEL == "linear",objL, obj)
  # return (c(KERNEL,objR,objL))
  return (c("radial",objR,"linear",objL))
}

setwd("analysis")
##multidimensional analysis:
library(glmpath)
library (randomForest)
library (ica)
library (e1071) #svm
require(Hmisc)   #binomial confidence 

library(osfr) ##access to osf

#normal libraries:
library (tidyverse)
library (stringr)
#for plotting
library(gridExtra)
library(RGraphics)
source ("Rcode/functions.r")

PMeta = osfr::path_file("myxcv")

RECREATEMINFILE= F # set to true if you want to recreate an existing min file, otherwise the code will create one only if it cannot find an exisiting one.

groupingby = "MITsoft" # other possibilities: "AOCF"

Npermutation = 250 # number of permutation to perform. set to 1 if testing (42 s per run with AOCF designation,30s with MIT)

Name_project ="Ro_testdata"
### getdata
source("Rcode/inputdata.r") #output = metadata



#computed variables2
# folder where outputs will be written:
Outputs = paste(WD,Projects_metadata$Folder_path,"Routputs", sep="/")
onlinemin=Outputs 
#for online projects, outputs are written on disk:
if (WD == "https:/") Outputs = paste("../Routputs",Projects_metadata$Folder_path, sep="/")

dir.create (Outputs, recursive = TRUE)
plot.path = Outputs



source("Rcode/checkmetadata.r") #output BEH_datafiles and MIN_datafiles: list of path
source ("Rcode/animal_groups.r") # output metadata$groupingvar
source ("Rcode/create_minfile.r") # output MIN_data, work probably only with HCS data

#filter data if data need exclusion:
metadata$Exclude_data[is.na(
  metadata$Exclude_data)] <- 'include'

metadata = metadata %>% filter (Exclude_data != "exclude")

MIN_data =MIN_data %>% filter(ID %in% metadata$ID)
source ("Rcode/multidimensional_analysis_prep.R")



#-------------------specific code

#1 do the analysis with real groups:
Multi_datainput_m$groupingvar =as.numeric(Multi_datainput_m$groupingvar)
#Multi_datainput_m$groupingvar =as.numeric(sample(Multi_datainput_m$groupingvar))
RF_selec = Multi_datainput_m#
# reorder
RF_selec = RF_selec[order(RF_selec$groupingvar),] 

## getting rid of variables with no variability (all 0)
temp = RF_selec %>% select (-groupingvar)
cfreq <- colSums(temp)
E1 = names(temp[, cfreq == 0])

RF_selec = RF_selec [,!names(RF_selec) %in% c(E1)]




set.seed(66)
xx= as.matrix(RF_selec %>% select (-groupingvar))
yy = as.numeric(RF_selec$groupingvar)-1
pp  <- rep(NA, length(yy))
ppsvm  <- rep(NA, length(yy))
ppsvm_L  <- rep(NA, length(yy))

num_per_class <- nrow(RF_selec)/2
before <- Sys.time()
for (k in 1:num_per_class) {
  hold_out = c(k, k+num_per_class) ## hold out one pos and one neg examples so samples are still balanced
  fit <- glmpath::glmpath(x=xx[-hold_out,], y=yy[-hold_out], family=binomial, max.arclength=1)
  bestdex <- which.min(fit$bic)
  if (bestdex==1) {bestdex <- 2}  ## break ties by avoiding degenerate classifiers
  bestlambda <- fit$lambda[bestdex]
  pred <- predict(fit, newx=xx[hold_out,], s=bestlambda, type="link", mode="lambda")
  pp[hold_out] = pred
  
  #svm
  ##ALL variables:
  ###
  
  ##tuning and performing svm  
  #bestk=NA
  bestk= tune.svm3(RF_selec[-hold_out],as.data.frame(yy[-hold_out]))
                   
                   
  best.parameters = bestk[[2]]
  best.parameters_L = bestk[[11]]
  
  
  svm.model <- svm(yy[-hold_out] ~ ., data = xx[-hold_out,], cost = best.parameters$cost, gamma = best.parameters$gamma, kernel = bestk[[1]])
  svm.model_L <- svm(yy[-hold_out] ~ ., data = xx[-hold_out,], cost = best.parameters_L$cost, gamma = best.parameters_L$gamma, kernel = "linear")
  
  #svm.pred <- predict(svm.model, xx[hold_out,])
  ppsvm[hold_out] = predict(svm.model, xx[hold_out,])
  ppsvm_L[hold_out] = predict(svm.model_L, xx[hold_out,])
  
  
}
duration = Sys.time()-before

true_class <- sign(yy - 0.5)
pred_class <- sign(pp);
pred_classsvm <- sign(ppsvm);
pred_classsvm_L <- sign(ppsvm_L);

prediction_res1=table(true_class, pred_class)
prediction_res2=table(true_class, pred_classsvm)
prediction_res3=table(true_class, pred_classsvm_L)

#Accuracy of grouping and plot
ACURRACY=NA
temp =classAgreement (prediction_res1)
ACURRACY = c(ACURRACY, temp$diag)
temp =classAgreement (prediction_res2)
ACURRACY = c(ACURRACY, temp$diag)
temp =classAgreement (prediction_res3)
ACURRACY = c(ACURRACY, temp$diag)
ACURRACY

b=Sys.time()
Acc_sampled = c("log_regr", "svm_radial")
Npermutation =2
before <- Sys.time()
for (i in 1:Npermutation){
  print(i)
  #metadata$groupingvar=as.factor(metadata$groupingvar)
  #metadata$groupingvar =as.numeric(sample(metadata$groupingvar))
  ### test for one TW
  #multidimensional analysis, prepare data
  #source ("Rcode/multidimensional_analysis_prep.R")
  #only one TW
  #source ("Rcode/testscode/multidimensional_analysis_prep_oneTW.R")
  
  #multidimensional analysis, Random forest in 2 rounds
  #source ("Rcode/RF_selection_2rounds.R") # returns RF_selec = Input
  Multi_datainput_m$groupingvar =as.numeric(sample(Multi_datainput_m$groupingvar))
  RF_selec = Multi_datainput_m
  # reorder
  RF_selec = RF_selec[order(RF_selec$groupingvar),] 
  
  
  
  xx= as.matrix(RF_selec %>% select (-groupingvar))
  yy = as.numeric(RF_selec$groupingvar)-1
  pp  <- rep(NA, length(yy))
  #ppsvm  <- rep(NA, length(yy))
  ppsvm_L  <- rep(NA, length(yy))
  
  num_per_class <- nrow(RF_selec)/2
  before <- Sys.time()
  for (k in 1:num_per_class) {
    hold_out = c(k, k+num_per_class) ## hold out one pos and one neg examples so samples are still balanced
    fit <- glmpath::glmpath(x=xx[-hold_out,], y=yy[-hold_out], family=binomial, max.arclength=1)
    bestdex <- which.min(fit$bic)
    if (bestdex==1) {bestdex <- 2}  ## break ties by avoiding degenerate classifiers
    bestlambda <- fit$lambda[bestdex]
    pred <- predict(fit, newx=xx[hold_out,], s=bestlambda, type="link", mode="lambda")
    pp[hold_out] = pred
    
    #svm
    ##ALL variables:
    ###
    
    ##tuning and performing svm  
    #bestk=NA
    
    groupingvar =as.data.frame(yy[-hold_out])
    
    objL <- tune.svm(groupingvar~., data = RF_selec[-hold_out,], gamma = 4^(-5:5), cost = 4^(-5:5),
                     tune.control(sampling = "cross"),kernel = "radial")
    
    #best.parameters = bestk[[2]]
    best.parameters_L = objL$best.parameters
    
    
    #svm.model <- svm(yy[-hold_out] ~ ., data = xx[-hold_out,], cost = best.parameters$cost, gamma = best.parameters$gamma, kernel = bestk[[1]])
    svm.model_L <- svm(yy[-hold_out] ~ ., data = xx[-hold_out,], cost = best.parameters_L$cost, gamma = best.parameters_L$gamma, kernel = "linear")
    
    #svm.pred <- predict(svm.model, xx[hold_out,])
    #ppsvm[hold_out] = predict(svm.model, xx[hold_out,])
    ppsvm_L[hold_out] = predict(svm.model_L, xx[hold_out,])
    
    
  }
  duration = Sys.time()-before
  
  true_class <- sign(yy - 0.5)
  pred_class <- sign(pp);
 # pred_classsvm <- sign(ppsvm);
  pred_classsvm_L <- sign(ppsvm_L);
  
  prediction_res1=table(true_class, pred_class)
  #prediction_res2=table(true_class, pred_classsvm)
  prediction_res3=table(true_class, pred_classsvm_L)
  
  #Accuracy of grouping and plot
  ACURRACY=NA
  temp =classAgreement (prediction_res1)
  ACURRACY = c(ACURRACY, temp$kappa)
  #temp =classAgreement (prediction_res2)
  #ACURRACY = c(ACURRACY, temp$kappa)
  temp =classAgreement (prediction_res3)
  ACURRACY = c(ACURRACY, temp$kappa)
  
  Acc_sampled = rbind(Acc_sampled, ACURRACY[-1])
}

beepr::beep()

print("time to perform the analysis:")
print(Sys.time()-b)

hist(Acc_sampled [,1], breaks=c(0:20)/20)
abline(v = 17/22, col="Red")
abline(v = 0.5, col="blue")

hist(Acc_sampled [,2], breaks=c(0:20)/20)
abline(v = 17/22, col="Red")
abline(v = 0.5, col="blue")



Accuracyreal=17/22
# Exports `binconf`
k <- sum(abs(Acc_sampled-0.5) >= abs(Accuracyreal-0.5))   # Two-tailed test

k <- sum(Acc_sampled >= Accuracyreal)   # One-tailed test
print(zapsmall(binconf(k, length(Acc_sampled), method='exact'))) # 95% CI by default
print(zapsmall(binconf(k, length(Acc_sampled), method='all')))
save.image(file= "thisisatest.rdata") 


