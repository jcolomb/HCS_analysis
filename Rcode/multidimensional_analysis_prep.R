#------- multidimensional analysis
#1. % time spent on each behavior calculated for each time window, output is one table with one raw being one test (one animal tested)
#2. The table is used  as the input to a multidimensional analysis
#------------REmarks---------------------------------------------------
Remarks = "modification of T5: tarabikin got a different T5, because some recording are not going until lightoff+15"
# set number of variables to be chosen after the randomforest:
numberofvariables =20

#------------1 Create data---------------------------------------------------

#1.1 get minute data from csv file (optional),
# and put different columns together (group behavior)

#MIN_data = read_csv (paste0(Outputs,'/Min_',Name_project,'.csv'))
Mins <- MIN_data

source ("Rcode/grouping_variables.r")

# calculate maxtime where all mice have data (time relative to light off)
temp =Mins %>% group_by(ID)%>% summarise(max(bintodark))
MAXTIME=trunc(min (temp$`max(bintodark)`)/6)/10




#1.2 create table of time window in minutes

#enter time windows, values in hours

T1 = c("Bin", 0,2) # 2 first hours of recording
T2= c("Bintodark", -2,0) # last 2h before light off
T3 = c("Bintodark", 0,3) # early night
T4 = c("Bintodark", 9,12) # late night
#T5 = c("Bintodark", 12,15) # early day 2
T5 = c("Bintodark", 12,min (15,MAXTIME)) # early day 2: 3h or maximal time with all mice included

#create table with numeric values, values being in minutes
Timewindows = data.frame(rbind(T1,T2,T3,T4,T5))
colnames (Timewindows) = c("time_reference", "windowstart", "windowend")

Timewindows =Timewindows %>%
  mutate (windowstart = 60*as.numeric (as.character(windowstart)))%>%
  mutate (windowend = 60*as.numeric (as.character(windowend)))

#1.3 function to calculate values
get_windowsummary <- function(windowdata) {
  temp= windowdata %>% group_by(ID) %>% 
    summarise_if(is.numeric,funs(sum)) %>%
    select (- Bin, -bintodark)
  names (temp)[-1]= paste0(names (temp)[-1],i)
  return(temp)
}
# ####TODO get sum count of bins to get %age and not values
# get_windowsummary <- function(windowdata) {
#   temp= windowdata %>% group_by(ID) %>% 
#     summarise_if(is.numeric,funs(sum)) %>%
#     select ( -bintodark)
#   names (temp)[-1]= paste0(names (temp)[-1],i)
#   return(temp)
# }

#1.4 create result table
if (groupingby == "AOCF"){
  behav_gp =behav_gp
} else if (groupingby == "MITsoft") {
  behav_gp = behav_jhuang
} 

Multi_datainput = behav_gp %>% group_by(ID) %>% 
  summarise_if(is.character,funs(sum)) %>% select (ID)

for (i in c(1:nrow(Timewindows))){
  # filer to data in the time window
  if (Timewindows$time_reference [i] =="Bin"){
    windowdata = behav_gp %>% filter (Bin > Timewindows [i,2] & Bin < Timewindows [i,3])
  }else if (Timewindows$time_reference[i] =="Bintodark"){
    windowdata = behav_gp %>% filter (bintodark > Timewindows [i,2] & bintodark < Timewindows [i,3])
  }else print ("error in timewindows table")
  
  #calculate values and add it to the result data frame
  Multi_datainput = inner_join (Multi_datainput,get_windowsummary(windowdata), by ="ID")
  
}

# save data for later use


write.table(Multi_datainput, paste0(Outputs,'/timedwindowed_',groupingby,"_",Name_project,'.csv'), sep = ';',row.names = FALSE)

