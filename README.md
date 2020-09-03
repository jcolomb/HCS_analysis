[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1162739.svg)](https://doi.org/10.5281/zenodo.1162739)


# Background

This repository contains software developed to analyse behaviour sequence data obtained over 24h with the home cage scan software, while avoiding harking and p-hacking. It does not require the data in any specific structure, but requires the user to create additional metadata files telling data file path and animal/experiment information. Shiny application makes it easier to use the software for non-Rusers. Some of the analysis is still best run (and extended) in R. Please see [paper.md](paper.md) for a longer description of the scientific background.

This repository was developed using Rstudio and has many dependencies. 

---

![Preview of the shiny GUI. On the left panel, the user chooses variables: project to analyse, behaviour categorisation to use, whether to recreate the minute summary file from the raw data, whether a machine learning analysis should be performed, and the number of permutations to perform (if a machine learning analysis is performed). The user can choose which time windows to incorporate in the analysis. Pushing the “Perform multidimensional analysis button” starts analysis and produces the report. By switching to the summary_reports tab, one can also produce a time series representation of each behaviour category. 
](paperfigure/shinyview.png)

# Installation

Clone or download this repository. Run `source(analysis/Installation_Rpackages.R)` to install dependencies.

Now open the shiny apps in Rstudio and click the run button or type `shiny::runApp('analysis/shiny__Analyse_data')`. You will open the data analysis software to analyse predetermined datasets.

You may need to first install the command line tools on osx, run this in the terminal
   ` xcode-select --install  `

# Generalities

Two Shiny apps are present in this repository. You will find them in the analysis folder. One does read and check your metadata before pushing the project metadata on osf, the second one is analysing data (master project metadata have no be made public first). One can also use the `master_noshiny.r` script to run the analysis, but one has to set varaiables manually.

The repository also contains data to test new functions, information about how to add data and metadata from you project. Dependencies have been taken cared of using the renv package. Additional information and code which were used to write a paper (not published yet) are also present.


# Data analysis overview

The analysis software is automatically reading the master metadata file on OSF. When the user specify the project to analyse, the software will (1) read the metadata associated with the project and create a minute summary file from the primary data file indicated (**either minute summary, hour summary or the raw behavioral sequence can be used as primary data**, 2) behaviour categories are pooled together and the software create time windows, calculating a value for each behaviour category for each time window. Some data might be excluded at this point of the analysis, following the label indicated in the experiment metadata. 

The software then performs multidimensional analyses on this latter data to plot it (3) and to tell whether the groups can be told apart (4). The user can choose which time window to incorporate on step 3. The analysis is running a random forest to report the variables which show most difference in the different groups of mice. It is then performing an independent component analysis (ICA) on these 8 to 20 variables and plotting the first 3 components in an interactive 3D plot. Independently, the part 5 of the software runs a PCA and look at the first principal component for statistically different results in the different groups, using a non-parametric test. Then it runs a machine learning algorithm on the data. Validation of the results is done via a non-exhaustive 2 out validation technique if the sample size per group is below 15, or a validation via a test dataset otherwise.

# Using your data

**You will gain a lot of time if you fill the metadata in a usable format during data acquisition**. You can use the .mbr files created automatically by the homescagescan software, there is no need for a specific export, unless you want to use the `distance travelled` data. In any cases, make sure you record information about the time at which the video has been started (it should be indicated in the video name, if you are using the HomeCageScan software.) 

Please refer to https://github.com/jcolomb/HCS_analysis/blob/master/Metadata_information/Readme.md to get familiar with the metadata schemes or if you already have collected the data: you will need to create new metadata and modify your data to have it in a usable state.

Once your data is in a format accepted by the software, you might upload it online, or keep it locally. By indicating the folder as the raw data folder in github or gitlab, the software can access the data directly. Once the project metadata has been pushed to osf via the app, you will be able to use the analysis application.



# metadata scheme

 In brief, there are different metadata files:

- a project metadata: each project is listed in one spreadseets (saved on osf, see below), path toward other metadata file is indicated there.
- a lab metadata: here is stocked information about the room where the experiment was performed (daily light cycle is indicated there).
- an experiment metadata: each row represent one test session. Information about the animal tested is stored there.



We are using the osf to create a "repository" for the project metadata information (the master metadata file is hosted there because we can read and update it from R). The shiny app was given access to a particular repostiory using [Token Auth](https://cran.r-project.org/web/packages/osfr/vignettes/auth.html) in the osf APIv2 (via the osfr package).

---

![Data and metadata structure. The master project_metadata file available online links the address of the metadata files and the data folder (blue arrows). The experiment metadata file links to each data file (for clarity, only one folder is shown here). The format of the data was either .xlsx summary files (with minutes or hour time resolution) or the output files .mbr (behavior sequence) and .tbd (position) of the proprietary HomeCageScan (CleverView) software. Note that the current software did not use the .tbd files. The master file, provided path information to the analysis software. Reports are stored in a folder indicating the software name and version. Derived data files are saved in a folder named after the software name, but not its version.
](paperfigure/tree-1.png)


# In the future

We hope to make the software flexible enough to analyse data coming for other, similar setups. Reach out if you get some.

[Any contribution to the code is welcome](https://github.com/jcolomb/HCS_analysis/blob/joss_reviewanswers/.github/CONTRIBUTING.md).

# License
This work is distributed under a MIT license, apart from the files present in the data folder.
The files present in the data folder are distributed under the more permissive CC0 license.

