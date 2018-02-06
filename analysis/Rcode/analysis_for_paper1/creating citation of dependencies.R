sink("test.bib")
out <- sapply(names(sessionInfo()$otherPkgs), 
              function(x) print(citation(x), style = "Bibtex"))

#table metadata

sink("analysis/materialforpaper/projectmetadata.tex")
temp=t(Projects_metadata)
temp=as.data.frame(temp)
Pmeta2=xtable::xtable(temp,
                      align = "|p{0.18\textwidth}|p{0.27\textwidth}|",
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
table_categorisation <- read.csv("~/github_repo/HCS/table_categorisation.csv")

sink("materialforpaper/tablecat.tex")
print(
  xtable::xtable(table_categorisation, align = "|l|l|l|l|",
                 label = "cat_table",
                 caption = "The initial 45 columns were pooled into 18 and 10 categories."), 
  include.rownames=FALSE,
  
  table.placement="!htbp"
)
sink()