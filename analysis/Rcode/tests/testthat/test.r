# variables

test_that("groupingby variable not correct",
          expect_true(all(groupingby %in% c("Berlin", "Jhuang")))
          )

# inputdata.r


test_that("source_data not indicated properly",expect_is(WD,"character"))
test_that("video analysis software not supported",expect_match(Projects_metadata$video_analysis, "HCS 3.0"))


# animalgroups.r

test_that("group_by should either be one element or elements separated with a + sign, and should correspond to metadata headers",{
  expect_gt(length(groups),0)
  expect_true(all(groups %in% names(metadata)))
})
          

# grouping_variables.r, run after the code is run.

test_that("headers of the data does not fit the expectation, please check.",{
  expect_true(all(
    names(Mins) %in% c("Bin", "ComeDown", "RearUp", "Turn", "Stretch", "HangCudl", 
                       "HangVert", "CDfromPR", "CDtoPR", "RUfromPR", "RUtoPR", "LandVert", 
                       "WalkLeft", "WalkRght", "Stationa", "Drink.1", "Eat.1", "Jump", 
                       "Unknown", "HVfromRU", "HVfromHC", "ReptJump", "Circle", "Dig", 
                       "Forage", "Pause", "Urinate", "Groom", "Sleep", "Twitch", "Arousal", 
                       "Awaken", "Chew", "Sniff", "RemainRU", "RemainPR", "RemainHV", 
                       "RemainHC", "RemainLw", "WalkSlow", "No Data", "Drink.2", "Drink.3", 
                       "Eat.2", "Eat.3", "distance.traveled", "ID", "bintodark", "animal_ID", 
                       "gender", "treatment", "genotype", "date", "test.cage", "real.time", 
                       "dark.start", "project.name", "dark.start.min", "Eat", "Drink", 
                       "animal_birthdate", "other_category", "test_cage", "real_time_start", 
                       "Lab_ID", "Exclude_data", "comment", "experiment_folder_name", 
                       "Behavior_sequence", "Onemin_summary", "Onehour_summary", "primary_behav_sequence", 
                       "primary_position_time", "primary_datafile", "Proj_name", "light_on", 
                       "light_off", "temperature", "cage_type", "address", "north_position", 
                       "daylight_intensity_lux", "daylight_spectrum", "nightlight_intensity_lux", 
                       "Identifier", "Title", "Creator", "Contributors", "Creator_email", 
                       "Publisher", "Publication year", "Production year", "Subject area", 
                       "Resource", "Rights", "rights holder", "Description_comments", 
                       "funder information", "video_acquisition", "video_analysis", 
                       "group_by", "confound_by", "source_data", "Folder_path", "raw_data_folder", 
                       "video_folder", "animal_metadata", "lab_metadata", "indentificator_metadata", 
                       "groupingvar", "lightcondition")
    
  ))
})

# createmin.r, timewindows_8.r

test_that("the software expect the experiment to start in day light, time windows will not all work otherwise",{
  expect_true(all(MIN_data %>% filter (Bin == 1) %>% select (bintodark)<0))
})

test_that("error in timewindows table",
          expect_true(all(Timewindows$time_reference %in% c("Bin", "Bintodark","lightcondition")))
)

#

ICA$groupingvar = as.character(ICA$groupingvar)
ICA$groupingvar[1]="test"
