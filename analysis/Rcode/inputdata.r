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
    animal_birthdate = col_date(format = ""),
    gender = col_character(),
    treatment = col_character(),
    genotype = col_character(),
    other_category = col_character(),
    date = col_date(format = ""),
    test_cage = col_character(),
    real_time_start = col_time(format = ""),
    Lab_ID = col_character(),
    Exclude_data = col_character(),
    comment = col_character(),
    experiment_folder_name = col_character(),
    Behavior_sequence = col_character(),
    Onemin_summary = col_character(),
    Onehour_summary = col_character(),
    primary_behav_sequence = col_character(),
    primary_position_time = col_character(),
    primary_datafile = col_character()
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

if (Projects_metadata$video_analysis =="HCS 3.0"){
  Behav_code <-
    read_delim(
      "infos/HCS_MBR_Code_Details/Short Behavior Codes-Table 1.csv",
      ",",
      escape_double = FALSE,
      col_types = cols(`Behavior Code` = col_integer()),
      trim_ws = TRUE,
      skip = 1
    )[, c(1, 3)]
  names (Behav_code) = c("behavior", "beh_name")
  
  framepersec = 25
}
