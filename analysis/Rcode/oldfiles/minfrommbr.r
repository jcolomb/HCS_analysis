#this code creates minutes file from MBR raw data, distance traveled cannot be computed from the MBR file.
#it works for MBR entries with 2 or 4 numbers.
setwd("analysis")
Behav_code <-
  read_delim(
    "infos/HCS_MBR_Code_Details/Short Behavior Codes-Table 1.csv",
    ",",
    escape_double = FALSE,
    col_types = cols(`Behavior Code` = col_integer()),
    trim_ws = TRUE,
    skip = 1
  )[, c(1, 3)]
names (Behav_code) = c("behavior", "beh_name")

framepersec = 25 #number of frame per second (when start and end in rawdata is in frames)

#-- get each file- for later
filesmbr = as.character(MBR_datafiles[, 1])

MIN_Datarw = c()
for (f in 1:length(filesmbr)) {
  if (WD == "https:/") {
    download.file(filesmbr[f], "tempor.mbr",  mode = "wb")
    fileshr[f] = "tempor.mbr"
  }
  rawdata = read.csv (filesmbr[f],
                      sep = "",
                      skip = 1 ,
                      header = F)
  
  #test:
  #rawdata = read.csv("D:/HCSdata/allexportsexample/HomeCageScan160613112221Y16M06D13H11M22S26C1.MBR", sep="", skip=1, header = F)
  
  Binned_min = min_from_mbr(rawdata, framepersec, Behav_code)
  # temp <- behav.1 %>% ungroup %>% group_by(Behavior) %>% summarise (duration.s = sum(Duration))
  orig =  MIN_data %>% filter (ID == MIN_datafiles[f, 2])
  orig = orig [-nrow(orig), c(1, 3:46)]
  TR = (Binned_min - orig) < 0.001
  if (length(TR[!TR]) > 45)
    print (f)
  
  Binned_min$ID = MIN_datafiles[f, 2]
  MIN_Datarw = rbind(MIN_Datarw,Binned_min)
}

# 
#   if (WD == "https:/"){
#     download.file(filesmbr[f], "tempor.mbr",  mode="wb")
#     fileshr[f] = "tempor.mbr"
#   }
#   rawdata = read.csv (filesmbr[f], sep="", skip=1 , header = F)
# 
# #test: 
# #rawdata = read.csv("D:/HCSdata/allexportsexample/HomeCageScan160613112221Y16M06D13H11M22S26C1.MBR", sep="", skip=1, header = F)
# 
# Binned_min = min_from_mbr(rawdata,framepersec,Behav_code)
# # temp <- behav.1 %>% ungroup %>% group_by(Behavior) %>% summarise (duration.s = sum(Duration))
# orig=  MIN_data %>% filter (ID == MIN_datafiles[f,2])
# orig=orig [-nrow(orig),c(1,3:46)]
# TR=(Binned_min - orig)< 0.001
# if (length(TR[!TR])> 45) print (f)
# 
# Binned_min$ID = MIN_datafiles[f,2]
# 
# 
# for (i in seq(1:46)){
#   if(!all(TR[,i])) print (i)
# }
# length(TR[!TR])
# names(orig)[17]
# 
# Binned_min =as.tibble(Binned_min)
# names(orig) %in% names(Binned_min) 
# 
# orig[(Binned_min - orig)< 0.001]
# View(rawdata)
# 
# A=cbind(new=Binned_min$ComeDown,ori= orig$ComeDown, (Binned_min$ComeDown - orig$ComeDown)< 0.001)[4,]
# class(A)  
# # find animal ID
#   behav$ID = MIN_datafiles[f,2]
  
library(tidyverse)
rawdata = read.csv("D:/HCSdata/allexportsexample/HomeCageScan160613112221Y16M06D13H11M22S26C1.MBR", sep="", skip=1, header = F) 
rawdata=rawdata [-nrow(rawdata),]
#-- get comon names
names (rawdata)= c("start", "end", "behavior")

#-- change behavior code to 2 digit
rawdata= rawdata %>% mutate (behavior = behavior-round(behavior, digits = -2))


#-- pool elements with same name
rawdata$behavior [rawdata$behavior== 14] <- 13
rawdata$behavior [rawdata$behavior== 18] <- 17
rawdata$behavior [rawdata$behavior== 31] <- 30

#-- add first line with no data
fline= c(0,rawdata$start[1], 44 )
rawdata =rbind(fline, rawdata)

#-- add animal ID
rawdata$animal_ID = 