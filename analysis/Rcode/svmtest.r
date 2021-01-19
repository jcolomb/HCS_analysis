# svmtest

## Check data: can the SVM be performed
svmMessage = ""
if (length(unique(Multi_datainput_m$groupingvar)) > 3) {
  NO_svm = TRUE
  svmMessage = paste0(svmMessage, "SVM can only be done if there no more than 3 groups.")
}

if (min(summary(
  Multi_datainput_m$groupingvar)) < 10 ) {
  NO_svm = TRUE
  svmMessage = paste0(svmMessage, " At least one group has a sample size lower than 10")
}

# choose the type of validation depending on the sample size (>15 in each group ?)
testvalidation = ifelse((min(summary(
  Multi_datainput_m$groupingvar
)) > 15), TRUE, FALSE)
Validation_type = ifelse(testvalidation, "independent test dataset", "2-out")

# check groups size difference.

if (Validation_type == "2-out" ){
  if (max(summary(Multi_datainput_m$groupingvar)) - min(summary(Multi_datainput_m$groupingvar)) != 0){
    NO_svm = TRUE
    svmMessage = paste0(svmMessage, "in 2-out validation, we need the same number of animals per group, please select animals manually.")
  }
}
  


  print(svmMessage)
  Accuracyreal = NA  # set Accuracyreal for the case no SVM can be performed
  