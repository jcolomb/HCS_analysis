#tarab = MIN_data
#save(tarab,metadata,file="testtarab.RData")
load ("testtarab.RData")
IDs=unique (tarab$animal_ID)
grouping = data.frame (IDs)
grouping$group ="group1"
#?runif


a=sample_frac(grouping, 0.5, replace = FALSE, weight = NULL, .env = NULL)
a$g = "group 2"
b=left_join(grouping,a)
b$g <- ifelse(is.na(b$g), 
              "group 1", b$g)
randomgrouping = b%>% transmute (animal_ID = IDs, treatment = g)
names (randomgrouping)[1]= names (metadata[1]) 

metadata =left_join(metadata %>% select (-treatment),randomgrouping, by =names (metadata[1]))

MIN_data = tarab
source ("Rcode/multidimensional_analysis.R")

#grid.arrange(splitTextGrob(text.all.d),pl.all.discr,
#             ncol=1,heights = c(1,5),
#             top = textGrob('...',gp=gpar(fontsize = 30, font=3)))
p