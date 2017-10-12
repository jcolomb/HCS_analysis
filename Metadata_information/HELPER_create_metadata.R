#---------helpfiles to create metadata.csv without missing files

#set directory to HCS folder with all data, typically "HCS3_output"
library (dplyr)
files = data.frame(f=as.character(dir(recursive = T)),stringsAsFactors = F)

filesb = files %>% filter (grepl('beh',f)| grepl('Beh',f))
filese = files %>% filter (grepl('min',f)|grepl('Min',f))


filese2 = data.frame(dir=dirname(filese$f), basename (filese$f))
filesb2 = data.frame(dir=dirname(filesb$f), basename (filesb$f))

meta1= cbind(filese2, filesb2)
#meta1= cbind(filese2, "filesb2"=filese2) #spec vida
meta1$animal_ID =NA
names (meta1) = c("experiment_folder_name","Onemin_summary", "dir" ,              
                  "Behavior_sequence", "animal_ID")
meta1=meta1 %>% select (experiment_folder_name,Behavior_sequence,Onemin_summary, animal_ID)

#, Behavior_sequence" = basename.filese.f. ,	"Onemin_summary" =basename.filesb.f)

#View(meta1) # you should have all files listed in a square dataframe (no NA)
write.csv(meta1, "eachfile2.csv")

#modification on the csv by hand: check animal ID is the same for 2 files, write animal ID
#if animals were tested more than once, add a distinction in a new column (treatment for instance).
# change file name to eachfile.csv.
#use the file as a base for the metadata file or try to merge it with a different version of the metadata if you can.

#------------------------Merging: code to modify for your data

#now we will read the file again 
meta1=read.csv ("eachfile.csv")
meta1$animal_ID = as.character(meta1$animal_ID)

### manual entries here!
# We will now merge it with  the old metadata file (AOCF only):
# read old metadata files gotten from melissa, 
Tarabykin_HP1TKO_1_HCS_All_old <- read_csv("C:/Users/cogneuro/Desktop/Project_exampledata1/metadata/metadata/Tarabykin_HP1TKO.1_HCS_All_old.csv")
Lookup_Lehnardt_MyD88_1_all <- read_excel("D:/HCSdata/Lookup_Lehnardt_MyD88.1_all.xlsx",sheet = 2)
LookUp_Meisel_EAMG_HCS_all <- read_excel("D:/HCSdata/LookUp_Meisel_EAMG_HCS_all.xlsx",
sheet = "Sheet2", col_types = c("text",
"text", "text", "text", "text", "numeric",
"numeric", "numeric", "text", "text"))
data <- read_excel("D:/HCSdata/Prüß_MNDAREoff.2_HCS_all.xlsx",
sheet = "Sheet2")


Rosendmund_VGlut1_1_HCS_all_ML_24112016 <- read_excel("D:/HCSdata/Rosendmund_VGlut1.1_HCS_all_ML_24112016.xlsx",
col_types = c("text", "text", "text",
"text", "text", "numeric", "numeric",
"numeric", "numeric", "text"))


data <- Lookup_Lehnardt_MyD88_1_all

                                          
#merging:

data$animal_ID <- as.character(data$`animal ID`)
#data$animal_ID <- as.character(data$animal_ID)
#data$animal_ID <- data$`id cohort.2`

a =left_join(data,meta1, by = "animal_ID")

#Lookup_Lehnardt_MyD88_1_all$animal_ID <- as.character(Lookup_Lehnardt_MyD88_1_all$`animal ID`)
#Lookup_Lehnardt_MyD88_1_all$animal_ID <- Lookup_Lehnardt_MyD88_1_all$`id cohort.2`
#LookUp_Meisel_EAMG_HCS_all$animal_ID <- LookUp_Meisel_EAMG_HCS_all$`animal ID`
#Rosendmund_VGlut1_1_HCS_all_ML_24112016$animal_ID <- Rosendmund_VGlut1_1_HCS_all_ML_24112016$`animal ID`
#a =left_join(Rosendmund_VGlut1_1_HCS_all_ML_24112016,meta1, by = c("animal_ID", "treatment"))
#View(a)
write.csv(a, "metadata4.csv")

# now modify this by hand to get the right column names.
