# #-------------------------SVM analysis

## the code perform a svm analysis with 2 groups,
## inputs: Multi_datainput_m2, Multi_datainput_m (chosen via Projects_metadata$confound_by)
## 2 types of strategy depending on testvalidation, which depends on sample size.


##---testset validation if enough data
if (testvalidation){
  #---- Determine the trainset and testset of data, more complex if there is a confounding factor.
  
  if (!is.na(Projects_metadata$confound_by)) {
    Input = Multi_datainput_m2 #take the data with confounding variable
    
    L = levels(Input$groupingvar)
    L2 = levels(Input$confoundvar)
    Glass = Input %>% filter (groupingvar == L[1])
    Glass2 = Input %>% filter (groupingvar == L[2])
    # message if group of different size
    if (nrow (Glass) != nrow (Glass2))
      print("the groups do not have the same size !")
    
    # split each randomly over confoundvar
    
    Glass_1 = Glass %>% filter (confoundvar == L2[1])
    Glass_2 = Glass %>% filter (confoundvar == L2[2])
    Glass2_1 = Glass2 %>% filter (confoundvar == L2[1])
    Glass2_2 = Glass2 %>% filter (confoundvar == L2[2])
    
    # prepare datasets
    indexl = min(nrow(Glass), nrow(Glass2))
    index     <- 1:indexl
    trainlength = max(4,  trunc(length(index) / 3)) #max fct deprecated, this run only if there is enough data
    indexl2 = min(nrow(Glass_1),
                  nrow(Glass_2),
                  nrow(Glass2_1),
                  nrow(Glass2_2))
    index     <- 1:indexl2
    trainindex <- sample(index, trainlength)
    
    
    trainset  <-
      rbind(Glass_1[trainindex, ], Glass_2[trainindex, ], Glass2_1[trainindex, ], Glass2_2[trainindex, ])
    testset <-
      rbind(Glass_1[-trainindex, ], Glass_2[-trainindex, ], Glass2_1[-trainindex, ], Glass2_2[-trainindex, ])
    trainset  <- trainset %>% select (-confoundvar)
    testset <- testset %>% select (-confoundvar)
    
  } else { # if no counfounding variable, it is faster!
    Input = Multi_datainput_m
    L = levels(Input$groupingvar)
    Glass = Input %>% filter (groupingvar == L[1])
    Glass2 = Input %>% filter (groupingvar == L[2])
    if (nrow (Glass) != nrow (Glass2))
      print("the groups do not have the same size !")
    indexl = min(nrow(Glass), nrow(Glass2))
    
    # split each randomly
    index     <- 1:indexl
    trainindex <- sample(index, max(8, 2 * trunc(length(index) / 3)))
    trainset  <- rbind(Glass[trainindex,], Glass2[trainindex,])
    testset <- rbind(Glass[-trainindex,], Glass2[-trainindex,])
  }
  ## we now have trainset and  testset!!
 ######--------------------------------run SVM analysis
  
  ##---- getting rid of variables with no variability (all 0)
  temp = trainset %>% select (-groupingvar)
  cfreq <- colSums(temp)
  E1 = names(temp[, cfreq == 0])
  temp = testset %>% select (-groupingvar)
  cfreq <- colSums(temp)
  E2 = names(temp[, cfreq == 0])
  trainset = trainset [,!names(trainset) %in% c(E1, E2)]
  testset = testset [,!names(testset) %in% c(E1, E2)]
  Input = Input[,!names(Input) %in% c(E1, E2)]
  
  ##--- tuning: choose best kernel and parameters (error rate minimal), all data (accuracy on trainset maximal, use all if identical), this takes time!
  bestk= tune.svm2(trainset,groupingvar)
  best.parameters = bestk[[2]]
  ##--- train model with best parameters on trainset data
  svm.model <- svm(groupingvar ~ ., data = trainset, cost = best.parameters$cost, gamma = best.parameters$gamma, kernel = bestk[[1]])
  
  #-- run model on test data
  svm.pred <- predict(svm.model, testset %>% select(-groupingvar))
  #-- compare prediction with real data
  SVMprediction_res = table(pred = svm.pred, true = testset$groupingvar)
  #SVMprediction = as.data.frame(SVMprediction_res)
  
  #-- Accuracy of grouping and plot
  temp = classAgreement (SVMprediction_res)
  Accuracyreal = temp$kappa
  kernel = bestk[[1]]

}

#### 2-out cross-validation if sample size too low.  
if (!testvalidation){
  ## set data to use for the svm
  if (!is.na(Projects_metadata$confound_by)) {
    out_sel = Multi_datainput_m2[order(Multi_datainput_m2$groupingvar, Multi_datainput_m2$confoundvar),]
    out_sel =out_sel %>% select (-confoundvar)
  }else {
    out_sel = Multi_datainput_m[order(Multi_datainput_m$groupingvar),]
  }
  
  # ## make same number of animal in each group, deprecated as svm is not running if this is the case.
  # out_sel_ori= out_sel
  # GP= out_sel$groupingvar
  # L =levels(GP)
  # out_sel1= out_sel [GP == L[1],]
  # out_sel2= out_sel [GP == L[2],]
  # NG = min (nrow (out_sel1),nrow (out_sel2))
  # out_sel =rbind (out_sel1[1:NG,],out_sel2[1:NG,])
  
  ## get rid of columns with NAs
  all_na <- function(x) any(!is.na(x))
  out_sel = out_sel %>% select_if(all_na)
  
  ## do the svm, with a radial kernel
  kernel ="radial"
  source ("Rcode/2_out_svm.r")
  Accuracyreal = temp$kappa


}

Accuracy = paste0(
  ncol(out_sel) - 1,
  " variables: Accuracy of the prediction with ",
  kernel,
  " kernel (Kappa index: 0 denotes chance level, maximum is 1):",
  Accuracyreal
)
