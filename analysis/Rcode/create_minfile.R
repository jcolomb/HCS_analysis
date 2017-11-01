#----------------- create minute file

if (file.exists(paste0(Outputs,'/Min_',Name_project,'.csv')) & !RECREATEMINFILE){
  MIN_data = read.csv2(paste0(Outputs,'/Min_',Name_project,'.csv'),dec = ".")
  MIN_data$ID = as.factor(MIN_data$ID)
}else{
  data = data.frame()
  files = as.character(MIN_datafiles[,1])
  
  for (f in 1:length(files)) {
    if (WD == "https:/"){
      download.file(files[f], "tempor.xlsx",  mode="wb")
      files[f] = "tempor.xlsx"
    }
    behav<- readxl::read_excel(files[f],sheet = 1)
    behav = behav[-nrow(behav),1:46] ## -> keep all data (sum columns not taken into account), excluding data come later.
    
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
    
    
    
    data = rbind(data,df)
    
  }
  
  data = data %>% filter(Bin != 'SUM') ##make sure the last row with the summary got removed
  MIN_data = data
  
  write.table(data, paste0(Outputs,'/Min_',Name_project,'.csv'), sep = ';',row.names = FALSE)
  
  rm(data)
}
  
  





