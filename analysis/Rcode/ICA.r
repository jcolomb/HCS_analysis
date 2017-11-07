p=icafast(Input%>% select (-groupingvar),2,center=T,maxit=100)

R= cbind(p$Y, Input   %>% select (groupingvar))
names(R) = c("D1", "D2",  "groupingvar")
pls=R %>% ggplot (aes (x=D1, y=D2, color = groupingvar))+
  geom_point()+
  labs (title=numberofvariables)+ 
  scale_colour_grey() + theme_bw()+
  theme(legend.position='none')
print(pls) 