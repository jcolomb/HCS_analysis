#######################################
#
# install.packages("glmpath")
library(glmpath)

set.seed(12)

num_per_class <- 10;
num_feat <- 15;

xx  <- matrix(rnorm(2*num_per_class*num_feat), nrow=2*num_per_class)   ## matrix of features
yy  <- rep(c(1,0), times=num_per_class);  ## class labels, alternating pos (1) and neg (0) cases
pp  <- rep(NA, length(yy))                ## linear predictions, exp(pp)/(1+exp(pp)) for response

for (k in 1:num_per_class) {
  hold_out = c(2*k-1, 2*k) ## hold out one pos and one neg examples so samples are still balanced 
  fit <- glmpath(x=xx[-hold_out,], y=yy[-hold_out], family=binomial, max.arclength=0.05)
  bestdex <- which.min(fit$bic)
  if (bestdex==1) {bestdex <- 2}  ## break ties by avoiding degenerate classifiers 
  bestlambda <- fit$lambda[bestdex]
  pred <- predict(fit, newx=xx[hold_out,], s=bestlambda, type="link", mode="lambda") 
  pp[hold_out] = pred
}

true_class <- sign(yy - 0.5)
pred_class <- sign(pp); 

print(table(true_class, pred_class))

########################################