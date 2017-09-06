

### behavior lists
## MR based on minute data, put unassigned to non existing entries
##   note the Arousal and urinate seem to be never picked up by software

B24_ori <- read_csv("C:/Users/cogneuro/Desktop/HCS_analysis/Rcode/24_ori.csv")
b20min_sum <- read_csv("C:/Users/cogneuro/Desktop/HCS_analysis/Rcode/behav20min_sum.csv")
BRawto24 <- read_csv("C:/Users/cogneuro/Desktop/HCS_analysis/Rcode/BehaviorlistRawto24.csv")

#View(left_join(BRawto24,B24_ori))
#View(left_join(b20min_sum,B24_ori))

Behav_forraw =left_join(BRawto24,B24_ori)
Behav_formin = left_join(b20min_sum,B24_ori)
## old code used to create files:

# p= data.frame(unique (Rawdata$Behavior))
# names(p)= "Behavior"
# 
# Behaviorlist <- read_csv("C:/Users/cogneuro/Desktop/HCS_analysis/Rcode/Behaviorlist.csv")
# names (Behaviorlist)= c("Behavior", "Behavior2", "test")
# Behaviorlist2=left_join(p,Behaviorlist)
# write_csv (Behaviorlist2, "C:/Users/cogneuro/Desktop/HCS_analysis/Rcode/Behaviorlist3.csv")
# 
# Behaviorlist <- read_csv("C:/Users/cogneuro/Desktop/HCS_analysis/Rcode/Behaviorlist2.csv")
