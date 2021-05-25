#-- this codes perfomes a PCA + stat on first discriminant
#input : Multi_datainput_m (after get_behav_gp.r)
#ouput : plspca (plot) and PCA_pval (PCA_pval$p.value)


#---------------------1 make the pca on data
input.pca <- prcomp(Multi_datainput_m %>% select (-groupingvar),
                    center = TRUE,
                    scale. = TRUE)


#---------------------2  statistics on pc1:
Moddata = as.data.frame(input.pca$x)
Moddata$groupingvar = as.factor(Multi_datainput_m$groupingvar)

#-- Mann-Whitney test if 2 groups, Kruskal-Wallis rank sum test otherwise
if (length(levels (Moddata$groupingvar)) == 2) {
  PCA_pval = wilcox_test(PC1 ~ groupingvar, data = Moddata)
  PCA_effectsize = wilcox_effsize(data= Moddata, PC1 ~ groupingvar, comparisons = NULL, ref.group = NULL,
                                  paired = FALSE, alternative = "two.sided", mu = 0, ci = FALSE,
                                  conf.level = 0.95, ci.type = "perc", nboot = 1000)
  
} else {
  PCA_pval = kruskal_test(PC1 ~ groupingvar, data = Moddata)
  PCA_effectsize = kruskal_effsize(Moddata, PC1 ~ groupingvar, ci = FALSE, conf.level = 0.95,
                                            ci.type = "perc", nboot = 1000)
}

#-- effect size calculation



#-- put stat results in a text
PCA_res <- ifelse (
  pvalue(PCA_pval) < .05,
  paste0("p < ", signif(pvalue(PCA_pval), digits = 2), ", effect size is ", PCA_effectsize$magnitude, " (Z/square(N) = ",signif(PCA_effectsize$effsize, digits = 2),
         ")."),
  "no statistically significant difference."
)

#-- plot 2 PC, add stat text in axes legend
plspca = Moddata %>% ggplot (aes (x = PC1, y = PC2, color = groupingvar)) +
  geom_point() +
  labs (title = paste0("PCA results (", groupingby, " variables grouping)")) +
  scale_colour_grey() + theme_bw() +
  labs(x = paste0 ("PC1: ", PCA_res))

#print(plspca)


#-- Plot boxplot of PC1

# calculate sample size
a <-
  aggregate(PC1 ~ groupingvar + groupingvar , Moddata, function(i)
    c(val = length(i), ypos = quantile(i)[2]))

#do boxplot, stat result as text between groups

boxplotPCA1 = Moddata %>% ggplot (aes (x = groupingvar, y = PC1, color = groupingvar)) +
  geom_boxplot(position = position_dodge(width = 0.9)) +
  labs (title = paste0("PCA results (", groupingby, " variables grouping)")) +
  geom_text(x = 1.5,
            y = max(Moddata$PC1) - 1,
            label = PCA_res) +
  geom_text(data = a,
            aes(y = PC1[, 2] + 0.5, label = paste0("n = ", PC1[, 1])),
            position = position_dodge(width = 0.9)) +
  theme_bw() +  theme(legend.position = 'none') +
  labs(x = metadata$group_by[1])

