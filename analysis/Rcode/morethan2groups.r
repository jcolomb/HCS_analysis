#-- this code is used if there is more than two groups 
#-- it does the svm analysis
#-- probably needs to be modified

Input = Multi_datainput_m


##data splitting
#split by variable


  metadata_ori= metadata
  Multi_datainput_m_ori = Multi_datainput_m
  if (!is.na(Projects_metadata$confound_by)) {
    Multi_datainput_m2_ori = Multi_datainput_m2
  }else {
    Multi_datainput_m2_ori =Multi_datainput_m
  }
  
  print("we need to choose grouping variables")
  metadata_ori$groupingvar = as.factor(metadata_ori$groupingvar)
  
  
  metadataRest= metadata_ori [metadata_ori$groupingvar %in% levels(metadata_ori$groupingvar)[1:2],]
  metadata=droplevels(metadataRest)
  Multi_datainput_mREST = Multi_datainput_m_ori [metadata_ori$groupingvar %in% levels(metadata_ori$groupingvar)[1:2],]
  Multi_datainput_m= droplevels(Multi_datainput_mREST)
  Multi_datainput_m2REST = Multi_datainput_m2_ori [metadata_ori$groupingvar %in% levels(metadata_ori$groupingvar)[1:2],]
  Multi_datainput_m2= droplevels(Multi_datainput_m2REST)
  # make svm!
  source ("Rcode/multidimensional_analysis_svm.r")
  Acc_sampled= c() # set 
  source ("Rcode/multidimensional_analysis_perm_svm.r") # returns Acc_sampled
  k <- sum(abs(Acc_sampled) >= abs(Accuracyreal))   # Two-tailed test
  R=binconf(k, length(Acc_sampled), method='exact')
  p1=print(paste0 ("For the groups ", paste (unique(metadata$groupingvar), collapse= " "),": ", Accuracy,
                   ". doing ",length(Acc_sampled) , " permutations, we find the p value lies between ", R[2], " and ", R[3]))
  
  
  metadataRest= metadata_ori [metadata_ori$groupingvar %in% levels(metadata_ori$groupingvar)[2:3],]
  metadata=droplevels(metadataRest)
  Multi_datainput_mREST = Multi_datainput_m_ori [metadata_ori$groupingvar %in% levels(metadata_ori$groupingvar)[2:3],]
  Multi_datainput_m= droplevels(Multi_datainput_mREST)
  # make svm!
  source ("Rcode/multidimensional_analysis_svm.r")
  Acc_sampled= c() # set 
  source ("Rcode/multidimensional_analysis_perm_svm.r") # returns Acc_sampled
  k <- sum(abs(Acc_sampled) >= abs(Accuracyreal))   # Two-tailed test
  R=binconf(k, length(Acc_sampled), method='exact')
   p2=print(paste0 ("For the groups ", paste (unique(metadata$groupingvar), collapse= " "),": ", Accuracy,
                   ". doing ",length(Acc_sampled) , " permutations, we find the p value lies between ", R[2], " and ", R[3]))
  
  metadataRest= metadata_ori [metadata_ori$groupingvar %in% levels(metadata_ori$groupingvar)[c(1,3)],]
  metadata=droplevels(metadataRest)
  Multi_datainput_mREST = Multi_datainput_m_ori [metadata_ori$groupingvar %in% levels(metadata_ori$groupingvar)[c(1,3)],]
  Multi_datainput_m= droplevels(Multi_datainput_mREST)
  # make svm!
  source ("Rcode/multidimensional_analysis_svm.r")
  Acc_sampled= c() # set 
  source ("Rcode/multidimensional_analysis_perm_svm.r") # returns Acc_sampled
  k <- sum(abs(Acc_sampled) >= abs(Accuracyreal))   # Two-tailed test
  R=binconf(k, length(Acc_sampled), method='exact')
  p3=print(paste0 ("For the groups ", paste (unique(metadata$groupingvar), collapse= " "),": ", Accuracy,
                   ". doing ",length(Acc_sampled) , " permutations, we find the p value lies between ", R[2], " and ", R[3]))
  

  Multi_datainput_m_ori -> Multi_datainput_m
  Multi_datainput_m2_ori -> Multi_datainput_m2
  metadata_ori -> metadata

# print(pls)
# p1
# p2
# p3