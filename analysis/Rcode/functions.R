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
    labs(x="Meters",y="", title = Title)+
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
