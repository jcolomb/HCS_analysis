

groups = str_split( as.character(Projects_metadata$group_by), " ")[[1]]
groups=groups [groups!="+"]
if (length(groups) ==1){
  temp <- metadata %>% select (groups)
  names (temp) = "groupingvar"
  metadata$groupingvar <- as.factor(temp$groupingvar)
}else if ("age_category" %in% groups){
  
  ## this need to be worked, workaround here for tarabikin:
  metadata$groupingvar = metadata$treatment
  message("grouping via treatment only")
}else {
  temp <- metadata %>% select (groups)
  metadata$groupingvar <- interaction(temp,sep="_")
}

