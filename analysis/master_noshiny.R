# here is the master file where packages are loaded and other functions are called,
# this is to be replaced by a shiny app or tcltk2 at the end.

###--------- Import libraries and set variables that do not change-------------

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
# path to the data if it is on a hard drive (a stick for example), this is the path to the folder countaining all data folders.
# ignore if the data is online or on the main repo

##project metadata path:

PMeta ="../data/Projects_metadata.csv"

RECREATEMINFILE= F # set to true if you want to recreate an existing min file, otherwise the code will create one only if it cannot find an exisiting one.

NOSTAT =T # if true no permutation will be made (this step takes hours)

###--------------------------------- Give Variables that change-------------

STICK= "D:/HCSdata/sharable"



Name_project ="test_online" # this is a test with data in a github repo
Name_project ="permutated_1" # this is a test with data in a github repo, using random grouping
#Name_project = "Exampledata" # this is the example data present in this github repository

#These files are on my USB stick, the data cannot be put on github
#without the formal agreements of the 
#people who did the experiments:

#Name_project = "Meisel_2017"
# Name_project ="lehnardt_my88"
# Name_project ="Schmidt2017svm"
# Name_project = "Meisel_2017"
# Name_project = "Rosenmund2015"
# Name_project = "Rosenmund2015g"
# Name_project = "Pruess_2016"
# Name_project = "Vida_2015"
# Name_project = "Lehnard_2016"
# Name_project ="Tarabykin_2015" 

#-------------------compute metadata and MIN_data----------------------------


# read metadata from the project metadata file
source("Rcode/inputdata.r") #output = metadata



#computed variables2
 # folder where outputs will be written:
Outputs = paste(WD,Projects_metadata$Folder_path,"Routputs", sep="/")
onlinemin=Outputs
if (WD == "https:/") Outputs = paste("../Routputs",Projects_metadata$Folder_path, sep="/")

dir.create (Outputs, recursive = TRUE)
plot.path = Outputs


#check data file existence and if the number of file correspond between the folder and the metadata
#create list of filepath for each animal_ID
source("Rcode/checkmetadata.r") #output BEH_datafiles and MIN_datafiles: list of path

# create a new column with the variable that are splitting the data into groups:
source ("Rcode/animal_groups.r") # output metadata$groupingvar


#create and save minute files (one file for all mice): returns MIN_data
# some warnings appear because the last line of the minute data is the sum.
# that raw is taken out of the MIN_data.

source ("Rcode/create_minfile.r") # output MIN_data, work probably only with HCS data

#filter data if data need exclusion:
metadata$Exclude_data[is.na(
  metadata$Exclude_data)] <- 'include'

metadata = metadata %>% filter (Exclude_data != "exclude")

MIN_data =MIN_data %>% filter(ID %in% metadata$ID)

#tests
#summary (as.factor(metadata$animal_ID))
#summary (as.factor(MIN_data$animal_ID))
#cbind(metadata$animal_ID, metadata$genotype)


#-------------------Run the analysis              ----------------------------

#multidimensional analysis, prepare data
source ("Rcode/multidimensional_analysis_prep.R")

#multidimensional analysis, Random forest in 2 rounds
source ("Rcode/RF_selection_2rounds.R") # returns RF_selec = Input

# get output
#source ("Rcode/multidimensional_analysis_RFsvm.R")
#save.image(paste0("Reports/multidim_",Name_project,".rdata"))


if (length(unique(metadata$groupingvar))==3) {
  source ("Rcode/morethan2groups.R")
  rmarkdown::render ("reports/multidim_anal_variable2.Rmd", output_file = "multidim_anal_variable.html")
}else{
  #source ("Rcode/multidim_anal_variable.R")
  rmarkdown::render ("reports/multidim_anal_variable.Rmd")

  }


# save reports in the correct output folder.  
file.copy("reports/multidim_anal_variable.html", paste0(Outputs,"/multidim_analysis_",groupingby,".html"), overwrite=TRUE,
          copy.mode = TRUE, copy.date = FALSE)

beepr::beep()

#other codes to be checked and maybe used.

#source ("Rcode/create_eventfile.r") # output EVENT_data, note this takes the whole recording and is therefore not very useful

#analysis (graphs) from the minute file, 
#source ("Rcode/analysis_from_min.R")

#the raw data have too much problems, timing and categories should be worked out before we can work with it
#source ("Rcode/create_rawdatafiles.r")