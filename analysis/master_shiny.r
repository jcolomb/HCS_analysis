## this reads the data path, check if all files exist, group animals following metadata entries and create a minute summary spreadsheet
## it exclude entries, create time windows and make summaries for each time window from the minute summary data.
source ("Rcode/get_behav_gp.r")

#get rid of columns with NA (distance traveled if data comes from mbr)
Multi_datainput_m = Multi_datainput_m[, !colSums(is.na(Multi_datainput_m)) >
                                        0]

#multidimensional analysis, Random forest in 2 rounds result will be used for ICA code below
source ("Rcode/RF_selection_2rounds.r")# returns RF_selec = Input
source ("Rcode/ICA.r") # return plot called pls

#multidimensional analysis, PCA followed by wilocoxon test on 1st component, and effect size calculation
source ("Rcode/PCA_strategy.r")

## SVM procedure
set.seed(74)
## put this to FALSE if you want to get more tests and not overwrite Acc_sampled, only works if not using the shiny app.
if (TRUE) Acc_sampled = c()

source ("Rcode/svmtest.r")
if (!NO_svm){ source ("Rcode/svmperf.r") } # SVM done only if asked in app, and there is enough data.


if (length(unique(metadata$groupingvar)) == 3) {
  rmarkdown::render ("reports/multidim_anal_variable2.Rmd", output_file = "multidim_anal_variable.html")
} else {rmarkdown::render ("reports/multidim_anal_variable.Rmd")}


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
