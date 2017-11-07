p=icafast(Input%>% select (-groupingvar),2,center=T,maxit=100)

R= cbind(p$Y, Input   %>% select (groupingvar))
names(R) = c("Component_1", "Component_2",  "groupingvar")
pls=R %>% ggplot (aes (x=Component_1, y=Component_2, color = groupingvar))+
  geom_point()+
  labs (title=paste0(numberofvariables, " variables used as input to the ICA"))+ 
  scale_colour_grey() + theme_bw()+
  theme(legend.position='none')
print(pls) 