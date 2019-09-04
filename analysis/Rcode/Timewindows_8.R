#------- Time windows creation.

# 1. get data and group variables- calculate MAXTIME

Mins <- MIN_data
Mins$animal_ID = as.character(Mins$animal_ID)

source ("Rcode/grouping_variables.r")

# calculate maxtime where all mice have data (time relative to light off), rounded
temp =Mins %>% group_by(ID)%>% summarise(max(bintodark))
MAXTIME=trunc(min (temp$`max(bintodark)`)/6)/10


#2 create table of time window in minutes

#2.1 calculate lenght of the day from the metadata:
LIGHT_ON = (as.numeric(strsplit(format(metadata$light_on,"%H:%M:%S"),split = ':')[[1]][1])*60)+
  as.numeric(strsplit(format(metadata$light_on,"%H:%M:%S"),split = ':')[[1]][2])
LIGHT_OFF = (as.numeric(strsplit(format(metadata$light_off,"%H:%M:%S"),split = ':')[[1]][1])*60)+
  as.numeric(strsplit(format(metadata$light_off,"%H:%M:%S"),split = ':')[[1]][2])
daylenght =(LIGHT_OFF-LIGHT_ON)/60
nightlenght = 24-daylenght

#2.2 create table: single elements:
T1 = c("Bin", 0,2,"first 2 hours of recording") # 2 first hours of recording
T2= c("Bintodark", -2,0, "last 2h before night") # last 2h before light off
T3 = c("Bintodark", 0,3, "first 3h of night") # early night
T35 =c("Bintodark", 3,nightlenght-3, "middle night") #middle night
T4 = c("Bintodark", nightlenght-3,min ((nightlenght),MAXTIME), "late night (3h)") # late night
#T5 = c("Bintodark", 12,15) # early day 2
T5 = c("Bintodark", nightlenght,min ((nightlenght+3),MAXTIME),"early day(3h)") # early day 2: 3h or maximal time with all mice included

T6= c("Bintodark", -2,min ((nightlenght+3),MAXTIME), "full recording")
T7 = c("lightcondition", "DAY",NA, "daytime")
T8 = c("lightcondition", "NIGHT", NA, "nighttime")

#2.3 put the table together

#create table with numeric values, values being in minutes
#Timewindows = data.frame(rbind(T1,T2,T3,T4,T5)) #original split
Timewindows = data.frame(rbind(T1,T2,T3,T35,T4,T5,T6,T7,T8))
Timewindows = Timewindows[1:7,]
#if (MAXTIME<daylenght) Timewindows = data.frame(rbind(T1,T2,T3,T35,T4))
colnames (Timewindows) = c("time_reference", "windowstart", "windowend", "windowname")
Timewindows$time_reference = as.character(Timewindows$time_reference)
Timewindows =Timewindows %>%
  mutate (windowstart = 60*as.numeric (as.character(windowstart)))%>%
  mutate (windowend = 60*as.numeric (as.character(windowend)))
Timewindows = data.frame(rbind(Timewindows,T7,T8))

Timewindows = Timewindows %>% filter ( is.na(windowend) | windowstart < windowend )

