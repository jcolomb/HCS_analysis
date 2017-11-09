Npermutation = 1000


  
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
