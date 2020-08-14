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

########### Overview Plot all data 
library(gridExtra)
library(dplyr)
library(viridis)

setwd(run)

list<-list()

for (i in 1:length(results)){
  setwd(results[i]) #
  myfiles <- list.files(full.names=T, pattern="*.csv")
  data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
  day=180
  years=as.numeric(as.character(data[[8]][41,2]))
  lake=as.character(data[[8]][21,2])
  species=as.character(data[[8]][36,2])
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
        extract[y,p,d]<-data[[d+2]][,p][((y-1)*365)+day]
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

