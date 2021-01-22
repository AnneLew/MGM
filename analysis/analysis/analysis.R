### Script to analyse output data of light version of Charisma in Julia

#Load packages
library(dplyr)
library(gridExtra)
library(dplyr)
library(viridis)
library(ggplot2)
library(tidyverse)

# Load design settings
source("C:/Users/anl85ck/Desktop/PhD/5_Macrophytes-Bavaria/3_WFD-Project/02_Themes/tidy_white_anne.R")

# Set WD
setwd("C:/Users/anl85ck/Desktop/PhD/4_Modellierung/2_CHARISMA/2_Macroph/output")

# Give start information (TODO noch zu automatisieren!)
nspecies = 20
nyears = 50
depths = 4
nlakes = 1

# Set type of whished analysis
alllakes_indivplots = T #takes long
alllakes_lastyear = T # takes long
overviewplot =T #use for not so many datasets
overviewplot_lastyear = T
overviewplot_lastyear_newfolder_multipleplots = T
overviewplot_lastyear_newfolder_overviewplot = T
parameters_specspec = T 

# Import data
modelruns<-list.dirs(recursive = F)
details = file.info(modelruns)
details = details[with(details, order(as.POSIXct(mtime))), ]
modelruns = rownames(details)

setwd(modelruns[length(modelruns)]) #takes the run you whish
#setwd(modelruns[length(modelruns)]) #takes the last modelrun
run<-getwd()
run
results<-list.dirs(recursive = F)
results
results <- results[ !grepl("./plots", results) ]


