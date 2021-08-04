# Optimization work flow for CHARISMA

## General configurations
setting = "local" # "HPC"
species = "species_3" # ! Adapt in general config file
lakeSel = c(1:5) # ! Adapt in general config file
ndepths = 4 # ! Adapt in general config file
parSel = c(9,15) # Set parameters that are selected: max c(1:28)
parameterspace = "parameterspace_all" # Definition of Parameterspace
iterMax = 5 # Number of Iterations for DEoptim
NPfactor = 10 # Minimum: 10
minimumBiomass = 1 # Minimum Biomass to get mapped

# Before running this script: 
# (1) Check if wd work
# (2) Adapt corresponding general.config.file
# (3) Write fixed parameters in corresponding species file!
# (4) Check general configurations above

# Packages
if (setting =="HPC") Sys.setenv(JULIA_NUM_THREADS = "60") #Gives number of of kernels to be used in julia; max nlakes*ndepths
if (setting =="local") Sys.setenv(JULIA_NUM_THREADS = "6")

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
library(data.table)
library(here)
#library(sensitivity)
#library(foreach)

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

# Import real world data
data <- data.table::fread(paste0("data/",species,".txt", sep=""), header = T) # TODO Change for Name of species
data <- data[lakeSel]


# Import parameterspace
space<-data.table::fread(paste0("input/",parameterspace,".csv"))

# Define parameter values (default values, upper and lower boundary of each parameter)
parNames <- space$V1
default <- space$V4 
names(default) <- parNames
lower <- space$V2
names(lower) <- parNames
upper <- space$V3
names(upper) <- parNames
refPar <- data.frame(default, lower, upper, row.names = parNames)

paraStart <- data.table::fread(paste0(wd,"/input/species/",species,".config.txt"), 
                          header = F)
counter=0

# Define function
likelihood = function(parameters){ #...
  counter=counter+1
  assign('counter',counter,envir = .GlobalEnv)
  print(counter)
  setwd(wd)

    # Import template for species specific parameters
    para <- data.table::fread(paste0(wd,"/input/species/",species,".config.txt"), 
                              header = F)
    
    # Replace given values with parameters of function
    to_change <- data.table(V1 = parNames[parSel], V2 = parameters)
    para[to_change, c("V1", "V2") := .(i.V1, i.V2), on = "V1"] #join of data.table
    

  # Round distinct parameters 
  roundparameters<-list("germinationDay","seedsStartAge","seedsEndAge","cThinning",
                        "maxAge","pWaveMort","pNutrient","reproDay") # [+Tuber]
  for (p in roundparameters){
    para[para$V1==p]$V2 <- round(as.numeric(para[para$V1==p]$V2))
  }
  
  # Overwrite species specific parameters 
  data.table::fwrite(para, 
                     file=paste0(wd,"/input/species/",species,".config.txt"), 
                     col.names=F, sep = " ") #TODO change name of species here? Than change also general.config
  
  # Run Model in julia
  model<-julia_eval("CHARISMA_biomass_parallel()") 
  model<-as.data.table(model)
  
  # Sort model output and real world data by lake number
  model <- setDT(model) %>% arrange(V6)
  data <- setDT(data) %>% dplyr::arrange(lakeID) 
  
  # If Biomass < 1.0g: Species is not found
  for (d in 1:ndepths){
    for (l in 1:length(lakeSel)){
      if(model[l,d, with=F]<minimumBiomass) { #if Biomass too small - not found
        model[l,d]=0
      }
    }
  }
  
  print(model)
  
  # Compare Model and Real World data
  LL_presabs=0
  for (d in 1:ndepths){
    for (l in 1:length(lakeSel)){
      if(model[l,d, with=F]==0 && data[l,d, with=F]>0) { #if observed but not predicted: penalization
        LL_presabs=LL_presabs+1
      }
      if(model[l,d, with=F]>0 && data[l,d, with=F]==0) { #if predicted, but not observed: penalization
        LL_presabs=LL_presabs+1
      }
    }
  }
  LL_presabs # Anzahl an Seen*Tiefen, wo Prdsens/Absens-Muster in dieser Tiefe nicht stimmt
  
  # DEPTH DEPENDENT CORRELATION
  # LL_corr=0
  # for (d in 1:ndepths){
  #   r=1-cor(model[,d, with=F], data[,d, with=F]^3) # Melzer
  #   if(is.na(r)) r=2
  #   LL_corr=sum(LL_corr,r, na.rm = T) 
  # }
  # LL_corr
  
  # Better alternative: DEPTH inDEPENDENT CORRELATION
  #if(LL_presabs!=0){
    LL_corr<-1-cor(c(as.matrix(model[,1:4, with=F])),
                   c(as.matrix(data[,1:4, with=F]^3)))
    if(is.na(LL_corr)) LL_corr=2
  #}

  # Sum
  #weight = (length(lakeSel) * ndepths) / (ndepths * 2) #nspecies * ndepths /8 ::: damit es maximal genau gleich ins Gewicht fdllt wie pres/abs
  weight = (length(lakeSel) * ndepths) / (2)
  
  LL = LL_presabs + LL_corr*weight 
  print(LL)
  
  return(LL)
}



#################################################################
# Optimization
lower_parameters <- lower[parSel]
upper_parameters <- upper[parSel]
NP<-length(parSel)*NPfactor

start.time <- Sys.time()

optim_param = DEoptim(fn=likelihood,
                      lower = lower_parameters, upper = upper_parameters,
                      control = list(NP=NP,itermax = iterMax)) #, method = "L-BFGS-B"; trace = FALSE,
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

if(!dir.exists("optimizer/output")){dir.create("optimizer/output")}
save(optim_param, file = here::here(paste0("optimizer/output/DEOptim_",species,"_backup.Rdata")), compress = "gzip")


# Add further information to optim_param object ---------------------------



namesparsel<-space$V1[parSel]
parafin<-paraStart
for (p in namesparsel){
  parafin[parafin$V1==p]$V2 <- optim_param$optim$bestmem[[p]]
}

optim_param$meta <- list(
  setting=setting,
  lakeSel=lakeSel,
  parSel=parSel,
  namesparsel=namesparsel,
  parameterspace=parameterspace,
  #iterMax=iterMax,
  parafin =parafin, #All parameters with best value
  space=space
)

save(optim_param, file = here::here(paste0("optimizer/output/DEOptim_",species,"_complete.Rdata")), compress = "gzip")

