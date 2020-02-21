Npermutation = 200
library(glmpath)

  
  #Acc_sampled= c()
  b=Sys.time()
  for (i in 1:Npermutation){
    print(i)
    #metadata$groupingvar=as.factor(metadata$groupingvar)
    #metadata$groupingvar =as.numeric(sample(metadata$groupingvar))
    ### test for one TW
    #multidimensional analysis, prepare data
    #source ("Rcode/multidimensional_analysis_prep.R")
    #only one TW
    #source ("Rcode/testscode/multidimensional_analysis_prep_oneTW.R")
    
    #multidimensional analysis, Random forest in 2 rounds
    #source ("Rcode/RF_selection_2rounds.R") # returns RF_selec = Input
    Multi_datainput_m$groupingvar =as.numeric(sample(Multi_datainput_m$groupingvar))
    RF_selec = Multi_datainput_m
    # reorder
    RF_selec = RF_selec[order(RF_selec$groupingvar),] 
    
    
    
    xx= as.matrix(RF_selec %>% select (-groupingvar))
    yy = as.numeric(RF_selec$groupingvar)-1
    pp  <- rep(NA, length(yy))
    
    num_per_class <- nrow(RF_selec)/2
    
    for (k in 1:num_per_class) {
      hold_out = c(k, k+num_per_class) ## hold out one pos and one neg examples so samples are still balanced
      fit <- glmpath(x=xx[-hold_out,], y=yy[-hold_out], family=binomial, max.arclength=1)
      bestdex <- which.min(fit$bic)
      if (bestdex==1) {bestdex <- 2}  ## break ties by avoiding degenerate classifiers
      bestlambda <- fit$lambda[bestdex]
      pred <- predict(fit, newx=xx[hold_out,], s=bestlambda, type="link", mode="lambda")
      pp[hold_out] = pred
    }
    
    true_class <- sign(yy - 0.5)
    pred_class <- sign(pp);
    
    prediction_res=table(true_class, pred_class)

    #Accuracy of grouping and plot
    temp =classAgreement (prediction_res)
    Acc_sampled = c(Acc_sampled, temp$diag)
  }
  
  print("time to perform the analysis:")
  print(Sys.time()-b)
  
  hist(Acc_sampled, breaks=c(0:20)/20)
  abline(v = 17/22, col="Red")
  abline(v = 0.5, col="blue")
  
  Accuracyreal=17/22
  # Exports `binconf`
  k <- sum(abs(Acc_sampled-0.5) >= abs(Accuracyreal-0.5))   # Two-tailed test
  
  k <- sum(Acc_sampled >= Accuracyreal)   # One-tailed test
  print(zapsmall(binconf(k, length(Acc_sampled), method='exact'))) # 95% CI by default
  print(zapsmall(binconf(k, length(Acc_sampled), method='all')))
  save.image(file= "thisisatest.rdata") 
  
  
  ###-------------------------------------------------------------one time window svm
  source ("Rcode/testscode/multidimensional_analysis_prep_oneTW.R")
  set.seed(66)
  
  
  RF_selec=Multi_datainput_m
  xx= as.matrix(RF_selec %>% select (-groupingvar))
  yy = as.numeric(RF_selec$groupingvar)-1
  pp  <- rep(NA, length(yy))
  ppsvm  <- rep(NA, length(yy))
  ppsvm_L  <- rep(NA, length(yy))
  
  num_per_class <- nrow(RF_selec)/2
  before <- Sys.time()
  for (k in 1:num_per_class) {
    hold_out = c(k, k+num_per_class) ## hold out one pos and one neg examples so samples are still balanced
    fit <- glmpath::glmpath(x=xx[-hold_out,], y=yy[-hold_out], family=binomial, max.arclength=1)
    bestdex <- which.min(fit$bic)
    if (bestdex==1) {bestdex <- 2}  ## break ties by avoiding degenerate classifiers
    bestlambda <- fit$lambda[bestdex]
    pred <- predict(fit, newx=xx[hold_out,], s=bestlambda, type="link", mode="lambda")
    pp[hold_out] = pred
    
    #svm
    ##ALL variables:
    ###
    
    ##tuning and performing svm  
    #bestk=NA
    bestk= tune.svm3(RF_selec[-hold_out,],as.data.frame(yy[-hold_out]))
    
    
    best.parameters = bestk[[2]]
    best.parameters_L = bestk[[11]]
    
    
    svm.model <- svm(yy[-hold_out] ~ ., data = xx[-hold_out,], cost = best.parameters$cost, gamma = best.parameters$gamma, kernel = bestk[[1]])
    svm.model_L <- svm(yy[-hold_out] ~ ., data = xx[-hold_out,], cost = best.parameters_L$cost, gamma = best.parameters_L$gamma, kernel = "linear")
    
    #svm.pred <- predict(svm.model, xx[hold_out,])
    ppsvm[hold_out] = predict(svm.model, xx[hold_out,])
    ppsvm_L[hold_out] = predict(svm.model_L, xx[hold_out,])
    
    
  }
  duration = Sys.time()-before
  
  true_class <- sign(yy - 0.5)
  pred_class <- sign(pp);
  pred_classsvm <- sign(ppsvm);
  pred_classsvm_L <- sign(ppsvm_L);
  
  prediction_res1=table(true_class, pred_class)
  prediction_res2=table(true_class, pred_classsvm)
  prediction_res3=table(true_class, pred_classsvm_L)
  
  #Accuracy of grouping and plot
  ACURRACY=NA
  temp =classAgreement (prediction_res1)
  ACURRACY = c(ACURRACY, temp$kappa)
  temp =classAgreement (prediction_res2)
  ACURRACY = c(ACURRACY, temp$kappa)
  temp =classAgreement (prediction_res3)
  ACURRACY = c(ACURRACY, temp$kappa)
  ACURRACY
  duration

  
  ###---------------------------------- permutation
  
  b=Sys.time()
  #Acc_sampled = c("log_regr", "svm_radial")
  Npermutation =50
  before <- Sys.time()
  for (i in 1:Npermutation){
    print(i)
    #metadata$groupingvar=as.factor(metadata$groupingvar)
    #metadata$groupingvar =as.numeric(sample(metadata$groupingvar))
    ### test for one TW
    #multidimensional analysis, prepare data
    #source ("Rcode/multidimensional_analysis_prep.R")
    #only one TW
    #source ("Rcode/testscode/multidimensional_analysis_prep_oneTW.R")
    
    #multidimensional analysis, Random forest in 2 rounds
    #source ("Rcode/RF_selection_2rounds.R") # returns RF_selec = Input
    Multi_datainput_m$groupingvar =as.numeric(sample(Multi_datainput_m$groupingvar))
    RF_selec = Multi_datainput_m
    # reorder
    RF_selec = RF_selec[order(RF_selec$groupingvar),] 
    
    
    
    xx= as.matrix(RF_selec %>% select (-groupingvar))
    yy = as.numeric(RF_selec$groupingvar)-1
    pp  <- rep(NA, length(yy))
    #ppsvm  <- rep(NA, length(yy))
    ppsvm_L  <- rep(NA, length(yy))
    
    num_per_class <- nrow(RF_selec)/2
    before <- Sys.time()
    for (k in 1:num_per_class) {
      hold_out = c(k, k+num_per_class) ## hold out one pos and one neg examples so samples are still balanced
      fit <- glmpath::glmpath(x=xx[-hold_out,], y=yy[-hold_out], family=binomial, max.arclength=1)
      bestdex <- which.min(fit$bic)
      if (bestdex==1) {bestdex <- 2}  ## break ties by avoiding degenerate classifiers
      bestlambda <- fit$lambda[bestdex]
      pred <- predict(fit, newx=xx[hold_out,], s=bestlambda, type="link", mode="lambda")
      pp[hold_out] = pred
      
      #svm
      ##ALL variables:
      ###
      
      ##tuning and performing svm  
      #bestk=NA
      
      groupingvar =as.data.frame(yy[-hold_out])
      
      objL <- tune.svm(groupingvar~., data = RF_selec[-hold_out,], gamma = 4^(-5:5), cost = 4^(-5:5),
                       tune.control(sampling = "cross"),kernel = "radial")
      
      #best.parameters = bestk[[2]]
      best.parameters_L = objL$best.parameters
      
      
      #svm.model <- svm(yy[-hold_out] ~ ., data = xx[-hold_out,], cost = best.parameters$cost, gamma = best.parameters$gamma, kernel = bestk[[1]])
      svm.model_L <- svm(yy[-hold_out] ~ ., data = xx[-hold_out,], cost = best.parameters_L$cost, gamma = best.parameters_L$gamma, kernel = "linear")
      
      #svm.pred <- predict(svm.model, xx[hold_out,])
      #ppsvm[hold_out] = predict(svm.model, xx[hold_out,])
      ppsvm_L[hold_out] = predict(svm.model_L, xx[hold_out,])
      
      
    }
    duration = Sys.time()-before
    
    true_class <- sign(yy - 0.5)
    pred_class <- sign(pp);
    # pred_classsvm <- sign(ppsvm);
    pred_classsvm_L <- sign(ppsvm_L);
    
    prediction_res1=table(true_class, pred_class)
    #prediction_res2=table(true_class, pred_classsvm)
    prediction_res3=table(true_class, pred_classsvm_L)
    
    #Accuracy of grouping and plot
    ACURRACY=NA
    temp =classAgreement (prediction_res1)
    ACURRACY = c(ACURRACY, temp$kappa)
    #temp =classAgreement (prediction_res2)
    #ACURRACY = c(ACURRACY, temp$kappa)
    temp =classAgreement (prediction_res3)
    ACURRACY = c(ACURRACY, temp$kappa)
    
    Acc_sampled = rbind(Acc_sampled, ACURRACY[-1])
  }
  
  beepr::beep()
  
  ## plot and test
  require(Hmisc)

  hist(as.numeric(Acc_sampled[-1,1]), breaks=c(-10:10)/10)
  abline(v = ACURRACYreal[2], col="Red")
  abline(v = 0, col="blue")
  
  hist(as.numeric(Acc_sampled[-1,2]), breaks=c(-20:20)/20)
  abline(v = ACURRACYreal[4], col="Red")


  

  k1 <- sum(as.numeric(Acc_sampled[-1,1]) >= ACURRACYreal[2])   # One-tailed test
  k2 <- sum(as.numeric(Acc_sampled[-1,2]) >= ACURRACYreal[4])   # One-tailed test

  print(zapsmall(binconf(k1, nrow(Acc_sampled)-1, method='all'))) # 95% CI by default
  print(zapsmall(binconf(k2, nrow(Acc_sampled)-1, method='all')))
  
  save.image(file= "oneTW_analysis.rdata") 