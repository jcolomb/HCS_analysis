# Review code, this should help reviewers to validate the code, note that tests were also added in the Rcode/tests folder.
# We first run the code for the Ro_testdata_mbr project, and then come back step by step. 


## input variables, similar as in master_noshiny.r

setwd("analysis")
library (randomForest)
library (ica)
library (e1071) #svm
require(Hmisc)   #binomial confidence 
require (plotly)
library (rstatix) #effect size calculation
library (coin) #effect size calculation
library(osfr) ##access to osf
library (tidyverse)
library (stringr)
library(gridExtra)
library(RGraphics)
source ("Rcode/functions.r")

version = "noused"
PMeta ="../data/Projects_metadata.csv"

RECREATEMINFILE= T # set to true if you want to recreate an existing min file, otherwise the code will create one only if it cannot find an exisiting one.
NO_svm = FALSE

# variable grouping, only working with HCS data at the moment.
groupingby =  "Berlin" #"Jhuang" # other possibilities:"Berlin" #
# choosing time windows for the analysis
selct_TW = c(8:9)

Npermutation = 1 # number of permutation to perform. set to 1 if testing (42 s per run with AOCF designation,30s with MIT)

Name_project ="Ro_testdata_mbr"

## run code
source ("master_shiny.r")

#################---------------------#################
#################---------------------#################
#################---------------------#################


## review process point by point

## experiment metadata: (read in input.r file, saved with the data in Min_Ro_testdata_mbr.csv)
## ----------------------------------------------


metadata # information about animals and lab (light on and light off time) as entered in the metadata files, 
#### depending of the type of input data used (minute summary, mbr files), links to data files are either here
metadata$Onemin_summary
#### or here
metadata$primary_behav_sequence

#### grouping variable (created in animal_groups.r from master metadata file entry)
metadata$groupingvar
metadata$confoundvar # confounding variables not interesting to test, but grouping may help statistics 

## The data (MIN_data, written to  Min_Ro_testdata_mbr.csv)
## ----------------------------------------------


# create_minfile.r code read, and pull together the data, its output is saved in the Min_Ro_testdata_mbr file, available in the data folder.
# Unless the input is hourly summary, it is a minute summary file, giving the amount of time doing each behavior for each minute of experiment.
# metadata and relation to light on/off time is added to the data.
MIN_data

# The file created by R from the raw behavior sequence should be very similar to identical to the excel file information created with the home cage scan software.
#compare for instance: 
View(MIN_data %>% filter (ID =="100"))
# with 150609_Testdata_HCS_groupB/150609_Testdata_HCS_min_2.xlsx



## the time-windowed summary data (Multi_datainput, written to timedwindowed_Ro_testdata_mbr.csv)
## this will become the input for the analysis (PCR, random forest, svm)
## ----------------------------------------------

## timewindows are created, only non-empty ones are displayed (depends on the length of the experiment)
Timewindows

## for each selected time window
selct_TW
## the code takes minutes summary for each meta-behavior (2 grouping choice possible at the moment berlin, jhuang),
names(behav_gp)
## and calculates the percentage of time spent doing each one, in each time window, based on the function get_windowsummary()
## its output is Multi_datainput, (metadata is not included, only animal ID is present)
unique(Multi_datainput$ID)

# one number (representing the time window) is added to each metabehavior name in the header
names(Multi_datainput)




## Analysis
## ID is replaced by groupingvar (and confoundvar if exists) in Multi_datainput_m (or Multi_datainput_m2)
Multi_datainput_m$groupingvar 

## random forest + ICA: RF_selection_2rounds.r, ICA.r

RF_selec # selection of Multi_datainput_m, with a minimum of 8 variables
# all variables having a MeanDecreaseGini > 0.95,
# theoretical maximum of variables is 20, because 20 are chosen after a first random forest.

pls2 # 3d plot of the results of the ICA done over RF_select, groups as color

## PCA analysis
# done over Multi_datainput_m, 

Moddata #output with each principal components
Moddata$PC1 # first principal components where statistics is done




