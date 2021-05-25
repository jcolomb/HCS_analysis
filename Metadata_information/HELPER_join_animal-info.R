#--- manual intervention needed on eachfile2.csv: -------------
## This may be used to include information about the animals present in a different spreadsheet.
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