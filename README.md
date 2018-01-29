# HCS_analysis
This code analyse data obtained from the homecagescan software (HCS, cleversys Inc.), it is buid to accept data from other single housed animal home cage monitoring systems.

As input, it uses the min or hour summary file exported from the HCS and specific metadata files described in more detail in the "metadata_information" folder. (Attempt to use the raw data are ongoing.) In brief, there are different metadata files:

- a project metadata: each project is listed in one spreadseets, path toward other metadata file is indicated there.
- a lab metadata: here is stocked information about the room where the experiment was performed (daily light cycle is indicated there).
- an experiment metadata: each row represent one test. Information about the animal tested is stored there.

# Adding data

Please refer to https://github.com/jcolomb/HCS_analysis/blob/master/Metadata_information/Readme.md to create new metadata and modify your data to obtain a usable state. Once your data is in a format accepted by the software, you might upload it on github and archive it on zenodo, or keep it locally. By indicating the folder as the raw data folder in github, the software can access the data directly on Github.

We are using the osf to create a "repository" for the data (the master metadata file is hosted there because we can read and update it from R).


We hope to make the software flexible enough to analyse data coming for other similar setups. Reach out if you get some.

# Helping with the code

Any contribution in the code is welcome.

#License
This work is distributed under a MIT license, apart from the files present in the data folder.
The files present in the data folder are distributed under the more permissive CC0 license.

