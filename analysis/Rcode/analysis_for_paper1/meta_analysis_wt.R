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
convert.factors.to.strings <- function(dataframe)
{
  class.data  <- sapply(dataframe, class)
  factor.vars <- class.data[class.data == "factor"]
  for (colname in names(factor.vars))
  {
    dataframe[,colname] <- as.character(dataframe[,colname])
  }
  return (dataframe)
}

versions =try(system("git tag", intern = TRUE))
if (class(versions)== "try-error"){
  versions =list.files("../.git/refs/tags")
}
version = versions[length(versions)]


PMeta = osfr::path_file("myxcv")
PMeta ="../data/Projects_metadata.csv"

RECREATEMINFILE= TRUE # set to true if you want to recreate an existing min file, otherwise the code will create one only if it cannot find an exisiting one.
NO_svm = TRUE

# variable grouping, only working with HCS data at the moment.
groupingby =  "Berlin" #"Jhuang" # other possibilities:"Berlin" #
# choosing time windows for the analysis
selct_TW = c(1:9)

Npermutation = 1 # number of permutation to perform. set to 1 if testing (42 s per run with AOCF designation,30s with MIT)


STICK= "~/Desktop/HCSdata_2/Sharable"
Projects_metadata_aLL <- read_csv(PMeta)
onlinemin = "~/Desktop/HCSdata_2/metaanalysis"

###--------- Import all data into one spreadsheet

alldata_conc = c() # reset value
groupingvar= "genotype"


for (proj in Projects_metadata_aLL$Proj_name[c(2,4:7)]){
# proj<-"Rosenmund_2015"  
  Name_project <- proj
  source("Rcode/inputdata.r")
  source("Rcode/checkmetadata.r")
  source ("Rcode/create_minfile.r")
  source ("Rcode/Timewindows_8.r") # get time windows
  Projects_metadata$confound_by = NA
  source ("Rcode/Timewindows_utilisation.r")

  # getting all metadata with the minute summary
  alldata=left_join(Multi_datainput,metadata)
  alldata=convert.factors.to.strings(alldata)
  #concatenate with the previous experiments:
  alldata_conc = rbind(alldata_conc, alldata)
  alldata_conc = rbind(alldata, alldata_conc)
}

unique(alldata_conc$genotype)
unique(alldata_conc$treatment)



Meta_analysis_data = alldata_conc %>% filter (genotype %in% c(
  "C57BL/6N",
  "C57BL/6J",
  "C57bl/6J",
  "129/C57BL6J",
  "C57BL/6N"
  )) %>%
  filter (treatment %in% c(
    "CTL",
    "0",
    "none"
  ))

Meta_analysis_data$age = -difftime(Meta_analysis_data$animal_birthdate,Meta_analysis_data$date,
                                   units = "weeks")

#Meta_analysis_data [,163]
PCAdat=Meta_analysis_data[,2:163]
metadata = Meta_analysis_data[,c(1,164:ncol(Meta_analysis_data))]



## get all zero out
out <- lapply(PCAdat, function(x) length(unique(x)))
want <- which(!out < 2)
PCAdat[,want]
#-- make pca and plot
input.pca <- prcomp(PCAdat[,want],
                    center = TRUE,
                    scale. = TRUE)


#---------------------2  statistics on pc1:
Moddata = as.data.frame(input.pca$x)
Moddata$age = as.numeric(Meta_analysis_data$age)
Moddata$genotype = as.factor(Meta_analysis_data$genotype)

p= ggplot(aes(y=PC1, x= age, color=genotype), data =Moddata)
p=p+geom_point()

ggsave("materialforpaper/metaanalysis.pdf")
