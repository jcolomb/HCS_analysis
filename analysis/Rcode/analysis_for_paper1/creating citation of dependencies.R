sink("test.bib")
out <- sapply(names(sessionInfo()$otherPkgs), 
              function(x) print(citation(x), style = "Bibtex"))