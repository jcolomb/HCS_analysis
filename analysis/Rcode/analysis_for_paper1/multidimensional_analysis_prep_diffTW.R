#------- multidimensional analysis
#1. % time spent on each behavior calculated for each time window, output is one table with one raw being one test (one animal tested)
#2. The table is used  as the input to a multidimensional analysis
#------------REmarks---------------------------------------------------


#------------1 Create data---------------------------------------------------

#1.1 get minute data from csv file (optional),
# and put different columns together (group behavior)

#MIN_data = read_csv (paste0(Outputs,'/Min_',Name_project,'.csv'))
Mins <- MIN_data

source ("Rcode/grouping_variables.r")

# calculate maxtime where all mice have data (time relative to light off), rounded
temp =Mins %>% group_by(ID)%>% summarise(max(bintodark))
MAXTIME=trunc(min (temp$`max(bintodark)`)/6)/10




#1.2 create table of time window in minutes

#calculate lenght of the day from the metadata:
LIGHT_ON = (as.numeric(strsplit(format(metadata$light_on,"%H:%M:%S"),split = ':')[[1]][1])*60)+
  as.numeric(strsplit(format(metadata$light_on,"%H:%M:%S"),split = ':')[[1]][2])
LIGHT_OFF = (as.numeric(strsplit(format(metadata$light_off,"%H:%M:%S"),split = ':')[[1]][1])*60)+
  as.numeric(strsplit(format(metadata$light_off,"%H:%M:%S"),split = ':')[[1]][2])
daylenght =(LIGHT_OFF-LIGHT_ON)/60

#enter time windows, values in hours


T1 = c("Bin", 0,2) # 2 first hours of recording
T2= c("Bintodark", -2,0) # last 2h before light off
T3 = c("Bintodark", 0,3) # early night
T35 =c("Bintodark", 3,daylenght-3) #middle day
T4 = c("Bintodark", daylenght-3,min ((daylenght),MAXTIME)) # late night
#T5 = c("Bintodark", 12,15) # early day 2
T5 = c("Bintodark", daylenght,min ((daylenght+3),MAXTIME)) # early day 2: 3h or maximal time with all mice included

T6= c("Bintodark", -2,min ((daylenght+3),MAXTIME))
#create table with numeric values, values being in minutes
#Timewindows = data.frame(rbind(T1,T2,T3,T4,T5)) #original split
Timewindows = data.frame(rbind(T1,T2,T3,T4,T5,T6))
#if (MAXTIME<daylenght) Timewindows = data.frame(rbind(T1,T2,T3,T35,T4))
colnames (Timewindows) = c("time_reference", "windowstart", "windowend")

Timewindows =Timewindows %>%
  mutate (windowstart = 60*as.numeric (as.character(windowstart)))%>%
  mutate (windowend = 60*as.numeric (as.character(windowend)))



#set transformation for %age time data (i.e. not distance traveled, all the other)
#we cannot use log (too many 0), the Arcsin is also not usable since we will do regressions afterwards.
calcul = function (x){
  sqrt(mean (x)/60)
}
calcul_text = "data (%age of time spent doing the behavior) transformed using the square root method."

## use calcul fonction and get values for one window:
get_windowsummary <- function(windowdata) {
  temp1= windowdata %>% group_by(ID) %>% 
    #summarise_if(is.numeric,funs(mean)) %>%   # we take the mean and not the sum, to account for different window size
    summarise_at(vars(Distance_traveled),funs(mean))
  

  temp2= windowdata %>% group_by(ID) %>% 
    select (- Bin, -bintodark, -Distance_traveled) %>%
    summarise_if(is.numeric,funs(calcul))   # we take the mean and not the sum, to account for different window size
    #summarise_at(vars(Distance_traveled),funs(mean)) %>%
    
  temp = inner_join(temp1,temp2)
  names (temp)[-1]= paste0(names (temp)[-1],i)
  return(temp)
}


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

#add groupingvar 
Multi_datainput_m = left_join(Multi_datainput, metadata %>% select (ID, groupingvar), by= "ID")

Multi_datainput_m = Multi_datainput_m %>% 
  mutate (groupingvar = as.factor(groupingvar))%>%
  select (-ID)

#add groupingvar + confoundvar
if (!is.na(Projects_metadata$confound_by)){
  Multi_datainput_m2 = left_join(Multi_datainput, metadata %>% select (ID, groupingvar, confoundvar), by= "ID")

  Multi_datainput_m2 = Multi_datainput_m2 %>% 
  mutate (groupingvar = as.factor(groupingvar))%>%
  select (-ID)
}