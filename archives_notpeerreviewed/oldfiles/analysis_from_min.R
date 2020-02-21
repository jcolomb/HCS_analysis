

#------- Difference Mean score plotting (against control)##
# choose indexing method
Calc_index <- function (x,y){
  (x-y)/(x+y)
}

# get one value per genotype x treatment: here the mean
meanvalues =dist %>% 
  ungroup %>%
  group_by(genotype,treatment,Bin.dark) %>% 
  summarise_at( vars(Distance_traveled:Stretch), funs(mean))%>%
  mutate (Bin.dark = Bin.dark +0.5) # get the x value in the middle of time interval

if (FALSE){
  #create data frame to join the index to.
  Indexvalues =meanvalues %>% 
    filter (genotype ==meanvalues$genotype[1]) %>%
    select (genotype,treatment,Bin.dark)
  
  #loop on every column, to get one index per column
  for (col in c(4:ncol(meanvalues))){
    NAME= names (meanvalues)[col]
    names (meanvalues)[col] = "totest"
    temp = meanvalues %>% select (genotype,treatment,Bin.dark,totest)
    temp=tidyr::spread(temp, genotype, totest) #change to genotype or treatment depending on what you want to obtain
    temp = temp%>% mutate (Index=Calc_index(test,control)) %>% select (treatment, Bin.dark, Index)
    names(temp)[3] = paste0(NAME,"_index")
    Indexvalues = left_join(Indexvalues,temp)
    names (meanvalues)[col] = NAME
  }
}

if (TRUE){
  #create data frame to join the index to.
  Indexvalues =meanvalues %>% 
    filter (treatment ==meanvalues$treatment[1]) %>%
    select (genotype,treatment,Bin.dark)
  
  #loop on every column, to get one index per column
  for (col in c(4:ncol(meanvalues))){
    NAME= names (meanvalues)[col]
    names (meanvalues)[col] = "totest"
    temp = meanvalues %>% select (genotype,treatment,Bin.dark,totest)
    temp=tidyr::spread(temp, treatment, totest) #change to genotype or treatment depending on what you want to obtain
    temp = temp%>% mutate (Index=Calc_index(o,y)) %>% select (genotype, Bin.dark, Index)
    names(temp)[3] = paste0(NAME,"_index")
    Indexvalues = left_join(Indexvalues,temp)
    names (meanvalues)[col] = NAME
  }
}


##plotting



for (i in c(1:N_behav)){
  dist_d =Indexvalues [,c(1,2,3,3+i)]
  dist_d$sd = 0
  Title_plot = names (dist_d) [4]
  names (dist_d) [4:5]= c("avg", "sd")
  p=plot24h(dist_d, Title_plot,datalenght=-0)+
    scale_y_continuous(limits = c(-1, 1), breaks = c(-0.5, 0, 0.5))+
     geom_line(aes(y=0), col=1)
  #print(p)
  pl[[i]]= p
}
#dev.off()


pl.all.d <- do.call(grid.arrange,c(pl,list(ncol = 3)))

#setwd(plot.path)
pdf(file = paste0(plot.path,"/test_index.pdf"), width = 15, height = 10)

grid.arrange(splitTextGrob("test"),pl.all.d,heights = c(.5,2.5),
             top=textGrob("6. Index of change for each behavior
                          ",gp=gpar(fontsize=20,font=3)))
dev.off()
