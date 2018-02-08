# plot data from svm against logreg experiment

load("analysis/svm_logreg_246")
Plothist_bin <- function (Acc_cumm,i){
  dataplot = data.frame(Acc_cumm [-1,i])
  realacc=Acc_cumm [1,i]
  title = names (Acc_cumm)[i]
  names (dataplot) = "Accuracy_perm_grouping"
  
  k1 <- sum(as.numeric(dataplot$Accuracy_perm_grouping) >=
              realacc)   # One-tailed test
  stat =print(zapsmall(Hmisc::binconf(k1, nrow(dataplot)-1, method='exact'))) # 95% CI by default
  R= "not enough \npermutation done"
  if (stat[1,2] > 0.05) R= "no difference spotted"
  if (stat[1,3] < 0.05) R= paste0("different \nwith p < ",stat[1,3])
  
  
  p=  ggplot(data=dataplot, aes(dataplot$Accuracy_perm_grouping)) + 
    geom_histogram(aes(y =..density..), 
                   binwidth=0.09)+
    #xlab (paste0 ("accuracy of grouping with ",nrow(dataplot)," permutations performed"))  +
    xlim (c(-1,1))+
    #geom_density(col=3) +
    geom_vline(xintercept=realacc, col=2)+
    labs(title= title,
         x="",#paste0 ("accuracy of grouping with ",nrow(dataplot)," permutations performed"),
         y="Proportion")+
    annotate("text", label = R, x = -1, y = 1, size = 4, colour = 1,hjust = 0)
  return(p)
}

#---- prepare plots
Nplot <- ncol(Acc_cumm) 
pl_hist <- list()

n=0
for (i in c(1,2,3,10,11,12,4,5,6,13,14,15,7,8,9,16,17,18)){
  n= n+1
  pl_hist [[n]] = Plothist_bin(Acc_cumm,i)
}

pdf(file = paste0("svm_logregresults.pdf"), width = 15, height = 20)

gridExtra::marrangeGrob(pl_hist ,
             ncol=3,nrow =6, top= paste0 ("accuracy of grouping with ",nrow(data.frame(Acc_cumm [-1,1]))," permutations performed"))


dev.off()
