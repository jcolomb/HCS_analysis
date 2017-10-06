## This code perform a svm on the subset of data and the whole data and choose the model fitting the traindataset at best.

##Subset 0f variables:

##data input
trainset2 =trainset [,names(trainset) %in% c(as.character(R2 [1:numberofvariables,1]), "groupingvar") ]
testset2 =testset [,names(testset) %in% c(as.character(R2 [1:numberofvariables,1]), "groupingvar") ]

##tuning and performing svm  on trainset
bestk=NA
bestk= tune.svm2(trainset2,groupingvar)

best.parameters = bestk[[2]]

svm.model <- svm(groupingvar ~ ., data = trainset2, cost = best.parameters$cost, gamma = best.parameters$gamma, kernel = bestk[[1]])
svm.pred <- predict(svm.model, trainset2 %>% select(-groupingvar))

SVMprediction_res =table(pred = svm.pred, true = trainset2$groupingvar)


#Accuracy of grouping and save model
temp =classAgreement (SVMprediction_res)
subsetcrand=temp$crand
subsetmodel=svm.model

##ALL variables:
###

##tuning and performing svm  
bestk=NA
bestk= tune.svm2(trainset,groupingvar)
best.parameters = bestk[[2]]


svm.model <- svm(groupingvar ~ ., data = trainset, cost = best.parameters$cost, gamma = best.parameters$gamma, kernel = bestk[[1]])

svm.pred <- predict(svm.model, trainset %>% select(-groupingvar))

SVMprediction_res =table(pred = svm.pred, true = trainset$groupingvar)


#Accuracy of grouping and plot
temp =classAgreement (SVMprediction_res)
allcrand=temp$crand
allmodel=svm.model

if (allcrand<  subsetcrand) {
  # get subset model insteadSVM also train and test sets
  svm.model = subsetmodel
  testset   <- testset2
  trainset  <- trainset2

  }

