#--- get file path for data files (behavior+ minute +hour summary)

BEH_datafiles = metadata  %>% transmute(paste(WD,Folder_path, raw_data_folder, experiment_folder_name,Behavior_sequence, sep= "/"))
names(BEH_datafiles)= "filepath"
BEH_datafiles= BEH_datafiles%>% mutate (file.exists (as.character(filepath)   ) )      


MIN_datafiles = metadata %>% transmute(paste(WD,Folder_path, raw_data_folder, experiment_folder_name,Onemin_summary, sep= "/"))
names(MIN_datafiles)= "filepath"
MIN_datafiles= MIN_datafiles%>% mutate (file.exists (as.character(filepath)   ) )   


Hour_datafiles = metadata %>% transmute(paste(WD,Folder_path, raw_data_folder, experiment_folder_name,Onehour_summary, sep= "/"))
names(Hour_datafiles)= "filepath"
Hour_datafiles= Hour_datafiles%>% mutate (file.exists (as.character(filepath)   ) )   

#--- bind all path into one data frame
all_datafiles=rbind(MIN_datafiles,BEH_datafiles,Hour_datafiles)

###for testing 
###all_datafiles [5,2]= FALSE
#View(all_datafiles)


#--- check correpondance between path in metadata and real files, only for data of the primary_datafile .

if (metadata$primary_datafile[1]== "hour_summary" ){
  if (all(Hour_datafiles$`file.exists(as.character(filepath))`)){
    print ("hourly metadata reaches to data files")
  }else {
    print(Hour_datafiles %>% filter (`file.exists(as.character(filepath))` == FALSE))
  }
}else if (all(all_datafiles$`file.exists(as.character(filepath))`)){
  print ("metadata reaches to data files")
}else {
  print(all_datafiles %>% filter (`file.exists(as.character(filepath))` == FALSE))
}
##TODO : check only min and not behav file??

#--- check if number of files corresponds, if not report files present but not in metadata.
datafolder = metadata %>% transmute(paste(WD,Folder_path, raw_data_folder,  sep= "/"))
files= list.files(as.character(datafolder[1,1]), recursive = TRUE)
if (nrow(all_datafiles) < length(files)){
  print("some files are not grabbed by the metadata, are some animals missing?")
  View(anti_join( data.frame(filepath=basename(files)), all_datafiles %>% transmute (filepath = basename(filepath))))
}


#--- put something in genotype and treatment fields if it is NA.
metadata$genotype=ifelse(is.na (metadata$genotype), "unknown",metadata$genotype)
metadata$treatment=ifelse(is.na (metadata$treatment), "none",metadata$treatment)

#--- add animal ID to table of file path
BEH_datafiles=cbind(BEH_datafiles$filepath, metadata$ID)
MIN_datafiles=cbind(MIN_datafiles$filepath, metadata$ID)
Hour_datafiles=cbind(Hour_datafiles$filepath, metadata$ID)

