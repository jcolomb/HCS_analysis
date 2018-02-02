# here is the master file where packages are loaded and other functions are called,
# this is to be replaced by a shiny app or tcltk2 at the end.

###--------- Import libraries and set variables that do not change-------------

setwd("analysis")
##multidimensional analysis:
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

versions =list.files("../.git/refs/tags")
version = versions[length(versions)]

#library (tcltk2)

# variables
#source ("Rcode/setvariables.r")
# path to the data if it is on a hard drive (a stick for example), this is the path to the folder countaining all data folders.
# ignore if the data is online or on the main repo

##project metadata path:

#PMeta ="../data/Projects_metadata.csv"
PMeta = osfr::path_file("myxcv")

RECREATEMINFILE= F # set to true if you want to recreate an existing min file, otherwise the code will create one only if it cannot find an exisiting one.


# variable grouping, only working with HCS data at the moment.
groupingby = "MITsoft" # other possibilities: "AOCF"
# choosing time windows for the analysis
selct_TW = c(1:9)

Npermutation = 1 # number of permutation to perform. set to 1 if testing (42 s per run with AOCF designation,30s with MIT)


###--------------------------------- Give Variables that change-------------

# 1. data location if on HD
STICK= "D:/HCSdata/sharable"



# 2. Choose project to analyse:

Name_project ="test_online" # this is a test with data in a github repo
# Name_project ="permutated_1" # this is a test with data in a github repo, using random grouping
Name_project = "Exampledata" # this is the example data present in this github repository
Name_project ="Ro_testdata"
#These files are on my USB stick, the data cannot be put on github
#without the formal agreements of the 
#people who did the experiments:

#Name_project = "Meisel_2017"
# Name_project ="Lehnard_2016"
# Name_project ="Schmidt2017svm"
# Name_project = "Meisel_2017"
# Name_project = "Rosenmund2015"
# Name_project = "Rosenmund2015g"
# Name_project = "Pruess_2016"
# Name_project = "Vida_2015"
# Name_project = "Lehnard_2016"
# Name_project ="Tarabykin_2015" 
#Name_project ="Steele07_HD"

#-------------------compute metadata and MIN_data----------------------------


# read metadata from the project metadata file
source("master_shiny.R")
