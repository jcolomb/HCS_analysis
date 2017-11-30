This document aims at providing a walkthrough for users creating their metadata file. It contains instruction on how to do it for new and for old projects.
#  Clone or download this project

Get a version of this software on your desktop!

#  Project_metadata.csv file

- Open the local Project_metadata.csv file (you will find it in the data folder) in excel (or similar sofware like libreoffice).
- Select all cells and change its format to "text" to avoid any intervention of the program in what you are typing
- take the next number available for the experiment ID
- enter data as requested in each cell, refer to the "explanation_of_metadata.csv" file for desctiption
- save the file as a .csv document (separator = ",". in excel save as and use ".csv(macintosh)")

# Add your data

- create a folder and name it according to the information given in the Project_metadata.csv file
- You can either place the folder in the data folder of your clone of this repository (source_data="this_github"), on another github repository online (source_data="https:/") or anywhere on your drive or an external drive (source_data="USB_stick", the value of STICK must be changed in the R code (in the master_noshiny.r or intered interactively, once the function will exist).
- Either use the template provided, or make sure there is a experiment metadata file and a lab metadata file found at the path given in the Project_metadata.csv file.
- Put the videos in the video folders (this is optional, we do not need the videos to run the analysis).
- Put the data in one videoanalysis_output folder. If the data was analysed with different software, add one folder per software (for example HCS3_output and HCS4_output). Note that only one output may be analysed at a time. If you have used different analysis software, you should create a new row in the Project_metadata.csv file for each.

# Create a lab metadata

- Fill the lab metadata information. Only time of light on and light off are necessary entries.

# Build the experiment metadata file

- Use the HELPER_create_metadata.R code to create the experiment_folder_name,	Behavior_sequence,	Onemin_summary columns.
- You may also do it by hand: for each experiment (one animal tested on a specific day), the path to the data file should be found by using the experiment_folder_name and one of the 2 other entries, relative to the folder containing the data (raw_data_folder in Project_metadata.csv file ,"videoanalysis_output folder").
- Enter the animal_ID by hand
- if animals were tested more than once, add a distinction in a new column (treatment for instance).
- Here you need to merge this information with other information you got in a different format. You may look at the helper code for inspiration, but this step is much dependent on your metadata. Be patient, this step might take some time, but you will get something clean at the end.
- Check the file for inconsistancy and other possible problems.

# Check and push

- Open the app found in "\analysis\testanduploaddata" (double click the app.r files, and push the run button on Rstudio)
- indicate in which folder is the data if it is neither online nor in the data folder of the software
- choose your project in the selection box.
- push the "test metadata" button.
- if they are error messages, investigate and modify the data or metadata accordingly, repeat previous steps
- if they are no error, push the next buttons
- Push the "push" button, if the final check is good, the metadata information present in the project metadata file is pushed to OSF (the data do not move).
- Once pushed to the online master metadata file, it cannot be modified. If you made a mistake, you will have to push a new version using a different name.

# You are done

You can run the analysis now. Read warnings carefully and go back to cleaning the metadata if you get problems.

NB: the checker will open a window with the files that are additional to the one used in the metadata, check at that moment whether some animals were tested and not incorporated in the metadata, or if it is only files which are not necessary (for example hour summary files).
