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



RECREATEMINFILE=T
STICK =NA
Name_project ="Ro_testdata"


groupingby = "MITsoft" # other possibilities: "AOCF"




source ("Rcode/get_behav_gp.r")

MIN_data_min= MIN_data

#----------------- hour summary: create the second min files
metadata$primary_datafile ="hour_summary"

RECREATEMINFILE =T
source ("Rcode/create_minfile.r") # output MIN_data, work probably only with HCS data

#filter data if data need exclusion:
metadata$Exclude_data[is.na(
  metadata$Exclude_data)] <- 'include'

metadata = metadata %>% filter (Exclude_data != "exclude")

MIN_data =MIN_data %>% filter(ID %in% metadata$ID)

source ("Rcode/multidimensional_analysis_prep.R") # ret


#----------------- Get difference
MIN_data_hr= MIN_data [1:nrow(MIN_data_min),]
names(MIN_data_hr) <-names(MIN_data_min)

temp=MIN_data_hr %>% select_if( is.numeric)-MIN_data_min %>% 
                          select_if( is.numeric)


temp=temp %>% select (-Bin,-bintodark,- dark.start.min)



MIN_data= cbind(MIN_data_min %>% select(which(!sapply(.,class)=="numeric"),Bin,bintodark,dark.start.min), temp)

source ("Rcode/multidimensional_analysis_prep.R") #time windows will not work


plotly::plot_ly(y= (MIN_data_min$`Travel(m)` - MIN_data_hr$`Travel(m)` ), x=MIN_data_hr$bintodark,
                color=MIN_data_min$ID)
plotly::plot_ly(y= MIN_data$`Travel(m)` , x=MIN_data$bintodark,
                color=MIN_data$ID)

plotly::plot_ly(y= MIN_data$`Travel(m)`+(MIN_data_min$`Travel(m)` - MIN_data_hr$`Travel(m)`) , x=MIN_data$bintodark,
                color=MIN_data$ID)

#problem of bintodark fro the last elemenets, need to check why.
# plotting
View(MIN_data)

source("Rcode/plot5_hoursummaries.R")