#Overview setting spec spec
if (parameters_specspec==T){
  
  extract <- array(0.0,
                   dim=c(76,length(results)))
  
  for (i in 1:length(results)){
    setwd(results[i]) #
    
    myfiles <- list.files(full.names=T, pattern="*.csv")
    
    data <- lapply(myfiles, read.csv, header=F) #data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
    names(data) <- myfiles
    
    #Aufteilen Data species / Data env -> dann jeweils loop
    myfilesSetting <- list.files(full.names=T, pattern=glob2rx("Settings*.csv" ))
    dataSetting <- lapply(myfilesSetting, read.csv, header=F) #data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
    names(dataSetting) <- myfilesSetting
    
    myfilesMacroph <- list.files(full.names=T, pattern=glob2rx("superInd*.csv" ))
    #myfilesReprod <- list.files(full.names=T, pattern=glob2rx("seeds|tubers*.csv" ))
    #myfilesEnv <- list.files(full.names=T, pattern=glob2rx("Irradiance|lightAttenuation|Temp|Waterlevel*.csv" ))
    dataMacroph <- lapply(myfilesMacroph, read.csv, header=F) #data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
    names(dataMacroph) <- myfilesMacroph
    #dataReprod <- lapply(myfilesReprod, read.csv, header=F) #data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
    #names(dataReprod) <- myfilesReprod
    #dataEnv <- lapply(myfilesEnv, read.csv, header=F) #data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
    #names(dataEnv) <- myfilesEnv
    
    extract[1:68,i]<-as.character(dataSetting$`./Settings.csv`$V2)
    
    extract[69,i]<-dataMacroph$`./superInd-0.5.csv`$V1[(((nyears-1)*365)+265)] 
    extract[70,i]<-dataMacroph$`./superInd-1.5.csv`$V1[(((nyears-1)*365)+265)]
    extract[71,i]<-dataMacroph$`./superInd-3.0.csv`$V1[(((nyears-1)*365)+265)]
    extract[72,i]<-dataMacroph$`./superInd-5.0.csv`$V1[(((nyears-1)*365)+265)]
    
    extract[73,i]<-dataMacroph$`./superInd-0.5.csv`$V2[(((nyears-1)*365)+265)] 
    extract[74,i]<-dataMacroph$`./superInd-1.5.csv`$V2[(((nyears-1)*365)+265)]
    extract[75,i]<-dataMacroph$`./superInd-3.0.csv`$V2[(((nyears-1)*365)+265)]
    extract[76,i]<-dataMacroph$`./superInd-5.0.csv`$V2[(((nyears-1)*365)+265)]
    setwd(run)
  }
  settings<-as.data.frame(extract)
  rnames1<-as.character(dataSetting$`./Settings.csv`$V1)
  rnames2<-c("Biomass_0.5","Biomass_1.5","Biomass_3.0","Biomass_5.0")
  rnames3<-c("N_0.5","N_1.5","N_3.0","N_5.0")
  rnames<-c(rnames1,rnames2,rnames3)
  rownames(settings)<-rnames

  settings_t<-as.data.frame(t(settings))
  settings_t$Lake<-as.character(settings_t$Lake)
  settings_t$Species<-as.character(settings_t$Species)
  
  
  indx <- sapply(settings_t, is.factor)
  settings_t[indx] <- lapply(settings_t[indx], function(x) as.numeric(as.character(x)))
  
  settings_t$Lake<-as.factor(settings_t$Lake)
  settings_t$Species<-as.factor(settings_t$Species)
  
  settings_t<-settings_t %>% mutate(Biomass=Biomass_0.5+Biomass_1.5+Biomass_3.0+Biomass_5.0)
  settings_t<-settings_t %>% mutate(Biomass_cat=ifelse(Biomass==0,0,1))
  
  settings_t_species <- settings_t %>% distinct(Species,.keep_all = TRUE)
  settings_t_lake <- settings_t %>% distinct(Lake,.keep_all = TRUE)
  
  surv_spec<-settings_t %>% filter(Biomass_cat!=0) %>% distinct(Species)
  surv_spec
  
  as.array(surv_spec$Species)
  
  surv_spec_dataset<-settings_t %>% filter(Species %in% as.array(surv_spec$Species))
  
  surv_spec_dataset %>% select(Lake, Species, Biomass) %>% spread(Species, Biomass)
  
  surv_spec_dataset %>% select(Lake, Species, Biomass_5.0) %>% spread(Species, Biomass_5.0)
  
  surv_spec_dataset %>% select(Lake, Species, N_0.5) %>% spread(Species, N_0.5)  
  surv_spec_dataset %>% select(Lake, Species, N_1.5) %>% spread(Species, N_1.5)
  surv_spec_dataset %>% select(Lake, Species, N_5.0) %>% spread(Species, N_5.0)
  
  ggplot(settings_t,aes(y=cThinning, group=Biomass_cat, x=Biomass_cat))+
    geom_boxplot()+
    geom_jitter()
  
  ggplot(settings_t,aes(y=minTemp, group=Biomass_cat, x=Biomass_cat))+
    geom_boxplot()+
    geom_jitter()
  
  ggplot(settings_t, aes(x=minTemp, y=maxTemp))+
    geom_point(aes(color=Biomass,x=minTemp, y=maxTemp))+facet_grid(~Biomass_cat)
  
  ggplot(settings_t, aes(x=minI, y=maxI))+
    geom_point(aes(color=Biomass))+facet_grid(~Biomass_cat)
  
  ggplot(settings_t, aes(x=cThinning, y=reproDay))+
    geom_point(aes(color=Biomass))+facet_grid(~Biomass_cat)
  
  ggplot(settings_t, aes(x=pMax, y=resp20))+
    geom_point(aes(color=Biomass))+facet_grid(~Biomass_cat)
  
  ggplot(settings_t, aes(x=seedsStartAge, y=seedsEndAge))+
    geom_point(aes(color=Biomass))+facet_grid(~Biomass_cat)
  
  ggplot(settings_t, aes(x=tuberStartAge, y=tuberEndAge))+
    geom_point(aes(color=Biomass))+facet_grid(~Biomass_cat)
  
  ggplot(settings_t, aes(x=heightMax, y=q10))+
    geom_point(aes(color=Biomass))+facet_grid(~Biomass_cat)
  
  ggplot(settings_t, aes(x=maxWeightLenRatio, y=rootShootRatio))+
    geom_point(aes(color=Biomass))+facet_grid(~Biomass_cat)
  
  ggplot(settings_t, aes(x=hPhotoLight, y=hPhotoTemp))+
    geom_point(aes(color=Biomass))+facet_grid(~Biomass_cat)
  
  ggplot(settings_t, aes(x=sPhotoTemp, y=pPhotoTemp))+
    geom_point(aes(color=Biomass))+facet_grid(~Biomass_cat)
  
  ggplot(settings_t, aes(x=hWaveMort, y=maxWaveMort))+
    geom_point(aes(color=Biomass))+facet_grid(~Biomass_cat)
  
  ggplot(settings_t, aes(x=pWaveMort, y=maxWaveMort))+
    geom_point(aes(color=Biomass))+facet_grid(~Biomass_cat)
  
  ggplot(settings_t, aes(x=pNutrient, y=hNutrient))+
    geom_point(aes(color=Biomass))+facet_grid(~Biomass_cat)
  
  ggplot(settings_t, aes(x=maxNutrient, y=hNutrient))+
    geom_point(aes(color=Biomass))+facet_grid(~Biomass_cat)
  
  ggplot(settings_t, aes(x=germinationDay, y=reproDay))+
    geom_point(aes(color=Biomass))+facet_grid(~Biomass_cat)
  
  ggplot(settings_t, aes(x=seedBiomass, y=seedFraction))+
    geom_point(aes(color=Biomass))+facet_grid(~Biomass_cat)
  
  ggplot(settings_t, aes(x=seedGermination, y=seedFraction))+
    geom_point(aes(color=Biomass))+facet_grid(~Biomass_cat)
  
  ggplot(settings_t, aes(x=tuberBiomass, y=tuberFraction))+
    geom_point(aes(color=Biomass))+facet_grid(~Biomass_cat)
  
  ggplot(settings_t, aes(x=tuberGerminationDay, y=tuberFraction))+
    geom_point(aes(color=Biomass))+facet_grid(~Biomass_cat)
  
  ggplot(settings_t, aes(x=pPhotoTemp, y=q10))+
    geom_point(aes(color=Biomass))+facet_grid(~Biomass_cat)
  
  mean(settings_t_lake$maxTemp)
  mean(settings_t_species$cThinning)
  
  
}





