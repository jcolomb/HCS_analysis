#read main metadata file
Projects_metadata <- read_csv(PMeta)

# get additional metadata
animal_meta= read_csv(paste(WD,Projects_metadata$Folder_path, Projects_metadata$animal_metadata, sep = "/")
)
lab_meta= read_csv(paste(WD,Projects_metadata$Folder_path, Projects_metadata$lab_metadata, sep = "/")
)
