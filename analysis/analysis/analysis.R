#library(plyr)
#library(readr)
library(dplyr)
library(gridExtra)
library(dplyr)
library(viridis)
library(ggplot2)
library(tidyverse)

source("C:/Users/anl85ck/Desktop/PhD/5_Macrophytes-Bavaria/3_WFD-Project/02_Themes/tidy_white_anne.R")

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

  data <- lapply(myfiles, read.csv, header=F) #data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
  names(data) <- myfiles

  #Aufteilen Data species / Data env -> dann jeweils loop
  myfilesMacroph <- list.files(full.names=T, pattern=glob2rx("superInd*.csv" ))
  myfilesReprod <- list.files(full.names=T, pattern=glob2rx("seeds|tubers*.csv" ))
  myfilesEnv <- list.files(full.names=T, pattern=glob2rx("Irradiance|lightAttenuation|Temp|Waterlevel*.csv" ))
  myfilesSetting <- list.files(full.names=T, pattern=glob2rx("Settings*.csv" ))

  
  dataMacroph <- lapply(myfilesMacroph, read.csv, header=F) #data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
  names(dataMacroph) <- myfilesMacroph
  dataReprod <- lapply(myfilesReprod, read.csv, header=F) #data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
  names(dataReprod) <- myfilesReprod
  dataEnv <- lapply(myfilesEnv, read.csv, header=F) #data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
  names(dataEnv) <- myfilesEnv
  dataSetting <- lapply(myfilesSetting, read.csv, header=F) #data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
  names(dataSetting) <- myfilesSetting

  nyears=as.numeric(as.character(data$`./Settings.csv`[45,2]))
  
  dir.create("plots")
  setwd("./plots")
  
  ##Environment
  plot_listEnv = list()
  
  for (w in 1:length(names(dataEnv))){
    message(w)
    plot_listEnv[[w]]<- local({
      w=w
      q=names(dataEnv)[w]
      datasub=as.data.frame(dataEnv[w])
      C1<-as.numeric(row.names(datasub))
      C2<-datasub[,1]
      p<-ggplot(data=datasub,aes(x=C1,y=C2))+geom_line()+ylab(q)+xlab("days") #+xlim(366,700)
      print(p)
    })
  }
  #grid.arrange(grobs = plot_listEnv, nrow=3)
  png("Environment.png",width = 1500, height = 880, res = 100)
  grid.arrange(grobs = plot_listEnv, nrow=3)
  dev.off()
  
  ##PLANTS
  #N
  plot_listMac = list()
  for (w in 1:length(names(dataMacroph))){
    message(w)
    plot_listMac[[w]]<-local({
      q=names(dataMacroph)[w]
      datasub=as.data.frame(dataMacroph[w])
      p<-ggplot(data=datasub,aes(x=as.numeric(row.names(datasub)),y=datasub[,2]))+geom_line()+
        ggtitle(q)+ylab("Number")+xlab("days")#+xlim(((nyears-1)*365+1),(nyears*365))
      print(p)
    })
  }
  #grid.arrange(grobs = plot_listMac, ncol=5)
  png("Plant_N.png",width = 1500, height = 880, res = 100)
  grid.arrange(grobs = plot_listMac, ncol=5)
  dev.off()
  
  #Biomass
  plot_listMac = list()
  for (w in 1:length(names(dataMacroph))){
    message(w)
    plot_listMac[[w]]<- local({
      w=w
      q=names(dataMacroph)[w]
      datasub=as.data.frame(dataMacroph[w])
      C1<-as.numeric(row.names(datasub))
      C2<-datasub[,1]
      p<-ggplot(data=datasub,aes(x=C1,y=C2))+geom_line()+
        ggtitle(q)+ylab("Biomass")+xlab("days")#+xlim(366,700)
      print(p)
    })
  }
  #grid.arrange(grobs = plot_listMac, ncol=5)
  png("Plant_Biomass.png",width = 1500, height = 880, res = 100)
  grid.arrange(grobs = plot_listMac, ncol=5)
  dev.off()
  
  #Height
  plot_listMac = list()
  for (w in 1:length(names(dataMacroph))){
    message(w)
    plot_listMac[[w]]<- local({
      w=w
      q=names(dataMacroph)[w]
      datasub=as.data.frame(dataMacroph[w])
      C1<-as.numeric(row.names(datasub))
      C2<-datasub[,4]
      p<-ggplot(data=datasub,aes(x=C1,y=C2))+geom_line()+
        ggtitle(q)+ylab("Height")+xlab("days")#+xlim(366,700)
      print(p)
    })
  }
  #grid.arrange(grobs = plot_listMac, ncol=5)
  png("Plant_Height.png",width = 1500, height = 880, res = 100)
  grid.arrange(grobs = plot_listMac, ncol=5)
  dev.off()
  

  ##SeedTubers
  plot_listRep = list()
  for (w in 1:length(names(dataReprod))){
    message(w)
    plot_listRep[[w]]<-local({
      w=w
      q=names(dataReprod)[w]
      datasub=as.data.frame(dataReprod[w])
      p<-ggplot(data=datasub,aes(x=as.numeric(row.names(datasub)),y=datasub[,2]))+geom_line()+
        ggtitle(q)+ylab("Number")+xlab("days")#+xlim(366,700)
      print(p)
    })
  }
  #grid.arrange(grobs = plot_listRep, ncol=5)
  png("SeedsTubers_N.png",width = 1500, height = 880, res = 100)
  grid.arrange(grobs = plot_listRep, ncol=5)
  dev.off()
  
  plot_listRep = list()
  for (w in 1:length(names(dataReprod))){
    message(w)
    plot_listRep[[w]]<-local({
      w=w
      q=names(dataReprod)[w]
      datasub=as.data.frame(dataReprod[w])
      p<-ggplot(data=datasub,aes(x=as.numeric(row.names(datasub)),y=datasub[,1]))+geom_line()+
        ggtitle(q)+ylab("Biomass")+xlab("days")#+xlim(366,700)
      print(p)
    })
  }
  #grid.arrange(grobs = plot_listRep, ncol=5)
  png("SeedsTubers_Biomass.png",width = 1500, height = 880, res = 100)
  grid.arrange(grobs = plot_listRep, ncol=5)
  dev.off()

  
  setwd(run)
}

