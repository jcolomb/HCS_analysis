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

# used information about groups as identified in 4. Hours file
# got arousal and urinate out (always 0)
behav_gp <- Mins%>% transmute(ID =ID,Bin = Bin, bintodark,Distance_traveled = distance.traveled, ComeDown = ComeDown+CDfromPR, hang = HangCudl+HangVert+HVfromRU+HVfromHC+RemainHC+RemainHV,
                              jump = Jump+ReptJump, immobile=Stationa+Pause+Sleep, rearup = RearUp+RUfromPR+CDtoPR+RUtoPR+RemainPR, digforage=Dig+Forage,
                              walk = Turn+WalkLeft+WalkRght+WalkSlow+Circle, Groom = Groom, #Urinate = Urinate,
                              Twitch = Twitch,
                              #Arousal = Arousal,
                              Awaken = Awaken,Chew = Chew, Sniffing = Sniff, RemainLow = RemainLw,
                              Eat = Eat.1+Eat.2+Eat.3, Drink = Drink.1+Drink.2+Drink.3, Stretch = Stretch)

behav_jhuang <- Mins%>% transmute(ID =ID,Bin = Bin, bintodark,
                                Distance_traveled = distance.traveled,
                                Hang = HangCudl+HangVert+HVfromRU+HVfromHC+RemainHC+RemainHV,
                                Unknown_behavior = Jump+ReptJump+Dig+Forage+Urinate,
                                Rest=Stationa+Sleep,
                                Rear = RearUp+RUfromPR+CDtoPR+RUtoPR+RemainPR+ComeDown+CDfromPR,
                                Walk = Turn+WalkLeft+WalkRght+WalkSlow+Circle,
                                Groom = Groom,
                                Micro_move = Awaken+Pause+RemainLw+Sniff+Twitch,
                                Eat = Chew+Eat.1+Eat.2+Eat.3,
                                Drink = Drink.1+Drink.2+Drink.3)

