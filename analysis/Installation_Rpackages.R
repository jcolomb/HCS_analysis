#installation:

install.packages(c(
  "randomForest",
  "ica",
  "e1071", #svm
  "Hmisc",   #binomial confidence 
  
  
  #normal libraries:
  "tidyverse",
  "stringr",
  #for plotting
  "gridExtra",
  "RGraphics"))

devtools::install_github('jcolomb/osfr')
