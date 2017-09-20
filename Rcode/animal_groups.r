

groups = str_split( as.character(Projects_metadata$group_by), " ")[[1]]
if (length(groups) ==1){
  temp <- metadata %>% select (groups)
  names (temp) = "groupingvar"
  metadata$groupingvar <- as.factor(temp$groupingvar)
}else{
  ## this need to be worked, workaround here for tarabikin:
  metadata$groupingvar = metadata %>% select (treatment)
  message("grouping via treatment only")
}

