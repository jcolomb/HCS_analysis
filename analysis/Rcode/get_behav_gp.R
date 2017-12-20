source("Rcode/inputdata.r") #output = metadata



#computed variables2
# folder where outputs will be written:
Outputs = paste(WD,Projects_metadata$Folder_path,"Routputs", sep="/")
onlinemin=Outputs 
#for online projects, outputs are written on disk:
if (WD == "https:/") Outputs = paste("../Routputs",Projects_metadata$Folder_path, sep="/")

dir.create (Outputs, recursive = TRUE)
plot.path = Outputs


#check data file existence and if the number of file correspond between the folder and the metadata
#create list of filepath for each animal_ID
source("Rcode/checkmetadata.r") #output BEH_datafiles and MIN_datafiles: list of path

# create a new column with the variable that are splitting the data into groups:
source ("Rcode/animal_groups.r") # output metadata$groupingvar


#create and save minute files (one file for all mice): returns MIN_data
# some warnings appear because the last line of the minute data is the sum.
# that raw is taken out of the MIN_data.

source ("Rcode/create_minfile.r") # output MIN_data, work probably only with HCS data

#filter data if data need exclusion:
metadata$Exclude_data[is.na(
  metadata$Exclude_data)] <- 'include'

metadata = metadata %>% filter (Exclude_data != "exclude")

MIN_data =MIN_data %>% filter(ID %in% metadata$ID)

#tests
#summary (as.factor(metadata$animal_ID))
#summary (as.factor(MIN_data$animal_ID))
#cbind(metadata$animal_ID, metadata$genotype)


#-------------------Run the analysis              ----------------------------


# get output
#source ("Rcode/multidimensional_analysis_RFsvm.R")
#save.image(paste0("Reports/multidim_",Name_project,".rdata"))

#multidimensional analysis, prepare data
source ("Rcode/multidimensional_analysis_prep.R") # return Multi_datainput_m or Multi_datainput_m2
