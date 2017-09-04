#-----------------create event file-----------------#


data = data.frame()
files = as.character(BEH_datafiles[,1])
  
  
  for (f in 1:length(files)) {
    
    behav.1<-readxl::read_excel (files[f], sheet = 2, skip = 11)
    behav.1 = behav.1[,c(1,2,4)]
    colnames(behav.1) = c('behav','Bouts','seconds')
    
    if (is.character(class(behav.1$seconds))) {
      behav.1$seconds = as.numeric(behav.1$seconds)
    }
    # temp <- behav.1 %>% ungroup %>% group_by(Behavior) %>% summarise (duration.s = sum(Duration))
    
    
    
    behav.1$ID = BEH_datafiles[f,2]
    
    metadata %>% filter (ID == BEH_datafiles[f,2])
    df= metadata  %>% filter (ID == BEH_datafiles[f,2]) %>% select(ID, animal_ID = 'animal ID', gender, treatment, genotype, date, test.cage='test cage', 
                            real.time.start = 'real time start', dark.start = light_off, project.name = Proj_name)
    
    
    # df = data.frame(animal_ID = animal_ID, gender = 'male',treatment = 'first',
    #                 genotype = look.up[id,'genotype'],
    #                 date = look.up[id,'date'],
    #                 test.cage = look.up[id,'test cage'],
    #                 hour.start = look.up[id,'hour start'],
    #                 dark.start = look.up[id,'dark start'],
    #                 real.time = look.up[id,'real time start'],
    #                 project.name = groups[g])
    df = left_join(behav.1,df)
    
    data = rbind(data,df)
  }
  

write.table(data, paste0(Outputs,'/Events_',Name_project,'.csv'), sep = ';',row.names = FALSE)

#progress = 2
#setTkProgressBar(pp.pb, progress, label=paste( round(progress/5*100, 0),"% done"))
EVENT_data = data
rm(data)