# svmperf


  if (length(unique(Multi_datainput_m$groupingvar)) == 3) { # case of 3 groups
    
    source ("Rcode/svm3groups.r") # this one filter the data for 2 groups and run the svm on these 2 groups, then give 2x2 differences (3 results as there are 3 couples possible).
    # returns p1, p2, p3
    
  } else if(length(unique(Multi_datainput_m$groupingvar)) == 2){   # case of 2 groups
    source ("Rcode/multidimensional_analysis_svm.r") # returns Accuracy (text), Accuracyreal = kappa of result of svm prediction on the test data

    source ("Rcode/multidimensional_analysis_perm_svm.r") # returns Acc_sampled
  } else {print ("something strange happen, is there only one group?") # more than 3 groups should make this code not run.
  }