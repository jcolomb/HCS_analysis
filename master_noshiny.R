# here is the master file where packages are loaded and other functions are called,
# this is to be replaced by a shiny app or tcltk2 at the end.

##multidimensional analysis:
library (randomForest)
library (ica)
library (e1071) #svm

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
PMeta ="C:/Users/cogneuro/Desktop/Marion_work/Projects_metadata.csv"

# #read main metadata file
# Projects_metadata <- read_csv(PMeta)
# Projects_metadata$Proj_name

##project to analyse
Name_project ="Tarabykin" #must be exactly the same in PMeta
#Name_project ="lehnardt_my88"

#computed variables1
WD = dirname(PMeta)



# read metadata from the project metadata file
source("Rcode/inputdata.r") #output = metadata

#computed variables2
Outputs = paste(WD,Projects_metadata$Folder_path,"Routputs", sep="/")
dir.create (Outputs)
plot.path = Outputs


#check data file existence and if the number of file correspond between the folder and the metadata
#create list of filepath for each animal_ID
source("Rcode/checkmetadata.r") #output BEH_datafiles and MIN_datafiles: list of path

source ("Rcode/animal_groups.r")


#create and save event and minute files (one file for all mice): returns EVENT_data and MIN_data
# some warnings appear because the last line of the minute data is the sum.
# this is not relevant because the data is cut at 22.5 hours of data.

#source ("Rcode/create_eventfile.r") # output EVENT_data, note this takes the whole recording and is therefore not very useful
source ("Rcode/create_minfile.r") # output MIN_data

#filter for repeated tests:
metadata = metadata %>% filter (genotype != "exclude")
MIN_data =MIN_data%>% filter (genotype != "exclude")
summary (as.factor(metadata$animal_ID))
#the raw data have too much problems, timing and categories should be worked out before we can work with it
#source ("Rcode/create_rawdatafiles.r")




#analysis from the minute file, 
#source ("Rcode/analysis_from_min.R")
source ("Rcode/multidimensional_analysis_prep.R")
#source ("Rcode/multidimensional_analysis_RFsvm.R")
save.image(paste0("Reports/multidim_",Name_project,".rdata"))
