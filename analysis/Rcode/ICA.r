p=icafast(Input%>% select (-groupingvar),2,center=T,maxit=100)

ICA= cbind(p$Y, Input   %>% select (groupingvar))
names(ICA) = c("Component_1", "Component_2",  "groupingvar")
pls=ICA %>% ggplot (aes (x=Component_1, y=Component_2, color = groupingvar))+
  geom_point()+
  labs (title=paste0(numberofvariables, " variables used as input to the ICA"))+ 
  scale_colour_grey() + theme_bw()+
  theme(legend.position='none')
print(pls) 


p=icafast(Input%>% select (-groupingvar),3,center=T,maxit=100)

ICA= cbind(p$Y, Input   %>% select (groupingvar),metadata   %>% select (animal_ID))
names(ICA) = c("Component_1", "Component_2", "Component_3","groupingvar","animal_ID")
ICA$groupingvar=as.factor(ICA$groupingvar)
pls2= plotly::plot_ly(data = ICA, x=~Component_1, y=~Component_2,
                    z=~Component_3, color=~groupingvar,
                    colors = c("blue", "violet"),
                    text = ~paste ("animal: ",animal_ID),
                    type ="scatter3d", mode= "markers") 
#pls2

