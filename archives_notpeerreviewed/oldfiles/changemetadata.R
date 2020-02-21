library (tidyverse)
options(row.names = FALSE)


names(Projects_metadata2)[2]= "Identifier"
names(Projects_metadata2)[4]="Creator"
names(Projects_metadata2)[13]="Description_comments"

Projects_metadata2 = Projects_metadata2[,-1]
A=right_join(Projects_metadata,Projects_metadata2)
B= cbind (Projects_metadata,A)

ncol(A)
ncol(Projects_metadata)
ncol(Projects_metadata2)


AA <- read_csv("D:/HCSdata/Sharable/lehnardt/metadata/lehnard_2016_meta.csv")[,-1]

##to run to create new metadata
metadatatemplate <-
  read.csv(
    "C:/Users/cogneuro/Desktop/HCS_analysis/data/Ro_testdata/metadata/Ro_testdata_meta.csv"
  )
metadatatemplate = metadatatemplate[1, ]
metadatatemplate = metadatatemplate[-1, ]

metadatatemplate[1:nrow(AA), 1] = AA$animal_ID
#right_join(metadatatemplate,lehnard_2016_meta)


A = cbind(AA, metadatatemplate[!names(metadatatemplate) %in% names(AA)])
metadatatemplate = metadatatemplate[1, ]
metadatatemplate = metadatatemplate[-1, ]
B = rbind(metadatatemplate, A)
#A[,order(names(metadatatemplate))]
C = B[, match(names(metadatatemplate), names(B))]

##---------------------------------------------##

write.csvrnf(C,y="D:/HCSdata/Sharable/lehnardt/metadata/lehnard_2016_meta.csv")

#meisel2017_meta
AA<- read.csv("D:/HCSdata/Sharable/meisel/metadata/meisel2017_meta.csv")
AA$primary_datafile= "min_summary"
C=AA
write.csvrnf(C,"D:/HCSdata/Sharable/meisel/metadata/meisel2017_meta.csv")

AA<- read.csv("D:/HCSdata/Sharable/pruess/metadata/pruess_2016_meta.csv")
AA$primary_datafile= "min_summary"
C=AA
write.csvrnf(C,"D:/HCSdata/Sharable/pruess/metadata/pruess_2016_meta.csv")

AA<- read.csv("D:/HCSdata/Sharable/rosenmund/metadata/rosenmund2015_meta_all.csv")
AA$primary_datafile= "min_summary"
C=AA
write.csvrnf(C,"D:/HCSdata/Sharable/rosenmund/metadata/rosenmund2015_meta_all.csv")

AA<- read.csv("D:/HCSdata/Sharable/rosenmund/metadata/rosenmund2015_meta.csv")
AA$primary_datafile= "min_summary"
C=AA
write.csvrnf(C,"D:/HCSdata/Sharable/rosenmund/metadata/rosenmund2015_meta.csv")

AA<- read.csv("D:/HCSdata/Sharable/schmidt2017/metadata/schmidt2017_meta.csv")
AA$primary_datafile= "min_summary"
C=AA
write.csvrnf(C,"D:/HCSdata/Sharable/schmidt2017/metadata/schmidt2017_meta.csv")

AA<- read.csv("D:/HCSdata/Sharable/tarabykin/metadata/tarabykin_2015_meta.csv")
AA$primary_datafile= "min_summary"
C=AA
write.csvrnf(C,"D:/HCSdata/Sharable/tarabykin/metadata/tarabykin_2015_meta.csv")

AA<- read.csv("D:/HCSdata/Sharable/vida/metadata/vida_2015_meta.csv")
AA$primary_datafile= "min_summary"
C=AA
write.csvrnf(C,"D:/HCSdata/Sharable/vida/metadata/vida_2015_meta.csv")

AA<- read.csv("C:/Users/cogneuro/Desktop/HCS_analysis/data/Steele07_HD/metadata/Steele07_HD_meta.csv")
AA$primary_datafile= "min_summary"
C=AA[,-1]
write.csvrnf(C,"C:/Users/cogneuro/Desktop/HCS_analysis/data/Steele07_HD/metadata/Steele07_HD_meta.csv",
          row.names = FALSE)


write.csvrnf <- function (x,y){
  write.csv( x,  y, row.names = FALSE)
}
