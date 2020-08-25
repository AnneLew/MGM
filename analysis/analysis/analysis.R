#library(plyr)
#library(readr)
library(dplyr)

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
results



## Plot for all lakes & species: Environment & Macrophyte Biomass, Height & Individuums
for (i in 1:length(results)){
  setwd(results[i]) #
  myfiles <- list.files(full.names=T, pattern="*.csv")
  #print(myfiles)
  
  data <- lapply(myfiles, read.csv, header=F) #data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
  names(data) <- myfiles

 
  # for (j in 1:length(names(data))){
  #   datasub<- data[[j]]
  #   par(mfrow = c(4, 1))
  #   plot(datasub)
  # }
  
  
  ##Env
  dir.create("plots")
  setwd("./plots")
  png("Env.png",width = 480, height = 880, res = 100)
  par(mfrow = c(4, 1))
  plot(data$`./Irradiance.csv`[,1], type="l", xlab = "", ylab="Irr") #irradiance, 
  plot(data$`./lightAttenuation.csv`[,1], type="l", xlab = "", ylab="LightAtt") #lightAttenuation
  plot(data$`./Temp.csv`[,1], type="l", xlab = "", ylab="Temp") #temp
  plot(data$`./Waterlevel.csv`[,1], type="l", xlab = "", ylab="WL") #waterlevel
  dev.off()
  
  #datasub=data$`./lightAttenuation.csv`
  #ggplot(data=datasub,aes(x=as.numeric(row.names(datasub)),y=V1))+geom_line()+xlab("lightAtt")
  
  
  
  #Macrophytes
  png("superInd.png",width = 1080, height = 880, res = 100)
  par(mfrow = c(5, 6))
  # maxbiomass= 200#max(max(data[[3]][,1], na.rm = TRUE),max(data[[5]][,1], na.rm = TRUE),max(data[[4]][,1], na.rm = TRUE),max(data[[6]][,1], na.rm = TRUE))
  # maxindWeight= max(max(data[[3]][,3], na.rm = TRUE),max(data[[5]][,3], na.rm = TRUE),max(data[[4]][,3], na.rm = TRUE),max(data[[6]][,3], na.rm = TRUE))
  # maxheight=max(max(data[[3]][,4], na.rm = TRUE),max(data[[5]][,4], na.rm = TRUE),max(data[[4]][,4], na.rm = TRUE),max(data[[6]][,4], na.rm = TRUE))
  # maxind=200#max(max(data[[3]][,2], na.rm = TRUE),max(data[[5]][,2], na.rm = TRUE),max(data[[4]][,2], na.rm = TRUE),max(data[[6]][,2], na.rm = TRUE))

  plot(data$`./superInd-0.5.csv`[,1], type="l", xlab = "", ylab="Biomass_0.5m") #Plants_0.1 #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
  lines(data$`./superIndSeed-0.5.csv`[,1], col="red")
  lines(data$`./superIndTuber-0.5.csv`[,1], col="blue")
  #plot(data$`./superInd-0.5.csv`[,3], type="l", xlab = "", ylab="indWeight_0.5m") #Plants_0.1 #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
  plot(data$`./superIndTuber-0.5.csv`[,3], col="red", type="l", xlab = "", ylab="indWeight_0.5m")
  lines(data$`./superIndSeed-0.5.csv`[,3], col="blue")
  #plot(data$`./superInd-0.5.csv`[,4], type="l", xlab = "", ylab="Height_0.5m") #Plants_0.1 #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
  plot(data$`./superIndTuber-0.5.csv`[,4], col="red", type="l", xlab = "", ylab="Height_0.5m")
  lines(data$`./superIndSeed-0.5.csv`[,4], col="blue")
  plot(data$`./superInd-0.5.csv`[,2], type="l", xlab = "", ylab="Ind_0.5m") #Plants_0.1 #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
  lines(data$`./superIndSeed-0.5.csv`[,2], col="red")
  lines(data$`./superIndTuber-0.5.csv`[,2], col="blue")
  plot(data$`./seeds-0.5.csv`[,1], type="l", xlab = "", ylab="SeedBiomass_0.5m")
  plot(data$`./tubers-0.5.csv`[,1], type="l", xlab = "", ylab="TuberBiomass_0.5m")

  plot(data$`./superInd-1.0.csv`[,1], type="l", xlab = "", ylab="Biomass_1.0m") #Plants_5
  lines(data$`./superIndSeed-1.0.csv`[,1], col="red")
  lines(data$`./superIndTuber-1.0.csv`[,1], col="blue")
  #plot(data$`./superInd-1.0.csv`[,3], type="l", xlab = "", ylab="indWeight_1.0m") #Plants_5
  plot(data$`./superIndTuber-1.0.csv`[,3], col="red", type="l", xlab = "", ylab="indWeight_1.0m")
  lines(data$`./superIndSeed-1.0.csv`[,3], col="blue")
  #plot(data$`./superInd-1.0.csv`[,4], type="l", xlab = "", ylab="Height_1.0m") #Plants_5
  plot(data$`./superIndTuber-1.0.csv`[,4], col="red", type="l", xlab = "", ylab="Height_1.0m")
  lines(data$`./superIndSeed-1.0.csv`[,4], col="blue")
  plot(data$`./superInd-1.0.csv`[,2], type="l", xlab = "", ylab="Ind_1.0m") #Plants_5
  lines(data$`./superIndSeed-1.0.csv`[,2], col="red")
  lines(data$`./superIndTuber-1.0.csv`[,2], col="blue")
  plot(data$`./seeds-1.0.csv`[,1], type="l", xlab = "", ylab="SeedBiomass_1.0m")
  plot(data$`./tubers-1.0.csv`[,1], type="l", xlab = "", ylab="TuberBiomass_1.0m")
  
  plot(data$`./superInd-1.5.csv`[,1], type="l", xlab = "", ylab="Biomass_1.5m") #Plants_10
  lines(data$`./superIndSeed-1.5.csv`[,1], col="red")
  lines(data$`./superIndTuber-1.5.csv`[,1], col="blue")
  #plot(data$`./superInd-1.5.csv`[,3], type="l", xlab = "", ylab="indWeight_1.5m") #Plants_10
  plot(data$`./superIndTuber-1.5.csv`[,3], col="red", type="l", xlab = "", ylab="indWeight_1.5m")
  lines(data$`./superIndSeed-1.5.csv`[,3], col="blue")
  #plot(data$`./superInd-1.5.csv`[,4], type="l", xlab = "", ylab="Height_1.5m") #Plants_10
  plot(data$`./superIndTuber-1.5.csv`[,4], col="red", type="l", xlab = "", ylab="Height_1.5m")
  lines(data$`./superIndSeed-1.5.csv`[,4], col="blue")
  plot(data$`./superInd-1.5.csv`[,2], type="l", xlab = "", ylab="Ind_1.5m") #Plants_10
  lines(data$`./superIndSeed-1.5.csv`[,2], col="red")
  lines(data$`./superIndTuber-1.5.csv`[,2], col="blue")
  plot(data$`./seeds-1.5.csv`[,1], type="l", xlab = "", ylab="SeedBiomass_1.5m")
  plot(data$`./tubers-1.5.csv`[,1], type="l", xlab = "", ylab="TuberBiomass_1.5m")
  
  plot(data$`./superInd-3.0.csv`[,1], type="l", xlab = "", ylab="Biomass_3m") #Plants_2
  lines(data$`./superIndSeed-3.0.csv`[,1], col="red")
  lines(data$`./superIndTuber-3.0.csv`[,1], col="blue")
  #plot(data$`./superInd-3.0.csv`[,3], type="l", xlab = "", ylab="indWeight_3m") #Plants_2
  plot(data$`./superIndTuber-3.0.csv`[,3], col="red", type="l", xlab = "", ylab="indWeight_3m")
  lines(data$`./superIndSeed-3.0.csv`[,3], col="blue")
  #plot(data$`./superInd-3.0.csv`[,4], type="l", xlab = "", ylab="Height_3m") #Plants_2
  plot(data$`./superIndTuber-3.0.csv`[,4], col="red", type="l", xlab = "", ylab="Height_3m")
  lines(data$`./superIndSeed-3.0.csv`[,4], col="blue")
  plot(data$`./superInd-3.0.csv`[,2], type="l", xlab = "", ylab="Ind_3m")
  lines(data$`./superIndSeed-3.0.csv`[,2], col="red")
  lines(data$`./superIndTuber-3.0.csv`[,2], col="blue")
  plot(data$`./seeds-3.0.csv`[,1], type="l", xlab = "", ylab="SeedBiomass_3.0m")
  plot(data$`./tubers-3.0.csv`[,1], type="l", xlab = "", ylab="TuberBiomass_3.0m")
  
  plot(data$`./superInd-5.0.csv`[,1], type="l", xlab = "", ylab="Biomass_5m") #Plants_10
  lines(data$`./superIndSeed-5.0.csv`[,1], col="red")
  lines(data$`./superIndTuber-5.0.csv`[,1], col="blue")
  #plot(data$`./superInd-5.0.csv`[,3], type="l", xlab = "", ylab="indWeight_5m") #Plants_10
  plot(data$`./superIndTuber-5.0.csv`[,3], col="red", type="l", xlab = "", ylab="indWeight_5m")
  lines(data$`./superIndSeed-5.0.csv`[,3], col="blue")
  #plot(data$`./superInd-5.0.csv`[,4], type="l", xlab = "", ylab="Height_5m") #Plants_10
  plot(data$`./superIndTuber-5.0.csv`[,4], col="red", type="l", xlab = "", ylab="Height_5m")
  lines(data$`./superIndSeed-5.0.csv`[,4], col="blue")
  plot(data$`./superInd-5.0.csv`[,2], type="l", xlab = "", ylab="Ind_5m") #Plants_10
  lines(data$`./superIndSeed-5.0.csv`[,2], col="red")
  lines(data$`./superIndTuber-5.0.csv`[,2], col="blue")
  plot(data$`./seeds-5.0.csv`[,1], type="l", xlab = "", ylab="SeedBiomass_5.0m")
  plot(data$`./tubers-5.0.csv`[,1], type="l", xlab = "", ylab="TuberBiomass_5.0m")
  
  dev.off()
  
  setwd(run)
}

