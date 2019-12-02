#-- run ICA on "RF_selec" and plot results

#-- run ICA taking groupingvar out (2 dimensions kept)
p=icafast(RF_selec%>% select (-groupingvar),2,center=T,maxit=100)
#-- take groupingvar back in result
ICA= cbind(p$Y, RF_selec   %>% select (groupingvar))

#- change name for plotting and plot
names(ICA) = c("Component_1", "Component_2",  "groupingvar")
pls=ICA %>% ggplot (aes (x=Component_1, y=Component_2, color = groupingvar))+
  geom_point()+
  labs (title=paste0(numberofvariables, " variables used as RF_selec to the ICA"))+ 
  scale_colour_grey() + theme_bw()+
  theme(legend.position='none')
#print(pls) 

#-- run ICA taking groupingvar out (3 dimensions kept)
p=icafast(RF_selec%>% select (-groupingvar),3,center=T,maxit=100)
#- take groupingvar back in result
ICA= cbind(p$Y, RF_selec   %>% select (groupingvar),metadata   %>% select (animal_ID))

#-- plot in 3d, with ID as labels

names(ICA) = c("Component_1", "Component_2", "Component_3","groupingvar","animal_ID")
ICA$groupingvar=as.factor(ICA$groupingvar)
pls2= plotly::plot_ly(data = ICA, x=~Component_1, y=~Component_2,
                    z=~Component_3, color=~groupingvar,
                    colors = c("blue", "violet"),
                    text = ~paste ("animal: ",animal_ID),
                    type ="scatter3d", mode= "markers") 
#pls2

