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
 - name: Humboldt University of Berlin, SFB1315, Inst. of Biology, Charitéplatz 1, 10117 Berlin
   index: 2
date: 05 April 2020
bibliography: test.bib
---

Deprecated document: this was written for JOSS submission. After the paper was rejected, information stated here was moved to a new paper and to the readme file.


# Summary

Automated mouse phenotyping via high-throughput behavior analysis of home cage behavior has brought hope for a more effective and efficient way to test rodent models of diseases. Very rich datasets are produced by advanced video analysis software. However, there is no dedicated mechanism to share or analyze this kind of data, such that it is common practice to reduce the analysis to a couple of variables summarized over the whole recording period.  

Here, we present an open source, free software actionable via a web browser (a R-shiny application), that can perform state of the art multidimensional analysis of home cage behavioral sequence data. By aligning time series data to the light cycle, it can use different time windows to produce up to 128 behavior variables per animal. It provides a p-hacking free analysis using a PCA strategy, while providing graphical representation of the behavior for further explorative analysis. A machine learning approach was implemented but had been proven ineffective at separating groups of animals.

With this work, we hope to engage researchers in data management practices by showing that it allows for better and more efficient analyses of the data. 

## Data input



In order to facilitate the analysis of data coming from different sources, we propose a format to organise the data (behavior sequence or binned summary data) and the metadata (information about the experiment, the lab and the animals), such that the R-Shiny applications can access the different files automatically. We designed a metadata structure according to metadata schemes developed for research data FAIRness [@2014DataPrinciples] and considering the needs of the analysis software (Fig. 1). We also made it a prerequisite to publish metadata about the experiment before running the shiny application on the data. Details about the metadata format and a walkthrough in the metadata production is given at: [Metadata_information/readme.md](https://github.com/jcolomb/HCS_analysis/Metadata_information/readme.md). We advise any user to create the metadata during or before data acquisition and provide a folder template.

![Data and metadata structure. The master project_metadata file available online links the address of the metadata files and the data folder (blue arrows). The experiment metadata file links to each data file (for clarity, only one folder is shown here). The format of the data was either .xlsx summary files (with minutes or hour time resolution) or the output files .mbr (behavior sequence) and .tbd (position) of the proprietary HomeCageScan (CleverView) software. Note that the current software did not use the .tbd files. The master file, provided path information to the analysis software. Reports are stored in a folder indicating the software name and version. Derived data files are saved in a folder named after the software name, but not its version.
](paperfigure/tree-1.png)


We have used raw time series of behavior categories produced by the (prioprietary) software HomeCageScan (CleverSys), that had been run on sideview videos of mice placed individually in common lab cages for 22h. The software could be extended to also work with behaviour sequence data from other origin (e.g.  using equivalent open source software [@Jhuang2010AutomatedMice]). Such application is facilitated since our analysis software only requires the behavioural time series data but not any data summaries.
 
We used an unpublished dataset based on 11 wild type female mice recorded twice (at the ages of 3 and 7 months, respectively) for about a day, and a published dataset from another study [@Steele2007; @Luby2012]. Other datasets were tested but the data is not made public here. For the new dataset, sample size was decided independently of this study and one animal was excluded for lack of data for the second time point. Mice were recorded in the same order at the two time points, and had undergone different behavioural tests before and between the two home cage monitoring events.

## Data analysis

![Preview of the shiny GUI. On the left panel, the user chooses variables: project to analyse, behaviour categorisation to use, whether to recreate the minute summary file from the raw data, whether a machine learning analysis should be performed, and the number of permutations to perform (if a machine learning analysis is performed). The user can choose which time windows to incorporate in the analysis. Pushing the “Perform multidimensional analysis button” starts analysis and produces the report. By switching to the summary_reports tab, one can also produce a time series representation of each behaviour category. 
](paperfigure/shinyview.png)

Briefly, we merged the 45 categories that were originally generated by the home cage scan software into 10 [@Jhuang2010AutomatedMice] or 18 meta-categories (see https://github.com/jcolomb/HCS_analysis/blob/master/analysis/Rcode/grouping_variables.R). The time series data was synchronised to the light off event and split into different time windows, in order to account for circadian rhythm linked effects. The square root of the frequency of each behaviour meta-category (percentage of time spent performing that behaviour) was calculated for each time window. We ended up with 10 to 124 variables per session.

In order to test for differences between different groups of animals, we used a non-parametric test on the first component of a PCA (a p-value and effect size was calculated). As another option, we applied a machine learning algorithm. For this, we used a support vector machine trained on one part of the data to predict potential group differences from the other part of the data (we used a 2-out validation for sample size below 15 per groups). The accuracy of this prediction was then compared to the distribution of accuracies obtained while shuffling the groups randomly (these were computer intensive calculations). The SVM approach seems not to be very efficient with our data.

An html report is created from the multidimensional analysis and can be visualised directly in the application. The application can be used directly with one of the test datasets included in the repository (Ro_testdata with minute summary data or Ro_testdata_mbr with sequence raw data).


## Putative future development

While the shiny app can fully perform the analysis, we also provide the R code to run the scripts step by step. In addition to facilitating code debugging, this allows users to include additional analysis steps (e.g. paired analysis) or change figures. We also provide additional analysis for visualisation and a more complex analysis using the raw (sequence) data. In particular, one script analyses the behaviour sequence itself, reporting the percentage of time a behaviour was performed just before another one (Fig. 3  shows the eight behaviours occurring just before or after a “land vertical” behaviour in the test data). 

A server version of the application was not yet possible, because the application needs to access folders (with ShinyFiles), something browsers are not allowed to do. One could develop a different version of the application that would upload (from the computer) or copy the data (from another server) before the analysis is done. This might facilitate metadata analyses combining data from different labs (but linked in the single master metadata file), in the future.


## Conclusion

The software presented here demonstrates the power of combining data management with analysis to process data more efficiently and effectively. This approach avoids most pitfalls of multivariate analysis such as p-hacking and harking, as well as human errors in data processing.

By making  this software available and linking it to re-usable (FAIR) open datasets, we hope to initiate community activity for tools facilitating long-term animal behaviour sequence analysis.


![Visual abstract. Left: HomeCageScan software (CleverSys) analyses video data to produce a time series of behaviour categories, as well as spreadsheets with pre-analysis data. Previous studies used the summary data to perform summary analysis.
Our software used the raw behaviour sequence data, as well as metadata spreadsheets the user had to provide. R code was used to synchronise the time series and cut datasets to a common length for all sessions, to merge categories, and to produce summaries for several time windows of observation. The summary data was then analysed and a report was saved on disc. The process takes about 3 hours (mostly used to create the metadata files), and uses multivariate analysis. Right: example of analysis output using a dataset from wild type mice recorded twice. A PCA analysis could tell the two groups apart, while the machine learning algorithm we used (SVM) had difficulties to do so. Hourly summaries for each behaviour category can also be visualised in the application. More complex analysis might be performed from the same data (see text).](paperfigure/vis_abstract.png)






# Acknowledgements

The authors want to thank members of the Winter lab and the NeuroCure Animal Outcome Core Faciltiy team: Andrei Istudor for his suggestion to integrate all used variables in the software report, Patrick Beye for discussions on the analysis design, Melissa Long for performing the home cage monitoring experiment and help with the creation of the metadata, and Vladislav Nachev for scientific inputs and discussion. In addition, we want to thank Prof. Andrew D. Steele and Prof. Oliver D. King for fruitful discussion and access to code and data, and the team of Cleversys Inc. for their help with the decoding of the HomeCageScan software outputs.

# Funding

Funded by the Deutsche Forschungsgemeinschaft (DFG, German Research Foundation) – Project number 327654276 – SFB 1315, and Project number 39052203 - EXC 257:  NeuroCure.



# Dependencies

The software was buildt on R ressources [@R-base]. This work would not have been possible without the  tidyverse environment [@tidyverse; @stingr], packages for interactive processing [@shinyfiles; @shiny; @plotly], statistical analysis [@svm; @rf; @Hmisc; @ica; @glmpath; @R-rstatix; @R-coin] and graphical interface [@RGraphics; @gridExtra; @plotly]. It also depended on the osfr package [@R-osfr]. We used the renv package [@R-renv] to dock the project. Other dependencies can be access in the renv.lock file.

# References
