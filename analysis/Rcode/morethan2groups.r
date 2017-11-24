#randomforest
if (nrow(metadata) < 22) print("there is not enough data to try to do a svm")

# get rid of variables with constant values (not scalable)



summary (as.factor(metadata$groupingvar))
numberofvariables = (length(names(behav_gp)) - 3) * nrow (Timewindows)
numberofvariables = trunc(numberofvariables / 3)
#pander::pandoc.table(Timewindows)
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
  #scale_colour_grey() + theme_bw() +
  theme(legend.position = 'side')
print(p)
p = icafast(Input %>% select (-groupingvar),
            2,
            center = T,
            maxit = 100)
R = cbind(p$Y, Input   %>% select (groupingvar))
names(R) = c("D1", "D2",  "groupingvar")
pls = R %>% ggplot (aes (x = D1, y = D2, color = groupingvar)) +
  geom_point() +
  labs (title = numberofvariables) #+
#scale_colour_grey() + theme_bw() +
#theme(legend.position = 'none')
print(pls)
Input = Multi_datainput_m
##data splitting
#split by variable

if (length(unique(metadata$groupingvar))==3) {
  metadata_ori= metadata
  Multi_datainput_m_ori = Multi_datainput_m
  
  print("we need to choose grouping variables")
  metadata_ori$groupingvar = as.factor(metadata_ori$groupingvar)
  
  
  metadataRest= metadata_ori [metadata_ori$groupingvar %in% levels(metadata_ori$groupingvar)[1:2],]
  metadata=droplevels(metadataRest)
  Multi_datainput_mREST = Multi_datainput_m_ori [metadata_ori$groupingvar %in% levels(metadata_ori$groupingvar)[1:2],]
  Multi_datainput_m= droplevels(Multi_datainput_mREST)
  # make svm!
  source ("Rcode/multidimensional_analysis_runnostat.R")
  p1=print(paste0 ("For the groups ", paste (unique(metadata$groupingvar), collapse= " "),": ", Accuracy))
  
  
  metadataRest= metadata_ori [metadata_ori$groupingvar %in% levels(metadata_ori$groupingvar)[2:3],]
  metadata=droplevels(metadataRest)
  Multi_datainput_mREST = Multi_datainput_m_ori [metadata_ori$groupingvar %in% levels(metadata_ori$groupingvar)[2:3],]
  Multi_datainput_m= droplevels(Multi_datainput_mREST)
  # make svm!
  source ("Rcode/multidimensional_analysis_runnostat.R")
  p2=print(paste0 ("For the groups ", paste (unique(metadata$groupingvar), collapse= " "),": ", Accuracy))
  
  metadataRest= metadata_ori [metadata_ori$groupingvar %in% levels(metadata_ori$groupingvar)[c(1,3)],]
  metadata=droplevels(metadataRest)
  Multi_datainput_mREST = Multi_datainput_m_ori [metadata_ori$groupingvar %in% levels(metadata_ori$groupingvar)[c(1,3)],]
  Multi_datainput_m= droplevels(Multi_datainput_mREST)
  # make svm!
  source ("Rcode/multidimensional_analysis_runnostat.R")
  p3=print(paste0 ("For the groups ", paste (unique(metadata$groupingvar), collapse= " "),": ", Accuracy))
   Multi_datainput_m =Multi_datainput_m_ori 
   metadata =metadata_ori
}
print(pls)
p1
p2
p3