########### Overview Plot all data 
library(gridExtra)
library(dplyr)
library(viridis)
library(ggplot2)

setwd(run)

list<-list()
library(tidyverse)
for (i in 1:length(results)){
  setwd(results[i]) #
  myfiles <- list.files(full.names=T, pattern=glob2rx("*.csv"))
  data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
  names(data) <- myfiles
  data2<- names(data) %>% 
    str_detect('superInd-') %>%
    keep(data, .)
  day=180
  years=as.numeric(as.character(data$`./Settings.csv`[47,2]))
  #years=as.numeric(as.character(data[[8]][47,2]))
  lake=as.character(data$`./Settings.csv`[24,2])
  species=as.character(data$`./Settings.csv`[41,2])
  parameters=4
  depths=5
  extract <- array(0,
                   dim=c(years,parameters,depths),
                   dimnames = list(c(1:years),
                                   c("Biomass","Ind","indWeight","Height"),
                                   c("0.5","1.0","1.5","3.0","5.0")))
  
  for (y in 1:years){
    for (p in 1:parameters){
      for (d in 1:(depths)){
        extract[y,p,d]<-data2[[d]][,p][((y-1)*365)+day]
      }
    }
  }
  
  list[[length(list)+1]]<-extract
  setwd(run)
}

# parameters=c("biomass","Ind","indWeight","Height")
# 
# for (p in 1:length(parameters)){
#   plot_list = list()
#   for (r in 1:length(results)){
#     data=as.data.frame(list[[r]][,p,]) 
#     data=data %>% tibble::rownames_to_column("year") %>% tidyr::gather("depth",as.string(parameters[1]),2:6)
#     p<-ggplot(data, aes(x=as.numeric(year), y=parameters[1], group=depth, col=depth))+geom_line()+xlab("years")+
#       ggtitle(results[r])+scale_color_viridis_d(direction = -1, begin = 0, end=0.8)
#     plot_list[[r]] = p
#   }
# }

