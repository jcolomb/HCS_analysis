summary (as.factor(metadata$groupingvar))
numberofvariables = (length(names(behav_gp)) - 3) * nrow (Timewindows)
numberofvariables = trunc(numberofvariables / 3)


HCS.rf <-
  randomForest(
    groupingvar ~ .,
    data = Multi_datainput_m,
    importance = TRUE,
    proximity = TRUE,
    ntree = 1500
  )
R = round(importance(HCS.rf, type = 2), 2)
R2 = data.frame(row.names (R), R)  %>% arrange(-MeanDecreaseGini)
#pander::pandoc.table(R2)
varImpPlot(HCS.rf)
Input = Multi_datainput_m [, names(Multi_datainput_m) %in% as.character(R2 [1:numberofvariables, 1])]
Input$groupingvar = Multi_datainput_m$groupingvar
HCS.rf2 <-
  randomForest(
    groupingvar ~ .,
    data = Input,
    importance = TRUE,
    proximity = TRUE,
    ntree = 1500
  )
R = round(importance(HCS.rf2, type = 2), 2)
R2 = data.frame(row.names (R), R)  %>% arrange(-MeanDecreaseGini)
#pander::pandoc.table(R2)
varImpPlot(HCS.rf2)
import_treshold = 0.95
R3 = data.frame(row.names (R), R)  %>%
  filter(MeanDecreaseGini > import_treshold)
numberofvariables = max (nrow (R3), 6)
Input = Multi_datainput_m [, names(Multi_datainput_m) %in% as.character(R2 [1:numberofvariables, 1])]
Input$groupingvar = Multi_datainput_m$groupingvar
HCS.rf2 <-
  randomForest(
    groupingvar ~ .,
    data = Input,
    importance = TRUE,
    proximity = TRUE,
    ntree = 1500
  )
varImpPlot(HCS.rf2)
Plot = Multi_datainput_m [, names(Multi_datainput_m) %in% as.character(R2 [1:2, 1])]
Plot = cbind(Multi_datainput_m$groupingvar, Plot)
Title_plot = paste0(names (Plot) [2], "x", names (Plot) [3])
names (Plot) = c("groupingvar", "disciminant1", "discriminant2")
p = ggplot (Plot, aes (y = disciminant1, x = discriminant2, color = groupingvar)) +
  geom_point() +
  labs(title = Title_plot) +
  #scale_x_log10() + scale_y_log10()+
  scale_colour_grey() + theme_bw() +
  theme(legend.position = 'none')
print(p)
p = icafast(Input %>% select (-groupingvar),
            2,
            center = T,
            maxit = 100)
R = cbind(p$Y, Input   %>% select (groupingvar))
names(R) = c("D1", "D2",  "groupingvar")
pls = R %>% ggplot (aes (x = D1, y = D2, color = groupingvar)) +
  geom_point() +
  labs (title = numberofvariables) +
  scale_colour_grey() + theme_bw() +
  theme(legend.position = 'none')
print(pls)


#-------------SVM

if (nrow(metadata) < 22) {
  print("there is not enough data to try to do a svm")
  knitr::knit_exit()
}

set.seed(74)
if (!is.na(Projects_metadata$confound_by)){
  Input = Multi_datainput_m2 [, names(Multi_datainput_m2) %in% as.character(R2 [1:numberofvariables, 1])]
  Input$groupingvar = Multi_datainput_m2$groupingvar
  Input$confoundvar = Multi_datainput_m2$confoundvar
  
  L = levels(Input$groupingvar)
  L2 =levels(Input$confoundvar)
  Glass = Input %>% filter (groupingvar == L[1] )
  Glass2 = Input %>% filter (groupingvar == L[2])
  if (nrow (Glass) != nrow (Glass2))
    print("the groups do not have the same size !")
  indexl = min(nrow(Glass), nrow(Glass2))
  if (indexl < 15)
    print(paste0("there is only ", indexl - 10, " animal in the test dataset (per group)"))
  # split each randomly
  
  Glass_1 = Glass %>% filter (confoundvar == L2[1] )
  Glass_2 = Glass %>% filter (confoundvar == L2[2] )
  Glass2_1 = Glass2 %>% filter (confoundvar == L2[1] )
  Glass2_2 = Glass2 %>% filter (confoundvar == L2[2] )
  
  index     <- 1:indexl
  trainlength= max(5,  trunc(length(index) / 3))
  indexl2 = min(nrow(Glass_1), nrow(Glass_2), nrow(Glass2_1), nrow(Glass2_2))
  index     <- 1:indexl2  
  trainindex <- sample(index, max(5, trainlength))
  
  
  trainset  <- rbind(Glass_1[trainindex,], Glass_2[trainindex,], Glass2_1[trainindex,], Glass2_2[trainindex,])
  testset <- rbind(Glass_1[-trainindex,], Glass_2[-trainindex,], Glass2_1[-trainindex,], Glass2_2[-trainindex,])
  trainset  <- trainset %>% select (-confoundvar)
  testset <- testset %>% select (-confoundvar)
  ## getting rid of variables with no variability (all 0)
  

}else {
  L = levels(Input$groupingvar)
  Glass = Input %>% filter (groupingvar == L[1])
  Glass2 = Input %>% filter (groupingvar == L[2])
  if (nrow (Glass) != nrow (Glass2))
    print("the groups do not have the same size !")
  indexl= min(nrow(Glass),nrow(Glass2))
  if (indexl<15) print(paste0("there is only ",indexl-10, " animal in the test dataset (per group)"))
  # split each randomly
  index     <- 1:indexl
  trainindex <- sample(index, max(10, 2*trunc(length(index) / 3)))
  
  trainset  <- rbind(Glass[trainindex, ], Glass2[trainindex, ])
  
  testset <- rbind(Glass[-trainindex, ], Glass2[-trainindex, ])
  
}

temp = trainset %>% select (-groupingvar)
cfreq <- colSums(temp)
E1 = names(temp[, cfreq == 0])
temp = testset %>% select (-groupingvar)
cfreq <- colSums(temp)
E2 = names(temp[, cfreq == 0])
trainset = trainset [, !names(trainset) %in% c(E1, E2)]
testset = testset [, !names(testset) %in% c(E1, E2)]
Input = Input[, !names(Input) %in% c(E1, E2)]
if (nrow(trainset) < 20) {
  print(
    "the sample size is not sufficient to produce a svm analysis, you need at least 15 animals per group"
  )
  NOSTAT = TRUE
} else{
  #tuning: choose best kernel (error rate minimal), all data or only a subset (accuracy on trainset maximal, use all if identical), this takes time!
  source ("Rcode/Tuning_svm2.r")
  # run model on test data
  svm.pred <- predict(svm.model, testset %>% select(-groupingvar))
  SVMprediction_res = table(pred = svm.pred, true = testset$groupingvar)
  SVMprediction = as.data.frame(SVMprediction_res)
  #Accuracy of grouping and plot
  temp = classAgreement (SVMprediction_res)
  Accuracyreal = temp$crand
  Accuracy = paste0(
    ncol(Input) - 1,
    " variables: Accuracy of the prediction with ",
    bestk[[1]],
    " kernel (Corrected Rand index: 0 denotes chance level, maximum is 1):",
    Accuracyreal
  )
  print(Accuracy)
}
