source("Rcode/inputdata.r") #output = metadata



#computed variables2
# folder where outputs will be written:
Outputs = paste(WD,Projects_metadata$Folder_path,"Routputs", sep="/")
onlinemin=Outputs 
#for online projects, outputs are written on disk:
if (WD == "https:/") Outputs = paste("../Routputs",Projects_metadata$Folder_path, sep="/")

dir.create (Outputs, recursive = TRUE)
plot.path = Outputs


#check data file existence and if the number of file correspond between the folder and the metadata
#create list of filepath for each animal_ID
source("Rcode/checkmetadata.r") #output BEH_datafiles and MIN_datafiles: list of path

# create a new column with the variable that are splitting the data into groups:
source ("Rcode/animal_groups.r") # output metadata$groupingvar


#create and save minute files (one file for all mice): returns MIN_data
# some warnings appear because the last line of the minute data is the sum.
# that raw is taken out of the MIN_data.

source ("Rcode/create_minfile.r") # output MIN_data, work probably only with HCS data

#filter data if data need exclusion:
metadata$Exclude_data[is.na(
  metadata$Exclude_data)] <- 'include'

metadata = metadata %>% filter (Exclude_data != "exclude")

MIN_data =MIN_data %>% filter(ID %in% metadata$ID)

#tests
#summary (as.factor(metadata$animal_ID))
#summary (as.factor(MIN_data$animal_ID))
#cbind(metadata$animal_ID, metadata$genotype)


#-------------------Run the analysis              ----------------------------


# get output
#source ("Rcode/multidimensional_analysis_RFsvm.R")
#save.image(paste0("Reports/multidim_",Name_project,".rdata"))

if (nrow(metadata) < 22) {
  print("not enough data for svm")
  Accuracyreal=NA
  Acc_sampled =NA
  calcul_text =NA
  source ("Rcode/multidimensional_analysis_prep.R")
  source ("Rcode/RF_selection_2rounds.R") # returns RF_selec = Input
  source ("Rcode/ICA.R")
  rmarkdown::render ("reports/multidim_anal_variable.Rmd")
  file.copy("reports/results.rdata", paste0(Outputs,"/multidim_analysis_",groupingby,".Rdata"), overwrite=TRUE,
            copy.mode = TRUE, copy.date = FALSE)
  file.copy("reports/multidim_anal_variable.html", paste0(Outputs,"/multidim_analysis_",groupingby,".html"), overwrite=TRUE,
            copy.mode = TRUE, copy.date = FALSE)
  
}else{
  if (length(unique(metadata$groupingvar))==3) {
    source ("Rcode/multidimensional_analysis_prep.R")
    source ("Rcode/RF_selection_2rounds.R")
    source ("Rcode/morethan2groups.R")
    rmarkdown::render ("reports/multidim_anal_variable2.Rmd", output_file = "multidim_anal_variable.html")
  }else{
    #source ("Rcode/multidim_anal_variable.R")
    #multidimensional analysis, prepare data
    source ("Rcode/multidimensional_analysis_prep.R") # return Multi_datainput_m or Multi_datainput_m2
    
    #multidimensional analysis, Random forest in 2 rounds
    source ("Rcode/RF_selection_2rounds.R") # returns RF_selec = Input
    source ("Rcode/ICA.R") # return plot called pls
    
    source ("Rcode/multidimensional_analysis_svm.R") # returns Accuracy (text), Accuracyreal = kappa of result of svm prediction on the test data
    
    Acc_sampled= c() # set 
    set.seed(87)
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
