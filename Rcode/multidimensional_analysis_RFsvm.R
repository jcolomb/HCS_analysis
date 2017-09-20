

#------------2 Analysis---------------------------------------------------
# 2.0 add only the metadata for grouping, get rid of ID

Multi_datainput_m = left_join(Multi_datainput, metadata %>% select (ID, groupingvar), by= "ID")

Multi_datainput_m = Multi_datainput_m %>% 
  #mutate (groupingvar = as.factor(treatment))%>%
  select (-ID)

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
