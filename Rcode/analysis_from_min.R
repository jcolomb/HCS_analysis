####################################
# 5.1. data loading & manipulation
####################################

# assign loaded data to dist variable
Mins <- MIN_data
rm(data)






#---------------group behaviours---------------#

# adjust column names to enable grouping of behaviours over columns
names(Mins)[names(Mins)=="Travel(m)"] = 'distance.traveled'
names(Mins)[names(Mins)=="Drnk(S1)"] = 'Drink.1'
names(Mins)[names(Mins)=="Drnk(S2)"] = 'Drink.2'
names(Mins)[names(Mins)=="Drnk(S3)"] = 'Drink.3'
names(Mins)[names(Mins)=="Eat(Z1)"] = 'Eat.1'
names(Mins)[names(Mins)=="Eat(Z2)"] = 'Eat.2'
names(Mins)[names(Mins)=="Eat(Z3)"] = 'Eat.3'

# used information about groups as identified in 4. Hours file

behav_gp <- Mins%>% transmute(ID =ID,Bin = Bin, bintodark,Distance_traveled = distance.traveled, ComeDown = ComeDown+CDfromPR, hang = HangCudl+HangVert+HVfromRU+HVfromHC+RemainHC+RemainHV,
                              jump = Jump+ReptJump, immobile=Stationa+Pause+Sleep, rearup = RearUp+RUfromPR+CDtoPR+RUtoPR+RemainPR, digforage=Dig+Forage,
                              walk = Turn+WalkLeft+WalkRght+WalkSlow+Circle, Groom = Groom, Urinate = Urinate, Twitch = Twitch,
                              Arousal = Arousal, Awaken = Awaken,Chew = Chew, Sniffing = Sniff, RemainLow = RemainLw,
                              Eat = Eat.1+Eat.2+Eat.3, Drink = Drink.1+Drink.2+Drink.3, Stretch = Stretch)

#behav_gp = cbind(Mins[,c(1:13)],behav_gp)




### convert genotpye into factor for later analysis
if (is.factor(behav_gp$genotype)==FALSE) {
  behav_gp <- behav_gp %>%  mutate(genotype = as.factor(genotype)) 
}
# change the class of hours as numeric instead of charachter
if (!is.numeric(behav_gp$Bin)) {
  behav_gp <- behav_gp %>% mutate(Bin = as.numeric(Bin))
}

#---------------creating 60 mins bins for visualisation---------------#



animals = unique(behav_gp$ID)
hour.info = matrix(,ncol = 2, nrow = length(animals))
colnames(hour.info) = c('earliest bin','last bin')
# define columns containing behaviours in behav_gp
b.var = 4:ncol(behav_gp)
behav.dark = data.frame()

for (i in animals) {
  
  # create subset of data for onlz the given animal
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
  temp.ad = matrix(,ncol = length(b.var)+1,nrow = max.b)
  temp.bd = matrix(,ncol = length(b.var)+1,nrow = abs(min.b))
  
  # sum up all values for each full hour after start of dark phase
  for (t in 1:max.b) {
    for (b in b.var) {
      temp.ad[t,1] = t-1
      temp.ad[t,b-min(b.var)+2] = sum(temp[(d.start+(60*(t-1))):(d.start+((60*t)-1)),b])
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
      temp.bd[t+(abs(min.b)+1),1] = t
      temp.bd[t+(abs(min.b)+1),b-min(b.var)+2] = sum(temp[(d.start+((t*60)+1))  : (d.start +((t+1)*60) ) ,b])
    }
  }
  
  # combine all bins
  temp <- rbind(temp.bd,temp.ad)
  # set colum names
  colnames(temp) = c('Bin.dark',names(behav_gp)[b.var])
  # add meta information again
  temp <- cbind(meta,temp)
  hour.info[which(animals == i),1] = min.b
  hour.info[which(animals == i),2] = max.b-1
  # combine for each animal_ID
  behav.dark = rbind(behav.dark,temp)
}

behav.dark2 <- data.frame(lapply(behav.dark, function(x) as.numeric(as.character(x))) )

  behav.dark2$meta = as.character(behav.dark2$meta)

#b.var = 15:ncol(behav.dark)

# create table containing meta information (e.g. animal_ID etc.)
#meta.info = behav.dark[,-b.var]

####################################
# 5.2. data plotting
####################################

#### plot for each behaviour the group average per hour (based on BIN given in the raw data [not actual time])

 N_behav= ncol(behav.dark2)-2
#distance traveled
dist <- left_join(behav.dark2, metadata, by =c( "meta"="ID") )
#dist$distance.traveled = behav.dark[,'Distance_traveled']
  
