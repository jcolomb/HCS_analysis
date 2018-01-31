names(Projects_metadata2)[2]= "Identifier"
names(Projects_metadata2)[4]="Creator"
names(Projects_metadata2)[13]="Description_comments"

Projects_metadata2 = Projects_metadata2[,-1]
A=right_join(Projects_metadata,Projects_metadata2)
B= cbind (Projects_metadata,A)

ncol(A)
ncol(Projects_metadata)
ncol(Projects_metadata2)
