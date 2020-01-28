# Analysis details

## Overview

Variables can be entered in the `master_noShiny` R file or via the Shiny application, the `master_Shiny.r` file is then processed. The second tab in the Shiny application ploted hourly summary data, by running the `plot5_hoursummaries.r` code. A brief description of the software procedure was given below.

The analysis software was automatically reading the master metadata file on OSF. When the user specified the project to analyse, the software did (1) read the metadata associated with the project and create a minute summary file from the primary data file indicated; (2) behaviour categories (see results) were pooled together and the software created time windows and calculated a value for each behaviour category for each time window. Some data might be excluded at this point of the analysis, following the label indicated in the experiment metadata.

The software then performed multidimensional analyses on this latter data to plot it (3) and to tell whether the groups can be told apart (4). The user could choose which time window to incorporate on step 3. The analysis was running a random forest to report the variables which showed most difference in the different groups of mice. It was then performing an independent component analysis (ICA) on these 8 to 20 variables and plotting the first 3 components in an interactive 3D plot. Independently, the next part of the software ran a PCA and looked at the first principal component for statistically different results in the groups, using a non-parametric test. Then it ran a machine learning algorithm on the data. Validation of these latter results was done via a non-exhaustive 2 out validation technique as in \citet{Steele2007} if the sample size per group was below 15, or a validation via a test dataset otherwise.

## minute summary

The first step of the analysis was to derive a minute summary sequence for the primary data indicated. It was quite straightforward when the primary data was the minute summary export from the HCS software: the software reads the data, add one  columns indicating the metadata entry (a number starting at 100 to avoid any ordering problem) and one column indicating the time to the light off event ("bintodark") and what was the light condition (DAY or NIGHT). All data and metadata was then concatenated and two files were saved in the .csv format.

If the primary data was hourly summaries, the software created minute data by dividing the hour value by 60 and repeating the data over 60 rows. If the primary data was the behavior sequence, the software calculated the amount of time spent doing each behaviour for each minute of experiment (using information about the behaviour code used in the .mbr file obtained from Cleversys). Note that in contrast to the HCS export, the distance travelled was not calculated, and that the last data of an incomplete minute was discarded.

## behavior categorisation

From the 45 columns reported by the HCS software in the summary files, we obtained 38 behaviour categories (the distance travelled on the x axis was not considered as a behavior category, No.Data and Arousal were discarded and 6 Drink and eat categories were pooled into two). We then pooled these categories in 18 (Berlin categories) or 10 (Jhuang categories) in the `grouping_variables.r` code.

##Time windows

The data was typically coming from experiments lasting a bit less than 24h. The time of start of the experiment (which could be read from the name of the video file coming from the HCS software) was introduced in the metadata. We used this information in combination with the light/dark cycle information obtained from the lab-metadata file to set a relative time to the light off event for each minute summary. Nine different time windows were defined relatively arbitrary, with the last 3 windows overlapping with the first 6.

## Data transformation

At step 3, one value was calculated for each category and for each time window. For the distance travelled, we simply took the mean distance travelled per minute. For behaviour categories, we calculated the square root of the proportion of time spent doing that behaviour during that time window. Because the windows were relatively small, we had a lot of 0 values and decided not to use a log transformation. This transformation was thought to make the data more normally distributed and allowed better analysis in a multidimensional space.

## Random Forest

We used the randomForest package (rf). The number of variables randomly sampled as candidates at each split was not tuned and the default value was used. The algorithm was run a first time to select 20 variables, and was run again on these 20 variables, such that the Gini score obtained at that step was not dependent on the initial number of variables. The best 8 variables or all variables with a Gini score above 0.95 are kept for the ICA analysis and are listed in the report.

## Machine learning algorithms

The Bseq_analyser was set to use a support vector machine with radial kernel. 
It did not perform this analysis if the box "Perform the multidimensional analysis (takes time)" was unpicked.
The models were used to predict the group membership of the data not used for training and we report the kappa score as a measure of the model accuracy.
We also tested other algorithms in the creation of the software.
For L1-regularised regression, the code used in \citet{Steele2007}, obtained from Prof. King, was slightly modified. It used the glmpath package \citep{glmpath} and optimised the lambda value choosing the one with the smallest Bayesian information criterion value.


For support vector machine methods, we used the e1071 R package \citep{svm}, with either a linear or a radial kernel and tuned its variables (gamma and cost) to choose an effective model. 

## {Validation of machine learning

The software used two different validation technique. For dataset with less than 15 animals per group, a 2-out validation strategy was used, while the software used a completely independent test dataset, when the sample size exceeded 15.

In the 2-out validation scheme, 2 data points, one from each group, were taken out of the sample. The remaining data was used to train the machine learning algorithms. The resulting model was then used to predict the group each one of the extra 2 data points were belonging to. This was repeated for each pair of data points once; and a list of predicted grouping was produced. By comparing that list with the real group membership, the software calculated an accuracy score (kappa score).
In the independent dataset validation, the model was trained using 2/3 of the data. The trained model was used to predict the group belonging of the remaining third of the data. The accuracy of this prediction was then calculated.

In both cases, the model was trained on a dataset comprising a similar amount of data of each type. In particular, the amount of data of each "confounding variable" (as entered in the metadata) was kept similar. In practice, it means that if the metadata indicates animals of different sex were tested, the algorithm did try to keep the same number of males and females in the training dataset.

In the validation step, the grouping of the train dataset (or the whole dataset in the 2-out version) was randomized to create a model fitted to wrong information. The accuracy of the "wrong" model to predict the test dataset was calculated. This was repeated until the range of the estimates of the p value was above or below 0.05, using a binomial test.