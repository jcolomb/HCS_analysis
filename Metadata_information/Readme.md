.
This document aims at providing a walkthrough for users creating their metadata file. Note that you might try to fit your data gathering to the format used here to facilitate future experiments integration.

So far (January 2020), we tested data from different labs, quality and formats.  The software deal only with outputs files from the Home Cage Scan system (HCS, Cleversys Inc.) software so far (the raw behaviour sequence `.mbr` file, or the minutes or hours binned data summaries). 

#  Clone or download this project

Get a version of this software on your desktop! You may install R and Rstudio at this stage. Fork and clone the project if you like to have your data on this github repository, you may just download it otherwise.

Refer to the "Metadata_information/explanation_of_metadata.csv" file for a description of the metadata fields in the different metadata files.

#  Project_metadata.csv file

- Open the local Project_metadata.csv file (you will find it in the data folder) in excel (or similar sofware like libreoffice).
- Select all cells and change its format to "text" to avoid any intervention of the program in what you are typing
- take the next number available for the experiment ID
- Keep information about metadata location empty for now, and keep the file open until further notice.
- in the source_data column, write "this_github" for now.
- Enter data about the experiment as requested in each cell. 
- save the file as a .csv document (separator = ",". In excel click "save as" and use the ".csv(macintosh)" option)


# Add your data

- copy the "Template_folder_newexp" folder you will find in the metadata_information folder.
- rename it and enter that information in the Project_metadata.csv file under "folder_path"
- paste it in the `data` folder.
- rename the experiment metadata file to include the project name.
- enter the file path in the Project_metadata.csv file under the "animal_metadata" and "lab_metadata" columns. (the path relative to the folder_path information, look at previous project for an example).
- Optionally, put the videos in the video folders.
- Put the data (output from the video analysis, may contain xlsx files, .MBR files or both) in one videoanalysis_output folder. If the data was analysed with different software, add one folder per software (for example HCS3_output and HCS4_output).  
- enter the file path in the Project_metadata.csv file under "raw_data_folder". Note that only one output may be analysed at a time. If you have used different analysis software, you should create a new row in the Project_metadata.csv file for each.
- The data files cannot lie directly in the data folder, create an additional folder if necessary.


# Create a lab metadata

- Fill the lab metadata information. Only time of light on and light off are necessary entries. You can add a row with using a different name. We will use that name later in the animal_metadata file

# Build the experiment metadata file (animal_metadata)

- In the main folder, you may open and have a look at the animal_metadata file (that is the file you have previously renamed) and this is the file we will fill up.
- For each primary data file(s) (for each experiment session), one row should be completed, with as much information as possible. Note that you may have multiple files corresponding to one experiment . Which one will be used by the software is set with the "primary_datafile" column entry (allowed content: min_summary, hour_summary, mbr). If the .mbr files are available, I would encourage you to use them as primary data file.
- You may use the HELPER_create_metadata.R code (you need R to be installed on your machine, I would recommand using Rstudio as an interface) to create a list of files to enter in the metadata. 
- A second helper (HELPER_join_animal-info) can combine the information with animal information if you have it in a different spreadsheet. You may also try to sort the spreadsheet in a way to be able to copy-paste information. In the end, you should be able to copy-paste information from the eachfile2.csv files into the animal_metadata file
- Enter missing information in the animal_metadata file.

Note:
- If animals were tested more than once, add a distinctive information in a new column (treatment for instance).
- Be patient, this step might take some time, but you will get something clean at the end.
- The lab_ID column in this file should correspond to the lab_ID information entered in the lab metadata information. 
- Check the file for inconsistancy and other possible problems.


# Check


- If using Rstudio, open the "HCS_analysis.Rproj" file. Install the dependencies, running the "\analysis\Installation_Rpackages" file.
- Run `shiny::runApp('analysis/shiny__testandupload_data')` in the console (or open the app found in "\analysis\testanduploaddata" (double click the app.r files, and push the run button in Rstudio).
- indicate in which folder the data is, if it is neither online nor in the data folder of the software (if you followed this guide step by step, you can ignore this step).
- choose your project in the selection box.
- push the "test metadata" button.
- if they are error messages, investigate and modify the data or metadata accordingly, repeat previous steps
- if they are no error, push the button: "if everything is correct, create the min file", follow the console in Rstudio to make sure it is successful.
- **Do not click the push button yet.**

# Push


- Your data is ready, but it needs to find a home. You can either keep it offline or bring it online.

## Offline data

- Change the project_metadata file information to source_data="USB_STICK".
- Run the check again. This time you will need to use the Data_directory button. You will need to browse until reaching the data folder. You may also copy the data folder on a USB-stick first and browse to there.
- Test the metadata, create the min file. If there are still no error, now you can push the "push the project if it passes the tests."

## online data

- Publish the data where you want, give it a license there.
- Indicate the license in the project_metadata file.
- Indicate the http address in the "Folder_path" column of the project_metadata file, do not include the "https://". This should be a publicly accessible address. Note that if you are using a git-based repository like github, gitlab or gin, the address should contain the term "raw". You can get this address using the download button on the website. For example the test data of this repository could be accessed with: "github.com/jcolomb/HCS_analysis/raw/master/data/Ro_testdata"
- Change the project_metadata file information to source_data="https:/"
_ Run the check again. If it fails, make sure the repository is public and the data has been completely uploaded already.
- if they are no error, push the "now you can push the "push the project if it passes the tests.

## Final check

button, if the final check is good, the metadata information present in the project metadata file is pushed to OSF (the data do not move).
- Once pushed to the online master metadata file, it cannot be modified. If you made a mistake, you will have to push a new version using a different name.

NB: the checker will open a window with the files that are additional to the one used in the metadata, check at that moment whether some animals were tested and not incorporated in the metadata, or if it is only files which are not necessary (for example hour summary files, text files,...).

# You are done

You can run the analysis now. Read warnings carefully and go back to cleaning the metadata if you get problems. Note that you can change the experiment metadata files without changing the information available on OSF.


.
