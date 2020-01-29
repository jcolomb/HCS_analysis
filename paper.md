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
    affiliation: 2 # (Multiple affiliations must be quoted)
affiliations:
 - name: Humboldt University of Berlin, Dept. of Biology, Philippstr. 13, 10099 Berlin, Germany
   index: 1
 - name: Humboldt University of Berlin, Dept. of Biology, Virchowweg 6, Berlin, 10117 Germany
   index: 2
date: 11 december 2019
bibliography: test.bib
---

# Summary

Automated mice phenotyping via high throughput behaviour analysis of home cage behaviour has brought hope for a more effective and efficient way to test rodent models of diseases. While different software track behavioural motives through time, software to analyse and archive this rich data has been lacking [@Steele2007].
Here we present an open source free software, actionable via a web browser, performing state of the art multidimensional analysis of home cage monitoring data, and creating an open repository of the linked metadata (while the data may be published separately). Some wild type data used to test the software is provided. It should facilitate the work of users of the home cage scan software.  

## Data input



In order to facilitate the analysis of data coming from different sources, we proposed here a format to organise the data (behavior sequence or binned summary data) and the metadata (information about the experiment, the lab and the animals), such that the R-Shiny applications could access the different files automatically. We designed a metadata structure according to metadata schemes developed for research data FAIRness [@2014DataPrinciples] and according to the needs of the analysis software. It is also a prerequisite to publish metadata about the experiment before running the shiny application on the data. Details about the metadata format and a walkthrough in the metadata production is given at: [Metadata_information/readme.md](https://github.com/jcolomb/HCS_analysis/Metadata_information/readme.md). We advice any user to create the metadata during or before the data acquisition.

![Data and metadata structure. The master project_metadata file was linking the address of the metadata files and the data folder. The experiment metadata file was linking to each data file (for clarity, only one folder was shown here). The format of the data was either .xlsx summary files (min or hour) or the HCS output files .mbr (behavior sequence) and .tbd (position), note that the software was not reading the .tbd files. By reading the master file, the computer could determine the path to every data file. Upon analysis, the software created a new folder indicating the software name and version. Its reports were saved there, while derived data files were saved in a folder named after the software name, but not its version.](paperfigure/tree-1.png)

We have been using raw time series of behavior categories produced by the (prioprietary) homecagescan software, when run on videos of mice set individually in a common lab cage for 22h. The software could be extended to work with other type of behaviour sequence data (for instance data obtained with the Jhuang software [@Jhuang2010AutomatedMice]). Interestingly, we could use datasets where the summaries created by the homecagescan software were missing or corrupted, which may facilitate the analysis of data obtained with that software.
 
We provided and used a unpublished dataset of 11 wild type female mice tested twice (at the age of 3 and 7 month, respectively) for about a day, and a published dataset obtained from Prof. Steele [@Steele2007, @Luby2012]. Other datasets were tested but the data was not made public. For the new dataset, sample size was decided independently of this study and one animal was excluded because we could not find the data at the second time point. Mice were tested in the same order at the two time points, and were tested in different behavioural tests before and between the two home cage monitoring events.

## Data analysis

![Preview of the shiny GUI. On the left panel, the user had to choose variables: project to analyse, behaviour categorisation to use, whether to recreate the minute summary file from the raw data, whether a machine learning analysis should be performed, and the number of permutation to perform (if a machine learning analysis was performed). The user might then choose which time windows to incorporate in the analysis. He could then push the "Do multidimensional analysis button" and wait until the report was produced and showed.](paperfigure/shinyview.png)

Briefly, we merged the 45 categories we get from the home cage scan software into 10 [@Jhuang2010AutomatedMice] or 18 meta-categories (see https://github.com/jcolomb/HCS_analysis/analysis/Rcode/otherclasses.csv). The time series data was synchronised to the ligth off event and split in different time windows, in order to account for circadian rhythms linked effects. The square root of the amount of time spent doing each meta-behavior is calculated for each time window. We ended up with 10 to 124 variable per session.

In order to tell differences in the behaviour of different group of animals, we used a non-parametric test on the first component of a PCA (a p-value and effect size is calculated). In addition, a machine learning algorithm can be used. Here we are using a support vector machine trained on one part of the data to predict the group appartenance of the other part of the data. The accuracy of this prediction is then compared to the distribution of accuracies obtained whie shuffling the groups randomly (computer intensive calculations are performed). 



An html report is created from the multidimensional analysis and can be visualised directly in the application. The application can be used directly while choosing the test dataset (Ro_testdata using minute summary as data input or Ro_testdata_mbr using sequence data as raw input) included in the repository.

## Putative future development

While the shiny app performs that primary analysis, we provide a R code to run it by hand, or step by step. On top of facilitating code debugging, this allows the users to perform the usual analysis before running additional analysis steps (paired analysis for example) or changing the apparence of the figures. We also provide some extra analysis as example of additional visualisation and more complex analysis one could perform using the raw data. In particular, one script is analysing the behavior sequence itself, reporting the percentage of time a behaviour was recorded just before another one. In the visual abstract figure below, you can see the output of such an anylsis with the average percent of time a behaviour appeared just before or after a "landvertical" behaviour in the test data. The eight behaviours with the highest median proportion were shown, squares and numbers represented the mean percentage (similar numbers were obtained while taking the median).

A server version of the application is not yet possible, because the application needs to access folders (with ShinyFiles). One could develop a different version of the application that would upload (from the computer) or copy the data (form another server) before the analysis is done. This might facilitate metadata analyses combining data from different labs (but linked in the single master metadata file), in the future.


## Conclusion

This software demonstrates the power of combining data management with its analysis to achieve a more efficient and effective analysis of the data, avoiding most pitfalls of multivariate analysis (p-hacking and harking) as well as human errors in the data processing. By providing this software and a easy way to add re-usable (FAIR) open datasets, we hope the community will expand the software capacities and increase the amount of the available open data.


![Visual abstract. Left: The HCS software analyse video data to produce a time series of behavior, as well as pre-analysed files. This data is usually poorly analysed with excel in about 15 hours of work (data files concatenated by hand, dataset of different duration pooled, often a single time window with few behavioural categories reported, no measures taken against harking and p-hacking). Our software use the raw behaviour sequence data, as well as metadata spreadsheets the user has to provide. I use R code to synchronise the time series and cut datasets to the common length to all datasets, merge categories, and produce summaries for several time windows. The summary data is then analysed and a report is saved on the disc. The process takes about 3 hours, and use state of the art multivariate analysis.
Right: example of analysis output using a dataset of wild type mice tested twice provided with the software. A PCA analysis can tell the two groups apart, while the machine learning algorithm we used (SVM) had difficulties to do so. We can also visualise the data with hourly summaries and might do more complex analysis looking at the sequence of behaviour itself.](paperfigure/vis_abstract.png)






# Acknowledgements

The authors want to thank member of the lab and the AOCF team: Andrei Istudor for his suggestion to integrate all used variables in the software report, Patrick Beye for discussion on the design of the analysis, Melissa Long for performing the home cage monitoring experiment and help with the creation of the metadata, Vladislav Nachev for scientific inputs and discussion. In addition, we want to thank Prof. Steele and Prof. King for fruitful discussion and access to code and data, and Cleversys Inc. for their help with the decoding of the HCS outputs.

# Funding

Funded by the Deutsche Forschungsgemeinschaft (DFG, German Research Foundation) – Project number 327654276 – SFB 1315.



# Dependencies

The software was build on R ressources [@R-base]. This work would not have been possible without the  tidyverse environment [@tidyverse; @stingr], packages for interactive processing [@shinyFiles; @Shiny; @plotly], statistical analysis [@svm; @rf; @Hmisc; @ica; @glmpath; @R-rstatix; @R-coin] and graphical interface [@RGraphics; @gridExtra; @plotly]. It also depended on the osfr package, which was still in development [@R-osfr] and loaded via the devtools package [@devtools]. We used the packrat package [@Rpackrat]  to dock the project.

# References