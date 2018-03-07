#-- analyse behavior sequence.

#-- Goal compare night and day data, what happens after sleep (2 next behavior)

dataraw_ori <- read_delim("C:/Users/cogneuro/Desktop/HCS_analysis/data/Ro_testdata/BSeqAnal_v0.1.1-alpha/Bseq_Ro_testdata_mbr.csv",
";", escape_double = FALSE, col_types = cols(animal_ID = col_character()),
trim_ws = TRUE)

#-- save original and clean data
 dataraw <- dataraw_ori
dataraw =left_join(dataraw,Behav_code, by= "behavior")
dataraw = dataraw [(dataraw$end-dataraw$start >0),]

#-- create column, with NA for first entry 
dataraw$behavior_n1 =dataraw$behavior
dataraw$behavior_n1 [dataraw$start ==0] =NA
dataraw$behavior_n1 =c(dataraw$behavior [-1], NA) # add column next behavior (add column, )



#-- once again for second in line behavior
dataraw$behavior_n2 =dataraw$behavior_n1
dataraw$behavior_n2 [dataraw$start ==0] =NA
dataraw$behavior_n2 =c(dataraw$behavior_n2 [-1], NA)


#-- get only night data
behav_gp


View(dataraw)

#dataraw %>% filter (start >(1712669-2000) & start <(1712669+60) ) %>%
#  filter (animal_ID == 107)