#dist_d = dist  %>% ungroup %>% group_by(genotype,treatment,Bin.dark) %>% summarise (avg = mean(Distance_traveled), sd = sd(Distance_traveled))
#CD = dist  %>% ungroup %>% group_by(genotype,treatment,Bin.dark) %>% summarise (avg = mean(ComeDown), sd = sd(ComeDown))


dist_sum =dist %>% 
   ungroup %>%
  group_by(genotype,treatment,Bin.dark) %>% 
  summarise_at( vars(Distance_traveled:Stretch), funs(mean, sd))

#pdf("test.pdf")
pl <- list()



for (i in c(1:N_behav)){
  dist_d =dist_sum [,c(1,2,3,3+i,3+i+N_behav)]
  Title_plot = names (dist_d) [4]
  names (dist_d) [4:5]= c("avg", "sd")
  p=plot24h(dist_d, Title_plot)
  #print(p)
  pl[[i]]= p
}
#dev.off()


pl.all.d <- do.call(grid.arrange,c(pl,list(ncol = 3)))


text.all.d = paste('
                   Comment:
                   Duration of each behaviour per hour and per genotype with dark phase start correction. The space between the dotted lines represents the time intervall in which data for all animals is present. Due to the different individual start times this alignment around the dark phase is necessary',
                   collapse=" ")



# all graphs in one plot
setwd(plot.path)
pdf(file = "14. Minutes-Behaviours_grouped_dark_corrected.pdf", width = 15, height = 10)

grid.arrange(splitTextGrob(text.all.d),pl.all.d,
             ncol=1,heights = c(1,5),
             top = textGrob('5. All behaviour kinetics with dark phase correction (AOCF grouping)',gp=gpar(fontsize = 30, font=3)))

dev.off()





######### MR # PLots around start of the dark phase
dist2 = dist %>% filter(Bin.dark %in% c(-2:2))

#replot all: copy paste what is up there:
dist_sum =dist2 %>% 
  ungroup %>%
  group_by(genotype,treatment,Bin.dark) %>% 
  summarise_at( vars(Distance_traveled:Stretch), funs(mean, sd))

#pdf("test.pdf")
pl <- list()



for (i in c(1:N_behav)){
  dist_d =dist_sum [,c(1,2,3,3+i,3+i+N_behav)]
  Title_plot = names (dist_d) [4]
  names (dist_d) [4:5]= c("avg", "sd")
  p=plot24h(dist_d, Title_plot, datalenght=2, hour.info2=data.frame(-2,2))
  #print(p)
  pl[[i]]= p
}
#dev.off()


pl.all.d <- do.call(grid.arrange,c(pl,list(ncol = 3)))


text.all.d = paste('
                   Comment:
                   Duration of each behaviour per hour and per genotype with dark phase start correction. The space between the dotted lines represents the time intervall in which data for all animals is present. Due to the different individual start times this alignment around the dark phase is necessary',
                   collapse=" ")



# all graphs in one plot
setwd(plot.path)
pdf(file = "16. Minutes-Activity_behaviours_dark_corrected_start_2hours.pdf", width = 15, height = 10)