# Plot for all lakes & species: Environment & Macrophyte Biomass, Height & Individuums
if (alllakes_indivplots == T){

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
  
    #nyears=as.numeric(as.character(data$`./Settings.csv`[45,2]))
  
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
    grid.arrange(grobs = plot_listMac, ncol=depths)
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
    grid.arrange(grobs = plot_listMac, ncol=depths)
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
    grid.arrange(grobs = plot_listMac, ncol=depths)
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
    grid.arrange(grobs = plot_listRep, ncol=depths)
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
    grid.arrange(grobs = plot_listRep, ncol=depths)
    dev.off()
  
  
    setwd(run)
  }
}

########################################################################################################
#Plots for last year of simulation
if (alllakes_lastyear = T){
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
    
    #nyears=as.numeric(as.character(data$`./Settings.csv`[45,2]))
    
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
    grid.arrange(grobs = plot_listMac, ncol=depths)
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
    grid.arrange(grobs = plot_listMac, ncol=depths)
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
    grid.arrange(grobs = plot_listMac, ncol=depths)
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
    grid.arrange(grobs = plot_listRep, ncol=depths)
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
    grid.arrange(grobs = plot_listRep, ncol=depths)
    dev.off()
    
    
    setwd(run)
  }
}





########### Overview Plot all data 

#Set directory
setwd(run)

#Initialisation
list<-list()

