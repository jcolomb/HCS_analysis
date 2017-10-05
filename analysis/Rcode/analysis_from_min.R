####################################
# 5.1. data loading & manipulation
####################################

# assign loaded data to dist variable
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

#behav_gp = cbind(Mins[,c(1:13)],behav_gp)



# no genotype in new files
# ### convert genotpye into factor for later analysis
# if (is.factor(behav_gp$genotype)==FALSE) {
#   behav_gp <- behav_gp %>%  mutate(genotype = as.factor(genotype)) 
# }
# change the class of hours as numeric instead of charachter
if (!is.numeric(behav_gp$Bin)) {
  behav_gp <- behav_gp %>% mutate(Bin = as.numeric(Bin))
}

#---------------creating 60 mins bins for visualisation---------------#



animals = unique(behav_gp$ID)
hour.info = as.data.frame(matrix(,ncol = 2, nrow = length(animals)))
colnames(hour.info) = c('earliest_bin','last_bin')
# define columns containing behaviours in behav_gp
b.var = 4:ncol(behav_gp)
behav.dark = data.frame()

for (i in animals) {
  
  # create subset of data for onlz the given animal
  temp <- filter(behav_gp, ID == i)
  # save meta information about given animal
  meta <- i
  # find the individual row with the start of the dark phase
  d.start = which(temp$bintodark == 0)
  # get maximal number of full hours after start of dark phase
  max.b = floor(max(temp$bintodark) / 60)
  # get number of full hours before start of dark phase
  min.b = ceiling(min(temp$bintodark) / 60)
  
  
  ### define bins after start of dark phase
  
  # create empty matrices to hold summed hourly data
  temp.ad = matrix(,ncol = length(b.var)+1,nrow = max.b)
  temp.bd = matrix(,ncol = length(b.var)+1,nrow = abs(min.b))
  
  # sum up all values for each full hour after start of dark phase
  for (t in 1:max.b) {
    for (b in b.var) {
      temp.ad[t,1] = t-1
      temp.ad[t,b-min(b.var)+2] = sum(temp[(d.start+(60*(t-1))):(d.start+((60*t)-1)),b])
    }
  }
  
  ### sum up all values for each full hour before the dark phase
  # for (t in 1:abs(min.b)) {
  #   for (b in b.var) {
  #     temp.bd[t,1] = seq(min.b,-1)[t]
  #     temp.bd[t,b-12] = sum(temp[ ((d.start-1)+(-60*(t)))  : ((d.start-1)+(-60*(t-1))),b])
  #   }
  # }
  for (t in min.b:-1) {
    for (b in b.var) {
      temp.bd[t+(abs(min.b)+1),1] = t
      temp.bd[t+(abs(min.b)+1),b-min(b.var)+2] = sum(temp[(d.start+((t*60)+1))  : (d.start +((t+1)*60) ) ,b])
    }
  }
  
  # combine all bins
  temp <- rbind(temp.bd,temp.ad)
  # set colum names
  colnames(temp) = c('Bin.dark',names(behav_gp)[b.var])
  # add meta information again
  temp <- cbind(meta,temp)
  hour.info[which(animals == i),1] = min.b
  hour.info[which(animals == i),2] = max.b-1
  # combine for each animal_ID
  behav.dark = rbind(behav.dark,temp)
}

behav.dark2 <- data.frame(lapply(behav.dark, function(x) as.numeric(as.character(x))) )

  behav.dark2$meta = as.character(behav.dark2$meta)
# calculate meaningful time limits
  timeMin = max (hour.info$earliest_bin) -0.1
  timeMax = min (hour.info$last_bin)+0.1

# filter for data where all mice have data:
  behav.dark2 = behav.dark2 %>% filter (Bin.dark >timeMin & Bin.dark < timeMax)
  
####################################
# 5.2. data plotting
####################################

#### plot for each behaviour the group average per hour (based on BIN given in the raw data [not actual time])

 N_behav= ncol(behav.dark2)-2
#distance traveled
dist <- left_join(behav.dark2, metadata, by =c( "meta"="ID") )
#dist$distance.traveled = behav.dark[,'Distance_traveled']
  
#dist_d = dist  %>% ungroup %>% group_by(genotype,treatment,Bin.dark) %>% summarise (avg = mean(Distance_traveled), sd = sd(Distance_traveled))
#CD = dist  %>% ungroup %>% group_by(genotype,treatment,Bin.dark) %>% summarise (avg = mean(ComeDown), sd = sd(ComeDown))


dist_sum =dist %>% 
   ungroup %>%
  group_by(genotype,treatment,Bin.dark) %>% 
  summarise_at( vars(Distance_traveled:Stretch), funs(mean, sd))%>%
  mutate (Bin.dark = Bin.dark +0.5) # get the x value in the middle of time interval

#pdf("test.pdf")
pl <- list()



for (i in c(1:N_behav)){
  dist_d =dist_sum [,c(1,2,3,3+i,3+i+N_behav)]
  Title_plot = names (dist_d) [4]
  names (dist_d) [4:5]= c("avg", "sd")
  p=plot24h(dist_d, Title_plot)
  #print(p)
  pl[[i]]= p
}
#dev.off()


pl.all.d <- do.call(grid.arrange,c(pl,list(ncol = 3)))


text.all.d = paste('
                   Comment:
                   Duration of each behaviour per hour and per genotype with dark phase start correction. The space between the dotted lines represents the time intervall in which data for all animals is present. Due to the different individual start times this alignment around the dark phase is necessary',
                   collapse=" ")