grid.arrange(splitTextGrob(text.act.d),pl.all.d,heights = c(.5,2.5),
             top=textGrob("6. Expression of behaviours during the first five hours in HCS
                          ",gp=gpar(fontsize=20,font=3)))
dev.off()


####################################
# 5.3. statistical tests
####################################

N_behav
# define vector with all grouped behaviours for analysis
b.actions = names(behav_gp)
b.actions = b.actions[b.var]

#---------------create statistics matrix---------------#

# initialize matrix for test results
TS.D = matrix(,nrow=length(b.actions),ncol=3)
colnames(TS.D) = c('behaviour',
                   'Wilcox-W score','Wilcox p.value')#,
# 'T.Test T-score','T.test p.value'#'Kruskal-Chi^2','Kruskal p.value')#,)
# perform Kruskal / Wilcox / T-Test between genotypes for all
# behaviours

####################################
# 5.3.1 kruskall wallis rank sum test
####################################

## Please comment
behav.dark = dist
for ( b in b.actions) {
  # KT <- kruskal.test(avg~genotype, data = beh.dark.list[[b]])
  # KT <- kruskal.test(behav.dark[,b]~behav.dark$genotype)
  WT <- wilcox.test(behav.dark[,b]~behav.dark$genotype)
  # TT <- t.test(behav.dark[,b]~behav.dark$genotype)
  
  TS.D[which(b.actions == b),1] = b
  # TS.D[which(b.actions == b),2] = KT$statistic
  # TS.D[which(b.actions == b),3] = KT$p.value
  TS.D[which(b.actions == b),2] = round(WT$statistic,4)
  TS.D[which(b.actions == b),3] = round(WT$p.value,4)
  # TS.D[which(b.actions == b),6] = TT$statistic
  # TS.D[which(b.actions == b),7] = TT$p.value
}
# convert into displayable table
gt.D <- tableGrob(TS.D)


# grid.arrange(gt.D,
#   top=textGrob('test statistics for genotype comparison (dark corrected) ',gp=gpar(fontsize=40,font=3)))
#   #,ncol=2, widths = c(0.5,0.5))


d.gt <-   grid.arrange(gt.D,
                       top=textGrob('
                                    dark phase corrected', gp=gpar(fontsize=20,font=3)))
setwd(plot.path)
pdf(file = "15. Test_statistics_MINUTES_dark_corrected.pdf", width = 15, height = 8)
grid.arrange(d.gt,
             top=textGrob('
                          5. Wilcoxon rank sum test for genotype comparison\n
                          on total duration per hour for each animal',gp=gpar(fontsize=30,font=3)),
             ncol=1)

dev.off()
#setwd('../')




####################################
# 5.3.2 ANOVA between genotypes within hours
####################################

##################################################################
#------compute anova BETWEEN genotypes within hours of dark phase
##################################################################

# the focus here is on analysing the difference between genotypes in their
# behaviour leading up to the swith from light to dark phase, rather than the difference in
# variances between hours, which is to be expected due to change of environment which
# introduces to much noise (variance) to make interpretation of differences of variances infeasible


#split by bins to compare betweeh genotypes change wthin time
temp.1 <- behav.dark %>% filter(Bin.dark == -2) %>% mutate(Bin.dark = as.factor(Bin.dark))
temp.2 <- behav.dark %>% filter(Bin.dark == -1) %>% mutate(Bin.dark = as.factor(Bin.dark))
temp.3 <- behav.dark %>% filter(Bin.dark == 0) %>% mutate(Bin.dark = as.factor(Bin.dark))
temp.4 <- behav.dark %>% filter(Bin.dark == 1) %>% mutate(Bin.dark = as.factor(Bin.dark))
temp.5 <- behav.dark %>% filter(Bin.dark == 2) %>% mutate(Bin.dark = as.factor(Bin.dark))

#---------------create ANOVA matrix---------------#

ANO.D.T = matrix(,nrow=length(b.actions),ncol=(h*2)+2)
colnames(ANO.D.T) = c('behaviour','overall p.value','-2h p.value','mean difference','-1h p.value',
                      'mean difference',' 0h p.value','mean difference','1h p.value','mean difference',
                      '2h p.value','mean difference')


#---------------perform ANOVA within Bin---------------#

for ( b in b.actions) {
  
  # perform anova for each behaviour over all hours
  Total.model <- aov(behav.dark[,b]~genotype, data = behav.dark)
  # perform anova for each behaviour within hour
  Bin.model.1 <- aov(temp.1[,b]~genotype, data = temp.1)
  Bin.model.2 <- aov(temp.2[,b]~genotype, data = temp.2)
  Bin.model.3 <- aov(temp.3[,b]~genotype, data = temp.3)
  Bin.model.4 <- aov(temp.4[,b]~genotype, data = temp.4)
  Bin.model.5 <- aov(temp.5[,b]~genotype, data = temp.5)
  
  # save anova & post-hoc results in one matrix per genotype
  ANO.D.T[which(b.actions == b),1] = b
  ANO.D.T[which(b.actions == b),2] = round(summary(Total.model)[[1]][1,5],4)
  ANO.D.T[which(b.actions == b),3] = round(summary(Bin.model.1)[[1]][[1,5]],4)
  ANO.D.T[which(b.actions == b),4] = round(summary.lm(Bin.model.1)$coefficients[[2,1]],4)
  ANO.D.T[which(b.actions == b),5] = round(summary(Bin.model.2)[[1]][[1,5]],4)
  ANO.D.T[which(b.actions == b),6] = round(summary.lm(Bin.model.2)$coefficients[[2,1]],4)
  ANO.D.T[which(b.actions == b),7] = round(summary(Bin.model.3)[[1]][[1,5]],4)
  ANO.D.T[which(b.actions == b),8] = round(summary.lm(Bin.model.3)$coefficients[[2,1]],4)
  ANO.D.T[which(b.actions == b),9] = round(summary(Bin.model.4)[[1]][[1,5]],4)
  ANO.D.T[which(b.actions == b),10] = round(summary.lm(Bin.model.4)$coefficients[[2,1]],4)
  ANO.D.T[which(b.actions == b),11] = round(summary(Bin.model.5)[[1]][[1,5]],4)
  ANO.D.T[which(b.actions == b),12] = round(summary.lm(Bin.model.5)$coefficients[2,1],4)
  
}


# convert into displayable table
ano.d.t <- tableGrob(ANO.D.T)

setwd(plot.path)
pdf(file = "20. MINUTES-ANOVA_between_gt_dark_phase_start.pdf", width = 22, height = 8)
test.table.hours <- grid.arrange(ano.d.t,
                                 top=textGrob('
                                              6. Between genotype around dark phase start \n
                                              ANOVA p-values & mean distances ',gp=gpar(fontsize=30,font=3)))
dev.off()
setwd('../')

# write.csv(ANO.D.T, paste('MINUTES-ANOVA-between-genotypes_dark_start_Lehnardt_MyD88',Sys.Date(),'.csv'))

#---------update progress bar--------------#
progress = 8
setTkProgressBar(pb, progress, label=paste( round(progress/10*100, 0),
                                            "% done"))



##############################################################
#---------------compute anova between dark phase hours WITHIN genotype
##############################################################

#split by genotypes to compare within genotype change over time
temp.1 <- behav.dark %>% filter(Bin.dark %in% c(-2,-1,0,1,2)) %>% filter(genotype == genotypes[1]) %>% mutate(Bin.dark = as.factor(Bin.dark))
temp.2 <- behav.dark %>% filter(Bin.dark %in% c(-2,-1,0,1,2)) %>% filter(genotype == genotypes[2]) %>% mutate(Bin.dark = as.factor(Bin.dark))

#---------------create ANOVA matrix---------------#

ANO.1 = matrix(,nrow=length(b.actions),ncol=h*2)
colnames(ANO.1) = c('behaviour','overall p.value','1:2 p.value','mean difference','1:3 p.value','mean difference',
                    '1:4 p.value','mean difference','1:5 p.value','mean difference')
ANO.2 = matrix(,nrow=length(b.actions),ncol=h*2)
colnames(ANO.2) = c('behaviour','overall p.value','1:2 p.value','mean difference','1:3 p.value','mean difference',
                    '1:4 p.value','mean difference','1:5 p.value','mean difference')

#---------------perform ANOVA within genotype---------------#


for ( b in b.actions) {
  
  # perform anova for each behaviour
  Bin.model.1 <- aov(temp.1[,b]~Bin.dark, data = temp.1)
  Bin.model.2 <- aov(temp.2[,b]~Bin.dark, data = temp.2)
  
  # save anova & post-hoc results in one matrix per genotype - CONTROL
  ANO.1[which(b.actions == b),1] = b
  ANO.1[which(b.actions == b),2] = round(summary(Bin.model.1)[[1]][[1,5]],4)
  ANO.1[which(b.actions == b),3] = round(summary.lm(Bin.model.1)$coefficients[2,4],4)
  ANO.1[which(b.actions == b),5] = round(summary.lm(Bin.model.1)$coefficients[3,4],4)
  ANO.1[which(b.actions == b),7] = round(summary.lm(Bin.model.1)$coefficients[4,4],4)
  ANO.1[which(b.actions == b),9] = round(summary.lm(Bin.model.1)$coefficients[5,4],4)
  ANO.1[which(b.actions == b),4] = round(summary.lm(Bin.model.1)$coefficients[2,1],4)
  ANO.1[which(b.actions == b),6] = round(summary.lm(Bin.model.1)$coefficients[3,1],4)
  ANO.1[which(b.actions == b),8] = round(summary.lm(Bin.model.1)$coefficients[4,1],4)
  ANO.1[which(b.actions == b),10] = round(summary.lm(Bin.model.1)$coefficients[5,1],4)
  # save anova & post-hoc results in one matrix per genotype - KO
  
  ANO.2[which(b.actions == b),1] = b
  ANO.2[which(b.actions == b),2] = round(summary(Bin.model.2)[[1]][[1,5]],4)
  ANO.2[which(b.actions == b),3] = round(summary.lm(Bin.model.2)$coefficients[2,4],4)
  ANO.2[which(b.actions == b),5] = round(summary.lm(Bin.model.2)$coefficients[3,4],4)
  ANO.2[which(b.actions == b),7] = round(summary.lm(Bin.model.2)$coefficients[4,4],4)
  ANO.2[which(b.actions == b),9] = round(summary.lm(Bin.model.2)$coefficients[5,4],4)
  ANO.2[which(b.actions == b),4] = round(summary.lm(Bin.model.2)$coefficients[2,1],4)
  ANO.2[which(b.actions == b),6] = round(summary.lm(Bin.model.2)$coefficients[3,1],4)
  ANO.2[which(b.actions == b),8] = round(summary.lm(Bin.model.2)$coefficients[4,1],4)
  ANO.2[which(b.actions == b),10] = round(summary.lm(Bin.model.2)$coefficients[5,1],4)
  
}


# combine anova tables
ANO.1 <- cbind(rep(as.character(genotypes[1]),each=nrow(ANO.1)),ANO.1)
ANO.2 <- cbind(rep(as.character(genotypes[2]),each=nrow(ANO.2)),ANO.2)
# save both genotypes results in one table
ANO.B <- rbind(ANO.1,ANO.2)
colnames(ANO.B)[1] = 'genotypes'

# convert into displayable table
ano.d.t.w <- tableGrob(ANO.B)
setwd(plot.path)
pdf(file = "21. Minutes-ANOVA_within_genotypes.pdf", width = 20, height = 15)
test.table.hours <- grid.arrange(ano.d.t.w,
                                 top=textGrob('
                                              6. Within genotype over hours around dark phase start \n
                                              ANOVA p-values & mean distances',gp=gpar(fontsize=30,font=3)))
dev.off()
setwd('../')
# save as csv file
# write.csv(ANO.B, paste('HOURS-ANOVA-within-genotype_Lehnardt_MyD88',Sys.Date(),'.csv'))



####################################
# 5.3.3 MCMCglmm for evaluation
####################################

b.actions = names(beh.dark.list)

set.seed(1)

test <- lapply(1:4, function(i) {
  MCMCglmm(Distance_traveled~genotype, random =~ animal_ID,
           family = c('gaussian'),
           nitt = 23000, # nitt = number of iterations the MonteCarlo simulation is run
           thin = 100,  # thin = only keep every thin iteration (Markov chain depends on previous iteration -> reduce autocorrelation of sampling)
           burnin = 3000, #burnin = Burn-in period: discard the first burnin iterations to be in max-likelihood space / neglect influence of seed values
           data = behav.dark, verbose = FALSE)
}
)
# test.fit <- lapply(test, function(m) m$Sol)
# test.fit <- do.call(mcmc.list, test.fit)
# test.influence <- lapply(test, function(m) m$VCV)
# test.influence <- do.call(mcmc.list, test.influence)

# # plot convergence of chains to scale reduction factor
# # to ensure stable convergence over stochastic simulations
# # if good convergence -> MCMC simulation is a good fit for our data

# gelman.plot(test.influence, auto.layout = T)

# # check for visual overlay of trace function to check fit of model
# par(mfrow = c(2,2))
# plot(test.fit, ask = FALSE, auto.layout = FALSE)

# # check for 'nicely' bell kurve of genotype as we expect the influence to be there.
# # should be the case when nice convergence above


# # compute gelman-rubin criterion
# # values close to 1 (below 1.1) are acceptable (below 1.02 very good approximation)
# # as valid representation for true posterior distribution ()
# gelman.diag(test.fit) # for genotype: 1.00 -> very good fit

# after validation of approximation of posterior distribution
# check influence of animal_ID results
# par(mfrow = c(2,2))
# plot(test.influence, ask = FALSE, auto.layout = FALSE) #
# summary(test.influence)

par(mfrow = c(1,2))
plot(density(test[[1]]$Sol[,2]), main = 'genotype', ylim = c(0,0.5))
for (i in 2:4) {
  lines(density(test[[i]]$Sol[,2]), col = i)
}
plot(density(test[[1]]$VCV[,1]), main = 'animal_ID', ylim = c(0,0.5))
for (i in 2:4) {
  lines(density(test[[i]]$VCV[,1]), col = i)
}
mcmc.plot <- grab_grob()

text.mcmc <- paste('
                   The influence of genotype and animal ID on the distance traveled is evaluated using four runs of MCMCglmm simulations. A bell curved density function indicates a strong influence.')

setwd(plot.path)
pdf(file = "2. MINUTES-MCMC_genotype_animal_ID_distance_traveled.pdf", width = 15, height = 10)
grid.arrange(splitTextGrob(text.mcmc),mcmc.plot, ncol = 1, nrow=2, heights = c(1,3),
             top = textGrob('1. MCMCglmm trace densities for distance traveled ~ genotype / animal ID',
                            gp = gpar(fontsize = 30, font = 3)))
dev.off()
setwd('../')
