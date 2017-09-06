#-----------------create rawdata file-----------------#


data = data.frame()
files = as.character(BEH_datafiles[,1])


for (f in 1:length(files)) {
  #print(f)
  behav.raw<-readxl::read_excel (files[f], sheet = 1, skip = 10, col_types =c ("skip","skip", "numeric","text", "skip"))
  #colnames(behav.raw) = c('duration_s','Behavior')
  behav.raw= behav.raw %>% transmute ( time_start=cumsum(`Length(seconds)`)-`Length(seconds)`, time_end = cumsum(`Length(seconds)`), duration_s = `Length(seconds)`, Behavior = Behavior)

  behav.raw$ID = BEH_datafiles[f,2]
  
  #metadata %>% filter (ID == BEH_datafiles[f,2])
  #df= metadata  %>% filter (ID == BEH_datafiles[f,2]) %>% select(ID, animal_ID = 'animal ID', gender, treatment, genotype, date, test.cage='test cage', 
  #                                                               real.time = 'real time start', dark.start = light_off, project.name = Proj_name)
  #df = left_join(behav.1,df)
  #temp= names(data)
  data = rbind(data, behav.raw)
}

write.table(data, paste0(Outputs,'/Eventsraw_',Name_project,'.csv'), sep = ';',row.names = FALSE)
Rawdata=data
#progress = 2
#setTkProgressBar(pp.pb, progress, label=paste( round(progress/5*100, 0),"% done"))

#read as a list, we will see later which one is best to use:

# mybiglist <- vector('list', length(files))
# names(mybiglist) <- BEH_datafiles[,2]
# for(f in seq_along(mybiglist)){
#   behav.raw<-readxl::read_excel (files[f], sheet = 1, skip = 10, col_types =c ("skip","skip", "numeric","text", "skip"))
#   colnames(behav.raw) = c('length_s','Behavior')
#   behav.raw= behav.raw %>% mutate( time_start=cumsum(length_s)-length_s)
#   
#   
#   
#   mybiglist[[f]] <- list(rawdata=behav.raw)
#   
# }


#test to check sleep
# test=data %>% filter (Behavior == "Sleep")
# min(test$length_s)
# test [test$length_s == "0.08",]