extract

plot_list = list()
for (r in 1:length(results)){
    data=as.data.frame(list[[r]][,1,]) 
    data=data %>% tibble::rownames_to_column("year") %>% tidyr::gather("depth","biomass",2:6)
    p<-ggplot(data, aes(x=as.numeric(year), y=biomass, group=depth, col=depth))+geom_line()+xlab("years")+
      ggtitle(results[r])+scale_color_viridis_d(direction = -1, begin = 0, end=0.8)
    plot_list[[r]] = p
}
grid.arrange(grobs = plot_list, ncol=2)
setwd(run)
png("all_biomass.png",width = 580, height = 880, res = 100)
grid.arrange(grobs = plot_list, ncol=2)
dev.off()



plot_list = list()
for (r in 1:length(results)){
  data=as.data.frame(list[[r]][,2,]) 
  data=data %>% tibble::rownames_to_column("year") %>% tidyr::gather("depth","N",2:6)
  p<-ggplot(data, aes(x=as.numeric(year), y=N, group=depth, col=depth))+geom_line()+xlab("years")+
    ggtitle(results[r])+scale_color_viridis_d(direction = -1, begin = 0, end=0.8)
  plot_list[[r]] = p
}
grid.arrange(grobs = plot_list, ncol=2)
setwd(run)
png("all_N.png",width = 580, height = 880, res = 100)
grid.arrange(grobs = plot_list, ncol=2)
dev.off()

plot_list = list()
for (r in 1:length(results)){
  data=as.data.frame(list[[r]][,3,]) 
  data=data %>% tibble::rownames_to_column("year") %>% tidyr::gather("depth","indWeight",2:6)
  p<-ggplot(data, aes(x=as.numeric(year), y=indWeight, group=depth, col=depth))+geom_line()+xlab("years")+
    ggtitle(results[r])+scale_color_viridis_d(direction = -1, begin = 0, end=0.8)
  plot_list[[r]] = p
}
grid.arrange(grobs = plot_list, ncol=2)
setwd(run)
png("all_indWeight.png",width = 580, height = 880, res = 100)
grid.arrange(grobs = plot_list, ncol=2)
dev.off()


plot_list = list()
for (r in 1:length(results)){
  data=as.data.frame(list[[r]][,4,]) 
  data=data %>% tibble::rownames_to_column("year") %>% tidyr::gather("depth","Height",2:6)
  p<-ggplot(data, aes(x=as.numeric(year), y=Height, group=depth, col=depth))+geom_line()+xlab("years")+
    ggtitle(results[r])+scale_color_viridis_d(direction = -1, begin = 0, end=0.8)
  plot_list[[r]] = p
}
grid.arrange(grobs = plot_list, ncol=2)
setwd(run)
png("all_Height.png",width = 580, height = 880, res = 100)
grid.arrange(grobs = plot_list, ncol=2)
dev.off()

