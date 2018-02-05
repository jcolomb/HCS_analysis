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
library(gridExtra)
library(RGraphics)
versions =list.files("../.git/refs/tags")
version = versions[length(versions)]



PMeta ="../data/Projects_metadata.csv"
Projects_metadata <- read_csv(PMeta)



RECREATEMINFILE=T
STICK =NA
Name_project ="Ro_testdata"
selct_TW = c(1:9)


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

MIN_data_hr_raw =MIN_data
#----------------- Get difference

MIN_data_hr= left_join(MIN_data_min %>% select (Bin, ID),MIN_data_hr_raw)
MIN_data_min = left_join(MIN_data_min %>% select (Bin, ID),MIN_data_min)
names(MIN_data_hr) <-names(MIN_data_min)

temp=MIN_data_hr %>% select_if( is.numeric)-MIN_data_min %>% 
                          select_if( is.numeric)


temp=temp %>% select (-Bin,-bintodark,- dark.start.min)



MIN_data= cbind(MIN_data_min %>% select(which(!sapply(.,class)=="numeric"),Bin,bintodark,dark.start.min), temp)

calcul = function (x){
  mean (x)/60
}
calcul_text = "data (%age of time spent doing the behavior) not transformed."

source ("Rcode/multidimensional_analysis_prep.R") 
source ("Rcode/PCA_strategy.R")


#plotly::plot_ly(y= (MIN_data_min$`Travel(m)` - MIN_data_hr$`Travel(m)` ), x=MIN_data_hr$bintodark,
#                color=MIN_data_min$ID)
plotly::plot_ly(y= MIN_data$`Travel(m)` , x=MIN_data$bintodark,
                color=MIN_data$ID)

#plotly::plot_ly(y= MIN_data$`Travel(m)`+(MIN_data_min$`Travel(m)` - MIN_data_hr$`Travel(m)`) , x=MIN_data$bintodark,
                color=MIN_data$ID)

#problem of bintodark fro the last elemenets, need to check why.
# plotting
View(MIN_data)

#--------- plot 
behav_gp$lightcondition =NA
source("Rcode/plot5_hoursummaries.R")
text.all.d = paste('
                   Comment:
                   difference in %age time spent doing each behaviour if minute or hourly summary data are taken as primary data.',
                   collapse=" ")



# all graphs in one plot
#setwd(plot.path)
pdf(file = paste0("Rcode/analysis_for_paper1/Diff_hour_mindata.pdf"), width = 15, height = 10)

grid.arrange(splitTextGrob(text.all.d),pl.all.d,
             ncol=1,heights = c(1,5),
             top = textGrob(paste0('Hourly or Minutes summary data as primary file. (',groupingby,' grouping)'),gp=gpar(fontsize = 30, font=3)))

dev.off()

