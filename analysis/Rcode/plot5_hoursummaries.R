####################################
#-----------plotting hourly mean around light off
####################################

# input = behav_gp

#keep a version of untouched behav_gp
behav_gpori = behav_gp
# change the class of hours as numeric instead of charachter
if (!is.numeric(behav_gp$Bin)) {
  behav_gp <- behav_gp %>% mutate(Bin = as.numeric(Bin))
}
behav_gp = behav_gp %>% select (-lightcondition)

#---------------creating 60 mins bins for visualisation---------------#



animals = unique(behav_gp$ID)
hour.info = as.data.frame(matrix(ncol = 2, nrow = length(animals)))
colnames(hour.info) = c('earliest_bin', 'last_bin')
# define columns containing behaviours in behav_gp
b.var = 4:ncol(behav_gp)
behav.dark = data.frame()

for (i in animals) {
  # create subset of data for only the given animal
  temp <- filter(behav_gp, ID == i)
  # save meta information about given animal
  meta <- i
  # find the individual row with the start of the dark phase
  d.start = which(temp$bintodark == 0)
  # get maximal number of full hours after start of dark phase
  max.b = floor(max(temp$bintodark) / 60)
  # get number of full hours before start of dark phase
  min.b = ceiling(min(temp$bintodark) / 60)
  
  
  ### define bins after start of dark phase
  
  # create empty matrices to hold summed hourly data
  temp.ad = matrix(ncol = length(b.var) + 1, nrow = max.b)
  temp.bd = matrix(ncol = length(b.var) + 1, nrow = abs(min.b))
  
  # sum up all values for each full hour after start of dark phase
  for (t in 1:max.b) {
    for (b in b.var) {
      temp.ad[t, 1] = t - 1
      temp.ad[t, b - min(b.var) + 2] = sum(temp[(d.start + (60 * (t - 1))):(d.start +
                                                                              ((60 * t) - 1)), b])
    }
  }
  
  ### sum up all values for each full hour before the dark phase
  # for (t in 1:abs(min.b)) {
  #   for (b in b.var) {
  #     temp.bd[t,1] = seq(min.b,-1)[t]
  #     temp.bd[t,b-12] = sum(temp[ ((d.start-1)+(-60*(t)))  : ((d.start-1)+(-60*(t-1))),b])
  #   }
  # }
  for (t in min.b:-1) {
    for (b in b.var) {
      temp.bd[t + (abs(min.b) + 1), 1] = t
      temp.bd[t + (abs(min.b) + 1), b - min(b.var) + 2] = sum(temp[(d.start +
                                                                      ((t * 60) + 1)):(d.start + ((t + 1) * 60)) , b])
    }
  }
  
  # combine all bins
  temp <- rbind(temp.bd, temp.ad)
  # set colum names
  colnames(temp) = c('Bin.dark', names(behav_gp)[b.var])
  # add meta information again
  temp <- cbind(meta, temp)
  hour.info[which(animals == i), 1] = min.b
  hour.info[which(animals == i), 2] = max.b - 1
  # combine for each animal_ID
  behav.dark = rbind(behav.dark, temp)
}

behav.dark2 <-
  data.frame(lapply(behav.dark, function(x)
    as.numeric(as.character(x))))

behav.dark2$meta = as.character(behav.dark2$meta)
# calculate meaningful time limits
timeMin = max (hour.info$earliest_bin) - 0.1
timeMax = min (hour.info$last_bin) + 0.1

# filter for data where all mice have data:
behav.dark2 = behav.dark2 %>% filter (Bin.dark > timeMin &
                                        Bin.dark < timeMax)

####################################
# 5.2. data plotting
####################################

#### plot for each behaviour the group average per hour (based on BIN given in the raw data [not actual time])

N_behav = ncol(behav.dark2) - 2
#distance traveled
dist <- left_join(behav.dark2, metadata, by = c("meta" = "ID"))
#dist$distance.traveled = behav.dark[,'Distance_traveled']

#dist_d = dist  %>% ungroup %>% group_by(genotype,treatment,Bin.dark) %>% summarise (avg = mean(Distance_traveled), sd = sd(Distance_traveled))
#CD = dist  %>% ungroup %>% group_by(genotype,treatment,Bin.dark) %>% summarise (avg = mean(ComeDown), sd = sd(ComeDown))

if (groupingby == "AOCF") {
  dist_sum = dist %>%
    ungroup %>%
    group_by(genotype, treatment, Bin.dark) %>%
    summarise_at(vars(Distance_traveled:Stretch), funs(mean, sd)) %>%
    mutate (Bin.dark = Bin.dark + 0.5) # get the x value in the middle of time interval
  
}

if (groupingby == "MITsoft") {
  dist_sum = dist %>%
    ungroup %>%
    group_by(genotype, treatment, Bin.dark) %>%
    summarise_at(vars(Distance_traveled:Drink), funs(mean, sd)) %>%
    mutate (Bin.dark = Bin.dark + 0.5) # get the x value in the middle of time interval
  
}

#pdf("test.pdf")
pl <- list()



for (i in c(1:N_behav)) {
  dist_d = dist_sum [, c(1, 2, 3, 3 + i, 3 + i + N_behav)]
  Title_plot = names (dist_d) [4]
  names (dist_d) [4:5] = c("avg", "sd")
  dist_d [4:5] <- dist_d [4:5] / 36
  p = plot24h(dist_d, Title_plot)
  #print(p)
  pl[[i]] = p
}
#dev.off()


pl.all.d <- do.call(grid.arrange, c(pl, list(ncol = 3)))


text.all.d = paste(
  '
  Comment:
  %age time spent doing each behaviour per hour and per genotype with dark phase start correction. The space between the dotted lines represents the time intervall in which data for all animals is present. Due to the different individual start times this alignment around the dark phase is necessary',
  collapse = " "
)



# all graphs in one plot
#setwd(plot.path)
pdf(
  file = paste0(plot.path, "/hourly_plotting_corrected.pdf"),
  width = 15,
  height = 10
)

grid.arrange(
  splitTextGrob(text.all.d),
  pl.all.d,
  ncol = 1,
  heights = c(1, 5),
  top = textGrob(
    paste0(
      'All hourly behaviour kinetics with dark phase correction (',
      groupingby,
      ' grouping)'
    ),
    gp = gpar(fontsize = 30, font = 3)
  )
)

dev.off()

# return behav_gp to original value before this code
behav_gpori -> behav_gp
