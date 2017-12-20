source ("Rcode/get_behav_gp.r")
#multidimensional analysis, Random forest in 2 rounds
source ("Rcode/RF_selection_2rounds.R")# returns RF_selec = Input

#multidimensional analysis, PCA followed by wilocoxon test on 1st component
source ("Rcode/PCA_strategy.R")

if (nrow(metadata) < 22) {
  print("not enough data for svm")
  Accuracyreal=NA
  Acc_sampled =NA
  calcul_text =NA
  
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
    #source ("Rcode/multidim_anal_variable.R")
    #multidimensional analysis, prepare data
   
    source ("Rcode/ICA.R") # return plot called pls
    
    set.seed(74)
    source ("Rcode/multidimensional_analysis_svm.R") # returns Accuracy (text), Accuracyreal = kappa of result of svm prediction on the test data
    
    Acc_sampled= c() # set 
    
    source ("Rcode/multidimensional_analysis_perm_svm.R") # returns Acc_sampled
    
    rmarkdown::render ("reports/multidim_anal_variable.Rmd")
    file.copy("reports/results.rdata", paste0(Outputs,"/multidim_analysis_",groupingby,".Rdata"), overwrite=TRUE,
              copy.mode = TRUE, copy.date = FALSE)
  }
}
  
  
  


# save reports in the correct output folder.
file.copy("reports/multidim_anal_variable.html", paste0(Outputs,"/multidim_analysis_",groupingby,".html"), overwrite=TRUE,
          copy.mode = TRUE, copy.date = FALSE)


beepr::beep()

#-------------------------------Other code not used ------------------
#other codes to be checked and maybe used.

#source ("Rcode/create_eventfile.r") # output EVENT_data, note this takes the whole recording and is therefore not very useful

#analysis (graphs) from the minute file, 
#source ("Rcode/analysis_from_min.R")

#the raw data have too much problems, timing and categories should be worked out before we can work with it
#source ("Rcode/create_rawdatafiles.r")


# #-------------------------------testing code ------------------
# metadata = metadata %>% filter (genotype == "wt")
# MIN_data =MIN_data %>% filter(ID %in% metadata$ID)
# 
# metadata$groupingvar=as.factor(metadata$groupingvar)
# metadata$groupingvar =as.numeric(sample(metadata$groupingvar))
# ### test for one TW
# #multidimensional analysis, prepare data
# source ("Rcode/multidimensional_analysis_prep.R")
# #only one TW
# #source ("Rcode/testscode/multidimensional_analysis_prep_oneTW.R")
# 
# #multidimensional analysis, Random forest in 2 rounds
# source ("Rcode/RF_selection_2rounds.R") # returns RF_selec = Input
# source ("Rcode/testscode/L1_reg_plotting.R")
# 
# plot
