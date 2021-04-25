# Analysis of global sensitivity of likelihood for optimization
#args <- commandArgs(TRUE) # to read in command line arguments
# Args: (1) Number of threads


# Packages
Sys.setenv(JULIA_NUM_THREADS = "6") #"6" Gives number of of kernels to be used in julia; max nlakes*ndepths
library(JuliaCall) 
library(tidyverse)
library(DEoptim)
#library(foreach)
library(data.table)
library(here)
#library(sensitivity)

# Set working directories 
wd<-here::here()
setwd(wd)

# Setup integration of julia
julia_setup(JULIA_HOME = "C:\\Users\\anl85ck\\AppData\\Local\\Programs\\Julia-1.6.0\\bin",
            installJulia = F)
#julia_setup(JULIA_HOME = "/home/anl85ck/.julia/bin",installJulia = F) #on HPC
julia <- julia_setup()
#julia_eval("Threads.nthreads()") #check 

# Load julia packages
julia_library("HCubature")
julia_library("DelimitedFiles")
julia_library("Dates")
julia_library("Distributions")
julia_library("Random")
julia_library("CSV")
julia_library("DataFrames")
julia_library("StatsBase")

julia_source("model/CHARISMA_function.jl")

# Import real world data
data<-data.table::fread("data/species_99t.txt", header = F) # TODO Change for Name of species
lakeSel = c(1:10) #Adapt in general config file
data <- data[lakeSel]
ndepths <- 4

# Import parameterspace
space<-data.table::fread("input/parameterspace_species99.csv")

## Define parameter values (default values, upper and lower boundary of each parameter)
parNames <- space$V1
default <- space$V4 
names(default) <- parNames
lower <- space$V2
names(lower) <- parNames
upper <- space$V3
names(upper) <- parNames
refPar <- data.frame(default, lower, upper, row.names = parNames)
#parSel = c(1:28) # TODO set parameters that are selected

parSel = c(3,4,5,6,9,15,27)


# FUNCTION LIKELIHOOD
likelihood = function(...){ #...
  setwd(wd)
  changedparameter <- list(...) #...
  
  # Import template for species specific parameters
  para <- data.table::fread(paste0(wd,"/input/template/template_species_99.txt"), 
                            header = F)
  
  # Replace given values with parameters of function
  for (p in names(changedparameter)){
    para[para$V1==p]$V2 <- changedparameter[[p]]
  }
  
  # Round distinct parameters?? 
  roundparameters<-list("germinationDay","seedsStartAge","seedsEndAge","cThinning",
                        "maxAge","pWaveMort","pNutrient","reproDay") # [+Tuber]
  for (p in roundparameters){
    para[para$V1==p]$V2 <- round(as.numeric(para[para$V1==p]$V2))
  }
  
  # Write species specific parameters 
  data.table::fwrite(para, 
                     file=paste0(wd,"/input/species/species_99.config.txt"), 
                     col.names=F, sep = " ") #TODO change name of species here? Than change also general.config
  
  # Run Model in julia
  model<-julia_eval("CHARISMA_biomass_parallel()") #? 4 depths defined in general.config.file?
  model<-as.data.table(model)
  
  # Status report
  #print("Model & Virtual Ecologist done")
  
  # Sort model output and real world data by lake number
  model <- setDT(model) %>% arrange(V6)
  data <- setDT(data) %>% dplyr::arrange(V6) #data[order(lakeID)]
  
  print(model)
  
  # Compare Model and Real World data
  LL_presabs=0
  for (d in 1:ndepths){
    for (l in 1:length(lakeSel)){
      if(model[l,d, with=F]==0 && data[l,d, with=F]>0) { #if observed but not predicted: penalization
        LL_presabs=LL_presabs+1
      }
    }
  }
  LL_presabs # Anzahl an Seen*Tiefen, wo Präsens/Absens-Muster in dieser Tiefe nicht stimmt
  
  LL_corr=0
  for (d in 1:ndepths){
    r=1-cor(model[,d, with=F], data[,d, with=F]^3) # Melzer
    if(is.na(r)) r=2
    LL_corr=sum(LL_corr,r, na.rm = T) 
  }
  LL_corr
  weight = (length(lakeSel) * ndepths) / (ndepths * 2) #nspecies * ndepths /8 ::: damit es maximal genau gleich ins Gewicht fällt wie pres/abs
  
  LL = LL_presabs + LL_corr*weight 
  
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


try(sensitivityTarget("pMax"), silent=TRUE)


#################################################################
# Optimization
lower_parameters <- lower[parSel]
upper_parameters <- upper[parSel]
NP<-length(parSel)*10

optim_param = DEoptim(fn=sensitivityTarget,
                      lower = lower_parameters, upper = upper_parameters,
                      control = list(NP=NP,itermax = 10)) #, method = "L-BFGS-B"; trace = FALSE,


save(optim_param, file = here::here("optimizer/output/test.Rdata"), compress = "gzip")

#plot(optim_param)