# all graphs in one plot
#setwd(plot.path)
pdf(file = paste0(plot.path,"/14. Minutes-Behaviours_grouped_dark_corrected.pdf"), width = 15, height = 10)

grid.arrange(splitTextGrob(text.all.d),pl.all.d,
             ncol=1,heights = c(1,5),
             top = textGrob('5. All behaviour kinetics with dark phase correction (AOCF grouping)',gp=gpar(fontsize = 30, font=3)))

dev.off()





######### MR # PLots around start of the dark phase
dist2 = dist %>% filter(Bin.dark %in% c(-2:2))

#replot all: copy paste what is up there:
dist_sum =dist2 %>% 
  ungroup %>%
  group_by(genotype,treatment,Bin.dark) %>% 
  summarise_at( vars(Distance_traveled:Stretch), funs(mean, sd)) %>%
  mutate (Bin.dark = Bin.dark +0.5) # get the x value in the middle of time interval

#pdf("test.pdf")
pl <- list()



for (i in c(1:N_behav)){
  dist_d =dist_sum [,c(1,2,3,3+i,3+i+N_behav)]
  Title_plot = names (dist_d) [4]
  names (dist_d) [4:5]= c("avg", "sd")
  p=plot24h(dist_d, Title_plot, datalenght=3, hour.info2=data.frame(-2,3))
  #print(p)
  pl[[i]]= p
}
#dev.off()


pl.all.d <- do.call(grid.arrange,c(pl,list(ncol = 3)))


text.act.d = paste('
	     Comment:
                   
                   Categories of behaviours following Adama-Biassi 2013 (only durations).
                   Two hours before and after start of the dark phase are displayed to analyse the influence of change in lighting.',collape=" ")



# all graphs in one plot
#setwd(plot.path)
pdf(file = paste0(plot.path,"/16. Minutes-Activity_behaviours_dark_corrected_start_2hours.pdf"), width = 15, height = 10)

grid.arrange(splitTextGrob(text.act.d),pl.all.d,heights = c(.5,2.5),
             top=textGrob("6. Expression of behaviours during the first five hours in HCS
                          ",gp=gpar(fontsize=20,font=3)))
dev.off()

#------- Difference Mean score plotting (against control)##
# choose indexing method
Calc_index <- function (x,y){
  (x-y)/(x+y)
}

# get one value per genotype x treatment: here the mean
meanvalues =dist %>% 
  ungroup %>%
  group_by(genotype,treatment,Bin.dark) %>% 
  summarise_at( vars(Distance_traveled:Stretch), funs(mean))%>%
  mutate (Bin.dark = Bin.dark +0.5) # get the x value in the middle of time interval

if (FALSE){
  #create data frame to join the index to.
  Indexvalues =meanvalues %>% 
    filter (genotype ==meanvalues$genotype[1]) %>%
    select (genotype,treatment,Bin.dark)
  
  #loop on every column, to get one index per column
  for (col in c(4:ncol(meanvalues))){
    NAME= names (meanvalues)[col]
    names (meanvalues)[col] = "totest"
    temp = meanvalues %>% select (genotype,treatment,Bin.dark,totest)
    temp=tidyr::spread(temp, genotype, totest) #change to genotype or treatment depending on what you want to obtain
    temp = temp%>% mutate (Index=Calc_index(test,control)) %>% select (treatment, Bin.dark, Index)
    names(temp)[3] = paste0(NAME,"_index")
    Indexvalues = left_join(Indexvalues,temp)
    names (meanvalues)[col] = NAME
  }
}

if (TRUE){
  #create data frame to join the index to.
  Indexvalues =meanvalues %>% 
    filter (treatment ==meanvalues$treatment[1]) %>%
    select (genotype,treatment,Bin.dark)
  
  #loop on every column, to get one index per column
  for (col in c(4:ncol(meanvalues))){
    NAME= names (meanvalues)[col]
    names (meanvalues)[col] = "totest"
    temp = meanvalues %>% select (genotype,treatment,Bin.dark,totest)
    temp=tidyr::spread(temp, treatment, totest) #change to genotype or treatment depending on what you want to obtain
    temp = temp%>% mutate (Index=Calc_index(o,y)) %>% select (genotype, Bin.dark, Index)
    names(temp)[3] = paste0(NAME,"_index")
    Indexvalues = left_join(Indexvalues,temp)
    names (meanvalues)[col] = NAME
  }
}


##plotting



for (i in c(1:N_behav)){
  dist_d =Indexvalues [,c(1,2,3,3+i)]
  dist_d$sd = 0
  Title_plot = names (dist_d) [4]
  names (dist_d) [4:5]= c("avg", "sd")
  p=plot24h(dist_d, Title_plot,datalenght=-0)+
    scale_y_continuous(limits = c(-1, 1), breaks = c(-0.5, 0, 0.5))+
     geom_line(aes(y=0), col=1)
  #print(p)
  pl[[i]]= p
}
#dev.off()


pl.all.d <- do.call(grid.arrange,c(pl,list(ncol = 3)))

#setwd(plot.path)
pdf(file = paste0(plot.path,"/test_index.pdf"), width = 15, height = 10)

grid.arrange(splitTextGrob("test"),pl.all.d,heights = c(.5,2.5),
             top=textGrob("6. Index of change for each behavior
                          ",gp=gpar(fontsize=20,font=3)))
dev.off()
