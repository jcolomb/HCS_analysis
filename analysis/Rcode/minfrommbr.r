#this code creates minutes file from MBR raw data, distance traveled cannot be computed from the MBR file.
#it works for MBR entries with 2 or 4 numbers.
Behav_code <- read_delim("analysis/infos/HCS_MBR_Code_Details/Short Behavior Codes-Table 1.csv",
";", escape_double = FALSE, col_types = cols(`Behavior Code` = col_integer()),trim_ws = TRUE, skip = 1)[,c(1,3)]
names (Behav_code)= c("behavior", "beh_name")

fpersec=25 #number of frame per second (when start and end in rawdata is in frames)

filesmbr = as.character(MBR_datafiles[,1])

#for (f in 1:length(files)) {

  if (WD == "https:/"){
    download.file(filesmbr[f], "tempor.mbr",  mode="wb")
    fileshr[f] = "tempor.mbr"
  }

#test: 
rawdata = read.csv("D:/HCSdata/allexportsexample/HomeCageScan160613112221Y16M06D13H11M22S26C1.MBR", sep="", skip=1, header = F)
rawdata = read.csv (fileshr[f], sep="", skip=1)

#get rid of last row (distance traveled)
rawdata=rawdata [-nrow(rawdata),]
# get comon names
names (rawdata)= c("start", "end", "behavior")

# change behavior code to 2 digit
rawdata= rawdata %>% mutate (behavior = behavior-round(behavior, digits = -2))

#Create summary (will be a function), note that bin is in frames, 25 frames per sec.
fpermin= 60*fpersec
rawdata <- rawdata %>% mutate ()
Binned_data = data.frame()

bin=1
starttime = (bin-1)*fpermin
endtime = bin*fpermin

subset_data = rawdata %>% filter (start < endtime & end >starttime)
subset_data$start [1]=starttime
subset_data$end [length(subset_data$end)]=endtime

temp=subset_data %>% transmute (duration = end-start, behavior = behavior)
temp=  temp %>% group_by(behavior) %>%summarize (sum(duration))
temp2 =left_join(Behav_code, temp, by = "behavior")
#replace NA with 0
temp2$`sum(duration)` = replace(temp2$`sum(duration)`,is.na(temp2$`sum(duration)`), 0)
temp2 = na.omit(temp2)

result = c(bin,temp2$`sum(duration)`/fpersec)
Binned_data= rbind(Binned_data,result)

names(Binned_data)= c("bin",na.omit(Behav_code$beh_name))
  
Binned_data%>% transmute (summary)
# temp <- behav.1 %>% ungroup %>% group_by(Behavior) %>% summarise (duration.s = sum(Duration))
  
  # find animal ID
  behav$ID = MIN_datafiles[f,2]
  
  #metadata %>% filter (ID == MIN_datafiles[f,2])
  df= metadata  %>% filter (ID == MIN_datafiles[f,2]) %>% select(ID, animal_ID = animal_ID, gender, treatment, genotype, date, test.cage='test cage', 
                                                                 real.time = 'real time start', dark.start = light_off, project.name = Proj_name)
  
  
  #calculate bins according to light off
  
  real.time.min = (as.numeric(strsplit(format(df$real.time,"%H:%M:%S"),split = ':')[[1]][1])*60)+
    as.numeric(strsplit(format(df$real.time,"%H:%M:%S"),split = ':')[[1]][2])
  
  dark.start.min = (as.numeric(strsplit(format(df$dark.start,"%H:%M:%S"),split = ':')[[1]][1])*60)+
    as.numeric(strsplit(format(df$dark.start,"%H:%M:%S"),split = ':')[[1]][2])
  
  
  
  df$dark.start.min = (dark.start.min - real.time.min)
  
  behav$bintodark = behav$Bin - df$dark.start.min
  
  #merging data with the metadata
  df = left_join(behav, df)
  
  
  
  dataf = rbind(dataf,df)
  
}
