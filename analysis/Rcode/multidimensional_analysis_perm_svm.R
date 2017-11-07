
  trainsetp=trainset
  
  b=Sys.time()
  for (i in 1:Npermutation){
    
    #permute trainset:
    
    #taking all permutation is impossible when we get more than 5 animals per group, so we sample one possibility
    trainsetp$groupingvar=sample (trainset$groupingvar)
    #create svm model: we tune only in one kernel:
    obj <- tune.svm(groupingvar~., data = trainsetp, gamma = 4^(-5:5), cost = 4^(-5:5),
                    tune.control(sampling = "cross"),kernel = bestk[[1]])
    
    svm.model <- svm(groupingvar ~ ., data = trainsetp, cost = obj$best.parameters$cost, gamma = obj$best.parameters$gamma, kernel = bestk[[1]])
    
    svm.pred <- predict(svm.model, testset %>% select(-groupingvar))
    SVMprediction_res =table(pred = svm.pred, true = testset$groupingvar)
    #SVMprediction = as.data.frame(SVMprediction_res)
    
    #Accuracy of grouping and plot
    temp =classAgreement (SVMprediction_res)
    Acc_sampled = c(Acc_sampled, temp$kappa)
  }
  
  print("time to perform the analysis:")
  print(Sys.time()-b)
  
  hist(Acc_sampled, breaks=c(-10:10)/10)
  abline(v = Accuracyreal, col="Red")
  
  # Exports `binconf`
  k <- sum(Acc_sampled >= Accuracyreal)   # one-tailed test
  print("P value for a one-tailed test:")
  print(zapsmall(binconf(k, length(Acc_sampled), method='exact'))) # 95% CI by default
  save.image(file= "thisisatest.rdata") 
