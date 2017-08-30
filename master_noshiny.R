# here is the master file where packages are loaded and other functions are called,
# this is to be replaced by a shiny app at the end.

library (tidyverse)
library (stringr)

# variables

#project metadata path:
PMeta ="/Volumes/KINGSTON/AOCF_HCS/HCS_analysis/data/minimal24h_data/Projects_metadata.csv"

WD = dirname(PMeta)
source("Rcode/inputdata.r")
