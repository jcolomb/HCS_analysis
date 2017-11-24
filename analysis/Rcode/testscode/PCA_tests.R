#trying pca before all the rest

input.pca <- prcomp(Multi_datainput_m%>% select (-groupingvar),
                center = TRUE,
                scale. = TRUE)
expl.var <- cumsum(input.pca$sdev^2/sum(input.pca$sdev^2)*100)


Input= data.frame(input.pca$x[,expl.var < 95])
Input$groupingvar = Multi_datainput_m$groupingvar

##do statistics on pc1:
Moddata=as.data.frame(input.pca$x)
Moddata$groupingvar = Multi_datainput_m$groupingvar


boxplot(PC1 ~ groupingvar, data = Moddata)
wilcox.test(PC1 ~ groupingvar, data = Moddata)
wilcox.test(PC2 ~ groupingvar, data = Moddata)

plspca=Moddata %>% ggplot (aes (x=PC1, y=PC2, color = groupingvar))+
  geom_point()+
  labs (title="PCA results")+ 
  scale_colour_grey() + theme_bw()#+
  #theme(legend.position='none')
print(plspca)  


#follow by ica

p=icafast(Input%>% select (-groupingvar),2,center=T,maxit=100)

R= cbind(p$Y, Input   %>% select (groupingvar))
names(R) = c("D1", "D2",  "groupingvar")
pls=R %>% ggplot (aes (x=D1, y=D2, color = groupingvar))+
  geom_point()+
  labs (title="PICA")+ 
  scale_colour_grey() + theme_bw()+
  theme(legend.position='none')
print(pls)    

HCS.rf <- randomForest(groupingvar ~ ., data=Input, importance=TRUE,
                       proximity=TRUE, ntree =1500)

R =round(importance(HCS.rf, type=2), 2)
R2=data.frame(row.names (R),R)  %>% arrange(-MeanDecreaseGini)

#pander::pandoc.table(R2)
varImpPlot(HCS.rf)


Input =Input [,names(Input) %in% c(as.character(R2 [1:6,1]), "groupingvar") ]

L=levels(Input$groupingvar)
Glass= Input %>% filter (groupingvar == L[1])
Glass2= Input %>% filter (groupingvar == L[2])

if (nrow (Glass) != nrow (Glass2)) stop("the groups do not have the same size !")

index     <- 1:nrow(Glass )
testindex <- sample(index, trunc(length(index)/3))
testset   <- rbind(Glass[testindex,],Glass2[testindex,])
trainset  <- rbind(Glass[-testindex,],Glass2[-testindex,])
##tuning and performing svm  
obj <- tune.svm(groupingvar~., data = trainset, gamma = 4^(-5:5), cost = 4^(-5:5),
                tune.control(sampling = "cross"))

svm.model <- svm(groupingvar ~ ., data = trainset, cost = obj$best.parameters$cost, gamma = obj$best.parameters$gamma)
svm.pred <- predict(svm.model, testset %>% select(-groupingvar))

SVMprediction_res =table(pred = svm.pred, true = testset$groupingvar)
SVMprediction = as.data.frame(SVMprediction_res)

#Accuracy of grouping and plot
temp =classAgreement (SVMprediction_res)
Accuracy =paste0(ncol(Input)-1," variables: Accuracy of the prediction (Corrected Rand index: 0 denotes chance level, maximum is 1):",temp$crand)

print(Accuracy)
