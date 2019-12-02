##-- Acc_sampled should be set a priori to this document, since the code may be run multiple times, we do not set it back to nothing here
## testvalidation is set in the master_shiny file (n>15 per group ?)


if (testvalidation){
  ##inputs are trainset, testset, bestk
  trainsetp = trainset
  for (i in 1:Npermutation) {
    #permute trainset:
    
    #taking all permutation is impossible when we get more than 5 animals per group, so we sample one possibility
    trainsetp$groupingvar = sample (trainset$groupingvar)
    #create svm model: we tune only in one kernel:
    obj <-
      tune.svm(
        groupingvar ~ .,
        data = trainsetp,
        gamma = 4 ^ (-5:5),
        cost = 4 ^ (-5:5),
        tune.control(sampling = "cross"),
        kernel = bestk[[1]]
      )
    
    svm.model <-
      svm(
        groupingvar ~ .,
        data = trainsetp,
        cost = obj$best.parameters$cost,
        gamma = obj$best.parameters$gamma,
        kernel = bestk[[1]]
      )
    
    svm.pred <- predict(svm.model, testset %>% select(-groupingvar))
    SVMprediction_res = table(pred = svm.pred, true = testset$groupingvar)
    #SVMprediction = as.data.frame(SVMprediction_res)
    
    #Accuracy of grouping and plot
    temp = classAgreement (SVMprediction_res)
    Acc_sampled = c(Acc_sampled, temp$kappa)
  }
}

if (!testvalidation){
  #out_sel_ori is taken from the svm with real groups
  for (i in 1:Npermutation) {
    out_sel =out_sel_ori
    out_sel$groupingvar = sample (out_sel_ori$groupingvar)
    #-- we perform the same analysis, but grouping was disturbed:
    source ("Rcode/2_out_svm.r")
    ##-- we save the result in the Acc_sampled file
    Acc_sampled = c(Acc_sampled, temp$kappa)
    write_lines(Acc_sampled, path  = paste0(Outputs,"/Bseq",Name_project,groupingby,"_permutation.csv"))
  }
}  