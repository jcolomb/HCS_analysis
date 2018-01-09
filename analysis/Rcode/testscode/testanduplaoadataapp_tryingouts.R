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
Outputs = paste(WD,Projects_metadata$Folder_path,"Routputs", sep="/")
onlinemin=Outputs 
#for online projects, outputs are written on disk:
if (WD == "https:/") Outputs = paste("../Routputs",Projects_metadata$Folder_path, sep="/")

dir.create (Outputs, recursive = TRUE)
plot.path = Outputs

source ("Rcode/animal_groups.r")

source ("Rcode/create_minfile.r")
