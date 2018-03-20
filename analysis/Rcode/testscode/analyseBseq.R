#-- analyse behavior sequence.
library (tidyverse)
#load ("...") get other info like metadata
load("data/Ro_testdata/BSeqAnal_v0.1.1-alpha/multidim_analysis_MITsoft.Rdata")

# fonction to calculate proportion of behavior before and after:
freq_behav <- function(bseq_an2, name) {
  R1=bseq_an2 %>%
    summarise (n=n())
  names(R1)=c("behavior", "freq_before")
  R1$freq_before =  R1$freq_before/  colSums(R1 )[2]*100
  names(R1)=c("behavior", name)
  return (R1)
}


#-- Goal compare night and day data, what happens after and before drink 

dataraw_ori <-
  read_delim(
    "data/Ro_testdata/BSeq_analyser_data/Bseq_Ro_testdata_mbr.csv",
    ";",
    escape_double = FALSE,
    col_types = cols(
      animal_ID = col_character(),
      end = col_double(),
      start = col_double()
    ),
    trim_ws = TRUE
  )

Behav_code <-
  read_delim(
    "analysis/infos/HCS_MBR_Code_Details/Short Behavior Codes-Table 1.csv",
    ",",
    escape_double = FALSE,
    col_types = cols(`Behavior Code` = col_integer()),
    trim_ws = TRUE,
    skip = 1
  )[, c(1, 3)]
names (Behav_code) = c("behavior", "beh_name")

#-- save original and clean data
dataraw <- dataraw_ori
dataraw =left_join(dataraw,Behav_code, by= "behavior")
dataraw = dataraw [(dataraw$end-dataraw$start >0),]

#-- create column, with NA for first entry 
dataraw$behavior_n1 =dataraw$behavior
dataraw$behavior_n1 [dataraw$start ==0] =NA
dataraw$behavior_n1 =c(dataraw$behavior [-1], NA) # add column next behavior (add column, )



#-- once again for second in line behavior
dataraw$behavior_n2 =dataraw$behavior_n1
dataraw$behavior_n2 [dataraw$start ==0] =NA
dataraw$behavior_n2 =c(dataraw$behavior_n2 [-1], NA)


#-- get only night data
nightstart=behav_gp$Bin [behav_gp$bintodark == 0]

Nendbin=(as.numeric(strsplit(
  format(metadata$light_off, "%H:%M:%S"), split = ':'
)[[1]][1]) * 60) +
  as.numeric(strsplit(format(metadata$light_off, "%H:%M:%S"), split = ':')[[1]][2])

nightend=nightstart+ Nendbin

#dataraw = dataraw %>% filter 


# only for groom here
beh= c(10) ##28:groom
title_plots = Behav_code$beh_name[Behav_code$behavior == beh]
#-- for each animal 
Before = Behav_code
After= Behav_code

for (ani in metadata$ID) {
  #-- choose behavior in _n1
  bseq_an = dataraw %>% filter (animal_ID == ani) %>%
    filter (behavior_n1 %in% beh)
  
  
  #--get list of behavior before/after
  
  R1 = freq_behav (
    bseq_an %>%
      group_by(behavior),
    paste0("before_", ani))
  R2 = freq_behav (
      bseq_an %>%
        group_by(behavior_n2),
      paste0("after_", ani))
      # combine with all code
      
      
    Before = left_join(Before, R1, by = "behavior")
    After = left_join(After, R2, by = "behavior")
}

Before[is.na(Before)] <- 0
After[is.na(After)] <- 0


Before$mean=rowMeans(Before[,c(-1,-2)])
After$mean=rowMeans(After[,c(-1,-2)])
Before$median=apply (Before[,c(-1,-2)],1, median)
After$median=apply (After[,c(-1,-2)],1, median)


# take best 8 and plot:

Before8= (Before %>% arrange (-median)) [1:8,]
After8= (After %>% arrange (-median)) [1:8,]
p=ggplot ( aes( x= c(1:8)) , data=cbind(Before8, After8))+
  geom_point(aes(size= mean, y = "before", x = beh_name), shape= 22, data=Before8)+
  geom_point(aes(size= mean, y = "after", x = beh_name), shape= 22, data=After8)+
  geom_text (aes(y = "before", x = beh_name, label =trunc(mean)), data=Before8)+
  geom_text (aes(y = "after", x = beh_name, label =trunc(mean)), data=After8)+
  scale_size(range = c(0, 25))+
  ggtitle(title_plots)#+scale_size_area()

p+
  theme (legend.position = "none", axis.text.x = element_text( angle = 45),
         panel.background =element_rect (fill = "white"),
         axis.title = element_blank())
ggsave("materialforpaper/serie_landvertical.pdf")

dev.off()
#datarboxaw %>% filter (start >(1712669-2000) & start <(1712669+60) ) %>%
#  filter (animal_ID == 107)