#Extract data
for (i in 1:length(results)){
  setwd(results[i]) #
  myfiles <- list.files(full.names=T, pattern=glob2rx("*.csv"))
  data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
  names(data) <- myfiles
  data2<- names(data) %>% 
    str_detect('superInd-') %>%
    keep(data, .)
  day=214 #First of August

  lake=as.character(data$`./Settings.csv`[25,2]) #Fehleranf?llig!
  species=as.character(data$`./Settings.csv`[41,2])  #Fehleranf?llig!
  parameters=4

  extract <- array(0,
                   dim=c(nyears,parameters,depths),
                   dimnames = list(c(1:nyears),
                                   c("Biomass","Ind","indWeight","Height"),
                                   c("0.5","1.5","3.0","5.0")))
  
  for (y in 1:nyears){
    for (p in 1:parameters){
      for (d in 1:(depths)){
        extract[y,p,d]<-data2[[d]][,p][((y-1)*365)+day]
      }
    }
  }
  
  list[[length(list)+1]]<-extract
  setwd(run)
}

if (overviewplot == T){
  #Biomass plot 
  plot_list = list()
  for (r in 1:length(results)){
      data=as.data.frame(list[[r]][,1,]) 
      data=data %>% tibble::rownames_to_column("year") %>% tidyr::gather("depth","biomass",2:5)
      p<-ggplot(data, aes(x=as.numeric(year), y=biomass, group=depth, col=depth))+geom_line()+xlab("years")+
        ggtitle(results[r])+scale_color_viridis_d(direction = -1, begin = 0, end=0.8)
      plot_list[[r]] = p
  }
  grid.arrange(grobs = plot_list, ncol=nspecies)#nspecies)
  setwd(run)
  png("all_biomass.png",width = 1280, height = 1580, res = 100)
  grid.arrange(grobs = plot_list, ncol=nspecies)#nspecies)
  dev.off()
  
  
  #N plot
  plot_list = list()
  for (r in 1:length(results)){
    data=as.data.frame(list[[r]][,2,]) 
    data=data %>% tibble::rownames_to_column("year") %>% tidyr::gather("depth","N",2:5)
    p<-ggplot(data, aes(x=as.numeric(year), y=N, group=depth, col=depth))+geom_line()+xlab("years")+
      ggtitle(results[r])+scale_color_viridis_d(direction = -1, begin = 0, end=0.8)
    plot_list[[r]] = p
  }
  grid.arrange(grobs = plot_list, ncol=nspecies)#nspecies)
  setwd(run)
  png("all_N.png",width = 1280, height = 1580, res = 100)
  grid.arrange(grobs = plot_list, ncol=nspecies)#nspecies)
  dev.off()
  
  #indWeight plot 
  plot_list = list()
  for (r in 1:length(results)){
    data=as.data.frame(list[[r]][,3,]) 
    data=data %>% tibble::rownames_to_column("year") %>% tidyr::gather("depth","indWeight",2:5)
    p<-ggplot(data, aes(x=as.numeric(year), y=indWeight, group=depth, col=depth))+geom_line()+xlab("years")+
      ggtitle(results[r])+scale_color_viridis_d(direction = -1, begin = 0, end=0.8)
    plot_list[[r]] = p
  }
  grid.arrange(grobs = plot_list, ncol=nspecies)
  setwd(run)
  png("all_indWeight.png",width = 1280, height = 1580, res = 100)
  grid.arrange(grobs = plot_list, ncol=nspecies)
  dev.off()
  
  #Height plot 
  plot_list = list()
  for (r in 1:length(results)){
    data=as.data.frame(list[[r]][,4,]) 
    data=data %>% tibble::rownames_to_column("year") %>% tidyr::gather("depth","Height",2:5)
    p<-ggplot(data, aes(x=as.numeric(year), y=Height, group=depth, col=depth))+geom_line()+xlab("years")+
      ggtitle(results[r])+scale_color_viridis_d(direction = -1, begin = 0, end=0.8)
    plot_list[[r]] = p
  }
  grid.arrange(grobs = plot_list, ncol=nspecies)
  setwd(run)
  png("all_Height.png",width = 1280, height = 1580, res = 100)
  grid.arrange(grobs = plot_list, ncol=nspecies)
  dev.off()

}
#########################################################################################################
#########################################################################################################
#########################################################################################################



