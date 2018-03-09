#-- analyse behavior sequence.
library (tidyverse)
#load ("...") get other info like metadata

#-- Goal compare night and day data, what happens after sleep (2 next behavior)

dataraw_ori <-
  read_delim(
    "~/github_repo/HCS_analysis/data/Ro_testdata/BSeqAnal_v0.1.1-alpha/Bseq_Ro_testdata_mbr.csv",
    ";",
    escape_double = FALSE,
    col_types = cols(
      animal_ID = col_character(),
      end = col_double(),
      start = col_double()
    ),
    trim_ws = TRUE
  )

Behav_code <-
  read_delim(
    "analysis/infos/HCS_MBR_Code_Details/Short Behavior Codes-Table 1.csv",
    ",",
    escape_double = FALSE,
    col_types = cols(`Behavior Code` = col_integer()),
    trim_ws = TRUE,
    skip = 1
  )[, c(1, 3)]
names (Behav_code) = c("behavior", "beh_name")

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
nightstart=behav_gp$Bin [behav_gp$bintodark == 0]

Nendbin=(as.numeric(strsplit(
  format(metadata$light_off, "%H:%M:%S"), split = ':'
)[[1]][1]) * 60) +
  as.numeric(strsplit(format(metadata$light_off, "%H:%M:%S"), split = ':')[[1]][2])

nightend=nightstart+ Nendbin

#-- for each animal 
ani = 100
beh= 29 #sleep

#-- get next behavior for awaken
bseq_an = dataraw %>% filter (animal_ID== ani) %>%
  filter (behavior == beh)

bseq_an$behavior_n1 [bseq_an$behavior_n1 == 32] =bseq_an$behavior_n2[bseq_an$behavior_n1 == 32]


R1=bseq_an %>%
  group_by(behavior_n1) %>%
  summarise (n=n())
names(R1)=c("behavior", "freq")
R1 =left_join(R1,Behav_code, by= "behavior")

R1




View(dataraw)

#dataraw %>% filter (start >(1712669-2000) & start <(1712669+60) ) %>%
#  filter (animal_ID == 107)
