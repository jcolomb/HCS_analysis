# get file path for data files (behavior+ minute summary)

BEH_datafiles = metadata  %>% transmute(paste(WD,Folder_path, raw_data_folder, experiment_folder_name,Behavior_sequence, sep= "/"))
names(BEH_datafiles)= "filepath"
BEH_datafiles= BEH_datafiles%>% mutate (file.exists (as.character(filepath)   ) )      
all_datafiles=BEH_datafiles

MIN_datafiles = metadata %>% transmute(paste(WD,Folder_path, raw_data_folder, experiment_folder_name,Onemin_summary, sep= "/"))
names(MIN_datafiles)= "filepath"
MIN_datafiles= MIN_datafiles%>% mutate (file.exists (as.character(filepath)   ) )   
all_datafiles=rbind(MIN_datafiles,BEH_datafiles)

###for testing testing
###all_datafiles [5,2]= FALSE
#View(all_datafiles)
#check correpondance between path in metadata and real files.

if (all(all_datafiles$`file.exists(as.character(filepath))`)){
  print ("metadata reaches to data files")
}else {
  print(all_datafiles %>% filter (`file.exists(as.character(filepath))` == FALSE))
}

datafolder = metadata %>% transmute(paste(WD,Folder_path, raw_data_folder,  sep= "/"))
files= list.files(as.character(datafolder[1,1]), recursive = T)
if (nrow(all_datafiles) < length(files)){
  print("some files are not grabbed by the metadata, are some animals missing?")
  View(anti_join( data.frame(filepath=basename(files)), all_datafiles %>% transmute (filepath = basename(filepath))))
}


#put something in genotype and treatment fields if it is NA.
metadata$genotype=ifelse(is.na (metadata$genotype), "unknown",metadata$genotype)
metadata$treatment=ifelse(is.na (metadata$treatment), "none",metadata$treatment)

# add animal ID to table
BEH_datafiles=cbind(BEH_datafiles$filepath, metadata$ID)
MIN_datafiles=cbind(MIN_datafiles$filepath, metadata$ID)




# 
# temp=BEH_datafiles %>% mutate(ids = max(str_locate_all(pattern = '_',filepath)[[1]]))
# ANIMAL_IDS= temp %>% transmute (animal_ID = substr(filepath,ids+1,nchar(filepath)-5))
# temp = cbind(ANIMAL_IDS, metadata$`animal ID`)
# temp %>% transmute (animal_ID == metadata$`animal ID`)
# 
# # find animal ID in file name
# ids <- max(str_locate_all(pattern = '_',files[f])[[1]])
# animal_ID = substr(files[f],ids+1,nchar(files[f])-5)