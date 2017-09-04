#---------------group behaviours for event file ---------------#

# group behaviours following Adama-Biassi 2013 (see above)

#### transform behaviour names according to grouping
behav_temp = EVENT_data %>% mutate(behav_ori = behav) %>%
      mutate(behav = as.character(behav)) %>%
      mutate (duration = seconds)  
  )# create a temporary data.frame with all behaviour information

for (i in 1:nrow(behav_temp)) { #for all rows in data frame check the following
  if (grepl('Hang',behav_temp$behav[i])) { # check if entry in given row contains the word 'Hang'
    behav_temp$behav[i] = 'Hang'  # if it contains the term -> change entry to resepective new behaviour name (here: 'Hang')
  } else if(grepl('CD',behav_temp$behav[i]) | grepl('Come Down F',behav_temp$behav[i]) | (grepl('Come Down', behav_temp$behav[i]) & !grepl('Come Down T',behav_temp$behav[i])) ) { #repeat logic as before for all behaviour groups
    behav_temp$behav[i] = 'ComeDown'
  } else if(grepl('Drink',behav_temp$behav[i])) {
    behav_temp$behav[i] = 'Drink'
  } else if(grepl('Eat',behav_temp$behav[i])) {
    behav_temp$behav[i] = 'Eat'
  } else if(grepl('Dig',behav_temp$behav[i]) | grepl('Forage',behav_temp$behav[i])) {
    behav_temp$behav[i] = 'digforage'
  } else if(grepl('Jump',behav_temp$behav[i])) {
    behav_temp$behav[i] = 'Jump'
  } else if(grepl('Pause',behav_temp$behav[i]) | grepl('Sleep',behav_temp$behav[i]) | grepl('Station', behav_temp$behav[i])) {
    behav_temp$behav[i] = 'immobile'
  } else if(grepl('Rear', behav_temp$behav[i])) {
    behav_temp$behav[i] = 'rearup'
  } else if(grepl('Walk', behav_temp$behav[i])) {
    behav_temp$behav[i] = 'Walk'
  }
}

unique(behav_temp$behav)

unique(behav_temp$behav_ori)

