## this reads the data path, check if all files exist, group animals following metadata entries and create a minute summary spreadsheet
## it exclude entries, create time windows and make summaries for each time window from the minute summary data.
source ("Rcode/get_behav_gp.r")

#get rid of columns with NA (distance traveled if data comes from mbr)
Multi_datainput_m = Multi_datainput_m[, !colSums(is.na(Multi_datainput_m)) >
                                        0]

#multidimensional analysis, Random forest in 2 rounds result will be used for ICA code below
source ("Rcode/RF_selection_2rounds.R")# returns RF_selec = Input

#multidimensional analysis, PCA followed by wilocoxon test on 1st component, and effect size calculation
source ("Rcode/PCA_strategy.R")

## start svm procedure
set.seed(74)
# choose the type of validation depending on the sample size
testvalidation = ifelse((min(summary(
  metadata$groupingvar
)) > 15), TRUE, FALSE)
Validation_type = ifelse(testvalidation, "independent test dataset", "2-out")

## put this to FALSE if you want to get more tests and not overwrite Acc_sampled
if (TRUE)
  Acc_sampled = c()
if (length(unique(metadata$groupingvar)) > 3) {NO_svm = TRUE}
if (nrow(metadata) < 20 || NO_svm) { ## sample size too low, no SVM done
  print("not enough data or too many groups for svm")
  Accuracyreal = NA
  NO_svm = TRUE
  #calcul_text =NA
  
  source ("Rcode/ICA.R")
  rmarkdown::render ("reports/multidim_anal_variable.Rmd")
  #file.copy("reports/results.rdata", paste0(Outputs,"/multidim_analysis_",groupingby,".Rdata"), overwrite=TRUE,
  #          copy.mode = TRUE, copy.date = FALSE)
  #file.copy("reports/multidim_anal_variable.html", paste0(Outputs,"/multidim_analysis_",groupingby,".html"), overwrite=TRUE,
  #          copy.mode = TRUE, copy.date = FALSE)
  
} else{
  if (length(unique(metadata$groupingvar)) == 3) { # case of 3 groups
    source ("Rcode/ICA.R") 
    source ("Rcode/morethan2groups.R")
    rmarkdown::render ("reports/multidim_anal_variable2.Rmd", output_file = "multidim_anal_variable.html")
  } else{ # case of 2 groups
    source ("Rcode/ICA.R") # return plot called pls
    source ("Rcode/multidimensional_analysis_svm.R") # returns Accuracy (text), Accuracyreal = kappa of result of svm prediction on the test data
    # set
    source ("Rcode/multidimensional_analysis_perm_svm.R") # returns Acc_sampled
    rmarkdown::render ("reports/multidim_anal_variable.Rmd")
  }
  
}



# save reports in the correct output folder.
file.copy(
  "reports/multidim_anal_variable.html",
  paste0(Outputs, "/Bseq", Name_project, groupingby, ".html"),
  overwrite = TRUE,
  copy.mode = TRUE,
  copy.date = FALSE
)
# save image in the same correct output folder, do not work if shiny app is used.
save.image(file = "reports/results.rdata")
file.copy(
  "reports/results.rdata",
  paste0(Outputs, "/Bseq", Name_project, groupingby, ".Rdata"),
  overwrite = TRUE,
  copy.mode = TRUE,
  copy.date = FALSE
)

## make a sound when it is finished
beepr::beep()
