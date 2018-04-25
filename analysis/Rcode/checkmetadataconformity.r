# View(metadata)
# metadata2= metadata
#metadata$date[1]= NA
# # test date formats:
# as.Date(metadata$date)
# as.Date(metadata$animal_ID)
errors = c()
warnings = c()

if (all (is.na(metadata$date))){
  warnings =c(warnings,"The format of the date (of experiment) is probably wrong, please use yyyy-mm-dd")
}

if (!all (!is.na(metadata$date))){
  warnings =c(warnings, paste0(sum(is.na(metadata$date))," dates of experiment are missing or have a wrong format?"))
}

if (all (is.na(metadata$animal_birthdate))){
  warnings =c(warnings,"The format of the date is probably wrong, please use yyyy-mm-dd")
}

if (!all (!is.na(metadata$animal_birthdate))){
  warnings =c(warnings, paste0( sum(is.na(metadata$date))," animal birthday dates are missing or have a wrong format ?"))
}

metadata$gender [metadata$gender %in% c("f", "F", "Female")] = "female"
metadata$gender [metadata$gender %in% c("m", "M", "Male")] = "male"

if (!all (!is.na(metadata$real_time_start))){
  errors =c(errors, paste0( sum(is.na(metadata$real_time_start))," real_time_start is needed for each animal, check format : hh:mm:ss"))
}

if (!all(metadata$Lab_ID %in% lab_meta$Lab_ID)){
  errors =c(errors,"there is some error with the Lab_ID")
}

if (!all (!is.na(metadata$light_on))){
  errors =c(errors, paste0( sum(is.na(metadata$real_time_start))," light_on must be indicated for each lab metadata, check format : hh:mm:ss"))
}

if (!all (!is.na(metadata$light_off))){
  errors =c(errors, paste0( sum(is.na(metadata$real_time_start))," light_off must be indicated for each lab metadata, check format : hh:mm:ss"))
}

if (!all(metadata$group_by %in% c("genotype", "treatment", "other_category", "genotype + other_category", " genotype + treatment") )){
  errors =c(errors,"How to group the variable must be indicated correctly")
}

if (!all(metadata$source_data %in% c("USB_stick", "this_github", "https:/"))){
  errors =c(errors,"source_data is incorrectly given.")
}

errors_t= c(paste("error:",errors),paste("warning:",warnings))