source("C:/Users/anl85ck/Desktop/PhD/5_Macrophytes-Bavaria/3_WFD-Project/02_Themes/tidy_white_anne.R")

# Set WD
setwd("C:/Users/anl85ck/Desktop/PhD/4_Modellierung/2_CHARISMA/2_Macroph/output")



# Import data
modelruns<-list.dirs(recursive = F)
details = file.info(modelruns)
details = details[with(details, order(as.POSIXct(mtime))), ]
modelruns = rownames(details)

setwd(modelruns[length(modelruns)]) #takes the last modelrun
run<-getwd()
run
results<-list.dirs(recursive = F)
results
#########################################################################################################
#########################################################################################################
#########################################################################################################


################################### LASTYEAR

  
#Set directory
setwd(run)

#Initialisation
list<-list()

#Extract data
for (i in 1:length(results)){
  setwd(results[i]) #
  myfiles <- list.files(full.names=T, pattern=glob2rx("*.csv"))
  data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
  names(data) <- myfiles
  data2<- names(data) %>% 
    str_detect('superInd-') %>%
    keep(data, .)
  day=245 #214 1st of August / 245 1st of Sept
  
  lake=as.character(data$`./Settings.csv`[25,2]) #Fehleranf?llig!
  species=as.character(data$`./Settings.csv`[42,2])  #Fehleranf?llig!
  parameters=4
  
  extract <- array(0,
                   dim=c(nyears,parameters,depths),
                   dimnames = list(c(1:nyears),
                                   c("Biomass","Ind","indWeight","Height"),
                                   c("0.5","1.5","3.0","5.0"))) ###!!!!
  
  for (y in 1:nyears){
    for (p in 1:parameters){
      for (d in 1:(depths)){
        extract[y,p,d]<-data2[[d]][,p][((y-1)*365)+day]
      }
    }
  }
  
  list[[length(list)+1]]<-extract[nyears,,]
  setwd(run)
}

