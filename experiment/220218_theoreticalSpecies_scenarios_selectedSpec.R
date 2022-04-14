## General configurations
setting = "local" # "HPC"
modelrun = "220306_experiment_scenarios_V4_Rest" #Name of experiment
years = 10 #Number of years to get simulated [n]
depths = c(-0.5, -1.5, -3.0, -5.0)
yearsoutput = 2

#species <- c(1000:2000)
#survspeclist<-"input/220213_survspeclist_base.csv" #THIS FILE MUST BE IN INPUT FOLDER!!
survspeclist<-"input/survSpec_Base_Rest_V4.csv"

#lakes <- c(1:31)
nthreads = as.character(5) #Set number of of kernels to be used in julia; max nlakes*ndepths
lakeSel = c(1:31) # Set lake IDs used for optimization
lakes = lakeSel
ndepths = length(depths)

library(data.table)
scenarios<-data.table(
  #para=c("maxTemp","maxNutrient", "maxKd"),
  base=c(0.0, 0.0, 0.0),  # TODO CHANGE!+3Temp, +100Nutr, +100Turb
  S0_m1=c(0.0,-0.25,-0.25),
  S0_1=c(0.0,0.25,0.25),
  S0_2=c(0.0,0.5,0.5),
  S1_m1=c(1.5,-0.25,-0.25),
  S1_0=c(1.5,0.0,0.0),
  S1_1=c(1.5,0.25,0.25),
  S1_2=c(1.5,0.5,0.5),
  S2_m1=c(3.0,-0.25,-0.25),
  S2_0=c(3.0,0.0,0.0),
  S2_1=c(3.0,0.25,0.25),
  S2_2=c(3.0,0.5,0.5),
  S2_N0_Tm1=c(3.0,0.0,-0.25),
  S2_N1_Tm1=c(3.0,0.25,-0.25),
  S2_Nm1_T0=c(3.0,-0.25,0.0),
  S2_N1_T0=c(3.0,0.25,0.0),
  S2_Nm1_T1=c(3.0,-0.25,0.25),
  S2_N0_T1=c(3.0,0.0,0.25) #,
  #BLIZ1=c(0.5, 0.0, 0.0),
  #BLIZ2=c(0.5, 0.25, 0.25),
  #BLIZ3=c(3.0, 0.25, 0.5)
)


# CORES
if (setting =="HPC") Sys.setenv(JULIA_NUM_THREADS = nthreads) #Sets number of threads
if (setting =="local") Sys.setenv(JULIA_NUM_THREADS = "5")

# Setup integration of julia
library(JuliaCall) 
if (setting =="local") julia_setup(JULIA_HOME = "C:\\Users\\anl85ck\\AppData\\Local\\Programs\\Julia-1.6.0\\bin",installJulia = F)
if (setting =="HPC") julia_setup(JULIA_HOME = "/home/anl85ck/.julia/bin",installJulia = F) #on HPC
julia <- julia_setup()
#julia_eval("Threads.nthreads()") #check N threads

# Load julia packages
julia_library("HCubature")
julia_library("DelimitedFiles")
julia_library("Dates")
julia_library("Distributions")
julia_library("Random")
julia_library("CSV")
julia_library("DataFrames")
julia_library("StatsBase")

# Packages
library(tidyverse)
library(DEoptim)
library(here)

# Set working directories 
if (setting =="local") {
  setwd('../')
  wd<-getwd()
  if (str_sub(wd, start= -9) != "2_Macroph") {
    print("Wrong path!")
    quit(save="no")
  }
  print(wd)
}
if (setting == "HPC"){
  wd<-here::here()
  setwd(wd)
  print(wd)
  #if (str_sub(wd, start= -9) != "2_Macroph") print("Wrong path!")
}

# Import julia functions
julia_source("model/CHARISMA_function.jl")
julia_source("model/structs.jl")
julia_source("model/defaults.jl")
julia_source("model/input.jl")
julia_source("model/functions.jl")
julia_source("model/run_simulation.jl")
julia_source("model/output.jl")


# Set species
surv_spec<-read.table(survspeclist, 
                      header = T, comment.char="#", sep=",")

NSPEC<-nrow(surv_spec)

surv_spec$ID <- c(1:NSPEC) #!! CHECK IF NECESSARY, DEPENDS ON DATA STRUCTURE
surv_spec<-surv_spec[,c(2,1)] #!! CHECK IF NECESSARY, DEPENDS ON DATA STRUCTURE

SPECsplit = 10
SPECslipN<-round(NSPEC/SPECsplit)

