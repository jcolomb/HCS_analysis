if (length(unique(metadata$groupingvar))>2){
  print(we need to choose grouping variables)
  metadata$groupingvar = as.factor(metadata$groupingvar)

  metadataRest= metadata [metadata$groupingvar %in% levels(metadata$groupingvar)[1:2],]
  metadataRest=droplevels(metadataRest)
  # make svm!
  
  
  
  }