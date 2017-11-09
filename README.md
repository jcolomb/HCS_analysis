# HCS_analysis
This code analyse data obtained from the homecagescan software (HCS, cleversys Inc.), it is buid to accept data from other single housed animal home cage monitoring systems.

As input, it uses the min summary file exported from the HCS and specific metadata files described in more detail in the "metadata_information" folder. (Attempt to use the raw data were not successful.) In brief, there are different metadata files:

- a project metadata: each project is listed in one spreadseets, path toward other metadata file is indicated there.
- a lab metadata: here is stocked information about the room where the experiment was performed (daily light cycle is indicated there).
- an experiment metadata: each row represent one test. Information about the animal tested is stored there.

# Adding data

Please refer to the metadata_information/Readme.md file. Once your data is in a format accepted by the software, you might upload it on github and archive it on zenodo. By indicating the folder as the raw data folder in github, the software can access the data directly on Github.

We are planning on getting a repository for that data, any help welcome.


We hope to make the software flexible enough to analyse data coming for other similar setups. Reach out if you get some.

# Helping with the code

Any contribution in the code is welcome, see the contibuting.md file.

#License
This work is distributed under a MIT license, apart from the files present in the data folder.
The files present in the data folder are distributed under the more permissive CC0 license.

