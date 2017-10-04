## This code perform a svm on the subset of data and the whole data and choose the model fitting the traindataset at best.

##Subset 0f variables:

##data input
Input =Multi_datainput_m [,names(Multi_datainput_m) %in% c(as.character(R2 [1:numberofvariables,1]), "groupingvar") ]

##data splitting  
#split by variable
L=levels(Input$groupingvar)
Glass= Input %>% filter (groupingvar == L[1])
Glass2= Input %>% filter (groupingvar == L[2])
if (nrow (Glass) != nrow (Glass2)) stop("the groups do not have the same size !")
# split each randomly
index     <- 1:nrow(Glass )
testindex <- sample(index, trunc(length(index)/3))
testset   <- rbind(Glass[testindex,],Glass2[testindex,])
trainset  <- rbind(Glass[-testindex,],Glass2[-testindex,])
##tuning and performing svm  on trainset
bestk= tune.svm2(trainset,groupingvar)

best.parameters = bestk[[2]]

svm.model <- svm(groupingvar ~ ., data = trainset, cost = best.parameters$cost, gamma = best.parameters$gamma, kernel = bestk[[1]])
svm.pred <- predict(svm.model, trainset %>% select(-groupingvar))

SVMprediction_res =table(pred = svm.pred, true = trainset$groupingvar)


#Accuracy of grouping and save model
temp =classAgreement (SVMprediction_res)
subsetcrand=temp$crand
subsetmodel=svm.model

##ALL variables:
###
Input =Multi_datainput_m #%>% select (-ID)
##data splitting  
L=levels(Input$groupingvar)
Glass= Input %>% filter (groupingvar == L[1])
Glass2= Input %>% filter (groupingvar == L[2])

if (nrow (Glass) != nrow (Glass2)) stop("the groups do not have the same size !")

#using same index as for the subset:
#index     <- 1:nrow(Glass )
#testindex <- sample(index, trunc(length(index)/3))
#we take the same data as for the previous run
testset   <- rbind(Glass[testindex,],Glass2[testindex,])
trainset  <- rbind(Glass[-testindex,],Glass2[-testindex,])
##tuning and performing svm  
bestk= tune.svm2(trainset,groupingvar)
best.parameters = bestk[[2]]


svm.model <- svm(groupingvar ~ ., data = trainset, cost = best.parameters$cost, gamma = best.parameters$gamma, kernel = bestk[[1]])

svm.pred <- predict(svm.model, trainset %>% select(-groupingvar))

SVMprediction_res =table(pred = svm.pred, true = trainset$groupingvar)


#Accuracy of grouping and plot
temp =classAgreement (SVMprediction_res)
allcrand=temp$crand
allmodel=svm.model

if (allcrand>  subsetcrand) {
  #nothing to change
}else {# get subset model insteadSVM also train and test sets
  svm.model = subsetmodel
  Input  =Multi_datainput_m [,names(Multi_datainput_m) %in% c(as.character(R2 [1:numberofvariables,1]), "groupingvar") ]
  Glass= Input %>% filter (groupingvar == L[1])
  Glass2= Input %>% filter (groupingvar == L[2])
  testset   <- rbind(Glass[testindex,],Glass2[testindex,])
  trainset  <- rbind(Glass[-testindex,],Glass2[-testindex,])
}