if(overviewplot_lastyear==T){
  
  
  
  #Biomass plot 
  plot_list = list()
  MAX<-max(unlist(lapply(list, `[`, 1,)))
  
  for (r in 1:length(results)){
    data=as.data.frame(list[[r]][1,]) %>% tibble::rownames_to_column("Depth")
    data=data %>% rename(biomass="list[[r]][1, ]")#%>% tidyr::gather("depth","biomass")
    p<-ggplot(data, aes(x=as.numeric(Depth), y=biomass,group = 1))+
      geom_line()+xlab("depth")+ggtitle(results[r])+ylim(0, MAX)
    plot_list[[r]] = p
  }
  grid.arrange(grobs = plot_list, ncol=nspecies)#nspecies)
  setwd(run)
  png("FirstofSept_biomass.png",width = 1280, height = 880, res = 100)
  grid.arrange(grobs = plot_list, ncol=nspecies)#nspecies)
  dev.off()
  
  #N plot 
  plot_list = list()
  MAX<-max(unlist(lapply(list, `[`, 2,)))
  
  for (r in 1:length(results)){
    data=as.data.frame(list[[r]][2,]) %>% tibble::rownames_to_column("Depth")
    data=data %>% rename(N="list[[r]][2, ]")#%>% tidyr::gather("depth","biomass")
    p<-ggplot(data, aes(x=as.numeric(Depth), y=N,group = 1))+
      geom_line()+xlab("depth")+ggtitle(results[r])+ylim(0, MAX)
    plot_list[[r]] = p
  }
  grid.arrange(grobs = plot_list, ncol=nspecies)#nspecies)
  setwd(run)
  png("FirstofSept_N.png",width = 1280, height = 880, res = 100)
  grid.arrange(grobs = plot_list, ncol=nspecies)#nspecies)
  dev.off()
  
  #IndWeight plot 
  plot_list = list()
  MAX<-max(unlist(lapply(list, `[`, 3,)))
  
  for (r in 1:length(results)){
    data=as.data.frame(list[[r]][3,]) %>% tibble::rownames_to_column("Depth")
    data=data %>% rename(indWeight="list[[r]][3, ]")#%>% tidyr::gather("depth","biomass")
    p<-ggplot(data, aes(x=as.numeric(Depth), y=indWeight,group = 1))+
      geom_line()+xlab("depth")+ggtitle(results[r])+ylim(0, MAX)
    plot_list[[r]] = p
  }
  grid.arrange(grobs = plot_list, ncol=nspecies)#)
  setwd(run)
  png("FirstofSept_indWeight.png",width = 1280, height = 880, res = 100)
  grid.arrange(grobs = plot_list, ncol=nspecies)#nspecies)
  dev.off()
  
  
  #Height plot 
  plot_list = list()
  MAX<-max(unlist(lapply(list, `[`, 4,)))
  
  for (r in 1:length(results)){
    data=as.data.frame(list[[r]][4,]) %>% tibble::rownames_to_column("Depth")
    data=data %>% rename(Height="list[[r]][4, ]")#%>% tidyr::gather("depth","biomass")
    p<-ggplot(data, aes(x=as.numeric(Depth), y=Height,group = 1))+
      geom_line()+xlab("depth")+ggtitle(results[r])+ylim(0, MAX)
    plot_list[[r]] = p
  }
  grid.arrange(grobs = plot_list, ncol=nspecies)#nspecies)
  setwd(run)
  png("FirstofSept_Height.png",width = 1280, height = 880, res = 100)
  grid.arrange(grobs = plot_list, ncol=nspecies)#nspecies)
  dev.off()
  
}















################################### LASTYEAR IN INDIVIDUAL FOLDERDS

