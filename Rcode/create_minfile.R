#----------------- create minute file

data = data.frame()
files = as.character(MIN_datafiles[,1])

for (f in 1:length(files)) {
  
  behav<- readxl::read_excel(files[f],sheet = 1)
  behav = behav[1:1320,1:46] ## -> only keep first 22 hours! only include full hours for all animals (minimal amount 22.5 hours for group D animals 6 & 9)
  
  
  # temp <- behav.1 %>% ungroup %>% group_by(Behavior) %>% summarise (duration.s = sum(Duration))
  
  # find animal ID
  behav$ID = MIN_datafiles[f,2]
  
  metadata %>% filter (ID == MIN_datafiles[f,2])
  df= metadata  %>% filter (ID == MIN_datafiles[f,2]) %>% select(ID, animal_ID = 'animal ID', gender, treatment, genotype, date, test.cage='test cage', 
                                                                 real.time = 'real time start', dark.start = light_off, project.name = Proj_name)
  
  
  
  
  real.time.min = (as.numeric(strsplit(format(df$real.time,"%H:%M:%S"),split = ':')[[1]][1])*60)+
    as.numeric(strsplit(format(df$real.time,"%H:%M:%S"),split = ':')[[1]][2])
  
  dark.start.min = (as.numeric(strsplit(format(df$dark.start,"%H:%M:%S"),split = ':')[[1]][1])*60)+
    as.numeric(strsplit(format(df$dark.start,"%H:%M:%S"),split = ':')[[1]][2])
  
  

  df$dark.start.min = (dark.start.min - real.time.min)
  
  behav$bintodark = behav$Bin - df$dark.start.min
  
  df = left_join(behav, df)
  
 
  
  data = rbind(data,df)
  
}

write.table(data, paste0(Outputs,'/Min_',Name_project,'.csv'), sep = ';',row.names = FALSE)
