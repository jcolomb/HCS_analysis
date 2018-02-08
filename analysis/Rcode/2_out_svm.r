if (!is.na(Projects_metadata$confound_by)) {
  RF_selec = Multi_datainput_m2[order(Multi_datainput_m2$groupingvar, Multi_datainput_m2$confoundvar),]
  RF_selec = RF_selec %>% select (-confoundvar)
}else {
  RF_selec = Multi_datainput_m[order(Multi_datainput_m$groupingvar),]
}

xx= as.matrix(RF_selec %>% select (-groupingvar))
yy = as.numeric(RF_selec$groupingvar)-1
#pp  <- rep(NA, length(yy))
ppsvm  <- rep(NA, length(yy))
#ppsvm_L  <- rep(NA, length(yy))

num_per_class <- nrow(RF_selec)/2

for (k in 1:num_per_class) {
  
  hold_out = c(k, k+num_per_class) ## hold out one pos and one neg examples so samples are still balanced
  # ##---logregression
  # fit <- glmpath::glmpath(x=xx[-hold_out,], y=yy[-hold_out], family=binomial, max.arclength=1)
  # bestdex <- which.min(fit$bic)
  # if (bestdex==1) {bestdex <- 2}  ## break ties by avoiding degenerate classifiers
  # bestlambda <- fit$lambda[bestdex]
  # pred <- predict(fit, newx=xx[hold_out,], s=bestlambda, type="link", mode="lambda")
  # pp[hold_out] = pred
  
  ##-- svm
  groupingvar=as.data.frame(yy[-hold_out])
  
  ##---linear svm
  #objL <- tune.svm(groupingvar~., data = RF_selec[-hold_out,], gamma = 4^(-5:5), cost = 4^(-5:5),
  #                 tune.control(sampling = "cross"),kernel = "linear")
  #best.parameters_L = objL$best.parameters
  #svm.model_L <- svm(yy[-hold_out] ~ ., data = xx[-hold_out,], cost = best.parameters_L$cost, gamma = best.parameters_L$gamma, kernel = "linear")
  #ppsvm_L[hold_out] = predict(svm.model_L, xx[hold_out,])
  
  ##---radial svm
  objR <- tune.svm(groupingvar~., data = RF_selec[-hold_out,], gamma = 4^(-5:5), cost = 4^(-5:5),
                   tune.control(sampling = "cross"),kernel = "radial")
  best.parameters = objR$best.parameters
  svm.model_R <- svm(yy[-hold_out] ~ ., data = xx[-hold_out,], cost = best.parameters$cost, gamma = best.parameters$gamma, kernel = "radial")
  ppsvm[hold_out] = predict(svm.model_R, xx[hold_out,])
}

true_class <- sign(yy - 0.5)
pred_classsvm <- sign(ppsvm);
prediction_res2=table(true_class, pred_classsvm)
temp =classAgreement (prediction_res2)

#Accuracyreal = temp$kappa
##--logreg:
#pred_class <- sign(pp);
#prediction_res1=table(true_class, pred_class)
##--svmlionear:
#pred_classsvm_L <- sign(ppsvm_L);
#prediction_res3=table(true_class, pred_classsvm_L)

#Accuracy of grouping and plot

# ACURRACY=NA
# temp =classAgreement (prediction_res1)
# ACURRACY = c(Accuracyreal, temp$kappa)
# 
# temp =classAgreement (prediction_res3)
# ACURRACY = c(ACURRACY, temp$kappa)
# ACURRACY