source("Rcode/inputdata.r") #output = metadata

#-- create folders for outputs.

foldername= paste0("BSeq_analyser",version)
Outputs = paste(WD,Projects_metadata$Folder_path,foldername, sep="/")
onlinemin=paste(WD,Projects_metadata$Folder_path,"BSeq_analyser_data", sep="/")

#for online projects, outputs are written on disk:
if (Projects_metadata$source_data == "https:/") {
  Outputs = paste("../Routputs",Projects_metadata$Folder_path, sep="/")
  onlinemin = Outputs
}

dir.create (Outputs, recursive = TRUE)
dir.create (onlinemin, recursive = TRUE)
plot.path = Outputs


#check data file existence and if the number of file correspond between the folder and the metadata
#create list of filepath for each animal_ID
source("Rcode/checkmetadata.r") #output Hour_datafiles, BEH_datafiles and MIN_datafiles: list of path

# create a new column with the variable that are splitting the data into groups:
source ("Rcode/animal_groups.r") # output metadata$groupingvar


#--- create and save minute files (one file for all mice): returns MIN_data
# some warnings appear because the last line of the minute data is the sum.
# that raw is taken out of the MIN_data.

source ("Rcode/create_minfile.r") # output MIN_data, work probably only with HCS data

# save minute summary to a Routputs folder (for online pushed projects!)
  write.table(
    MIN_data,
    paste0(onlinemin, '/Min_', Name_project, '.csv'),
    sep = ';',
    row.names = FALSE
  )

#--- filter data if data need exclusion:
metadata$Exclude_data[is.na(
  metadata$Exclude_data)] <- 'include'

metadata = metadata %>% filter (Exclude_data != "exclude")

MIN_data =MIN_data %>% filter(ID %in% metadata$ID)

MIN_data =droplevels(MIN_data)
metadata =droplevels(metadata)
#tests
#summary (as.factor(metadata$animal_ID))
#summary (as.factor(MIN_data$animal_ID))
#cbind(metadata$animal_ID, metadata$genotype)


#-------------------work with time windows

#multidimensional analysis, prepare data
source ("Rcode/Timewindows_8.r") # get time windows
source ("Rcode/Timewindows_utilisation.r") # return Multi_datainput_m or Multi_datainput_m2
