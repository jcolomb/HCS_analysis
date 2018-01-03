#test for changing testanduploaddata app
# pacakages

setwd("analysis")

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

groupingby = "MITsoft" # other possibilities: "AOCF"

PMeta ="../data/Projects_metadata.csv"
Projects_metadata <- read_csv(PMeta)



RECREATEMINFILE=FALSE
STICK =NA

Name_project ="Steele07_HD"
source("Rcode/inputdata.r")

source("Rcode/checkmetadata.r")
