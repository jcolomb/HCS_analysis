#---------helpfiles to create metadata.csv without missing files


#set directory to HCS folder with all data, typically "HCS3_output" (in Rstudio: Session- set working directory - browse)

# comment or erase alternative you will not use, only one option possible
#Alternative = "work with minutes xlsx exports" # files must have 'min' in their name
#Alternative = "work with hourly xlsx exports"  # files must have 'hour' in their name
Alternative = "work with mbr files" # files must have 'mbr' in their name

## Run the rest of the code, if it does not work, you may need to trick the grepl commands to filter things in or out.
library (dplyr)
files = data.frame(f=as.character(dir(recursive = T)),stringsAsFactors = F)

output= structure(list(animal_ID = character(0), animal_birthdate = character(0), 
                       gender = character(0), treatment = character(0), genotype = character(0), 
                       other_category = character(0), date = character(0), test_cage = character(0), 
                       real_time_start = character(0), Lab_ID = character(0), Exclude_data = character(0), 
                       comment = character(0), experiment_folder_name = character(0), 
                       Behavior_sequence = character(0), Onemin_summary = character(0), 
                       Onehour_summary = character(0), primary_behav_sequence = character(0), 
                       primary_position_time = character(0), primary_datafile = character(0)), row.names = integer(0), class = "data.frame")


##Alternative A: work with minutes xlsx exports:
##--------------
if (Alternative == "work with minutes xlsx exports"){
  # get file names for behavior and minute files (xlsx exports)
  filesb = files %>% filter (grepl('beh',f)| grepl('Beh',f))
  filese = files %>% filter (grepl('min',f)|grepl('Min',f))
  
  
  # split name of files
  filese2 = data.frame(dir=dirname(filese$f), basename (filese$f))
  filesb2 = data.frame(dir=dirname(filesb$f), basename (filesb$f))
  
  
  #bind 2 files in one table
  meta1= cbind(filese2, filesb2)
  
  meta1$animal_ID =NA
  names (meta1) = c("experiment_folder_name","Onemin_summary", "dir" ,              
                    "Behavior_sequence", "animal_ID")
  meta1$primary_datafile = "min_summary"
  meta1=meta1 %>% select (experiment_folder_name,Behavior_sequence,Onemin_summary, animal_ID)
  
}

if (Alternative == "work with hourly xlsx exports"){
  
  filesa = files %>% filter (grepl('hour',f)|grepl('hour',f)) 
  filesa2 = data.frame(dir=dirname(filesa$f), basename (filesa$f))
  meta1=cbind(filesa2, filesa2)
  meta1$animal_ID =NA
  names (meta1) = c("experiment_folder_name","Onehour_summary", "dir" , "Behavior_sequence", "animal_ID")
meta1=meta1 %>% select (experiment_folder_name,Behavior_sequence,Onemin_summary, animal_ID)
meta1$primary_datafile = "hour_summary"
output= left_join(meta1, output) %>% relocate (names (output))
}
### Alternative B: work with hourly xlsx exports:
##--------------



### Alternative C: work with mbr files (created automatically):
##--------------
if (Alternative == "work with mbr files"){
  filesf = files %>% filter (grepl('mbr',f)|grepl('MBR',f))
  ## putatively exclude some files
  
  filesf= filesf %>% filter (grepl('HomeCageScan',f)) # exclude files with glut in their name
  filesf2 = data.frame(dir=dirname(filesf$f), basename (filesf$f))
  meta1= filesf2
  names (meta1)= c("experiment_folder_name","primary_behav_sequence")
  meta1$primary_datafile = "mbr_raw"
  
  
  }


#meta1= cbind(filese2, "filesb2"=filese2) #spec vida

#create report table and write it down:




#View(meta1) # you should have all files listed in a square dataframe (no NA)
output= left_join(meta1, output) %>% relocate (names (output))
write.csv(output, "eachfile2.csv", fileEncoding = "UTF8")


