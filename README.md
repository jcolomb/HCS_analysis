# HCS_analysis
This code analyse data obtained from the homecagescan software (HCS, cleversys Inc.)

As input, it uses the min summary file exported from the HCS. Attempt to use the raw data were not successful. It also access different metadata file:

- a project metadata: each project is listed, path toward other metadata file is indicated.
- a lab metadata: here is stocked information about the room where the experiment was performed (daily light cycle is indicated there)
- an experiment metadata: each row represent one test. Information about the animal tested is stored there.

# Development

We are now seeking a way to have a repository for all data analysed with this software, to get one unique project metadata file for the whole universe is the goal! Please help!

We hope to make the software flexible enough to analyse data coming for other similar setups.
