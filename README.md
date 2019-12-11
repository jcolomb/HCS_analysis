[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1162739.svg)](https://doi.org/10.5281/zenodo.1162739)


# Background

This repository contains software developed to analyse behaviour sequence data obtained over 24h with the home cage scan software. It does not require the data in any specific structure, but requires the user to create additional metadata files telling data file path and animal/experiment information. Shiny application makes it easier to use the software for non-Rusers. Some of the analysis is still best run (and extended) in R.

This repository was developed using Rstudio and has many dependencies. 


# Generalities

Two Shiny apps are present in this repository. You will find them in the analysis folder. One does read and check your metadata before publication, the second one is analysing data (master metadata have no be made public first). One can also use the master_noshiny.r script to run the analysis.

The repository also contains data to test new functions, information about how to add data and metadata from you project. Dependencies have been taken cared of using the packrat package. Additional information and code which were used to write a paper (not published yet) are also present.

start the apps with

    if (!require('shiny')) install.packages("shiny")
    shiny::runGitHub("HCS_analysis", "jcolomb", subdir = "analysis/shiny__Analyse_data/") 
    shiny::runGitHub("HCS_analysis", "jcolomb", subdir = "analysis/shiny__testandupload_data/")
  
you may need to first install the command line tools on osx, run this in the terminal
    xcode-select --install    
    
If this is not working, please download this repo and try to open the apps manually and debug it, leave a message in the issue section.

# Data analysis overview

The analysis software is automatically reading the master metadata file on OSF. When the user specify the project to analyse, the software will (1) read the metadata associated with the project and create a minute summary file from the primary data file indicated (**either minute summary, hour summary or the raw behavioral sequence can be used as primary data**, 2) behaviour categories are pooled together and the software create time windows,. calculating a value for each behaviour category for each time window. Some data might be excluded at this point of the analysis, following the label indicated in the experiment metadata. 

The software then performs multidimensional analyses on this latter data to plot it (3) and to tell whether the groups can be told apart (4). The user can choose which time window to incorporate on step 3. The analysis is running a random forest to report the variables which show most difference in the different groups of mice. It is then performing an independent component analysis (ICA) on these 8 to 20 variables and plotting the first 3 components in an interactive 3D plot. Independently, the part 5 of the software runs a PCA and look at the first principal component for statistically different results in the different groups, using a non-parametric test. Then it runs a machine learning algorithm on the data. Validation of the results is done via a non-exhaustive 2 out validation technique if the sample size per group is below 15, or a validation via a test dataset otherwise.

# metadata scheme

 In brief, there are different metadata files:

- a project metadata: each project is listed in one spreadseets, path toward other metadata file is indicated there.
- a lab metadata: here is stocked information about the room where the experiment was performed (daily light cycle is indicated there).
- an experiment metadata: each row represent one test. Information about the animal tested is stored there.

# Adding data

Please refer to https://github.com/jcolomb/HCS_analysis/blob/master/Metadata_information/Readme.md to create new metadata and modify your data to obtain a usable state. Once your data is in a format accepted by the software, you might upload it on github and archive it on zenodo, or keep it locally. By indicating the folder as the raw data folder in github, the software can access the data directly on Github.

We are using the osf to create a "repository" for the data (the master metadata file is hosted there because we can read and update it from R).

# In the future

We hope to make the software flexible enough to analyse data coming for other similar setups. Reach out if you get some.

Any contribution to the code is welcome.

# License
This work is distributed under a MIT license, apart from the files present in the data folder.
The files present in the data folder are distributed under the more permissive CC0 license.

