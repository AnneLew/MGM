## General configurations
setting = "local" # "HPC"
modelrun = "211128_experiment" #Name of experiment
years = 20 #Number of years to get simulated [n]
depths = c(-0.5, -1.5, -3.0, -5.0)
yearsoutput = 2
species <- c(1:3000)
lakes <- c(1:15)


# CORES
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


for (l in 1:length(lakes)){
  
  ## Create config files SPEC ----
  S1<-c()
  for (n in 1:length(species)){
    SPEC=paste("./input/species/species_",species[n], ".config.txt",sep="")
    S1<-cbind(S1, SPEC)
  }
  
  ## Create config files LAKES ----
  # L1<-c()
  # for (n in 1:length(lakes)){
  #   LAK=paste("./input/lakes/lake_",lakes[n], ".config.txt",sep="")
  #   L1<-cbind(L1, LAK)
  # }
  
  L1<-paste("./input/lakes/lake_",lakes[l], ".config.txt",sep="")
  
  
  ## Combine and write output 
  to_print <- c(
    paste0("modelrun ", paste0(modelrun, collapse = " ")),
    paste0("years ", paste0(years, collapse = " ")),
    paste0("depths ", paste0(depths, collapse = " ")),
    paste0("yearsoutput ", paste0(yearsoutput, collapse = " ")),
    paste0("lakes ", paste0(L1, collapse = " ")),
    paste0("species ", paste0(S1, collapse = " "))
  )
  
  #writeLines(text = to_print)
  writeLines(text = to_print, con = paste0(wd,"/input/general.config.txt"))
  
  
  #start.time <- Sys.time()
  model<-julia_eval("CHARISMA_biomass_parallel()") 
  model<-as.data.table(model)
  
  for (i in 1:length(species)){
    model[,5][model[,5] == i] <- species[i]
  }
  for (i in 1:length(lakes)){
    model[,6][model[,6] == i] <- lakes[i]
  }
  
  model <- model %>% rename(specNr=V5, 
                            lakeNr=V6)
  print(model)
  # end.time <- Sys.time()
  # time.taken <- end.time - start.time
  # time.taken
  
  if(!dir.exists("output")){dir.create("output")}
  if(!dir.exists(paste0("output/",modelrun))){dir.create(paste0("output/",modelrun))}
  save(model, file = paste0(wd,"/output/",modelrun,"/result_lake_",lakes[l],".Rdata"), compress = "gzip")
  
  
}
