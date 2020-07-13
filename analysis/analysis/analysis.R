library(plyr)
library(readr)

#setwd("C:/Users/anl85ck/Desktop/PhD/4_Modellierung/2_CHARISMA/2_Macroph/analysis/analysis")
setwd("C:/Users/anl85ck/Desktop/PhD/4_Modellierung/2_CHARISMA/2_Macroph/output")
modelruns<-list.dirs()
modelruns

setwd(modelruns[2])
results<-list.dirs()
results

setwd(results[4])
myfiles <- list.files(full.names=T)
myfiles

data<-lapply(myfiles, function(x) read.csv(file=x, header=F))

#Check
data[[7]][19,2]
data[[7]][32,2]



##Env
par(mfrow = c(4, 1))
plot(data[[1]][,1], type="l", xlab = "", ylab="Irr") #irradiance, 
plot(data[[2]][,1], type="l", xlab = "", ylab="LightAtt") #lightAttenuation
plot(data[[8]][,1], type="l", xlab = "", ylab="Temp") #temp
plot(data[[9]][,1], type="l", xlab = "", ylab="WL") #waterlevel

##Macrophytes
#Biomass
par(mfrow = c(4, 1))
plot(data[[3]][,1], type="l", ylim = c(0,max(data[[3]][,1])), xlab = "", ylab="Biomass_0.1m") #Plants_0.1 #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
plot(data[[5]][,1], type="l", ylim = c(0,max(data[[3]][,1])), xlab = "", ylab="Biomass_2m") #Plants_5
plot(data[[6]][,1], type="l", ylim = c(0,max(data[[3]][,1])), xlab = "", ylab="Biomass_5m") #Plants_10
plot(data[[4]][,1], type="l", ylim = c(0,max(data[[3]][,1])), xlab = "", ylab="Biomass_10m") #Plants_2
#plot(data[[7]][,1], type="l") #Settings

#Height
par(mfrow = c(4, 1))
plot(data[[3]][,4], type="l", ylim = c(0,max(data[[3]][,4])), xlab = "", ylab="Height_0.1m") #Plants_0.1 #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
plot(data[[5]][,4], type="l", ylim = c(0,max(data[[3]][,4])), xlab = "", ylab="Height_2m") #Plants_5
plot(data[[6]][,4], type="l", ylim = c(0,max(data[[3]][,4])), xlab = "", ylab="Height_5m") #Plants_10
plot(data[[4]][,4], type="l", ylim = c(0,max(data[[3]][,4])), xlab = "", ylab="Height_10m") #Plants_2

#plot(data[[7]][,1], type="l") #Settings