########################################################################################################
#Plots for last year of simulation

for (i in 1:length(results)){
  setwd(results[i]) #
  
  myfiles <- list.files(full.names=T, pattern="*.csv")
  
  data <- lapply(myfiles, read.csv, header=F) #data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
  names(data) <- myfiles
  
  #Aufteilen Data species / Data env -> dann jeweils loop
  myfilesMacroph <- list.files(full.names=T, pattern=glob2rx("superInd*.csv" ))
  myfilesReprod <- list.files(full.names=T, pattern=glob2rx("seeds|tubers*.csv" ))
  myfilesEnv <- list.files(full.names=T, pattern=glob2rx("Irradiance|lightAttenuation|Temp|Waterlevel*.csv" ))
  myfilesSetting <- list.files(full.names=T, pattern=glob2rx("Settings*.csv" ))
  
  
  dataMacroph <- lapply(myfilesMacroph, read.csv, header=F) #data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
  names(dataMacroph) <- myfilesMacroph
  dataReprod <- lapply(myfilesReprod, read.csv, header=F) #data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
  names(dataReprod) <- myfilesReprod
  dataEnv <- lapply(myfilesEnv, read.csv, header=F) #data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
  names(dataEnv) <- myfilesEnv
  dataSetting <- lapply(myfilesSetting, read.csv, header=F) #data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
  names(dataSetting) <- myfilesSetting
  
  nyears=as.numeric(as.character(data$`./Settings.csv`[45,2]))
  
  dir.create("plots")
  setwd("./plots")
  
  ##Environment
  plot_listEnv = list()
  
  for (w in 1:length(names(dataEnv))){
    message(w)
    plot_listEnv[[w]]<- local({
      w=w
      q=names(dataEnv)[w]
      datasub=as.data.frame(dataEnv[w])
      C1<-as.numeric(row.names(datasub))
      C2<-datasub[,1]
      p<-ggplot(data=datasub,aes(x=C1,y=C2))+geom_line()+ylab(q)+xlab("days") #+xlim(366,700)
      print(p)
    })
  }
  #grid.arrange(grobs = plot_listEnv, nrow=3)
  png("Environment.png",width = 1500, height = 880, res = 100)
  grid.arrange(grobs = plot_listEnv, nrow=3)
  dev.off()
  
  ##PLANTS
  #N
  plot_listMac = list()
  for (w in 1:length(names(dataMacroph))){
    message(w)
    plot_listMac[[w]]<-local({
      q=names(dataMacroph)[w]
      datasub=as.data.frame(dataMacroph[w])
      p<-ggplot(data=datasub,aes(x=as.numeric(row.names(datasub)),y=datasub[,2]))+geom_line()+
        ggtitle(q)+ylab("Number")+xlab("days")+xlim(((nyears-1)*365+1),(nyears*365))
      print(p)
    })
  }
  #grid.arrange(grobs = plot_listMac, ncol=5)
  png("Plant_N_lastyearofsimulation.png",width = 1500, height = 880, res = 100)
  grid.arrange(grobs = plot_listMac, ncol=5)
  dev.off()
  
  #Biomass
  plot_listMac = list()
  for (w in 1:length(names(dataMacroph))){
    message(w)
    plot_listMac[[w]]<- local({
      w=w
      q=names(dataMacroph)[w]
      datasub=as.data.frame(dataMacroph[w])
      C1<-as.numeric(row.names(datasub))
      C2<-datasub[,1]
      p<-ggplot(data=datasub,aes(x=C1,y=C2))+geom_line()+
        ggtitle(q)+ylab("Biomass")+xlab("days")+xlim(((nyears-1)*365+1),(nyears*365))
      print(p)
    })
  }
  #grid.arrange(grobs = plot_listMac, ncol=5)
  png("Plant_Biomass_lastyearofsimulation.png",width = 1500, height = 880, res = 100)
  grid.arrange(grobs = plot_listMac, ncol=5)
  dev.off()
  
  #Height
  plot_listMac = list()
  for (w in 1:length(names(dataMacroph))){
    message(w)
    plot_listMac[[w]]<- local({
      w=w
      q=names(dataMacroph)[w]
      datasub=as.data.frame(dataMacroph[w])
      C1<-as.numeric(row.names(datasub))
      C2<-datasub[,4]
      p<-ggplot(data=datasub,aes(x=C1,y=C2))+geom_line()+
        ggtitle(q)+ylab("Height")+xlab("days")+xlim(((nyears-1)*365+1),(nyears*365))
      print(p)
    })
  }
  #grid.arrange(grobs = plot_listMac, ncol=5)
  png("Plant_Height_lastyearofsimulation.png",width = 1500, height = 880, res = 100)
  grid.arrange(grobs = plot_listMac, ncol=5)
  dev.off()
  
  
  ##SeedTubers
  plot_listRep = list()
  for (w in 1:length(names(dataReprod))){
    message(w)
    plot_listRep[[w]]<-local({
      w=w
      q=names(dataReprod)[w]
      datasub=as.data.frame(dataReprod[w])
      p<-ggplot(data=datasub,aes(x=as.numeric(row.names(datasub)),y=datasub[,2]))+geom_line()+
        ggtitle(q)+ylab("Number")+xlab("days")+xlim(((nyears-1)*365+1),(nyears*365))
      print(p)
    })
  }
  #grid.arrange(grobs = plot_listRep, ncol=5)
  png("SeedsTubers_N_lastyearofsimulation.png",width = 1500, height = 880, res = 100)
  grid.arrange(grobs = plot_listRep, ncol=5)
  dev.off()
  
  plot_listRep = list()
  for (w in 1:length(names(dataReprod))){
    message(w)
    plot_listRep[[w]]<-local({
      w=w
      q=names(dataReprod)[w]
      datasub=as.data.frame(dataReprod[w])
      p<-ggplot(data=datasub,aes(x=as.numeric(row.names(datasub)),y=datasub[,1]))+geom_line()+
        ggtitle(q)+ylab("Biomass")+xlab("days")+xlim(((nyears-1)*365+1),(nyears*365))
      print(p)
    })
  }
  #grid.arrange(grobs = plot_listRep, ncol=5)
  png("SeedsTubers_Biomass_lastyearofsimulation.png",width = 1500, height = 880, res = 100)
  grid.arrange(grobs = plot_listRep, ncol=5)
  dev.off()
  
  
  setwd(run)
}






