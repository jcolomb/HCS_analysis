####################################
# 1.3. define global variables
####################################

## newcode variables:
groupingby = "AOCF" # other possibilities follow:
#groupingby = "MITsoft"

# define the plotting themes for the following visual representations

cols <- c("CONT" = "#3399CC","KO" = "#FF6666") # colors of the genotypes

pl.theme <- theme (axis.title = element_text(size=11,face="bold"),
                   plot.title = element_text(size=18),
                   axis.text.y = element_text(angle=0, hjust=-0.25),
                   axis.text.x = element_text(angle=0, hjust=1),
                   axis.ticks.length = unit(-0.15, "cm"),
                   axis.line=element_line(colour="black"),
                   axis.line.y=element_line(colour="black"),
                   axis.line.x=element_line(colour="black"),
                   legend.title = element_blank(),
                   legend.text =element_text(size=8),
                   legend.position=c(0.1,0.85))

pl.theme.it <- theme (axis.title = element_text(size=11,face="bold"),
                      plot.title = element_text(size=18),
                      axis.text.y = element_text(angle=0, hjust=-0.25),
                      axis.text.x = element_text(angle=60, hjust=1),
                      axis.ticks.length = unit(-0.15, "cm"),
                      axis.line=element_line(colour="black"),
                      axis.line.y=element_line(colour="black"),
                      axis.line.x=element_line(colour="black"),
                      legend.title = element_blank(),
                      legend.text =element_text(size=8),
                      legend.position=c(0.1,0.85))

theme.mr <- theme (axis.title = element_text(size=11,face="bold"),
                   axis.line.x = element_line(colour = "black"),
                   axis.line.y = element_line(colour = "black"),
                   plot.title = element_text(size=18),
                   axis.text.y = element_text(angle=0, hjust=-0.25),
                   axis.text.x = element_text(angle=0, hjust=1), #inclination of text of X axis
                   legend.title = element_blank(),
                   legend.text =element_text(size=11))


# initialize lists to store average duration for each behaviour
# for each hour / dark phase corrected bin for Hours and Minutes files later
beh.list <- list()
beh.dark.list <- list()

# initialize data frame to contain dark phase corrected 60 min bins
behav.dark = data.frame()

# define time intervall of first hours to analyse later on
h = 5

# pb <- tkProgressBar(title = "HCS analysis ", min = 0,
#                     max = 10, width = 300)

