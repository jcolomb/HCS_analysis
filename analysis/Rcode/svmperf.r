# svmperf


  if (length(unique(metadata$groupingvar)) == 3) { # case of 3 groups
    
    source ("Rcode/morethan2groups.r")
    
  } elseif (length(unique(metadata$groupingvar)) == 2){   # case of 2 groups
    source ("Rcode/multidimensional_analysis_svm.r") # returns Accuracy (text), Accuracyreal = kappa of result of svm prediction on the test data

    source ("Rcode/multidimensional_analysis_perm_svm.r") # returns Acc_sampled
  } else {print ("something stranged happen, is there only one group?")}
  
}