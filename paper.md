---
title: 'Analysing circadian behaviour sequence data with a Rshiny application'
tags:
  - R
  - shiny
  - behaviourneurobiologygal
  - multivariate analysis
  - PCA
  - Support vector machine
authors:
  - name: Julien Colomb
    orcid: 0000-0002-3127-5520
    affiliation: "1, 2" # (Multiple affiliations must be quoted)
  - name: York Winter
    orcid: 0000-0002-7828-1872
    affiliation: "2" # (Multiple affiliations must be quoted)
affiliations:
 - name: Dept. of Biology, Humboldt University, Philippstr. 13, 10099 Berlin, Germany
   index: 1
 - name: Institut für Biologie, Virchowweg 6, Humboldt Universität, Berlin, 10117 Germany
   index: 2
date: 15 december 2019
bibliography: test.bib

# Optional fields if submitting to a AAS journal too, see this blog post:
# https://blog.joss.theoj.org/2018/12/a-new-collaboration-with-aas-publishing
#aas-doi: 10.3847/xxxxx <- update this with the DOI from AAS once you know it.
#aas-journal: Astrophysical Journal <- The name of the AAS journal.
---

# Summary

Automated mice phenotyping via high throughput behaviour analysis of home cage behaviour has brought hope for a more effective and efficient way to test rodent models of diseases. While different software track behavioural motives through time, software to analyse and archive this rich data has been lacking.
Here we present an open source free software, actionable via a web browser, performing state of the art multidimensional analysis of home cage monitoring data, and creating an open repository of the linked metadata (while the data may be published separately). Some provided wild type data was used to test the software.

We are using raw time series of behavior categories produced by the (prioprietary) homecagescan software when run on videos of mice set individually in a usual lab cage for 22h. We merged categories and split the time series (to account for circadian rhythms linked effects), and ended up with 10 to 124 variable per session. To distinguish groups of animals, we used a non-parametric test on the first component of a PCA. In addition, a machine learning algorithm can be used. Here we are using a support vector machine trained on one part of the data to predict the group appartenance of the other part of the data. The accuracy of this prediction is then compared to the distribution of accuracies obtained whie shuffling the group appartenance randomly. 

As a prerequisite to perform the analysis, the users are asked to publish some basic metadata about the dataset (who did what experiment). The metadata is pushed to the osf and read back in the analysis software. The data structure does not have to be changed, but an experiment metadata spreadsheet should be included, where animal information and data path are linked. The analysis softwere can then load the right data file from the information it gets in that metadata file.

This software  demonstrates the power of combining data management with its analysis to achieve a more efficient and effective analysis of the data, avoiding most pitfalls of multivariate analysis (p-hacking and harking) as well as human errors in the data processing. By providing this software and a easy way to add re-usable (FAIR) open datasets, we hope the community will expand the software capacities and increase the amount of the available open data.



# Citations

Citations to entries in paper.bib should be in
[rMarkdown](http://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html)
format.

For a quick reference, the following citation commands can be used:
- `@author:2001`  ->  "Author et al. (2001)"
- `[@author:2001]` -> "(Author et al., 2001)"
- `[@author1:2001; @author2:2001]` -> "(Author1 et al., 2001; Author2 et al., 2002)"

# Figures

Figures can be included like this: ![Example figure.](figure.png)

# Acknowledgements

We acknowledge contributions from Brigitta Sipocz, Syrtis Major, and Semyeong
Oh, and support from Kathryn Johnston during the genesis of this project.

# References

# Dependencies

The software was build on R ressources `[@Rcore]`. This work would not have been possible without the  tidyverse environment `[@tidyverse,stingr]`,  packages for interactive processing `[@ShinyFiles,Shiny,plotly]`, statistical analysis `[@svm,rf,Hmisc,ica, glmpath]` and graphical interface `[@RGraphics,gridExtra,plotly]`. It also depended on the osfr package, which was still in development `[@R-osfr]` and loaded via the devtools package `[@devtools]`. We used the packrat package `[@Rpackrat]`  to dock the project.