if (overviewplot_lastyear_newfolder_multipleplots == T){
  
  #Set directory
  setwd(run)
  
  #Initialisation
  list<-list()
  
  #Extract data
  for (i in 1:length(results)){
    setwd(results[i]) #
    myfiles <- list.files(full.names=T, pattern=glob2rx("*.csv"))
    data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
    names(data) <- myfiles
    data2<- names(data) %>% 
      str_detect('superInd-') %>%
      keep(data, .)
    day=245 #214 1st of August / 245 1st of Sept
    
    lake=as.character(data$`./Settings.csv`[25,2]) #Fehleranf?llig!
    species=as.character(data$`./Settings.csv`[42,2])  #Fehleranf?llig!
    parameters=4
    
    extract <- array(0,
                     dim=c(nyears,parameters,depths),
                     dimnames = list(c(1:nyears),
                                     c("Biomass","Ind","indWeight","Height"),
                                     c("0.5","1.5","3.0","5.0"))) ###!!!!
    
    for (y in 1:nyears){
      for (p in 1:parameters){
        for (d in 1:(depths)){
          extract[y,p,d]<-data2[[d]][,p][((y-1)*365)+day]
        }
      }
    }
    
    list[[length(list)+1]]<-extract[nyears,,]
    setwd(run)
  }
  setwd(run)
  dir.create("plots")
  setwd("./plots")
  
  #Biomass plot 
  plot_list = list()
  MAX<-max(unlist(lapply(list, `[`, 1,)))
  
  for (r in 1:length(results)){
    data=as.data.frame(list[[r]][1,]) %>% tibble::rownames_to_column("Depth")
    data=data %>% rename(biomass="list[[r]][1, ]")#%>% tidyr::gather("depth","biomass")
    p<-ggplot(data, aes(x=as.numeric(Depth), y=biomass,group = 1))+
      geom_line()+xlab("depth")+ggtitle(results[r])+ylim(0, MAX)
  
    png(paste(results[r],"biomass.png",sep="_"),width = 1280, height = 880, res = 100)
    plot(p)
    dev.off()
  }
  
  
  
  
  #N plot 
  plot_list = list()
  MAX<-max(unlist(lapply(list, `[`, 2,)))
  
  for (r in 1:length(results)){
    data=as.data.frame(list[[r]][2,]) %>% tibble::rownames_to_column("Depth")
    data=data %>% rename(N="list[[r]][2, ]")#%>% tidyr::gather("depth","biomass")
    p<-ggplot(data, aes(x=as.numeric(Depth), y=N,group = 1))+
      geom_line()+xlab("depth")+ggtitle(results[r])+ylim(0, MAX)
    png(paste(results[r],"N.png",sep="_"),width = 1280, height = 880, res = 100)
    plot(p)
    dev.off()
  }
  
  
  #IndWeight plot 
  
  MAX<-max(unlist(lapply(list, `[`, 3,)))
  
  for (r in 1:length(results)){
    data=as.data.frame(list[[r]][3,]) %>% tibble::rownames_to_column("Depth")
    data=data %>% rename(indWeight="list[[r]][3, ]")#%>% tidyr::gather("depth","biomass")
    p<-ggplot(data, aes(x=as.numeric(Depth), y=indWeight,group = 1))+
      geom_line()+xlab("depth")+ggtitle(results[r])+ylim(0, MAX)
    png(paste(results[r],"indWeight.png",sep="_"),width = 1280, height = 880, res = 100)
    plot(p)
    dev.off()
  }
  
  
  #Height plot 
  
  MAX<-max(unlist(lapply(list, `[`, 4,)))
  
  for (r in 1:length(results)){
    data=as.data.frame(list[[r]][4,]) %>% tibble::rownames_to_column("Depth")
    data=data %>% rename(Height="list[[r]][4, ]")#%>% tidyr::gather("depth","biomass")
    p<-ggplot(data, aes(x=as.numeric(Depth), y=Height,group = 1))+
      geom_line()+xlab("depth")+ggtitle(results[r])+ylim(0, MAX)
    png(paste(results[r],"height.png",sep="_"),width = 1280, height = 880, res = 100)
    plot(p)
    dev.off()
  }
}

