#test PCA then SVM radial

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


groupingby = "MITsoft"

source ("Rcode/get_behav_gp.r")
source ("Rcode/analysis_for_paper1/multidimensional_analysis_prep_diffTW.R")
six_windowMIT = Multi_datainput_m

input.pca <- prcomp(Multi_datainput_m %>% select (-groupingvar),
                    center = TRUE,
                    scale. = TRUE)

Moddata = as.data.frame(input.pca$x)
Moddata$groupingvar = as.factor(Multi_datainput_m$groupingvar)

data =Moddata
source ("Rcode/analysis_for_paper1/SVM_logreg_accuracycalc.r")
ACURRACY

data =Moddata [,1:10]
data$groupingvar = as.factor(Multi_datainput_m$groupingvar)

source ("Rcode/analysis_for_paper1/SVM_logreg_accuracycalc.r")
ACURRACY