########### Overview Plot all data 


setwd(run)
nspecies = 3

list<-list()

for (i in 1:length(results)){
  setwd(results[i]) #
  myfiles <- list.files(full.names=T, pattern=glob2rx("*.csv"))
  data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
  names(data) <- myfiles
  data2<- names(data) %>% 
    str_detect('superInd-') %>%
    keep(data, .)
  day=180
  years=as.numeric(as.character(data$`./Settings.csv`[45,2]))
  #years=as.numeric(as.character(data[[8]][47,2]))
  lake=as.character(data$`./Settings.csv`[24,2])
  species=as.character(data$`./Settings.csv`[40,2])
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
grid.arrange(grobs = plot_list, ncol=nspecies)
setwd(run)
png("all_biomass.png",width = 1280, height = 880, res = 100)
grid.arrange(grobs = plot_list, ncol=nspecies)
dev.off()



plot_list = list()
for (r in 1:length(results)){
  data=as.data.frame(list[[r]][,2,]) 
  data=data %>% tibble::rownames_to_column("year") %>% tidyr::gather("depth","N",2:6)
  p<-ggplot(data, aes(x=as.numeric(year), y=N, group=depth, col=depth))+geom_line()+xlab("years")+
    ggtitle(results[r])+scale_color_viridis_d(direction = -1, begin = 0, end=0.8)
  plot_list[[r]] = p
}
grid.arrange(grobs = plot_list, ncol=nspecies)
setwd(run)
png("all_N.png",width = 1280, height = 880, res = 100)
grid.arrange(grobs = plot_list, ncol=nspecies)
dev.off()

plot_list = list()
for (r in 1:length(results)){
  data=as.data.frame(list[[r]][,3,]) 
  data=data %>% tibble::rownames_to_column("year") %>% tidyr::gather("depth","indWeight",2:6)
  p<-ggplot(data, aes(x=as.numeric(year), y=indWeight, group=depth, col=depth))+geom_line()+xlab("years")+
    ggtitle(results[r])+scale_color_viridis_d(direction = -1, begin = 0, end=0.8)
  plot_list[[r]] = p
}
grid.arrange(grobs = plot_list, ncol=nspecies)
setwd(run)
png("all_indWeight.png",width = 1280, height = 880, res = 100)
grid.arrange(grobs = plot_list, ncol=nspecies)
dev.off()


plot_list = list()
for (r in 1:length(results)){
  data=as.data.frame(list[[r]][,4,]) 
  data=data %>% tibble::rownames_to_column("year") %>% tidyr::gather("depth","Height",2:6)
  p<-ggplot(data, aes(x=as.numeric(year), y=Height, group=depth, col=depth))+geom_line()+xlab("years")+
    ggtitle(results[r])+scale_color_viridis_d(direction = -1, begin = 0, end=0.8)
  plot_list[[r]] = p
}
grid.arrange(grobs = plot_list, ncol=nspecies)
setwd(run)
png("all_Height.png",width = 1280, height = 880, res = 100)
grid.arrange(grobs = plot_list, ncol=nspecies)
dev.off()

