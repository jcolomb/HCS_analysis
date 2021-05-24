

## -- the bib was created using multiple time this and citation ("xxx") commands, adding code by hand afterwards
sink("test.bib")
#knitr::write_bib(names(renvLock$Packages))
#knitr::write_bib("devtools")

# out <- sapply(names(sessionInfo()$otherPkgs), 
#               function(x) print(citation(x), style = "Bibtex"))
# print (citation(), style = "Bibtex")
# print (citation("devtools"), style = "Bibtex")

renvLock <- jsonlite::read_json("renv.lock")
knitr::write_bib(names(renvLock$Packages))
knitr::write_bib("devtools")


sink()


#table metadata

sink("analysis/materialforpaper/projectmetadata.tex")
temp=t(Projects_metadata)
temp=as.data.frame(temp)
Pmeta2=xtable::xtable(temp,
                      align = "|p{0.35\\linewidth}|p{0.55\\linewidth}|",
                      caption = "Master metadata information.",
                      label = "tab:project_metadata")
print (Pmeta2, 
       table.placement= "!htpb",
       include.colnames =F#,
       #tabular.environment ="tabular*",
       #width ="\\linewidth"
       )
sink()

## table categories
table_categorisation <- read.csv("analysis/materialforpaper/table_categorisation.csv")

sink("analysis/materialforpaper/tablecat2.tex")
print(
  xtable::xtable(table_categorisation, align = "|l|l|l|l|",
                 label = "cat_table",
                 caption = "The initial 45 columns were pooled into 18 and 10 categories."), 
  include.rownames=FALSE,
  
  table.placement="!htbp"
)
sink()
