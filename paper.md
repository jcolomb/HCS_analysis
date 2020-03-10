---
title: 'Analysing 24-hour behaviour sequence data with an Rshiny application'
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
    affiliation: 1 # (Multiple affiliations must be quoted)
affiliations:
 - name: Humboldt University of Berlin, Inst. of Biology, Philippstr. 13, 10099 Berlin, Germany
   index: 1
 - name: Humboldt-Universität zu Berlin, SFB1315, Institut für Biologie, Charitéplatz
    1, 10117 Berlin: 2
date: 29 January 2020
bibliography: test.bib


---

# Summary

Automated mouse phenotyping via high throughput behaviour analysis of home cage behaviour has brought hope for a more effective and efficient way to test rodent models of diseases. While different software solutions track behavioural motives through time, software to analyse and archive this rich data is mostly lacking [@Steele2007].
Here, we present an open source, free software actionable via a web browser, that can perform state of the art multidimensional analysis of home cage behavioural sequence data. We created an open repository of the linked metadata that we treat as separate from the raw data. Data from wild type strain of mice used to test the software is provided. 

This software should facilitate the analysis of long behavioural sequence data such as extracted by machine learning and other algorithms from video based home cage monitoring.

## Data input



In order to facilitate the analysis of data coming from different sources, we propose a format to organise the data (behavior sequence or binned summary data) and the metadata (information about the experiment, the lab and the animals), such that the R-Shiny applications can access the different files automatically. We designed a metadata structure according to metadata schemes developed for research data FAIRness [@2014DataPrinciples] and considering the needs of the analysis software. We also made it a prerequisite to publish metadata about the experiment before running the shiny application on the data. Details about the metadata format and a walkthrough in the metadata production was given at: [Metadata_information/readme.md](https://github.com/jcolomb/HCS_analysis/Metadata_information/readme.md). We advice any user to create the metadata during or before the data acquisition and provide a folder template.

![Data and metadata structure. The master project_metadata file  links the address of the metadata files and the data folder. The experiment metadata file links to each data file (for clarity, only one folder is shown here). The format of the data was either .xlsx summary files (with minutes or hour time resolution) or the output files .mbr (behavior sequence) and .tbd (position) of the proprietary HomeCageScan (CleverView) software. Note that the current software did not use the .tbd files. The master file, provided path information to the analysis software. Reports are stored in a folder indicating the software name and version. Derived data files are saved in a folder named after the software name, but not its version.
](paperfigure/tree-1.png)


We have used raw time series of behavior categories produced by the (prioprietary) software HomeCageScan (CleverSys), that had been run on sideview videos of mice placed individually in common lab cages for 22h. The software could be extended to also work with behaviour sequence data from other origin (e.g.  using equivalent open source software [@Jhuang2010AutomatedMice]). Such application is facilitated since our analysis software only requires the behavioural time series data but not any data summaries.
 
We provided and used an unpublished dataset based on 11 wild type female mice recorded twice (at the ages of 3 and 7 months, respectively) for about a day, and a published dataset from another study [@Steele2007; @Luby2012]. Other datasets were tested but the data was not made public here. For the new dataset, sample size was decided independently of this study and one animal was excluded for lack of data for the second time point. Mice were recorded in the same order at the two time points, and had undergone different behavioural tests before and between the two home cage monitoring events.

## Data analysis

![Preview of the shiny GUI. On the left panel, the user chooses variables: project to analyse, behaviour categorisation to use, whether to recreate the minute summary file from the raw data, whether a machine learning analysis should be performed, and the number of permutations to perform (if a machine learning analysis is performed). The user can choose which time windows to incorporate in the analysis. Pushing the “Perform multidimensional analysis button” starts analysis and produces the report.
](paperfigure/shinyview.png)

Briefly, we merged the 45 categories we get from the home cage scan software into 10 [@Jhuang2010AutomatedMice] or 18 meta-categories (see https://github.com/jcolomb/HCS_analysis/blob/master/analysis/Rcode/grouping_variables.R). The time series data was synchronised to the ligth off event and split in different time windows, in order to account for circadian rhythms linked effects. The square root of the amount of time spent doing each meta-behavior was calculated for each time window. We ended up with 10 to 124 variable per session.

In order to tell differences in the behaviour of different group of animals, we used a non-parametric test on the first component of a PCA (a p-value and effect size was calculated). In addition, a machine learning algorithm could be used. Here we were using a support vector machine trained on one part of the data to predict the group appartenance of the other part of the data (we used a 2-out validation for sample size below 15 per groups). The accuracy of this prediction was then compared to the distribution of accuracies obtained whie shuffling the groups randomly (computer intensive calculations were performed). 



An html report was created from the multidimensional analysis and could be visualised directly in the application. The application could be used directly while choosing the test dataset (Ro_testdata using minute summary as data input or Ro_testdata_mbr using sequence data as raw input) included in the repository.

## Putative future development

While the shiny app performed the analysis, we provided a R code to run the same scipts by hand, or step by step. On top of facilitating code debugging, this allowed users to perform  additional analysis steps (paired analysis for example) or changing the apparence of the figures. We also provided some extra analysis as example of additional visualisation and more complex analysis that could be performed using the raw (sequence) data. In particular, one script was analysing the behavior sequence itself, reporting the percentage of time a behaviour was recorded just before another one. In the visual abstract figure below, the output of such an anylsis was presented, with the average percent of time a behaviour appeared just before or after a "landvertical" behaviour in the test data. The eight behaviours with the highest median proportion were shown, squares and numbers represented the mean percentage (similar numbers were obtained while taking the median).

A server version of the application was not yet possible, because the application needs to access folders (with ShinyFiles), something browsers are not allowed to do. One could develop a different version of the application that would upload (from the computer) or copy the data (form another server) before the analysis is done. This might facilitate metadata analyses combining data from different labs (but linked in the single master metadata file), in the future.


## Conclusion

This software demonstrated the power of combining data management with its analysis to achieve a more efficient and effective analysis of the data, avoiding most pitfalls of multivariate analysis (p-hacking and harking), as well as human errors in the data processing. By providing this software and a easy way to add re-usable (FAIR) open datasets, we hoped the community will expand the software capacities and increase the amount of the available open data.


![Visual abstract. Left: The HCS software analyses video data to produce a time series of behavior, as well as spreadsheets resulting of pre-analysis. So far, this data was usually poorly analysed with excel in about 15 hours of work (data files concatenated by hand, dataset of different duration pooled, often a single time window with few behavioural categories reported, no measures taken against harking and p-hacking). Our software used the raw behaviour sequence data, as well as metadata spreadsheets the user had to provide. R code were used to synchronise the time series and cut datasets to a common length for all sessions, to merge categories, and to produce summaries for several time windows. The summary data was then analysed and a report was saved on the disc. The process took about 3 hours, and used state of the art multivariate analysis.
Right: example of analysis output using a dataset of wild type mice tested twice provided with the software. A PCA analysis could tell the two groups apart, while the machine learning algorithm we used (SVM) had difficulties to do so. We could also visualise the data with hourly summaries and do more complex analysis looking at the sequence of behaviour itself.](paperfigure/vis_abstract.png)






# Acknowledgements

The authors want to thank member of the Winter lab and the AOCF team: Andrei Istudor for his suggestion to integrate all used variables in the software report, Patrick Beye for discussion on the design of the analysis, Melissa Long for performing the home cage monitoring experiment and help with the creation of the metadata, Vladislav Nachev for scientific inputs and discussion. In addition, we want to thank Prof. Steele and Prof. King for fruitful discussion and access to code and data, and Cleversys Inc. for their help with the decoding of the HCS outputs.

# Funding

Funded by the Deutsche Forschungsgemeinschaft (DFG, German Research Foundation) – Project number 327654276 – SFB 1315.



# Dependencies

The software was build on R ressources [@R-base]. This work would not have been possible without the  tidyverse environment [@tidyverse; @stingr], packages for interactive processing [@shinyfiles; @Shiny; @R-plotly], statistical analysis [@svm; @rf; @Hmisc; @ica; @glmpath; @R-rstatix; @R-coin] and graphical interface [@RGraphics; @gridExtra; @plotly]. It also depended on the osfr package, which was still in development [@R-osfr] and loaded via the devtools package [@devtools]. We used the packrat package [@Rpackrat]  to dock the project.

# References
