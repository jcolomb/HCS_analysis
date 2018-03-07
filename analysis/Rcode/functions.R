dataread.c <- function() {
  name <- tclvalue(tkgetOpenFile(
    filetypes = "{ {XLSX Files} {.xlsx} } { {All Files} * }"))
  if (name == "")
    return(data.frame()) # Return an empty data frame if no file was selected
  
  
  data <- read_xlsx(name,sheet = 2)
  assign("data", data, envir = .GlobalEnv)
  assign("name",name, envir = .GlobalEnv)
  cat("The lookup data was imported successfully.\n
      Please close the file selection by pressing the OK Button")
}

# function to create an plot object usable in grid.arrange without using ggplot
# use via grab_grob() in line after plot was created

grab_grob <- function(){
  grid.echo()
  grid.grab()
}

##plotting 24h data
theme.mr <- theme (axis.title = element_text(size=11,face="bold"),
                   axis.line.x = element_line(colour = "black"),
                   axis.line.y = element_line(colour = "black"),
                   plot.title = element_text(size=18),
                   axis.text.y = element_text(angle=0, hjust=-0.25),
                   axis.text.x = element_text(angle=0, hjust=1), #inclination of text of X axis
                   legend.title = element_blank(),
                   legend.text =element_text(size=11))



plot24h <- function (data_d, Title, hour.info2= hour.info, datalenght=12){
  data_d %>% 
    ggplot(aes(x=Bin.dark, y=avg, group=treatment, color= genotype)) +
    geom_rect( aes(xmin = 0, xmax = datalenght, ymin = 0, ymax = Inf), fill = 'lightgrey', alpha = .05)+
    #geom_vline(xintercept=max(hour.info2[,1]),linetype = "dotted")+
    #geom_vline(xintercept=min(hour.info2[,2]),linetype = "dotted")+
    geom_point (aes (colour=(genotype), shape=(treatment)), size=2)+
    #geom_line(aes(colour=(genotype)))+
    #facet_grid( genotype~, switch="x") +
    geom_errorbar(aes(ymin=avg, ymax=avg+sd, colour=(genotype),linetype=(treatment) ), width=0, position=position_dodge(0.05))+
    labs(x="time of day",y="%time or meters", title = Title)+
    theme_classic() +
    #scale_colour_manual(values = cols)+ ###Stop here if want to save as pdf
    theme.mr
}

## tune the svm over different kernels

tune.svm2 <- function(trainset,groupingvar){
  objS <- tune.svm(groupingvar~., data = trainset, gamma = 4^(-5:5), cost = 4^(-5:5),
                   tune.control(sampling = "cross"),kernel = "sigmoid")
  S=min(objS$performances$error)
  
  objR <- tune.svm(groupingvar~., data = trainset, gamma = 4^(-5:5), cost = 4^(-5:5),
                   tune.control(sampling = "cross"),kernel = "radial")
  R=min(objR$performances$error)
  
  objP <- tune.svm(groupingvar~., data = trainset, gamma = 4^(-5:5), cost = 4^(-5:5),
                   tune.control(sampling = "cross"),kernel = "polynomial")
  P=min(objP$performances$error)
  
  objL <- tune.svm(groupingvar~., data = trainset, gamma = 4^(-5:5), cost = 4^(-5:5),
                   tune.control(sampling = "cross"),kernel = "linear")
  L=min(objL$performances$error)
  
  choice=data.frame ("S"=S, "R"=R, "P"=P, "L"=L)
  Min =choice %>% transmute (C=min(S,R,P,L))
  choice=cbind(data.frame (t(choice)), kernel=c("sigmoid","radial","polynomial","linear"))
  
  #choice %>% filter (t.choice. ==Min [1,1])
  KERNEL=as.character(choice [choice$t.choice ==Min [1,1],2])[1]
  obj=NA
  obj= ifelse (KERNEL == "sigmoid",objS, obj)
  obj= ifelse (KERNEL == "radial",objR, obj)
  obj= ifelse (KERNEL == "polynomial",objP, obj)
  obj= ifelse (KERNEL == "linear",objL, obj)
  return (c(KERNEL,obj))
}

permutate_trainset <- function(LIST) {
  # list must be a list of factors, with 2 levels
  
  #get combination of n/2 number in a list of n
  n= length(LIST)
  
  x=combn (n,n/2)
  x=x[,1:(ncol(x)/2)]
  
  # create initial list with all elements of first level
  P = rep(levels (LIST)[1], n)
  # for each permutation, change the element of position x to the element of second level
  perm= c()
  for (i in c(1:ncol(x))){
    Px= P
    Px[x[,i]]= levels (LIST)[2]
    perm= rbind(perm,Px)
  }
  perm
}

tune.svm3 <- function(trainset,groupingvar){

  
  objR <- tune.svm(groupingvar~., data = trainset, gamma = 4^(-5:5), cost = 4^(-5:5),
                   tune.control(sampling = "cross"),kernel = "radial")
  
  
  objL <- tune.svm(groupingvar~., data = trainset, gamma = 4^(-5:5), cost = 4^(-5:5),
                   tune.control(sampling = "cross"),kernel = "linear")
  
  
 
  return (c("radial",objR,"linear",objL))
}

#set transformation for %age time data (i.e. not distance traveled, all the other)
#we cannot use log (too many 0), the Arcsin is also not usable since we will do regressions afterwards.
calcul = function (x){
  sqrt(mean (x)/60)
}
calcul_text = "data (%age of time spent doing the behavior) transformed using the square root method."

## use calcul fonction and get values for one window:
get_windowsummary <- function(windowdata,i) {
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

## function to work with hourly summary files: transform it into minute summary file by dividing scores by 60
xx_to_min <- function(behav_data,min_in_x=60){
  temp= behav_data %>% select (-Bin) %>%
  mutate_all(funs(. /min_in_x))
  temp=temp[rep(seq_len(nrow(temp)), each=min_in_x),]
  result =cbind (Bin=seq(1:(nrow(behav_data)*min_in_x)),
                               temp)
  return(result)
}

## function to create min summary file from the mbr file, note that we had an unknown behavior for the first time with no data, 
## while the HCS export function do not integrate it at all

min_from_mbr <- function(rawdata,fpersec,Behav_code) {
  #-- get rid of last row (distance traveled)
  rawdata=rawdata [-nrow(rawdata),]
  #-- get comon names
  names (rawdata)= c("start", "end", "behavior")
  
  #-- change behavior code to 2 digit
  rawdata= rawdata %>% mutate (behavior = behavior-round(behavior, digits = -2))
  
  
  #-- pool elements with same name
  rawdata$behavior [rawdata$behavior== 14] <- 13
  rawdata$behavior [rawdata$behavior== 18] <- 17
  rawdata$behavior [rawdata$behavior== 31] <- 30
  
  #-- add first line with no data
  fline= c(0,rawdata$start[1], 44 )
  rawdata =rbind(fline, rawdata)
  
  #Create summary (will be a function), note that bin is in frames, 25 frames per sec.
  fpermin= 60*fpersec
  
  Binned_data = data.frame()
  
  MAXbin=trunc(rawdata$end [length(rawdata$end)]/fpermin)
  for (bin in seq(1:MAXbin)){
    starttime = (bin-1)*fpermin
    endtime = bin*fpermin
    
    subset_data = rawdata %>% filter (start < endtime & end >starttime)
    subset_data$start [1]=starttime
    subset_data$end [length(subset_data$end)]=endtime
    
    temp=subset_data %>% transmute (duration = end-start, behavior = behavior)
    temp=  temp %>% group_by(behavior) %>%summarize (sum(duration))
    temp2 =left_join(Behav_code, temp, by = "behavior")
    #replace NA with 0
    temp2$`sum(duration)` = replace(temp2$`sum(duration)`,is.na(temp2$`sum(duration)`), 0)
    temp2 = na.omit(temp2)
    
    result = c(bin,temp2$`sum(duration)`/fpersec)
    Binned_data= rbind(Binned_data,result)
    
  }
  
  names(Binned_data)= c("Bin",na.omit(Behav_code$beh_name))
  return(Binned_data)
}

rawd_from_mbr <- function(rawdata,fpersec,Behav_code) {
  #-- get rid of last row (distance traveled)
  rawdata=rawdata [-nrow(rawdata),]
  #-- get comon names
  names (rawdata)= c("start", "end", "behavior")
  
  #-- change behavior code to 2 digit
  rawdata= rawdata %>% mutate (behavior = behavior-round(behavior, digits = -2))
  
  
  #-- pool elements with same name
  rawdata$behavior [rawdata$behavior== 14] <- 13
  rawdata$behavior [rawdata$behavior== 18] <- 17
  rawdata$behavior [rawdata$behavior== 31] <- 30
  
  #-- add first line with no data
  fline= c(0,rawdata$start[1], 44 )
  rawdata =rbind(fline, rawdata)
  left_join(rawdata, Behav_code, by = "behavior")
  
  return(rawdata)
}