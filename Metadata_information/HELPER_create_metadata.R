#---------helpfiles to create metadata.csv without missing files

#set directory to HCS folder with all data

files = data.frame(f=as.character(dir(recursive = T)),stringsAsFactors = F)

filesb = files %>% filter (grepl('beh',f)| grepl('Beh',f))
filese = files %>% filter (grepl('min',f)|grepl('Min',f))


filese2 = data.frame(dir=dirname(filese$f), basename (filese$f))
filesb2 = data.frame(dir=dirname(filesb$f), basename (filesb$f))

View(cbind(filese2, filesb2)) # you should have all files listed in a square dataframe (no NA)
write.csv(cbind(filese2, filesb2), "eachfile2.csv")

#modification on the csv by hand: check animal ID is the same for 2 files, write animal ID and treatment columns similar to original metadata file
#now we will read the file again and merge it with the old metadata file:
meta1=read_csv ("eachfile.csv")
# read old metadata files gotten from melissa
Tarabykin_HP1TKO_1_HCS_All_old <- read_csv("C:/Users/cogneuro/Desktop/Project_exampledata1/metadata/metadata/Tarabykin_HP1TKO.1_HCS_All_old.csv")

#merging:
a =left_join(Tarabykin_HP1TKO_1_HCS_All_old,meta1, by = c("animal ID","treatment"))
#View(a)
write.csv(a, "metadata2.csv")
