#------- multidimensional analysis
#1. % time spent on each behavior calculated for each time window, output is one table with one raw being one test (one animal tested)
#2. The table is used  as the input to a multidimensional analysis

#------------1 Create data
#1.1 get minute data from csv file (optional), and put different columns together

#MIN_data = read_csv (paste0(Outputs,'/Min_',Name_project,'.csv'))

Mins <- MIN_data



#---------------group behaviours---------------#

# adjust column names to enable grouping of behaviours over columns
names(Mins)[names(Mins)=="Travel(m)"] = 'distance.traveled'
names(Mins)[names(Mins)=="Drnk(S1)"] = 'Drink.1'
names(Mins)[names(Mins)=="Drnk(S2)"] = 'Drink.2'
names(Mins)[names(Mins)=="Drnk(S3)"] = 'Drink.3'
names(Mins)[names(Mins)=="Eat(Z1)"] = 'Eat.1'
names(Mins)[names(Mins)=="Eat(Z2)"] = 'Eat.2'
names(Mins)[names(Mins)=="Eat(Z3)"] = 'Eat.3'

# used information about groups as identified in 4. Hours file
# got arousal and urinate out (always 0)
behav_gp <- Mins%>% transmute(ID =ID,Bin = Bin, bintodark,Distance_traveled = distance.traveled, ComeDown = ComeDown+CDfromPR, hang = HangCudl+HangVert+HVfromRU+HVfromHC+RemainHC+RemainHV,
                              jump = Jump+ReptJump, immobile=Stationa+Pause+Sleep, rearup = RearUp+RUfromPR+CDtoPR+RUtoPR+RemainPR, digforage=Dig+Forage,
                              walk = Turn+WalkLeft+WalkRght+WalkSlow+Circle, Groom = Groom, #Urinate = Urinate,
                              Twitch = Twitch,
                              #Arousal = Arousal,
                              Awaken = Awaken,Chew = Chew, Sniffing = Sniff, RemainLow = RemainLw,
                              Eat = Eat.1+Eat.2+Eat.3, Drink = Drink.1+Drink.2+Drink.3, Stretch = Stretch)

#1.2 create table of time window in minutes

#enter time windows, values in hours

T1 = c("Bin", 0,2) # 2 first hours of recording
T2= c("Bintodark", -2,0) # last 2h before light off
T3 = c("Bintodark", 0,3) # early night
T4 = c("Bintodark", 9,12) # late night
T5 = c("Bintodark", 12,15) # early day 2

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

#1.4 create result table

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
# 1.5 add only the metadata for grouping, get rid of ID

Multi_datainput_m = left_join(Multi_datainput, metadata %>% select (ID, treatment), by= "ID")

Multi_datainput_m = Multi_datainput_m %>% 
  mutate (groupingvar = as.factor(treatment))%>%
  select (-ID, -treatment)

# 2. multidimensional analysis: random forest

set.seed(71)
HCS.rf <- randomForest(groupingvar ~ ., data=Multi_datainput_m, importance=TRUE,
                        proximity=TRUE)
print(HCS.rf)
## Look at variable importance:
R =round(importance(HCS.rf), 2)
R2=data.frame(row.names (R),R)  %>% arrange(-MeanDecreaseGini)
R2 [1:20,]

#Plot = Multi_datainput_m [,names(Multi_datainput_m) %in% as.character(R2 [1:20,1]) ]
#Plot = cbind(Multi_datainput_m$groupingvar, Plot)
pl <- list()
for (i in c(1:20)){
  Plot = Multi_datainput_m [,names(Multi_datainput_m) %in% as.character(R2 [i,1]) ]
  Plot = cbind(Multi_datainput_m$groupingvar, Plot)
  
  
  Title_plot = paste0(names (Plot) [2],", disciminant_",i)
  names (Plot) = c("groupingvar","disciminant")
  p=ggplot (Plot, aes (y= disciminant, x= groupingvar))+
    geom_boxplot()+
    labs(title = Title_plot)
  #print(p)
  pl[[i]]= p
}

pl.all.discr <- do.call(grid.arrange,c(pl,list(ncol = 5)))

text.all.d = "plotting the most significant variables"



# all graphs in one plot
#setwd(plot.path)
pdf(file = paste0(plot.path,"/100. randomforest_results.pdf"), width = 15, height = 10)

grid.arrange(splitTextGrob(text.all.d),pl.all.discr,
             ncol=1,heights = c(1,5),
             top = textGrob('...',gp=gpar(fontsize = 30, font=3)))

dev.off()
