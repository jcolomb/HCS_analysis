# here is the master file where packages are loaded and other functions are called,
# this is to be replaced by a shiny app or tcltk2 at the end.
setwd("analysis")
##multidimensional analysis:
library (randomForest)
library (ica)
library (e1071) #svm
require(Hmisc)   #binomial confidence 

library (tidyverse)
library (stringr)
#for plotting
library(gridExtra)
library(RGraphics)
source ("Rcode/functions.r")


#library (tcltk2)

# variables
source ("Rcode/setvariables.r")

##project metadata path:
PMeta ="data/minimal24h_data/Projects_metadata.csv"
#PMeta ="C:/Users/cogneuro/Desktop/Marion_work/Projects_metadata.csv"
PMeta ="D:/HCSdata/Sharable/Projects_metadata.csv"

# #read main metadata file
# Projects_metadata <- read_csv(PMeta)
# Projects_metadata$Proj_name

##project to analyse
Name_project ="Tarabykin" #must be exactly the same in PMeta
#Name_project ="lehnardt_my88"
Name_project ="Schmidt2017svm"
Name_project = "Meisel_2017"
Name_project = "Rosenmund2015"
Name_project = "Rosenmund2015g"
Name_project = "Pruess_2016"
Name_project = "Vida_2015"

#computed variables1
WD = dirname(PMeta)



# read metadata from the project metadata file
source("Rcode/inputdata.r") #output = metadata

#filter metadata with no data in the Onemin_summary
#metadata= metadata %>% filter (!is.na(Onemin_summary ))

#computed variables2
Outputs = paste(WD,Projects_metadata$Folder_path,"Routputs", sep="/")
dir.create (Outputs)
plot.path = Outputs


#check data file existence and if the number of file correspond between the folder and the metadata
#create list of filepath for each animal_ID
source("Rcode/checkmetadata.r") #output BEH_datafiles and MIN_datafiles: list of path

source ("Rcode/animal_groups.r") # output metadata$groupingvar


#create and save event and minute files (one file for all mice): returns EVENT_data and MIN_data
# event file not created anymore: only data for whole recording, which is of different length for each experiment.

# some warnings appear because the last line of the minute data is the sum.
# that data point is taken out of the MIN_data.

#source ("Rcode/create_eventfile.r") # output EVENT_data, note this takes the whole recording and is therefore not very useful
source ("Rcode/create_minfile.r") # output MIN_data

#filter for repeated tests:

metadata = metadata %>% filter (genotype != "exclude")
MIN_data =MIN_data%>% filter (genotype != "exclude")
summary (as.factor(metadata$animal_ID))
cbind(metadata$animal_ID, metadata$genotype)
#the raw data have too much problems, timing and categories should be worked out before we can work with it
#source ("Rcode/create_rawdatafiles.r")


#metadata$groupingvar = metadata$treatment

#analysis from the minute file, 
#source ("Rcode/analysis_from_min.R")

#multidimensional analysis, prepare data
source ("Rcode/multidimensional_analysis_prep.R")

# get output
#source ("Rcode/multidimensional_analysis_RFsvm.R")
#save.image(paste0("Reports/multidim_",Name_project,".rdata"))
NOSTAT =T
if (length(unique(metadata$groupingvar))==3) {
  source ("Rcode/morethan2groups.R")
  rmarkdown::render ("reports/multidim_anal_variable2.Rmd", output_file = "multidim_anal_variable.html")
}else{
  rmarkdown::render ("reports/multidim_anal_variable.Rmd")
}


  
file.copy("reports/multidim_anal_variable.html", paste0(Outputs,"/multidim_analysis.html"), overwrite=TRUE,
          copy.mode = TRUE, copy.date = FALSE)  
