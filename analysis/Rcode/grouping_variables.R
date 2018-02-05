#---------------group behaviours---------------#

# adjust column names to enable grouping of behaviours over columns
names(Mins)[names(Mins)=="Travel(m)"] = 'distance.traveled'
names(Mins)[names(Mins)=="Drnk(S1)"] = 'Drink.1'
names(Mins)[names(Mins)=="Drnk(S2)"] = 'Drink.2'
names(Mins)[names(Mins)=="Drnk(S3)"] = 'Drink.3'
names(Mins)[names(Mins)=="Eat(Z1)"] = 'Eat.1'
names(Mins)[names(Mins)=="Eat(Z2)"] = 'Eat.2'
names(Mins)[names(Mins)=="Eat(Z3)"] = 'Eat.3'

names(Mins)[names(Mins)=="Travel.m."] = 'distance.traveled'
names(Mins)[names(Mins)=="Drnk.S1."] = 'Drink.1'
names(Mins)[names(Mins)=="Drnk.S2."] = 'Drink.2'
names(Mins)[names(Mins)=="Drnk.S3."] = 'Drink.3'
names(Mins)[names(Mins)=="Eat.Z1."] = 'Eat.1'
names(Mins)[names(Mins)=="Eat.Z2."] = 'Eat.2'
names(Mins)[names(Mins)=="Eat.Z3."] = 'Eat.3'

# if eat and drink are separated in 3 zones, calculate the sum
if (!is.null(Mins$Eat.2)){
  Mins<- Mins %>% mutate (Eat = Eat.1+Eat.2+Eat.3, Drink = Drink.1+Drink.2+Drink.3)
}


# group behavior following AOCF rules
# got arousal and urinate in Unknown (always 0)
behav_gp <- Mins%>% transmute(ID =ID,Bin = Bin, bintodark,
                              Distance_traveled = distance.traveled,
                              ComeDown = ComeDown+CDfromPR,
                              hang = HangCudl+HangVert+HVfromRU+HVfromHC+RemainHC+RemainHV+LandVert,
                              jump = Jump+ReptJump, 
                              immobile=Stationa+Pause+Sleep, 
                              rearup = RearUp+RUfromPR+CDtoPR+RUtoPR+RemainPR+RemainRU,
                              digforage=Dig+Forage,
                              walk = Turn+WalkLeft+WalkRght+WalkSlow+Circle,
                              Groom = Groom, 
                              Twitch = Twitch,
                              Unknown = Unknown + Urinate , # urinate always(?) 0
                              Awaken = Awaken,
                              Chew = Chew, 
                              Sniffing = Sniff,
                              RemainLow = RemainLw,
                              Eat = Eat, 
                              Drink = Drink, 
                              Stretch = Stretch)
# group behavior following Jhuang et al. rules
behav_jhuang <- Mins%>% transmute(ID =ID,Bin = Bin, bintodark,
                                Distance_traveled = distance.traveled,
                                Hang = HangCudl+HangVert+HVfromRU+HVfromHC+RemainHC+RemainHV,
                                Unknown_behavior = Jump+ReptJump+Dig+Forage+Urinate + Unknown,
                                Rest=Stationa+Sleep,
                                Rear = RearUp+RUfromPR+CDtoPR+RUtoPR+RemainPR+ComeDown+CDfromPR+RemainRU+LandVert+Stretch,
                                Walk = Turn+WalkLeft+WalkRght+WalkSlow+Circle,
                                Groom = Groom,
                                Micro_move = Awaken+Pause+RemainLw+Sniff+Twitch,
                                Eat = Chew+Eat,
                                Drink = Drink)

