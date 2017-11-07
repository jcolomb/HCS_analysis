#RF

# first round:
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

Input = Multi_datainput_m [, names(Multi_datainput_m) %in% as.character(R2 [1:20, 1])]
Input$groupingvar = Multi_datainput_m$groupingvar

# second round
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

# selection of variables (8-20)

import_treshold = 0.95
R3 = data.frame(row.names (R), R)  %>%
  filter(MeanDecreaseGini > import_treshold)
numberofvariables = max (nrow (R3), 8)

#Result table with only selected variables:

Input = Multi_datainput_m [, names(Multi_datainput_m) %in% as.character(R2 [1:numberofvariables, 1])]
Input$groupingvar = Multi_datainput_m$groupingvar
RF_selec = Input
Variables_list =as.character(R2 [1:numberofvariables, 1])
