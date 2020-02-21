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

#######################################
#
# install.packages("glmpath")
library(glmpath)

set.seed(7)

num_per_class <- 10;
num_feat <- 15;

xx  <- data.frame(matrix(rnorm(2*num_per_class*num_feat), nrow=2*num_per_class)) # data.frame with features
yy  <- rep(c(1,0), times=num_per_class);  ## class labels, alternating pos (1) and neg (0) cases
pp  <- rep(NA, length(yy))                ## linear predictions, exp(pp)/(1+exp(pp)) for response

xx <- data.matrix(xx); ## glmpath and predict prefer matrix or data.matrix to data.frame?

print_coefs = T;  # print coefs during each round of cross-validation
my_eps = 1e-11;   # cutoff on abs value of coef for calling it non-zero
num_nonzero_coef = rep(NA, num_per_class) # num non-zero coef in each round, including intercept

for (k in 1:num_per_class) {
  hold_out = c(2*k-1, 2*k)  ## hold out one pos and one neg examples so samples are still balanced
  fit <- glmpath(x=xx[-hold_out,], y=yy[-hold_out], family=binomial, max.arclength=0.05)
  bestdex <- which.min(fit$bic)
  if (bestdex==1) {bestdex <- 2}  ## break ties by avoiding degenerate classifiers
  bestlambda <- fit$lambda[bestdex]
  coefs <- fit$b.corrector[bestdex,];
  if (print_coefs) {
    cat("######################\nnon-zero coefficients for round", k, "of cross-validation\n")
    print(coefs[abs(coefs) > my_eps])
  }
  num_nonzero_coef[k] <- sum(abs(coefs) > my_eps)
  pred <- predict(fit, newx=xx[hold_out,], s=bestlambda, type="link", mode="lambda")
  pp[hold_out] = pred
}

cat("######################\nnumber of non-zero coefficients in each round of cross-validation:\n")
cat(num_nonzero_coef, "\n")

true_class <- sign(yy - 0.5)
pred_class <- sign(pp);

cat("######################\nresults of cross-validation:\n")
print(table(true_class, pred_class))

true_pos <- (true_class == 1 & pred_class == 1)
true_neg <- (true_class == -1 & pred_class == -1)
false_pos <- (true_class == -1 & pred_class == 1)
false_neg <- (true_class == 1 & pred_class == -1)
no_guess <- (pred_class == 0)

# print(data.frame(true_class, pred_class, true_pos, true_neg, false_pos, false_neg))

num_correct <- sum(true_pos) + sum(true_neg);
num_incorrect  <- sum(false_pos) + sum(false_neg);

if (sum(no_guess)==0) {
  ## since we had balanced classes we use p=0.5 as baseline prob of correct guess
  test <- binom.test(x=num_correct, n = num_correct + num_incorrect, p=0.5, alternative="greater")
  cat("######################\nbinomial test of accuracy:\n")
  print(test)
} else {
  ## could break ties randomly, regard them as incorrect, or something else
  error("need to decide how to regard cases with no guess")
}


### fit model using all the data
fit <- glmpath(x=xx, y=yy, family=binomial, max.arclength=0.05)
bestdex <- which.min(fit$bic)
print(bestdex)
if (bestdex==1) {bestdex <- 2}  ## break ties by avoiding degenerate classifiers
bestlambda <- fit$lambda[bestdex]
coefs <- fit$b.corrector[bestdex,];
if (print_coefs) {
  cat("######################\nnon-zero coefficients using all the data \n")
  print(coefs[abs(coefs) > my_eps])
}
num_nonzero_coef <- sum(abs(coefs) > my_eps)
## check classification on same samples used for training --- can overfit!
pred <- predict(fit, newx=xx, s=bestlambda, type="link", mode="lambda")

true_class <- sign(yy - 0.5)
pred_class <- sign(pred);

cat("######################\nresults of classification on training data:\n")
print(table(true_class, pred_class))
