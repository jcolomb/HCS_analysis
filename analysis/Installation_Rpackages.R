#installation, running this code will use renv if you are using R 3.6.1 (i.e download the dependencies as they were during software testing) or install packages in your normal environment if using a new version of R.
vers=R.Version()
if (vers$major =="3"){
  renv::restore()
} else {
  print("renv set for R 3.6.1, trying to install new packages version from CRAN, it will probably work, but was not tested.")
  install.packages(c(
    "randomForest",
    "ica",
    "e1071", #svm
    "Hmisc",   #binomial confidence
    "rstatix",
    "coin",
    #normal libraries:
    "tidyverse",
    "stringr",
    #for plotting
    "gridExtra",
    "RGraphics",
    "shinyFiles",
    "devtools",
    "plotly",
    "glmpath",
    "pander",
    "DT",
    "beepr",
    "osfr"))
}



## alternatively you may install all packages and hope it works without packrat:
#





### old dependencies, no need to get it anymore
### devtools::install_github('jcolomb/osfr')
