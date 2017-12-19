#plot with color

p = icafast(Input %>% select (-groupingvar),
            2,
            center = T,
            maxit = 100)
R = cbind(p$Y, Input   %>% select (groupingvar))
names(R) = c("D1", "D2",  "groupingvar")
pls = R %>% ggplot (aes (x = D1, y = D2, color = groupingvar)) +
  geom_point() +
  labs (title = numberofvariables) #+
#scale_colour_grey() + theme_bw() +
#theme(legend.position = 'none')
print(pls)

p=icafast(Input%>% select (-groupingvar),3,center=T,maxit=100)

ICA= cbind(p$Y, Input   %>% select (groupingvar),metadata   %>% select (animal_ID))
names(ICA) = c("Component_1", "Component_2", "Component_3","groupingvar","animal_ID")
ICA$groupingvar=as.factor(ICA$groupingvar)
pls2= plotly::plot_ly(data = ICA, x=~Component_1, y=~Component_2,
                      z=~Component_3, color=~groupingvar,
                      colors = c("blue", "violet", "green"),
                      text = ~paste ("animal: ",animal_ID),
                      type ="scatter3d", mode= "markers") 


Input = Multi_datainput_m
##data splitting
#split by variable

if (length(unique(metadata$groupingvar))==3) {
  metadata_ori= metadata
  Multi_datainput_m_ori = Multi_datainput_m
  
  print("we need to choose grouping variables")
  metadata_ori$groupingvar = as.factor(metadata_ori$groupingvar)
  
  
  metadataRest= metadata_ori [metadata_ori$groupingvar %in% levels(metadata_ori$groupingvar)[1:2],]
  metadata=droplevels(metadataRest)
  Multi_datainput_mREST = Multi_datainput_m_ori [metadata_ori$groupingvar %in% levels(metadata_ori$groupingvar)[1:2],]
  Multi_datainput_m= droplevels(Multi_datainput_mREST)
  # make svm!
  source ("Rcode/multidimensional_analysis_svm.R")
  Acc_sampled= c() # set 
  source ("Rcode/multidimensional_analysis_perm_svm.R") # returns Acc_sampled
  k <- sum(abs(Acc_sampled) >= abs(Accuracyreal))   # Two-tailed test
  R=binconf(k, length(Acc_sampled), method='exact')
  p1=print(paste0 ("For the groups ", paste (unique(metadata$groupingvar), collapse= " "),": ", Accuracy,
                   ". doing ",length(Acc_sampled) , " permutations, we find the p value lies between ", R[2], " and ", R[3]))
  
  
  metadataRest= metadata_ori [metadata_ori$groupingvar %in% levels(metadata_ori$groupingvar)[2:3],]
  metadata=droplevels(metadataRest)
  Multi_datainput_mREST = Multi_datainput_m_ori [metadata_ori$groupingvar %in% levels(metadata_ori$groupingvar)[2:3],]
  Multi_datainput_m= droplevels(Multi_datainput_mREST)
  # make svm!
  source ("Rcode/multidimensional_analysis_svm.R")
  Acc_sampled= c() # set 
  source ("Rcode/multidimensional_analysis_perm_svm.R") # returns Acc_sampled
  k <- sum(abs(Acc_sampled) >= abs(Accuracyreal))   # Two-tailed test
  R=binconf(k, length(Acc_sampled), method='exact')
   p2=print(paste0 ("For the groups ", paste (unique(metadata$groupingvar), collapse= " "),": ", Accuracy,
                   ". doing ",length(Acc_sampled) , " permutations, we find the p value lies between ", R[2], " and ", R[3]))
  
  metadataRest= metadata_ori [metadata_ori$groupingvar %in% levels(metadata_ori$groupingvar)[c(1,3)],]
  metadata=droplevels(metadataRest)
  Multi_datainput_mREST = Multi_datainput_m_ori [metadata_ori$groupingvar %in% levels(metadata_ori$groupingvar)[c(1,3)],]
  Multi_datainput_m= droplevels(Multi_datainput_mREST)
  # make svm!
  source ("Rcode/multidimensional_analysis_svm.R")
  Acc_sampled= c() # set 
  source ("Rcode/multidimensional_analysis_perm_svm.R") # returns Acc_sampled
  k <- sum(abs(Acc_sampled) >= abs(Accuracyreal))   # Two-tailed test
  R=binconf(k, length(Acc_sampled), method='exact')
  p3=print(paste0 ("For the groups ", paste (unique(metadata$groupingvar), collapse= " "),": ", Accuracy,
                   ". doing ",length(Acc_sampled) , " permutations, we find the p value lies between ", R[2], " and ", R[3]))
  

}
# print(pls)
# p1
# p2
# p3