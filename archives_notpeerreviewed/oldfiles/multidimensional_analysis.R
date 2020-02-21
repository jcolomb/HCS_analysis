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



#------------2 Analysis---------------------------------------------------
# 2.0 add only the metadata for grouping, get rid of ID

Multi_datainput_m = left_join(Multi_datainput, metadata %>% select (ID, treatment), by= "ID")

Multi_datainput_m = Multi_datainput_m %>% 
  mutate (groupingvar = as.factor(treatment))%>%
  select (-ID, -treatment)

class(Multi_datainput_m$groupingvar)
# 2.1 multidimensional analysis: random forest

set.seed(71)
#tuneRF(Multi_datainput_m%>% select (-groupingvar),Multi_datainput_m$groupingvar, ntreeTry=50, stepFactor=2, improve=0.05,
#       trace=TRUE, plot=TRUE, doBest=FALSE)

HCS.rf <- randomForest(groupingvar ~ ., data=Multi_datainput_m, importance=TRUE,
                        proximity=TRUE, mtry= 21, ntree =1500)
print(HCS.rf)
## Look at variable importance:
R =round(importance(HCS.rf, type=2), 2)
R2=data.frame(row.names (R),R)  %>% arrange(-MeanDecreaseGini)
R2 [1:7,]

#Plot = Multi_datainput_m [,names(Multi_datainput_m) %in% as.character(R2 [1:20,1]) ]
#Plot = cbind(Multi_datainput_m$groupingvar, Plot)
pl <- list()
for (i in c(1:numberofvariables)){
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
if (exists ("plot.path")){
  pdf(file = paste0(plot.path,"/100_randomforest_results.pdf"), width = 15, height = 10)
  
  grid.arrange(splitTextGrob(text.all.d),pl.all.discr,
               ncol=1,heights = c(1,5),
               top = textGrob('...',gp=gpar(fontsize = 30, font=3)))
  
  dev.off()
}


  ##plot first 2 discriminants: 
  Plot = Multi_datainput_m [,names(Multi_datainput_m) %in% as.character(R2 [1:2,1]) ]
  Plot = cbind(Multi_datainput_m$groupingvar, Plot)
  Title_plot = paste0(names (Plot) [2],"x",names (Plot) [3])
  names (Plot) = c("groupingvar","disciminant1", "discriminant2")
  p=ggplot (Plot, aes (y= disciminant1, x=discriminant2, color= groupingvar))+
    geom_point()+
    labs(title = Title_plot)+
    scale_x_log10() + scale_y_log10()

# 2.2 ICA on raw data

  Input = Multi_datainput_m   %>% select (-groupingvar)
  #p=icafast(Input,3,center=T,maxit=100)
  #p=icaimax(Input,3,center=T,maxit=1000)
  p=icafast(Input,2,center=T,maxit=100)
  R= cbind(p$Y, Multi_datainput_m   %>% select (groupingvar))
  names(R) = c("D1", "D2",  "groupingvar")
  R %>% ggplot (aes (x=D1, y=D2, color = groupingvar))+
    geom_point()
  
  # 2.3 ICA on random forest chosen subset
  p=list()
  for (i in 2:80){
    nv = i
    
    Input =Multi_datainput_m [,names(Multi_datainput_m) %in% as.character(R2 [1:numberofvariables,1]) ]
    
    p=icafast(Input,2,center=T,maxit=100)
    R= cbind(p$Y, Multi_datainput_m   %>% select (groupingvar))
    names(R) = c("D1", "D2",  "groupingvar")
    pls=R %>% ggplot (aes (x=D1, y=D2, color = groupingvar))+
      geom_point()+
      labs (title=nv)+ 
      scale_colour_grey() + theme_bw()+
      theme(legend.position='none')
    pl[[i]]= pls
  }
  pl.all.discr <- do.call(grid.arrange,c(pl[2:20],list(ncol = 5)))
  
  grid.arrange(splitTextGrob(text.all.d),pl.all.discr,
               ncol=1,heights = c(1,5),
               top = textGrob('...',gp=gpar(fontsize = 30, font=3)))
  
# 2.3 SVM: Support Vector Machines
  
  

  
  
# 2.4 SVM: Support Vector Machines on random forest results 
  #numberofvariables = length(names(Multi_datainput_m))-1 #all variables used

  
  Input =Multi_datainput_m [,names(Multi_datainput_m) %in% c(as.character(R2 [1:numberofvariables,1]), "groupingvar") ]
  
  L=levels(Input$groupingvar)
  Glass= Input %>% filter (groupingvar == L[1])
  Glass2= Input %>% filter (groupingvar == L[2])
  
  if (nrow (Glass) != nrow (Glass2)) stop("the groups do not have the same size !")
  
  index     <- 1:nrow(Glass )
  testindex <- sample(index, trunc(length(index)/3))
  testset   <- rbind(Glass[testindex,],Glass2[testindex,])
  trainset  <- rbind(Glass[-testindex,],Glass2[-testindex,])
  
  obj <- tune.svm(groupingvar~., data = trainset, gamma = 4^(-5:5), cost = 4^(-5:5),
                  tune.control(sampling = "cross"))
  svm.model <- svm(groupingvar ~ ., data = trainset, cost = obj$best.parameters$cost, gamma = obj$best.parameters$gamma)
  svm.pred <- predict(svm.model, testset %>% select(-groupingvar))
  
  SVMprediction_res =table(pred = svm.pred, true = testset$groupingvar)
  SVMprediction = as.data.frame(SVMprediction_res)
  
  #Accuracy of grouping and plot
  temp =classAgreement (SVMprediction_res)
  Accuracy =paste0("Accuracy of the prediction (Corrected Rand index: 0 denotes chance level, maximum is 1):",temp$crand)
  
  
  ## plot result
pdf (paste0(Outputs,"/Multidimensional_analysis_result.pdf"))
  pl[[numberofvariables]]+ labs(title = "2 best discrimant from a ICA",subtitle = 
                                  paste0("ICA performed on ",
    numberofvariables,
    " variables, chosen after a random forest procedure.
We trained a SVM on 2/3 of this data, and use it to predict the last third.
    The model could predict the grouping of the test data with an accuracy of:
    ",
    trunc (temp$crand*100),
    "%
    (corrected Rind index. 0 denotes chance, maximum is 100%).")
  )
dev.off()
    

##test
R=c()
nv=c()
for (numberofvariables in 2:length(names(Multi_datainput_m))-1){
  Input =Multi_datainput_m [,names(Multi_datainput_m) %in% c(as.character(R2 [1:numberofvariables,1]), "groupingvar") ]
  
  L=levels(Input$groupingvar)
  Glass= Input %>% filter (groupingvar == L[1])
  Glass2= Input %>% filter (groupingvar == L[2])
  
  if (nrow (Glass) != nrow (Glass2)) stop("the groups do not have the same size !")
  
  index     <- 1:nrow(Glass )
  testindex <- sample(index, trunc(length(index)/3))
  testset   <- rbind(Glass[testindex,],Glass2[testindex,])
  trainset  <- rbind(Glass[-testindex,],Glass2[-testindex,])
  
  obj <- tune.svm(groupingvar~., data = trainset, gamma = 4^(-5:5), cost = 4^(-5:5),
                  tune.control(sampling = "cross"))
  svm.model <- svm(groupingvar ~ ., data = trainset, cost = obj$best.parameters$cost, gamma = obj$best.parameters$gamma)
  svm.pred <- predict(svm.model, testset %>% select(-groupingvar))
  
  SVMprediction_res =table(pred = svm.pred, true = testset$groupingvar)
  SVMprediction = as.data.frame(SVMprediction_res)
  
  #Accuracy of grouping and plot
  temp =classAgreement (SVMprediction_res)
  R= c(R, temp$crand)
  nv = c(nv,numberofvariables)
}

svm_acc=data.frame(cbind ( nv, R))
names(svm_acc)= c("number of variables", "SVM accuracy")
plot(svm_acc)   
boxplot(svm_acc$`SVM accuracy`) 
