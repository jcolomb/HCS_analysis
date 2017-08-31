#read main metadata file
Projects_metadata <- read_csv(PMeta)
#choose line containing the project we want to analyse
Projects_metadata = Projects_metadata %>% filter (Proj_name == Name_project)

# get additional metadata
animal_meta= read_csv(paste(WD,Projects_metadata$Folder_path, Projects_metadata$animal_metadata, sep = "/"),
                      col_names =T,cols(
                        `animal ID` = col_character(),
                        gender = col_character(),
                        treatment = col_character(),
                        genotype = col_character(),
                        date = col_character(),
                        `test cage` = col_character(),
                        `real time start` = col_time(format = ""),
                        experiment_folder_name = col_character(),
                        Behavior_sequence = col_character(),
                        Onemin_summary = col_character(),
                        Lab_ID = col_character()
                      )
)
animal_meta$Proj_name = Name_project
lab_meta= read_csv(paste(WD,Projects_metadata$Folder_path, Projects_metadata$lab_metadata, sep = "/")
)

metadata=left_join(left_join(animal_meta, lab_meta , by ="Lab_ID"),Projects_metadata, by ="Proj_name")
metadata$ID = as.character(c(100: (99+nrow(metadata))))
