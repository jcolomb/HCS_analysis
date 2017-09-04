# here is the master file where packages are loaded and other functions are called,
# this is to be replaced by a shiny app or tcltk2 at the end.

library (tidyverse)
library (stringr)
#library (tcltk2)

# variables

##project metadata path:
PMeta ="data/minimal24h_data/Projects_metadata.csv"


##project to analyse
Name_project ="Tarabykin" #must be exactly the same in PMeta


#computed variables
WD = dirname(PMeta)
Outputs = paste(WD,Projects_metadata$Folder_path,"Routputs", sep="/")
dir.create (Outputs)

##code
#read metadata
source("Rcode/inputdata.r")

#check data file existence and if the number of file correspond between the folder and the metadata
#create list of filepath for each animal_ID
source("Rcode/checkmetadata.r")

#create and save event files (one file for all mice)
source ("Rcode/create_eventfile.r")

