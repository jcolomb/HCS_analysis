#----------------- create minute and metadata csv files (and corresponding values MIN_data and metadata)
#-- if file exists, just read it again (unless RECREATEMINFILE is true)
if (!RECREATEMINFILE) {
  MIN_data = try(read.csv2(paste0(onlinemin, '/Min_', Name_project, '.csv'), dec = ".")
                 , TRUE)
  
}

#-- if not found, create it
if (RECREATEMINFILE || class(MIN_data) == "try-error") {
  dataf = data.frame() # initialise dataf
  dataraw = data.frame()
  
  files = as.character(MIN_datafiles[, 1]) 
  fileshr = as.character(Hour_datafiles[, 1])
  filesmbr = as.character(MBR_datafiles[, 1])
  for (f in 1:length(files)) {
    #specific code if data needs to be downloaded first
    if (WD == "https:/") {
      download.file(files[f], "tempor.xlsx",  mode = "wb")
      files[f] = "tempor.xlsx"
      download.file(fileshr[f], "temporhr.xlsx",  mode = "wb")
      fileshr[f] = "temporhr.xlsx"
      download.file(filesmbr[f], "tempor.mbr",  mode = "wb")
      fileshr[f] = "tempor.mbr"
    }
    # read primary data
    if (metadata$primary_datafile[f] == "min_summary")
      behav <- readxl::read_excel(files[f], sheet = 1)
    if (metadata$primary_datafile[f] == "hour_summary")
      behav <- xx_to_min(readxl::read_excel(fileshr[f], sheet = 1), 60)
    if (metadata$primary_datafile[f] == "mbr"){
      rawdata = read.csv (filesmbr[f],
                          sep = "",
                          skip = 1 ,
                          header = F)
      behav = min_from_mbr(rawdata, framepersec, Behav_code)
      behav$`Travel(m)`= NA
      Bseq = rawd_from_mbr(rawdata, framepersec, Behav_code)
      Bseq$animal_ID =MIN_datafiles[f, 2]
      dataraw = rbind (dataraw, Bseq)
    }

    
    ### take out sum column and row if they exists
    behav = behav %>% filter(Bin != 'SUM') 
    behav = behav %>% select(-matches("SUM")) 
    
    # find and add animal ID
    behav$ID = MIN_datafiles[f, 2]
    
    #prepare some metadata to add
    df = metadata  %>% filter (ID == MIN_datafiles[f, 2]) %>% select(
      ID,
      animal_ID = animal_ID,
      gender,
      treatment,
      genotype,
      date,
      test.cage = test_cage,
      real.time = real_time_start,
      dark.start = light_off,
      project.name = Proj_name
    )
    
    
    #calculate bins according to light off (bintodark from information of the metadata)
    
    real.time.min = (as.numeric(strsplit(
      format(df$real.time, "%H:%M:%S"), split = ':'
    )[[1]][1]) * 60) +
      as.numeric(strsplit(format(df$real.time, "%H:%M:%S"), split = ':')[[1]][2])
    
    dark.start.min = (as.numeric(strsplit(
      format(df$dark.start, "%H:%M:%S"), split = ':'
    )[[1]][1]) * 60) +
      as.numeric(strsplit(format(df$dark.start, "%H:%M:%S"), split = ':')[[1]][2])
    

    df$dark.start.min = (dark.start.min - real.time.min)
    behav$bintodark = behav$Bin - df$dark.start.min
    
    #merging data with the metadata
    df = left_join(behav, df)
    # saving this animal in main result dataframe
    dataf = rbind(dataf, df)

  }
  
  #export to MIN_data and remove dataf
  MIN_data = dataf
  rm(dataf)
  
  #export MIN_data to a csv file (which can be read)
  write.table(
    MIN_data,
    paste0(Outputs, '/Min_', Name_project, '.csv'),
    sep = ';',
    row.names = FALSE
  )
  
  
}

MIN_data$ID = as.factor(MIN_data$ID)

# save metadata in a csv file.

write.table(
  metadata,
  paste0(Outputs, '/Metadata_', Name_project, '.csv'),
  sep = ';',
  row.names = FALSE
)

if (!exists("dataraw")){
  write.table(
    dataraw,
    paste0(Outputs, '/Bseq_', Name_project, '.csv'),
    sep = ';',
    row.names = FALSE
  )
}
