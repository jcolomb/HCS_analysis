#---------helpfiles to create metadata.csv without missing files

#set directory to HCS folder with all data, typically "HCS3_output"
library (dplyr)
files = data.frame(f=as.character(dir(recursive = T)),stringsAsFactors = F)

#get file names for behavior and minute files
filesb = files %>% filter (grepl('beh',f)| grepl('Beh',f))
filese = files %>% filter (grepl('min',f)|grepl('Min',f))

# split name of files
filese2 = data.frame(dir=dirname(filese$f), basename (filese$f))
filesb2 = data.frame(dir=dirname(filesb$f), basename (filesb$f))

#bind 2 files in one table
meta1= cbind(filese2, filesb2)

# alternatively get the hour data and duplicate it
filesa = files %>% filter (grepl('bin',f)|grepl('Bin',f))
filesa2 = data.frame(dir=dirname(filesa$f), basename (filesa$f))
meta1=cbind(filesa2, filesa2)
#meta1= cbind(filese2, "filesb2"=filese2) #spec vida

#create report table and write it down:
meta1$animal_ID =NA
names (meta1) = c("experiment_folder_name","Onemin_summary", "dir" ,              
                  "Behavior_sequence", "animal_ID")
meta1=meta1 %>% select (experiment_folder_name,Behavior_sequence,Onemin_summary, animal_ID)



#View(meta1) # you should have all files listed in a square dataframe (no NA)
write.csv(meta1, "eachfile2.csv", fileEncoding = "UTF8")

#--- manual intervention needed on eachfile2.csv: -------------
#modification on the csv by hand: check animal ID is the same for 2 files, write animal ID
#if animals were tested more than once, add a distinction in a new column (treatment for instance).
# change file name to eachfile.csv.
#use the file as a base for the metadata file or try to merge it with a different version of the metadata if you can.

#------------------------Merging: code to modify for your data

#now we will read the file back 
meta1=read.csv ("eachfile.csv")
meta1$animal_ID = as.character(meta1$animal_ID)

### manual entries here!
# We will now merge it with  the old metadata file (to be modified for your metadata!):
# read old metadata files : 

data <- read_excel("D:/HCSdata/Rosendmund_VGlut1.1_HCS_all_ML_24112016.xlsx",
col_types = c("text", "text", "text",
"text", "text", "numeric", "numeric",
"numeric", "numeric", "text"))

                                          
#merging:

data$animal_ID <- as.character(data$`animal ID`)
#data$animal_ID <- as.character(data$animal_ID)
#data$animal_ID <- data$`id cohort.2`


a =left_join(data,meta1, by = "animal_ID")

#View(a)
write.csv(a, "metadata4.csv")

# now modify this by hand to get the right column names.
