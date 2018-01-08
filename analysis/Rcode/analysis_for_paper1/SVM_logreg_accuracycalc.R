before =Sys.time()
RF_selec = data[order(data$groupingvar),]

xx= as.matrix(RF_selec %>% select (-groupingvar))
yy = as.numeric(RF_selec$groupingvar)-1
pp  <- rep(NA, length(yy))
ppsvm  <- rep(NA, length(yy))
ppsvm_L  <- rep(NA, length(yy))

num_per_class <- nrow(RF_selec)/2

for (k in 1:num_per_class) {
  ##logregression
  hold_out = c(k, k+num_per_class) ## hold out one pos and one neg examples so samples are still balanced
  fit <- glmpath::glmpath(x=xx[-hold_out,], y=yy[-hold_out], family=binomial, max.arclength=1)
  bestdex <- which.min(fit$bic)
  if (bestdex==1) {bestdex <- 2}  ## break ties by avoiding degenerate classifiers
  bestlambda <- fit$lambda[bestdex]
  pred <- predict(fit, newx=xx[hold_out,], s=bestlambda, type="link", mode="lambda")
  pp[hold_out] = pred
  
  #svm
  groupingvar=as.data.frame(yy[-hold_out])
  objR <- tune.svm(groupingvar~., data = RF_selec[-hold_out,], gamma = 4^(-5:5), cost = 4^(-5:5),
                   tune.control(sampling = "cross"),kernel = "radial")
  objL <- tune.svm(groupingvar~., data = RF_selec[-hold_out,], gamma = 4^(-5:5), cost = 4^(-5:5),
                   tune.control(sampling = "cross"),kernel = "linear")
  
  best.parameters = objR$best.parameters
  best.parameters_L = objL$best.parameters
  
  
  svm.model_R <- svm(yy[-hold_out] ~ ., data = xx[-hold_out,], cost = best.parameters$cost, gamma = best.parameters$gamma, kernel = "radial")
  
  svm.model_L <- svm(yy[-hold_out] ~ ., data = xx[-hold_out,], cost = best.parameters_L$cost, gamma = best.parameters_L$gamma, kernel = "linear")
  
  #svm.pred <- predict(svm.model, xx[hold_out,])
  ppsvm[hold_out] = predict(svm.model_R, xx[hold_out,])
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
ACURRACY = c(temp$kappa)
temp =classAgreement (prediction_res2)
ACURRACY = c(ACURRACY, temp$kappa)
temp =classAgreement (prediction_res3)
ACURRACY = c(ACURRACY, temp$kappa)
ACURRACY
