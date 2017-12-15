#PCA+stat
#input =Multi_datainput_m (after multidimensional_analysis_prep.R)
#ouput = plspca (plot) and PCA_pval (PCA_pval$p.value)
#trying pca before all the rest

#---------------------1 make the pca on data 
input.pca <- prcomp(Multi_datainput_m%>% select (-groupingvar),
                    center = TRUE,
                    scale. = TRUE)

#expl.var <- cumsum(input.pca$sdev^2/sum(input.pca$sdev^2)*100)
#Input= data.frame(input.pca$x[,expl.var < 95])
#Input$groupingvar = Multi_datainput_m$groupingvar

#---------------------2  statistics on pc1:
Moddata=as.data.frame(input.pca$x)
Moddata$groupingvar = as.factor(Multi_datainput_m$groupingvar)

# Mann-Whitney test if 2 groups, Kruskal-Wallis rank sum test otherwise
if (length(levels (Moddata$groupingvar))== 2){
  PCA_pval=wilcox.test(PC1 ~ groupingvar, data = Moddata)
}else {
  PCA_pval=kruskal.test(PC1 ~ groupingvar, data = Moddata)
}

PCA_res <- ifelse (PCA_pval$p.value< .05,
                   paste0("p < ",signif(PCA_pval$p.value,digits=2)),
                   "no statistically significant difference.")

#wilcox.test(PC2 ~ groupingvar, data = Moddata)

plspca=Moddata %>% ggplot (aes (x=PC1, y=PC2, color = groupingvar))+
  geom_point()+
  labs (title=paste0("PCA results (",groupingby," variables grouping)"))+ 
  scale_colour_grey() + theme_bw()+
  labs( x= paste0 ("PC1: ",PCA_res))
  #+
#theme(legend.position='none')
print(plspca)  

# calculate sample size
a <- aggregate(PC1 ~ groupingvar + groupingvar , Moddata, function(i) c(val=length(i), ypos=quantile(i)[2]))
#do boxplot
boxplotPCA1 =Moddata %>% ggplot (aes (x=groupingvar, y=PC1, color = groupingvar))+
  geom_boxplot(position = position_dodge(width=0.9)) +
  labs (title=paste0("PCA results (",groupingby," variables grouping)"))+ 
  geom_text(x = 1.5, y = max(Moddata$PC1)-1, label = PCA_res)+
  geom_text(data = a, aes(y= PC1[,2]+0.5,label= paste0("n = ",PC1[,1])), 
            position = position_dodge(width=0.9))+
   theme_bw()+  theme(legend.position = 'none')+
  labs( x= metadata$group_by[1])


Moddata$groupingvar= as.factor(metadata$`test cage`)
