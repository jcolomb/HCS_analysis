

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

if (!is.na(Projects_metadata$confound_by)){
  groupc = str_split( as.character(Projects_metadata$confound_by), " ")[[1]]
  groupc=groupc [groupc!="+"]
  if (length(groupc) ==1){
    temp <- metadata %>% select (groupc)
    names (temp) = "confoundvar"
    metadata$confoundvar <- as.factor(temp$confoundvar)
  }else {
    temp <- metadata %>% select (groupc)
    metadata$confoundvar <- interaction(temp,sep="_")
  }
}

