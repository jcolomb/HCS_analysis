## SVM tests
Npermutation = 1 # make sure only one permutation is done.

## data input:
source ("analysis/reviews_and_tests.r") # set working directory to project first.

#seed set to 74

# change data to test 3 groups:
Multi_datainput_moriginal = Multi_datainput_m

Multi_datainput_mplus = Multi_datainput_moriginal
Multi_datainput_mplus$groupingvar = "third"
Multi_datainput_m= rbind(Multi_datainput_moriginal, Multi_datainput_mplus
                        )
# test 1: do not run if groups are not equal

source ("Rcode/svmtest.r")
if (!NO_svm){ source ("Rcode/svmperf.r") } # will not run

# put same number of data per group
Multi_datainput_m = Multi_datainput_m [1:30,]

# test 2: run with 3 groups of 10
NO_svm = FALSE
source ("Rcode/svmtest.r")
if (!NO_svm){ source ("Rcode/svmperf.r") } # not run
# run the code for 3 groups, get 3 text outputs (takes time, as one permutation is done)
p1
p2
p3

# test 3: with more than 15 animals per group: run testset and trainset (2 groups)

Multi_datainput_mplus = Multi_datainput_moriginal
Multi_datainput_m= rbind(Multi_datainput_moriginal, Multi_datainput_mplus
)

NO_svm = FALSE
source ("Rcode/svmtest.r")
if (!NO_svm){ source ("Rcode/svmperf.r") }

trainset$groupingvar
testset$groupingvar
Accuracy

# Accuracy very good:
# trying more permutation to see whether there is a chance problem:

Npermutation = 30
if (!NO_svm){ source ("Rcode/svmperf.r") }
hist(Acc_sampled, breaks=c(0:15)/15*2-1)
abline(v = Accuracyreal, col="Red")
beepr::beep()
Npermutation = 1
Acc_sampled = c()


# High Accuracyreal indeed due to chance


# test 4: 2-out validation with 2 groups
Multi_datainput_m = Multi_datainput_moriginal

NO_svm = FALSE
source ("Rcode/svmtest.r")
if (!NO_svm){ source ("Rcode/svmperf.r") }

# Accuracyreal is very low, but it does not seem to be a bug.
# change data to make difference between groups bigger:
Multi_datainput_m = Multi_datainput_moriginal 
Multi_datainput_m [11:20, 3] = 3*Multi_datainput_m [11:20, 3]
Multi_datainput_m [11:20, 4] = Multi_datainput_m [11:20, 4]- 2*Multi_datainput_m [11:20, 3] # total will still 1

Multi_datainput_m [1:20, 3]
Multi_datainput_m [1:20, 4] 

NO_svm = FALSE
source ("Rcode/svmtest.r")
if (!NO_svm){ source ("Rcode/svmperf.r") }

Accuracyreal

Multi_datainput_moriginal -> Multi_datainput_m
