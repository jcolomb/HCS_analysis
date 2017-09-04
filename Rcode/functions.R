dataread.c <- function() {
  name <- tclvalue(tkgetOpenFile(
    filetypes = "{ {XLSX Files} {.xlsx} } { {All Files} * }"))
  if (name == "")
    return(data.frame()) # Return an empty data frame if no file was selected
  
  
  data <- read_xlsx(name,sheet = 2)
  assign("data", data, envir = .GlobalEnv)
  assign("name",name, envir = .GlobalEnv)
  cat("The lookup data was imported successfully.\n
      Please close the file selection by pressing the OK Button")
}

# function to create an plot object usable in grid.arrange without using ggplot
# use via grab_grob() in line after plot was created

grab_grob <- function(){
  grid.echo()
  grid.grab()
}

##plotting 24h data

plot24h <- function (data_d, Title, hour.info2= hour.info, datalenght=12){
  data_d %>% 
    ggplot(aes(x=Bin.dark, y=avg, group=treatment, color= genotype)) +
    geom_rect( aes(xmin = 0, xmax = datalenght, ymin = 0, ymax = Inf), fill = 'lightgrey', alpha = .05)+
    geom_vline(xintercept=max(hour.info2[,1]),linetype = "dotted")+
    geom_vline(xintercept=min(hour.info2[,2]),linetype = "dotted")+
    geom_point (aes (colour=(genotype), shape=(treatment)), size=2)+
    #geom_line(aes(colour=(genotype)))+
    #facet_grid( genotype~, switch="x") +
    geom_errorbar(aes(ymin=avg, ymax=avg+sd, colour=(genotype),linetype=(treatment) ), width=0, position=position_dodge(0.05))+
    labs(x="Meters",y="", title = Title)+
    theme_classic() +
    #scale_colour_manual(values = cols)+ ###Stop here if want to save as pdf
    theme.mr
}
