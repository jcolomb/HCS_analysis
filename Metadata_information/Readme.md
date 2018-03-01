This document aims at providing a walkthrough for users creating their metadata file. Note that you might try to fit your data gathering to the format used here to facilitate future experiments integration.

#  Clone or download this project

Get a version of this software on your desktop! You may install R and Rstudio at this stage. Fork and clone the project if you like to have your data on this github repository, you may just download it otherwise.

#  Project_metadata.csv file

- Open the local Project_metadata.csv file (you will find it in the data folder) in excel (or similar sofware like libreoffice).
- Select all cells and change its format to "text" to avoid any intervention of the program in what you are typing
- take the next number available for the experiment ID
- enter data as requested in each cell, refer to the "explanation_of_metadata.csv" file for a desctiption. Keep information about metadata location empty for now, and keep the file open.
- in the source_data column, write "this_github" for now.
- save the file as a .csv document (separator = ",". In excel click "save as" and use the ".csv(macintosh)" option)


# Add your data

- copy the "Template_folder_newexp" folder you will find in the metadata_information folder.
- rename it and enter that information in the Project_metadata.csv file under "folder_path"
- rename the experiment metadata file to include the project name and make sure there is a lab metadata file found at the path given in the Project_metadata.csv file
- enter the file path in the Project_metadata.csv file under "animal_metadata" and "lab_metadata". (the path relative to the folder_path information, look at previous project for an example).
- Put the videos in the video folders (this is optional, we do not need the videos to run the analysis).
- Put the data (output from the video analysis) in one videoanalysis_output folder. If the data was analysed with different software, add one folder per software (for example HCS3_output and HCS4_output).  
- enter the file path in the Project_metadata.csv file under "raw_data_folder". Note that only one output may be analysed at a time. If you have used different analysis software, you should create a new row in the Project_metadata.csv file for each.
- The data files cannot lie directly in the data folder, create an additional folder if necessary.


# Create a lab metadata

- Fill the lab metadata information. Only time of light on and light off are necessary entries.

# Build the experiment metadata file (animal_metadata)

- For each primary data file, one row should be completed with as much information as possible. Note that you may have multiple files corresponding to one experiment (min_summary, hour_summary, mbr). Which one will be used by the software is set with the "primary_datafile" column entry.
- You may use the HELPER_create_metadata.R code (you need R to be installed on your machine, I would recommand using Rstudio as a interface) to create the experiment_folder_name,	Behavior_sequence,	Onemin_summary columns, and save the spreadseet in the data folder.
- You may also do it by hand: for each experiment (one animal tested on a specific day), the path to the data file should be found by using the "experiment_folder_name"" and the data column, relative to the folder containing the data (raw_data_folder in Project_metadata.csv file).
- Enter the animal_ID by hand in that file.
- If animals were tested more than once, add a distinctive information in a new column (treatment for instance).
- optional: Here you may merge this information with other information you got in a different format. You may look at the helper code for inspiration, but this step is much dependent on your metadata. Be patient, this step might take some time, but you will get something clean at the end.
- Open the last file created by the helper file and the metadata template, copy-paste columns and enter any missing information (use "NA" if there is no information for that column.)
- The lab_ID columin this file should correspond to the lab_ID information entered in the lab metadata information. 
- Check the file for inconsistancy and other possible problems.


# Check

- Open the app found in "\analysis\testanduploaddata" (double click the app.r files, and push the run button in Rstudio). you may run `shiny::runApp('analysis/shiny__testandupload_data')` in the console (working directory should be the project working directory).
- indicate in which folder is the data if it is neither online nor in the data folder of the software (If you followed this guide step by step, you can ignore this step).
- choose your project in the selection box.
- push the "test metadata" button.
- if they are error messages, investigate and modify the data or metadata accordingly, repeat previous steps
- if they are no error, push the next buttons

# push

- Your data is ready. If you want to keep it offline, change the project_metadata file information to source_data="USB_STICK". If you like to publish it, you may either let it where it is and commit and push the changes if you cloned the project (you might think of making a pull request later), or publish it somewhere else and indicate the http address as "experiment_folder"" path and use source_data="HTTP:/".
- Give your data a license if you published it and enter the information in the project metadata file. (If you keep it in the original folder and pushed your change to github, the data got a CC0 license attached to it).
- Run the check again.
- if they are no error, push the "push" button, if the final check is good, the metadata information present in the project metadata file is pushed to OSF (the data do not move).
- Once pushed to the online master metadata file, it cannot be modified. If you made a mistake, you will have to push a new version using a different name.

NB: the checker will open a window with the files that are additional to the one used in the metadata, check at that moment whether some animals were tested and not incorporated in the metadata, or if it is only files which are not necessary (for example hour summary files, text files,...).

# You are done

You can run the analysis now. Read warnings carefully and go back to cleaning the metadata if you get problems. Note that you can change the experiment metadata files without changing the information available on OSF.


