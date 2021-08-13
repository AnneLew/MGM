# Morris screening work flow for CHARISMA

## General configurations
setting = "local" # "HPC"
species = "species_3" #Adapt in general config file
lakeSel = c(1:15) #Adapt in general config file
parSel = c(1:28) # Set parameters that are selected: max c(1:28); test: c(3,4,5,6,9,15,27)
parameterspace = "parameterspace_all"
minimumBiomass = 1

# Before running this script: 
# (1) Check if wd work
# (2) Adapt corresponding general.config.file
# (3) Write fixed parameters in corresponding species file!
# (4) Check general configurations above

# Packages
if (setting =="HPC") Sys.setenv(JULIA_NUM_THREADS = "60") #"6" Gives number of of kernels to be used in julia; max nlakes*ndepths
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
library(sensitivity)
library(foreach)

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
  if (str_sub(wd, start= -9) != "2_Macroph") print("Wrong path!")
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
data<-data.table::fread(paste0("data/",species,".txt", sep=""), header = F) # TODO Change for Name of species
data <- data[lakeSel]
ndepths <- 4

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


# Define function
likelihood = function(...){ #...
  setwd(wd)
  changedparameter <- list(...) #...
  
  # Import template for species specific parameters
  para <- data.table::fread(paste0(wd,"/input/species/",species,".config.txt"), 
                            header = F)
  
  # Replace given values with parameters of function
  for (p in names(changedparameter)){
    para[para$V1==p]$V2 <- changedparameter[[p]]
  }
  
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
  data <- setDT(data) %>% dplyr::arrange(V6) 
  
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
  #print(LL)
  return(LL)
}

#likelihood(pMax=0.3, resp20=0.00193)

sensitivityTarget <- function(parameters){
  # copy default values of the parameter
  x = refPar$default
  # change parameter
  x[parSel] = parameters
  # run model
  LL<-likelihood(
    cThinning=x[1],
    germinationDay=x[2],
    hNutrient=x[3],
    hPhotoLight=x[4],
    hPhotoTemp=x[5],
    hWaveMort=x[6],
    maxAge=x[7],
    maxWaveMort=x[8],
    pMax=x[9],#9
    pNurtient=x[10],
    pPhotoTemp=x[11],
    pWaveMort=x[12],
    q10=x[13],
    reproDay=x[14],
    resp20=x[15],#15
    seedBiomass=x[16],
    seedFraction=x[17],
    seedsStartAge=x[18],
    seedsEndAge=x[19],
    sPhotoTemp=x[20],
    seedGermination=x[21],
    cTuber=x[22],
    heightMax=x[23],
    maxWeightLenRatio=x[24],
    rootShootRatio=x[25],
    fracPeriphyton=x[26],
    hPhotoDist=x[27],
    plantK=x[28],
    Kohler5=x[29] #21
  )
  print(x)
  print(LL)
  return(LL)
}


#try(sensitivityTarget("pMax"), silent=TRUE)


##############################
targetFunction <- function(parmatrix) {
  apply(parmatrix, 1, sensitivityTarget)
}
# Modelruns = r*Nparameters+1
# run the morris screening
morrisOut <- morris(model = targetFunction, factors = rownames(refPar[parSel, ]), r = 100, #r=200
                    design = list(type = "oat", levels = 5, grid.jump = 3),
                    binf = refPar$lower[parSel], bsup = refPar$upper[parSel], scale = TRUE)

# Write output
if(!dir.exists("sensitivity/output")){dir.create("sensitivity/output")}
save(morrisOut, file = here::here("sensitivity/output/morris_likelihood.Rdata"), compress = "gzip")