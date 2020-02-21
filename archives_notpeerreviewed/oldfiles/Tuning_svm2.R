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
allcrand=temp$kappa
allmodel=svm.model


