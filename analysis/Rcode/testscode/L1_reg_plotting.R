library(glmpath)
#input: results of the RF:
RF_selec = Input
# reorder
RF_selec = RF_selec[order(RF_selec$groupingvar),] 



xx= as.matrix(RF_selec %>% select (-groupingvar))
yy = as.numeric(RF_selec$groupingvar)-1
pp  <- rep(NA, length(yy))

#num_per_class <- nrow(RF_selec)/2

# for (k in 1:num_per_class) {
#   hold_out = c(k, k+num_per_class) ## hold out one pos and one neg examples so samples are still balanced 
#   fit <- glmpath(x=xx[-hold_out,], y=yy[-hold_out], family=binomial, max.arclength=1)
#   bestdex <- which.min(fit$bic)
#   if (bestdex==1) {bestdex <- 2}  ## break ties by avoiding degenerate classifiers 
#   bestlambda <- fit$lambda[bestdex]
#   pred <- predict(fit, newx=xx[hold_out,], s=bestlambda, type="link", mode="lambda") 
#   pp[hold_out] = pred
# }
# 
# true_class <- sign(yy - 0.5)
# pred_class <- sign(pp); 
# 
# print(table(true_class, pred_class))


fit <- glmpath(x=xx, y=yy, family=binomial, max.arclength=1)
fit$df
bestdex <- which.min(fit$bic)
if (bestdex==1) {bestdex <- 2}  ## break ties by avoiding degenerate classifiers 
bestdex=19
bestlambda <- fit$lambda[bestdex]

#pred <- predict(fit, newx=xx, type="coefficients", mode="step") 
pred <- predict(fit, newx=xx, s=bestlambda, type="coefficients", mode="lambda")
f=pred[-1]

RF_selec$Index=xx %*%f

boxplot(Index ~ groupingvar, data= RF_selec)
title= paste (f,names(RF_selec)[1:length(f)], sep= "*", collapse = " + ")
title = paste(strwrap(title, width=80), collapse=" \n")


RF_selec%>% ggplot(aes (y=Index, x=groupingvar))+
  geom_boxplot()+
  ggtitle ("lasso logistic regression results",subtitle=title)











# 
# 
# 
# 
# 
# 
# Input %>% mutate (pos = 1.997*immobile1 , neg =3.74*walk4-16.503*Awaken1)->Input2
# Input %>% mutate (pos = 3.274667*immobile1+32.74*Awaken1, neg =-7.569162*walk4-3.673409*walk2)->Input2
# Input %>% mutate (pos = 12.060696*immobile1+117.447616*Awaken1, neg =-29.668648*walk4-14.516887*walk2, z=2.682923*digforage6-7.159406*Stretch6)->Input2
# Input %>% mutate (r2 = 12.060696*immobile1+117.447616*Awaken1-29.668648*walk4-14.516887*walk2-2.682923*digforage6+7.159406*Stretch6)->Input2
# 
# max(Input2 %>% transmute (r-r2))
# 
# plot (Input2$r2, col=Input2$groupingvar)
# 
# library(plotly)
# plot_ly(x=Input2$pos,y=Input2$neg,z=Input2$r, color=Input2$groupingvar, type="scatter3d")
# 
# pp[hold_out] = pred
# 
# summary(fit)
# 
# ## do it with all data
# 
# RF_selec =Multi_datainput_m
# 
# RF_selec = RF_selec[order(RF_selec$groupingvar),] 
# 
# 
# 
# xx= as.matrix(RF_selec %>% select (-groupingvar))
# yy = as.numeric(RF_selec$groupingvar)-1
# pp  <- rep(NA, length(yy))
# 
# num_per_class <- nrow(RF_selec)/2
# 
# fit <- glmpath(x=xx, y=yy, family=binomial, max.arclength=1)
# fit$df
# bestdex <- which.min(fit$bic)
# if (bestdex==1) {bestdex <- 2}  ## break ties by avoiding degenerate classifiers 
# bestdex=19
# bestlambda <- fit$lambda[bestdex]
# 
# #######################################
# #
# # install.packages("glmpath")
# library(glmpath)
# 
# set.seed(7)
# 
# num_per_class <- 15
# num_feat <- 15;
# 
# xx  <- matrix(rnorm(2*num_per_class*num_feat), nrow=2*num_per_class)   ## matrix of features
# yy  <- rep(c(1,0), times=num_per_class);  ## class labels, alternating pos (1) and neg (0) cases
# pp  <- rep(NA, length(yy))                ## linear predictions, exp(pp)/(1+exp(pp)) for response
# 
# for (k in 1:num_per_class) {
#   hold_out = c(2*k-1, 2*k) ## hold out one pos and one neg examples so samples are still balanced 
#   fit <- glmpath(x=xx[-hold_out,], y=yy[-hold_out], family=binomial, max.arclength=0.05)
#   bestdex <- which.min(fit$bic)
#   if (bestdex==1) {bestdex <- 2}  ## break ties by avoiding degenerate classifiers 
#   bestlambda <- fit$lambda[bestdex]
#   pred <- predict(fit, newx=xx[hold_out,], s=bestlambda, type="link", mode="lambda") 
#   pp[hold_out] = pred
# }
# 
# true_class <- sign(yy - 0.5)
# pred_class <- sign(pp); 
# 
# print(table(true_class, pred_class))
# 
# ########################################