for (i in 1:SPECsplit){
  if(i==1){
    species_id = surv_spec[1:SPECslipN,2]
  }
  if(i==2){
    species_id = surv_spec[(SPECslipN+1):(SPECslipN*2),2]
  }
  if(i==3){
    species_id = surv_spec[(SPECslipN*2+1):(SPECslipN*3),2]
  }
  if(i==4){
    species_id = surv_spec[(SPECslipN*3+1):(SPECslipN*4),2]
  }
  if(i==5){
    species_id = surv_spec[(SPECslipN*4+1):(SPECslipN*5),2]
  }
  if(i==6){
    species_id = surv_spec[(SPECslipN*5+1):(SPECslipN*6),2]
  }
  if(i==7){
    species_id = surv_spec[(SPECslipN*6+1):(SPECslipN*7),2]
  }
  if(i==8){
    species_id = surv_spec[(SPECslipN*7+1):(SPECslipN*8),2]
  }
  if(i==9){
    species_id = surv_spec[(SPECslipN*8+1):(SPECslipN*9),2]
  }
  if(i==10){
    species_id = surv_spec[(SPECslipN*9+1):NSPEC,2]
  }
  
  #species = paste0("species_", species_id)
  species = species_id
  
  #### Setup of model input ----
  # Write general.config-file
  S1 <- c()
  for (n in 1:length(species_id)) {
    SPEC = paste("./input/species/",
                 species_id[n],
                 ".config.txt",
                 sep = "")
    S1 <- cbind(S1, SPEC)
  }
  L1 <- c()
  for (n in 1:length(lakes)) {
    LAK = paste("./input/lakes/lake_", lakes[n], ".config.txt", sep = "")
    L1 <- cbind(L1, LAK)
  }
  to_print <- c(
    paste0("modelrun ", paste0(modelrun, collapse = " ")),
    paste0("years ", paste0(years, collapse = " ")),
    paste0("depths ", paste0(depths, collapse = " ")),
    paste0("yearsoutput ", paste0(yearsoutput, collapse = " ")),
    paste0("lakes ", paste0(L1, collapse = " ")),
    paste0("species ", paste0(S1, collapse = " "))
  )
  
  writeLines(text = to_print)
  writeLines(text = to_print,
             con = paste0(wd, "/input/general.config.txt"))
  
  
  
  ## SZENARIOS LOOP
  
  for (S in 1:length(scenarios)){
    
    change<-as.array(scenarios[[S]])
    scenario_name<-colnames(scenarios)[S]
    
    for (N in 1:31){
      # Import template for lakes
      lak <- read.table(paste0(wd,"/input/template/lakes/reallakes_simplifiedVersion/lake_",N,".config.txt"), 
                        header = F, comment.char="#")
      
      lak[lak$V1=="maxTemp",]$V2 <- sprintf("%.1f",
                                            round((as.numeric(as.character(lak[lak$V1=="maxTemp",]$V2))+
                                                     change[1]),1))
      lak[lak$V1=="maxNutrient",]$V2 <- as.numeric(as.character(lak[lak$V1=="maxNutrient",]$V2))+
        (as.numeric(lak[lak$V1=="maxNutrient",]$V2) *
           change[2])
      lak[lak$V1=="maxKd",]$V2 <- as.numeric(as.character(lak[lak$V1=="maxKd",]$V2))+
        (as.numeric(as.character(lak[lak$V1=="maxKd",]$V2)) *
           change[3])
      lak[lak$V1=="minKd",]$V2 <- lak[lak$V1=="maxKd",]$V2
      
      # Write adapted lake config file
      data.table::fwrite(lak, 
                         file=paste0(wd,"/input/lakes/lake_",N,".config.txt"), 
                         col.names=F, sep = " ")
    }
    
    
    
    ###################
    # Run Model in julia
    model<-julia_eval("CHARISMA_biomass_parallel()") #? 4 depths defined in general.config.file?
    model<-as.data.table(model)
    setnames(model, c("V1","V2","V3","V4","V5","V6"), c("-0.5","-1.5","-3","-5","speciesID","lakeID"))
    
    for (d in 1:4){
      for (l in 1:dim(model)[1]){
        if(model[l,d, with=F]<1) { #if Biomass too small - not found
          model[l,d]=0
        }
      }
    }
    
    
    modelout <- melt(model, id=5:6)
    modelout$scenario<-scenario_name
    
    # OUTPUT
    if(!dir.exists("output")){dir.create("output")}
    if(!dir.exists(paste0("output/",modelrun))){dir.create(paste0("output/",modelrun))}
    data.table::fwrite(modelout, 
                       file=paste0(wd,"/output/",modelrun,"/",scenario_name,"_scenario_",i,".txt"), 
                       col.names=T, sep = " ")
    
  }
}
