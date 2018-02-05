sink("test.bib")
out <- sapply(names(sessionInfo()$otherPkgs), 
              function(x) print(citation(x), style = "Bibtex"))


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
