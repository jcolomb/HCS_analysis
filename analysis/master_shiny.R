if (Projects_metadata$video_analysis =="HCS 3.0"){
  Behav_code <-
  read_delim(
    "infos/HCS_MBR_Code_Details/Short Behavior Codes-Table 1.csv",
    ",",
    escape_double = FALSE,
    col_types = cols(`Behavior Code` = col_integer()),
    trim_ws = TRUE,
    skip = 1
  )[, c(1, 3)]
names (Behav_code) = c("behavior", "beh_name")

framepersec = 25
}
source ("Rcode/get_behav_gp.r")
#get rid of columns with NA (distance traveled if data comes from mbr)
Multi_datainput_m=Multi_datainput_m[,!colSums(is.na(Multi_datainput_m))>0 ]

#multidimensional analysis, Random forest in 2 rounds
source ("Rcode/RF_selection_2rounds.R")# returns RF_selec = Input

#multidimensional analysis, PCA followed by wilocoxon test on 1st component
source ("Rcode/PCA_strategy.R")

set.seed(74)
testvalidation = ifelse((min(summary(metadata$groupingvar)) > 15),TRUE,FALSE)
Validation_type = ifelse(testvalidation,"independent test dataset","2-out")

if (TRUE) Acc_sampled = c()

if (nrow(metadata) < 20 || NO_svm) {
  print("not enough data for svm")
  Accuracyreal=NA
  NO_svm = TRUE
  #calcul_text =NA
  
  source ("Rcode/ICA.R")
  rmarkdown::render ("reports/multidim_anal_variable.Rmd")
  file.copy("reports/results.rdata", paste0(Outputs,"/multidim_analysis_",groupingby,".Rdata"), overwrite=TRUE,
            copy.mode = TRUE, copy.date = FALSE)
  file.copy("reports/multidim_anal_variable.html", paste0(Outputs,"/multidim_analysis_",groupingby,".html"), overwrite=TRUE,
            copy.mode = TRUE, copy.date = FALSE)
  
}else{
  if (length(unique(metadata$groupingvar))==3) {
    source ("Rcode/morethan2groups.R")
    rmarkdown::render ("reports/multidim_anal_variable2.Rmd", output_file = "multidim_anal_variable.html")
  }else{
    source ("Rcode/ICA.R") # return plot called pls
    source ("Rcode/multidimensional_analysis_svm.R") # returns Accuracy (text), Accuracyreal = kappa of result of svm prediction on the test data
    # set 
    source ("Rcode/multidimensional_analysis_perm_svm.R") # returns Acc_sampled
    rmarkdown::render ("reports/multidim_anal_variable.Rmd")
  }
  save.image(file= "reports/results.rdata") 
  file.copy("reports/results.rdata", paste0(Outputs,"/multidim_analysis_",groupingby,".Rdata"), overwrite=TRUE,
            copy.mode = TRUE, copy.date = FALSE)
}
  


# save reports in the correct output folder.
file.copy("reports/multidim_anal_variable.html", paste0(Outputs,"/multidim_analysis_",groupingby,".html"), overwrite=TRUE,
          copy.mode = TRUE, copy.date = FALSE)


beepr::beep()

