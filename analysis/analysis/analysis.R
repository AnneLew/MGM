library(plyr)
library(readr)

#setwd("C:/Users/anl85ck/Desktop/PhD/4_Modellierung/2_CHARISMA/2_Macroph/analysis/analysis")
setwd("C:/Users/anl85ck/Desktop/PhD/4_Modellierung/2_CHARISMA/2_Macroph/output")
modelruns<-list.dirs(recursive = F)
modelruns

setwd(modelruns[8])
run<-getwd()
run
results<-list.dirs(recursive = F)
#results<-results[2:length(results)]
results

for (i in 1:length(results)){
  setwd(results[i]) #
  myfiles <- list.files(full.names=T, pattern="*.csv")
  #print(myfiles)
  
  data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
  
  #Check
  print(data[[7]][19,2])
  print(data[[7]][32,2])
  #print(data[[7]][40,2])
  
  ##Env
  dir.create("plots")
  setwd("./plots")
  png("Env.png",width = 480, height = 880, res = 100)
  par(mfrow = c(4, 1))
  plot(data[[1]][,1], type="l", xlab = "", ylab="Irr") #irradiance, 
  plot(data[[2]][,1], type="l", xlab = "", ylab="LightAtt") #lightAttenuation
  plot(data[[8]][,1], type="l", xlab = "", ylab="Temp") #temp
  plot(data[[9]][,1], type="l", xlab = "", ylab="WL") #waterlevel
  dev.off()
  
  
  #Macrophytes
  png("macrophytes.png",width = 1080, height = 880, res = 100)
  par(mfrow = c(4, 3))
  maxbiomass=max(max(data[[3]][,1]),max(data[[5]][,1]),max(data[[4]][,1]),max(data[[6]][,1]))
  maxheight=max(max(data[[3]][,4]),max(data[[5]][,4]),max(data[[4]][,4]),max(data[[6]][,4]))
  maxind=max(max(data[[3]][,2]),max(data[[5]][,2]),max(data[[4]][,2]),max(data[[6]][,2]))
  
  plot(data[[3]][,1], type="l", ylim = c(0,maxbiomass), xlab = "", ylab="Biomass_0.5m") #Plants_0.1 #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
  plot(data[[3]][,4], type="l", ylim = c(0,maxheight), xlab = "", ylab="Height_0.5m") #Plants_0.1 #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
  plot(data[[3]][,2], type="l", ylim = c(0,maxind), xlab = "", ylab="Ind_0.5m") #Plants_0.1 #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
  
  plot(data[[4]][,1], type="l", ylim = c(0,maxbiomass), xlab = "", ylab="Biomass_1.5m") #Plants_5
  plot(data[[4]][,4], type="l", ylim = c(0,maxheight), xlab = "", ylab="Height_1.5m") #Plants_5
  plot(data[[4]][,2], type="l", ylim = c(0,maxind), xlab = "", ylab="Ind_1.5m") #Plants_5
  
  plot(data[[5]][,1], type="l", ylim = c(0,maxbiomass), xlab = "", ylab="Biomass_3m") #Plants_10
  plot(data[[5]][,4], type="l", ylim = c(0,maxheight), xlab = "", ylab="Height_3m") #Plants_10
  plot(data[[5]][,2], type="l", ylim = c(0,maxind), xlab = "", ylab="Ind_3m") #Plants_10
  
  plot(data[[6]][,1], type="l", ylim = c(0,maxbiomass), xlab = "", ylab="Biomass_6m") #Plants_2
  plot(data[[6]][,4], type="l", ylim = c(0,maxheight), xlab = "", ylab="Height_6m") #Plants_2
  plot(data[[6]][,2], type="l", ylim = c(0,maxind), xlab = "", ylab="Ind_6m")
  
  dev.off()
  
  setwd(run)
}



setwd(results[5]) #
myfiles <- list.files(full.names=T, pattern="*.csv")
myfiles
getwd()

data<-lapply(myfiles, function(x) read.csv(file=x, header=F))

#Check
data[[7]][19,2]
data[[7]][32,2]


##Env
png("Env.png",width = 480, height = 880, res = 100)
par(mfrow = c(4, 1))
plot(data[[1]][,1], type="l", xlab = "", ylab="Irr") #irradiance, 
plot(data[[2]][,1], type="l", xlab = "", ylab="LightAtt") #lightAttenuation
plot(data[[8]][,1], type="l", xlab = "", ylab="Temp") #temp
plot(data[[9]][,1], type="l", xlab = "", ylab="WL") #waterlevel
dev.off()


#Macrophytes
png("macrophytes.png",width = 1080, height = 880, res = 100)
par(mfrow = c(4, 3))
maxbiomass=max(max(data[[3]][,1]),max(data[[5]][,1]),max(data[[4]][,1]),max(data[[6]][,1]))
maxheight=max(max(data[[3]][,4]),max(data[[5]][,4]),max(data[[4]][,4]),max(data[[6]][,4]))
maxind=max(max(data[[3]][,2]),max(data[[5]][,2]),max(data[[4]][,2]),max(data[[6]][,2]))

plot(data[[3]][,1], type="l", ylim = c(0,maxbiomass), xlab = "", ylab="Biomass_0.5m") #Plants_0.1 #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
plot(data[[3]][,4], type="l", ylim = c(0,maxheight), xlab = "", ylab="Height_0.5m") #Plants_0.1 #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
plot(data[[3]][,2], type="l", ylim = c(0,maxind), xlab = "", ylab="Ind_0.5m") #Plants_0.1 #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass

plot(data[[4]][,1], type="l", ylim = c(0,maxbiomass), xlab = "", ylab="Biomass_1.5m") #Plants_5
plot(data[[4]][,4], type="l", ylim = c(0,maxheight), xlab = "", ylab="Height_1.5m") #Plants_5
plot(data[[4]][,2], type="l", ylim = c(0,maxind), xlab = "", ylab="Ind_1.5m") #Plants_5

plot(data[[5]][,1], type="l", ylim = c(0,maxbiomass), xlab = "", ylab="Biomass_3m") #Plants_10
plot(data[[5]][,4], type="l", ylim = c(0,maxheight), xlab = "", ylab="Height_3m") #Plants_10
plot(data[[5]][,2], type="l", ylim = c(0,maxind), xlab = "", ylab="Ind_3m") #Plants_10

plot(data[[6]][,1], type="l", ylim = c(0,maxbiomass), xlab = "", ylab="Biomass_6m") #Plants_2
plot(data[[6]][,4], type="l", ylim = c(0,maxheight), xlab = "", ylab="Height_6m") #Plants_2
plot(data[[6]][,2], type="l", ylim = c(0,maxind), xlab = "", ylab="Ind_6m")

dev.off()