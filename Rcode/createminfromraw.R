#--------------create minute file from raw


tablemin = Rawdata %>% group_by (ID) %>%
   count(Behavior)

names(tablemin)[3]= "total"

minmax = floor(max(Rawdata$time_start) /60)
minmax = 200

for (i in 0:minmax){
  
  min = Rawdata %>% group_by (ID) %>%
    filter ( time_start < i+60 & time_start >i) %>% count(Behavior)
  names(min)[3]= as.character(i+1)
  
  tablemin = left_join(tablemin, min, by = c("ID" , "Behavior"))%>% 
    mutate_all(funs(replace(., which(is.na(.)), 0)))
}


count_betweentime <- function(BEGIN, END, Rawdata) {
  tablemin = Rawdata %>% group_by (ID) %>%
    count(Behavior) %>% select (ID, Behavior)
  

  min = Rawdata %>% group_by (ID) %>%
    filter ( time_start < END & time_end >BEGIN) %>% count(Behavior)
  names(min)[3]= as.character(paste (BEGIN,END, sep = "-"))
  
  tablemin = left_join(tablemin, min, by = c("ID" , "Behavior"))%>% 
    mutate_all(funs(replace(., which(is.na(.)), 0)))
}
a=count_betweentime (0,1,Rawdata)

duration_betweentime <- function(BEGIN, END, Rawdata) {
  tablemin = Rawdata %>% group_by (ID) %>%
    count(Behavior) %>% select (ID, Behavior)
  
  
  min = Rawdata %>% group_by (ID, Behavior) %>%
    filter ( time_start < END & time_end >BEGIN)  %>% transmute(sum (duration_s))
  
  names(min)[3]= as.character(paste (BEGIN,END, sep = "-"))
  
  tablemin = left_join(tablemin, min, by = c("ID" , "Behavior"))%>% 
    mutate_all(funs(replace(., which(is.na(.)), 0)))
}
a=count_betweentime (1,2,Rawdata)
View(a)

min=Rawdata%>% group_by (ID, Behavior) %>%
  filter ( time_start < 2 & time_end >1)  %>% transmute(cumsum (duration_s))

names(min)[3]= as.character(paste (2,1, sep = "-"))
