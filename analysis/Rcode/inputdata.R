#read main metadata file
Projects_metadata <- read_csv(PMeta)
#-- choose line containing the project we want to analyse
Projects_metadata = Projects_metadata %>% filter (Proj_name == Name_project)


#-- define WD: path to the folder
WD= NA
WD = ifelse (Projects_metadata$source_data =="this_github", "../data",WD)
WD = ifelse (Projects_metadata$source_data =="USB_stick", STICK,WD)
WD = ifelse (Projects_metadata$source_data =="https:/", "https:/",WD)
#-- get additional metadata
animal_meta = read_csv(
  paste(
    WD,
    Projects_metadata$Folder_path,
    Projects_metadata$animal_metadata,
    sep = "/"
  ),
  col_names = TRUE,
  cols(
    animal_ID = col_character(),
    gender = col_character(),
    treatment = col_character(),
    genotype = col_character(),
    date = col_character(),
    test_cage = col_character(),
    real_time_start = col_time(format = ""),
    experiment_folder_name = col_character(),
    Behavior_sequence = col_character(),
    Onemin_summary = col_character(),
    Lab_ID = col_character()
  )
)

animal_meta$Proj_name = Name_project

lab_meta = read_csv(paste(
  WD,
  Projects_metadata$Folder_path,
  Projects_metadata$lab_metadata,
  sep = "/"
))

#-- put all information together
metadata=left_join(left_join(animal_meta, lab_meta , by ="Lab_ID"),Projects_metadata, by ="Proj_name")
#-- add an ID for each animal (number starting at 100)
metadata$ID = as.character(c(100: (99+nrow(metadata))))
