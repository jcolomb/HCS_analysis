# here is the master file where packages are loaded and other functions are called,
# this is to be replaced by a shiny app or tcltk2 at the end.

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

##project to analyse
Name_project ="Tarabykin" #must be exactly the same in PMeta


#computed variables
WD = dirname(PMeta)
Outputs = paste(WD,Projects_metadata$Folder_path,"Routputs", sep="/")
dir.create (Outputs)
plot.path = Outputs
a=Sys.time()
##code
#read metadata
source("Rcode/inputdata.r")

#check data file existence and if the number of file correspond between the folder and the metadata
#create list of filepath for each animal_ID
source("Rcode/checkmetadata.r")

#create and save event and minute files (one file for all mice): returns EVENT_data and MIN_data
# some warnings appear because the last line of the minute data is the sum.
# this is not relevant because the data is cut at 22.5 hours of data.

source ("Rcode/create_eventfile.r") # to be modified: this takes the whole recording

source ("Rcode/create_rawdatafiles.r")
b=Sys.time()
source ("Rcode/create_minfile.r")

#event analysis (total time only)
source ("Rcode/analysis_from_min.R")
b=Sys.time()
