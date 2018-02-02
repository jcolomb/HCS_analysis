#----------------------------prepare data
starttime <- Sys.time()
setwd("analysis")


library (e1071) #svm
require(Hmisc)   #binomial confidence 

library(osfr) ##access to osf

#normal libraries:
library (tidyverse)
library (stringr)
#for plotting
library(glmpath)

source ("Rcode/functions.r")



PMeta ="../data/Projects_metadata.csv"
Projects_metadata <- read_csv(PMeta)



RECREATEMINFILE=FALSE
STICK =NA
Name_project ="Ro_testdata"


groupingby = "MITsoft" # other possibilities: "AOCF"


#-----------------different data for each time window x grouping strategy (6 total)

source ("Rcode/get_behav_gp.r")
source ("Rcode/analysis_for_paper1/multidimensional_analysis_prep_diffTW.R")

One_windowMIT = Multi_datainput_m %>% select (Distance_traveled6:groupingvar)
five_windowMIT = Multi_datainput_m %>% select (Distance_traveled1:Drink5,groupingvar )
six_windowMIT = Multi_datainput_m

groupingby =  "AOCF"


source ("Rcode/get_behav_gp.r")
source ("Rcode/analysis_for_paper1/multidimensional_analysis_prep_diffTW.R")

One_windowaocf = Multi_datainput_m %>% select (Distance_traveled6:groupingvar)
five_windowaocf = Multi_datainput_m %>% select (Distance_traveled1:Stretch5,groupingvar )
six_windowaocf = Multi_datainput_m

allwindowconc =list(One_windowMIT,five_windowMIT,six_windowMIT,One_windowaocf,five_windowaocf,six_windowaocf)
name_allwindowconc =c("One_windowMIT","five_windowMIT","six_windowMIT","One_windowaocf","five_windowaocf","six_windowaocf")

# cleaning (not necessary with test data, but kept for integrity)
for (i in 1:6){
  data = allwindowconc[[i]]
  data$groupingvar =as.numeric(data$groupingvar)
  
  temp = data %>% select (-groupingvar)
  cfreq <- colSums(temp)
  E1 = names(temp[, cfreq == 0])
  
  data = data [,!names(data) %in% c(E1)]
  
  allwindowconc[[i]]= data
  
}
#----------------- SVM and log regressions

set.seed(74)

Acc_real = NA
for (i in 1:6){
  #i=1
  data = allwindowconc[[i]]
  source ("Rcode/analysis_for_paper1/SVM_logreg_accuracycalc.r")
  x=as.data.frame(t(ACURRACY))
    as.data.frame(cbind(
    c(paste(name_allwindowconc[i], "accuracy_logreg", sep="_"),ACURRACY [1]),
    c(paste(name_allwindowconc[i], "accuracy_svm_radial", sep="_"),ACURRACY [2]),
    c(paste(name_allwindowconc[i], "accuracy_svm_linear", sep="_"),ACURRACY [3])
 ))
  names(x)=  c(paste(name_allwindowconc[i], "accuracy_logreg", sep="_"),
               paste(name_allwindowconc[i], "accuracy_svm_radial", sep="_"),
               paste(name_allwindowconc[i], "accuracy_svm_linear", sep="_")
  )
  Acc_real <- cbind(Acc_real,x)            
}
Acc_real= Acc_real[,-1]


#----------------- SVM and log regressions: permutations
Npermutation = 246

if (!exists("Acc_cumm")) Acc_cumm = Acc_real
for (j in (seq(1:Npermutation)+1)){
  Acc_notreal = NA
  for (i in 1:6){
    #i=1
    data = allwindowconc[[i]]
    data$groupingvar =sample(data$groupingvar)
    source ("Rcode/analysis_for_paper1/SVM_logreg_accuracycalc.r")
    x=as.data.frame(t(ACURRACY))
    as.data.frame(cbind(
      c(paste(name_allwindowconc[i], "accuracy_logreg", sep="_"),ACURRACY [1]),
      c(paste(name_allwindowconc[i], "accuracy_svm_radial", sep="_"),ACURRACY [2]),
      c(paste(name_allwindowconc[i], "accuracy_svm_linear", sep="_"),ACURRACY [3])
    ))
    names(x)=  c(paste(name_allwindowconc[i], "accuracy_logreg", sep="_"),
                 paste(name_allwindowconc[i], "accuracy_svm_radial", sep="_"),
                 paste(name_allwindowconc[i], "accuracy_svm_linear", sep="_")
    )
    Acc_notreal <- cbind(Acc_notreal,x)            
  }
  Acc_notreal= Acc_notreal[,-1]
  
  Acc_cumm= rbind (Acc_cumm,Acc_notreal)
  save.image(file = paste0("svm_logreg_", nrow(Acc_cumm)))
  
}

stoptime <- Sys.time()
beepr::beep()
#save.image(file = paste0("svm_logreg_", nrow(Acc_cumm)))





difftime(stoptime, starttime,units= "mins")
# 
# set.seed(74)
# source ("Rcode/multidimensional_analysis_svm.R") # returns Accuracy (text), Accuracyreal = kappa of result of svm prediction on the test data
# 
# Acc_sampled= c() # set 
# 
# source ("Rcode/multidimensional_analysis_perm_svm.R")