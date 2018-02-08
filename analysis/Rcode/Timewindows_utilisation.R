#------------------ choose only some time windows

Timewindows = Timewindows[selct_TW,]


#-------------add a column to the data saying if it is day or night

# get time of start in minutes (temp):
temp=t(as.data.frame(strsplit(format(metadata$real_time_start,"%H:%M:%S"),split = ':')))
temp= as.data.frame(temp)
names (temp)= c("hr","min", "sec")
temp <- temp %>% mutate (time= as.numeric(as.character(hr))*60+ as.numeric(as.character(min)))

# add the column to metadata and Mins, get light conditions in minadd
metadata$start_time_min =temp$time
Mins=left_join (Mins,metadata)
Mins= Mins %>% mutate(timeofday = (start_time_min+Bin) %% (24*60)) %>% 
  mutate (lightcondition = ifelse(timeofday >LIGHT_ON & timeofday <LIGHT_OFF, "DAY","NIGHT")) %>%
  select (-timeofday, -start_time_min)
Mins$lightcondition = as.factor(Mins$lightcondition)
minadd= Mins %>% select (ID, Bin, lightcondition)

#----------------------- create result table (Multi_datainput_m, behav_gp)

#--choose the behavior grouping used (both defined during grouping_variables.r called from Timewindows_8.r)

if (groupingby == "AOCF"){
  behav_gp =behav_gp
} else if (groupingby == "MITsoft") {
  behav_gp = behav_jhuang
} 

#-- add lightcondition to behav_gp
behav_gp = left_join(behav_gp, minadd)

#-- create Multi_datainput: 1 for character elements
Multi_datainput = behav_gp %>% group_by(ID) %>% 
  summarise_if(is.character,funs(sum)) %>% select (ID)

#-- create Multi_datainput: 2 get a value for each time window,:
#--- 1 take all data for a window

for (i in c(1:nrow(Timewindows))){
  # filer to data in the time window
  if (Timewindows$time_reference [i] =="Bin"){
    windowdata = behav_gp %>% filter (Bin > Timewindows [i,2] & Bin < Timewindows [i,3])
  }else if (Timewindows$time_reference[i] =="Bintodark"){
    windowdata = behav_gp %>% filter (bintodark > Timewindows [i,2] & bintodark < Timewindows [i,3])
  }else if (Timewindows$time_reference[i] =="lightcondition"){
    windowdata = behav_gp %>% filter (lightcondition == Timewindows [i,2] )
  }else print ("error in timewindows table")
  
  #based on the get_windowsummary() function, calculate values and add it to the result data frame
  Multi_datainput = inner_join (Multi_datainput,get_windowsummary(windowdata, i=i), by ="ID")
  
}

#-- save data for later use


write.table(Multi_datainput, paste0(Outputs,'/timedwindowed_',groupingby,"_",Name_project,'.csv'), sep = ';',row.names = FALSE)

#-- add groupingvar, take ID out 
Multi_datainput_m = left_join(Multi_datainput, metadata %>% select (ID, groupingvar), by= "ID")

Multi_datainput_m = Multi_datainput_m %>% 
  mutate (groupingvar = as.factor(groupingvar))%>%
  select (-ID)

#-- alternatively add groupingvar + confoundvar
if (!is.na(Projects_metadata$confound_by)){
  Multi_datainput_m2 = left_join(Multi_datainput, metadata %>% select (ID, groupingvar, confoundvar), by= "ID")
  
  Multi_datainput_m2 = Multi_datainput_m2 %>% 
    mutate (groupingvar = as.factor(groupingvar))%>%
    select (-ID)
}