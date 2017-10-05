if (length(unique(metadata$groupingvar))==3) {
  metadata_ori= metadata
  Multi_datainput_m_ori = Multi_datainput_m
  
  print("we need to choose grouping variables")
  metadata$groupingvar = as.factor(metadata$groupingvar)
  
  
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
