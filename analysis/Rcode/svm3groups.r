#-- this code is used if there is more than two groups 
#-- it does the svm analysis, get 3 output text for each svm (p1,p2,p3)


## save original data, 
if (!is.na(Projects_metadata$confound_by)) {
Multi_datainput_m2_ori = Multi_datainput_m2
} else {Multi_datainput_m2_ori= Multi_datainput_m} # put something in here when the object do not exist

Multi_datainput_m_ori = Multi_datainput_m


## Select couple and run svm: 1,2

Multi_datainput_m = Multi_datainput_m_ori %>%
  filter (groupingvar %in% levels (Multi_datainput_m_ori$groupingvar)[1:2])


Multi_datainput_m2 = Multi_datainput_m2_ori %>%
            filter (groupingvar %in% levels (Multi_datainput_m_ori$groupingvar)[1:2] )

Multi_datainput_m= droplevels(Multi_datainput_m)
Multi_datainput_m2= droplevels(Multi_datainput_m2)
# make svm!
source ("Rcode/multidimensional_analysis_svm.r")
Acc_sampled= c() # set 
source ("Rcode/multidimensional_analysis_perm_svm.r") # returns Acc_sampled
k <- sum(abs(Acc_sampled) >= abs(Accuracyreal))   # Two-tailed test
R=binconf(k, length(Acc_sampled), method='exact')
p1=print(paste0 ("For the groups ", paste (unique(Multi_datainput_m$groupingvar), collapse= " "),": ", Accuracy,
                 ". doing ",length(Acc_sampled) , " permutations, we find the p value lies between ", R[2], " and ", R[3]))

## Select couple and run svm: 1,3

Multi_datainput_m = Multi_datainput_m_ori %>%
  filter (groupingvar %in% levels (Multi_datainput_m_ori$groupingvar)[c(1,3)])

Multi_datainput_m2 = Multi_datainput_m2_ori %>%
  filter (groupingvar %in% levels (Multi_datainput_m_ori$groupingvar)[c(1,3)] )
Multi_datainput_m= droplevels(Multi_datainput_m)
Multi_datainput_m2= droplevels(Multi_datainput_m2)
# make svm!
source ("Rcode/multidimensional_analysis_svm.r")
Acc_sampled= c() # set 
source ("Rcode/multidimensional_analysis_perm_svm.r") # returns Acc_sampled
k <- sum(abs(Acc_sampled) >= abs(Accuracyreal))   # Two-tailed test
R=binconf(k, length(Acc_sampled), method='exact')
p2=print(paste0 ("For the groups ", paste (unique(Multi_datainput_m$groupingvar), collapse= " "),": ", Accuracy,
                 ". doing ",length(Acc_sampled) , " permutations, we find the p value lies between ", R[2], " and ", R[3]))

## Select couple and run svm: 2,3

Multi_datainput_m = Multi_datainput_m_ori %>%
  filter (groupingvar %in% levels (Multi_datainput_m_ori$groupingvar)[2:3])

Multi_datainput_m2 = Multi_datainput_m2_ori %>%
  filter (groupingvar %in% levels (Multi_datainput_m_ori$groupingvar)[2:3] )
Multi_datainput_m= droplevels(Multi_datainput_m)
Multi_datainput_m2= droplevels(Multi_datainput_m2)
# make svm!
source ("Rcode/multidimensional_analysis_svm.r")
Acc_sampled= c() # set 
source ("Rcode/multidimensional_analysis_perm_svm.r") # returns Acc_sampled
k <- sum(abs(Acc_sampled) >= abs(Accuracyreal))   # Two-tailed test
R=binconf(k, length(Acc_sampled), method='exact')
p3=print(paste0 ("For the groups ", paste (unique(Multi_datainput_m$groupingvar), collapse= " "),": ", Accuracy,
                 ". doing ",length(Acc_sampled) , " permutations, we find the p value lies between ", R[2], " and ", R[3]))

# recreate original data

Multi_datainput_m_ori -> Multi_datainput_m
Multi_datainput_m2_ori -> Multi_datainput_m2