################################### LASTYEAR IN INDIVIDUAL FOLDER, but same plot
if (overviewplot_lastyear_newfolder_overviewplot==T){
  #Set directory
  setwd(run)
  
  #Initialisation
  list<-list()
  
  #Extract data
  for (i in 1:length(results)){
    setwd(results[i]) #
    myfiles <- list.files(full.names=T, pattern=glob2rx("*.csv"))
    data<-lapply(myfiles, function(x) read.csv(file=x, header=F))
    names(data) <- myfiles
    data2<- names(data) %>% 
      str_detect('superInd-') %>%
      keep(data, .)
    day=245 #214 1st of August / 245 1st of Sept
    
    lake=as.character(data$`./Settings.csv`[25,2]) #Fehleranf?llig!
    species=as.character(data$`./Settings.csv`[42,2])  #Fehleranf?llig!
    parameters=4
    
    extract <- array(0,
                     dim=c(nyears,parameters,depths),
                     dimnames = list(c(1:nyears),
                                     c("Biomass","Ind","indWeight","Height"),
                                     c("0.5","1.5","3.0","5.0"))) ###!!!!
    
    for (y in 1:nyears){
      for (p in 1:parameters){
        for (d in 1:(depths)){
          extract[y,p,d]<-data2[[d]][,p][((y-1)*365)+day]
        }
      }
    }
    
    list[[length(list)+1]]<-extract[nyears,,]
    setwd(run)
  }
  setwd(run)
  dir.create("plots")
  setwd("./plots")
  
  ###Biomass plot 
  #plot_list = list()
  MAX<-max(unlist(lapply(list, `[`, 1,)))
  
  #empty ggplot
  df <- data.frame()
  plt<-ggplot(df) + geom_point()+ylim(0, MAX)+ylab("Biomass")
  
  # dataframe
  dataframe<-matrix(nrow=4, ncol=length(results))
  for (r in 1:length(results)){
    dataframe[,r]<-list[[r]][1,] #
  }
  dataset<-as.data.frame(dataframe)%>% tibble::rownames_to_column("Depth")
  
  #Plot
  Depth<-c(-0.5,-1.5,-3.0,-5.0)
  colNames <- names(dataset)[2:length(dataset)]
  for(i in colNames){
    plt <- plt+
      geom_line(data=dataset, mapping=aes_string(x=-Depth, y = i))# +
  }
  print(plt)
  
  png("biomass.png",width = 1280, height = 880, res = 100)
  plot(plt)
  dev.off()
  
  
  
  #N plot 
  #plot_list = list()
  MAX<-max(unlist(lapply(list, `[`, 2,)))
  
  #empty ggplot
  df <- data.frame()
  plt<-ggplot(df) + geom_point()+ylim(0, MAX)+ylab("N")
  
  # dataframe
  dataframe<-matrix(nrow=4, ncol=length(results))
  for (r in 1:length(results)){
    dataframe[,r]<-list[[r]][2,] #
  }
  dataset<-as.data.frame(dataframe)%>% tibble::rownames_to_column("Depth")
  
  #Plot
  Depth<-c(-0.5,-1.5,-3.0,-5.0)
  colNames <- names(dataset)[2:length(dataset)]
  for(i in colNames){
    plt <- plt+
      geom_line(data=dataset, mapping=aes_string(x=-Depth, y = i))# +
  }
  print(plt)
  
  png("N.png",width = 1280, height = 880, res = 100)
  plot(plt)
  dev.off()
  
  
  #IndWeight plot 
  #plot_list = list()
  MAX<-max(unlist(lapply(list, `[`, 3,)))
  
  #empty ggplot
  df <- data.frame()
  plt<-ggplot(df) + geom_point()+ylim(0, MAX)+ylab("indWeight")
  
  # dataframe
  dataframe<-matrix(nrow=4, ncol=length(results))
  for (r in 1:length(results)){
    dataframe[,r]<-list[[r]][3,] #
  }
  dataset<-as.data.frame(dataframe)%>% tibble::rownames_to_column("Depth")
  
  #Plot
  Depth<-c(-0.5,-1.5,-3.0,-5.0)
  colNames <- names(dataset)[2:length(dataset)]
  for(i in colNames){
    plt <- plt+
      geom_line(data=dataset, mapping=aes_string(x=-Depth, y = i))# +
  }
  print(plt)
  
  png("indWeight.png",width = 1280, height = 880, res = 100)
  plot(plt)
  dev.off()
  
  
  
  #Height plot 
  #plot_list = list()
  MAX<-max(unlist(lapply(list, `[`, 4,)))
  
  #empty ggplot
  df <- data.frame()
  plt<-ggplot(df) + geom_point()+ylim(0, MAX)+ylab("Height")
  
  # dataframe
  dataframe<-matrix(nrow=4, ncol=length(results))
  for (r in 1:length(results)){
    dataframe[,r]<-list[[r]][4,] #
  }
  dataset<-as.data.frame(dataframe)%>% tibble::rownames_to_column("Depth")
  
  #Plot
  Depth<-c(-0.5,-1.5,-3.0,-5.0)
  colNames <- names(dataset)[2:length(dataset)]
  for(i in colNames){
    plt <- plt+
      geom_line(data=dataset, mapping=aes_string(x=-Depth, y = i))# +
  }
  print(plt)
  
  png("height.png",width = 1280, height = 880, res = 100)
  plot(plt)
  dev.off()
  
  ##How many are just zeros per depth? 
  rowSums(dataset == 0)
  rowSums(dataset != 0) #has results
}

