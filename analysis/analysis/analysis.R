#library(plyr)
#library(readr)

#setwd("C:/Users/anl85ck/Desktop/PhD/4_Modellierung/2_CHARISMA/2_Macroph/analysis/analysis")
setwd("C:/Users/anl85ck/Desktop/PhD/4_Modellierung/2_CHARISMA/2_Macroph/output")
modelruns<-list.dirs(recursive = F)


details = file.info(modelruns)
details = details[with(details, order(as.POSIXct(mtime))), ]
modelruns = rownames(details)

setwd(modelruns[length(modelruns)]) #takes the last modelrun
run<-getwd()
run
results<-list.dirs(recursive = F)
#results<-results[2:length(results)]
results

## Plot for all lakes & species: Environment & Macrophyte Biomass, Height & Individuums

for (i in 1:length(results)){
  setwd(results[i]) #
  myfiles <- list.files(full.names=T, pattern="*.csv")
  #print(myfiles)
  
  data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
  
  #Check
  print(data[[8]][19,2])
  print(data[[8]][32,2])
  #print(data[[7]][40,2])
  
  ##Env
  dir.create("plots")
  setwd("./plots")
  png("Env.png",width = 480, height = 880, res = 100)
  par(mfrow = c(4, 1))
  plot(data[[1]][,1], type="l", xlab = "", ylab="Irr") #irradiance, 
  plot(data[[2]][,1], type="l", xlab = "", ylab="LightAtt") #lightAttenuation
  plot(data[[9]][,1], type="l", xlab = "", ylab="Temp") #temp
  plot(data[[10]][,1], type="l", xlab = "", ylab="WL") #waterlevel
  dev.off()
  
  
  #Macrophytes
  png("macrophytes.png",width = 1080, height = 880, res = 100)
  par(mfrow = c(5, 4))
  # maxbiomass= 200#max(max(data[[3]][,1], na.rm = TRUE),max(data[[5]][,1], na.rm = TRUE),max(data[[4]][,1], na.rm = TRUE),max(data[[6]][,1], na.rm = TRUE))
  # maxindWeight= max(max(data[[3]][,3], na.rm = TRUE),max(data[[5]][,3], na.rm = TRUE),max(data[[4]][,3], na.rm = TRUE),max(data[[6]][,3], na.rm = TRUE))
  # maxheight=max(max(data[[3]][,4], na.rm = TRUE),max(data[[5]][,4], na.rm = TRUE),max(data[[4]][,4], na.rm = TRUE),max(data[[6]][,4], na.rm = TRUE))
  # maxind=200#max(max(data[[3]][,2], na.rm = TRUE),max(data[[5]][,2], na.rm = TRUE),max(data[[4]][,2], na.rm = TRUE),max(data[[6]][,2], na.rm = TRUE))

  plot(data[[3]][,1], type="l", xlab = "", ylab="Biomass_0.5m") #Plants_0.1 #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
  plot(data[[3]][,3], type="l", xlab = "", ylab="indWeight_0.5m") #Plants_0.1 #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
  plot(data[[3]][,4], type="l", xlab = "", ylab="Height_0.5m") #Plants_0.1 #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
  plot(data[[3]][,2], type="l", xlab = "", ylab="Ind_0.5m") #Plants_0.1 #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
  
  plot(data[[4]][,1], type="l", xlab = "", ylab="Biomass_1.0m") #Plants_5
  plot(data[[4]][,3], type="l", xlab = "", ylab="indWeight_1.0m") #Plants_5
  plot(data[[4]][,4], type="l", xlab = "", ylab="Height_1.0m") #Plants_5
  plot(data[[4]][,2], type="l", xlab = "", ylab="Ind_1.0m") #Plants_5
  
  plot(data[[5]][,1], type="l", xlab = "", ylab="Biomass_1.5m") #Plants_10
  plot(data[[5]][,3], type="l", xlab = "", ylab="indWeight_1.5m") #Plants_10
  plot(data[[5]][,4], type="l", xlab = "", ylab="Height_1.5m") #Plants_10
  plot(data[[5]][,2], type="l", xlab = "", ylab="Ind_1.5m") #Plants_10
  
  plot(data[[6]][,1], type="l", xlab = "", ylab="Biomass_3m") #Plants_2
  plot(data[[6]][,3], type="l", xlab = "", ylab="indWeight_3m") #Plants_2
  plot(data[[6]][,4], type="l", xlab = "", ylab="Height_3m") #Plants_2
  plot(data[[6]][,2], type="l", xlab = "", ylab="Ind_3m")
  
  plot(data[[7]][,1], type="l", xlab = "", ylab="Biomass_5m") #Plants_10
  plot(data[[7]][,3], type="l", xlab = "", ylab="indWeight_5m") #Plants_10
  plot(data[[7]][,4], type="l", xlab = "", ylab="Height_5m") #Plants_10
  plot(data[[7]][,2], type="l", xlab = "", ylab="Ind_5m") #Plants_10
  
  dev.off()
  
  setwd(run)
}



