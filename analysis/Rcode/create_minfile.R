#----------------- create minute file

if ( !RECREATEMINFILE){
  MIN_data = try(read.csv2(paste0(onlinemin,'/Min_',Name_project,'.csv'),dec = ".")
  ,T)
  
}

if (RECREATEMINFILE || class(MIN_data)=="try-error"){
    dataf = data.frame()
  files = as.character(MIN_datafiles[,1])
  fileshr = as.character(Hour_datafiles[,1])
  for (f in 1:length(files)) {
    if (WD == "https:/"){
      download.file(files[f], "tempor.xlsx",  mode="wb")
      files[f] = "tempor.xlsx"
      download.file(fileshr[f], "temporhr.xlsx",  mode="wb")
      fileshr[f] = "temporhr.xlsx"
    }
    if (metadata$primary_datafile[f] =="min_summary") behav<- readxl::read_excel(files[f],sheet = 1)
    if (metadata$primary_datafile[f] =="hour_summary") behav <- xx_to_min(readxl::read_excel(fileshr[f],sheet = 1),60)
    behav = behav %>% filter(Bin != 'SUM') ##make sure the last row with the summary got removed
    behav = behav %>% select(-matches("SUM")) # take out sum column if exists
    
    
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
  
  
  MIN_data = dataf
  
  write.table(MIN_data, paste0(Outputs,'/Min_',Name_project,'.csv'), sep = ';',row.names = FALSE)
  
  rm(dataf)
}
  
MIN_data$ID = as.factor(MIN_data$ID)  

write.table(metadata, paste0(Outputs,'/Metadata_',Name_project,'.csv'), sep = ';',row.names = FALSE)




