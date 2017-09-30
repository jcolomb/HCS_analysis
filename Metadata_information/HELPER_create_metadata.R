#---------helpfiles to create metadata.csv without missing files

#set directory to HCS folder with all data, typically "HCS3_output"
library (dplyr)
files = data.frame(f=as.character(dir(recursive = T)),stringsAsFactors = F)

filesb = files %>% filter (grepl('beh',f)| grepl('Beh',f))
filese = files %>% filter (grepl('min',f)|grepl('Min',f))


filese2 = data.frame(dir=dirname(filese$f), basename (filese$f))
filesb2 = data.frame(dir=dirname(filesb$f), basename (filesb$f))

meta1= cbind(filese2, filesb2)
meta1$animal_ID =NA
View(meta1) # you should have all files listed in a square dataframe (no NA)
write.csv(meta1, "eachfile2.csv")

#modification on the csv by hand: check animal ID is the same for 2 files, write animal ID
#if animals were tested more than once, add a distinction in a new column (treatment for instance).
# change file name to eachfile.csv.
#use the file as a base for the metadata file or try to merge it with a different version of the metadata if you can.

#------------------------Merging: code to modify for your data

#now we will read the file again 
meta1=read.csv ("eachfile.csv")

### manual entries here!
# We will now merge it with  the old metadata file (AOCF only):
# read old metadata files gotten from melissa, 
Tarabykin_HP1TKO_1_HCS_All_old <- read_csv("C:/Users/cogneuro/Desktop/Project_exampledata1/metadata/metadata/Tarabykin_HP1TKO.1_HCS_All_old.csv")
Lookup_Lehnardt_MyD88_1_all <- read_excel("D:/HCSdata/Lookup_Lehnardt_MyD88.1_all.xlsx",sheet = 2)

data <- Schmidt_Metadata_HCS_All
                                          
#merging:

data$animal_ID <- data$`animal ID`
#data$animal_ID <- data$`id cohort.2`

a =left_join(data,meta1, by = "animal_ID")
#View(a)
write.csv(a, "metadata3.csv")

# now modify this by hand to get the right column names.
