## Run model for multiple species in multiple lakes
## Parameter combinations have to be produced first with an extra script and added to the input folder
## Script runs all species in one lake per loop and writes ouput per lake
## Output mean summer biomass after a given number of years in given depths
## Output is written in folder output in a subfolder called after the name of the modelrun


## General configurations
setting = "local" # "HPC"
modelrun = "220304_newModelVersion_1000_V5" #Name of experiment
years = 10 #Number of years to get simulated [n]
depths = c(-0.5, -1.5, -3.0, -5.0)
yearsoutput = 2
species <- c(17001:18000)
#species <- c(3,33,21,57,56,36)
lakes <- c(1:31)
nthreads = as.character(100) #Set number of of kernels to be used in julia; max nlakes*ndepths
detectable=1
lakestemplate = "reallakes_simplifiedVersion"


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
#julia_library("HCubature")
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


# Rewrite lake files with base parameters
for (N in 1:31){
  # Import template for lakes
  lak <- read.table(paste0(wd,"/input/template/lakes/",lakestemplate,"/lake_",N,".config.txt"), 
                    header = F, comment.char="#")
  
  #lak[lak$V1=="maxTemp",]$V2 <- sprintf("%.1f",
  #                                      round((as.numeric(as.character(lak[lak$V1=="maxTemp",]$V2))+
  #                                               change[1]),1))
  #lak[lak$V1=="maxNutrient",]$V2 <- as.numeric(as.character(lak[lak$V1=="maxNutrient",]$V2))+
  #  (as.numeric(lak[lak$V1=="maxNutrient",]$V2) *
  #     change[2])
  #lak[lak$V1=="maxKd",]$V2 <- as.numeric(as.character(lak[lak$V1=="maxKd",]$V2))+
  #  (as.numeric(as.character(lak[lak$V1=="maxKd",]$V2)) *
  #     change[3])
  #lak[lak$V1=="minKd",]$V2 <- lak[lak$V1=="maxKd",]$V2
  
  # Write adapted lake config file
  data.table::fwrite(lak, 
                     file=paste0(wd,"/input/lakes/lake_",N,".config.txt"), 
                     col.names=F, sep = " ")
}

## Loop over species ---- because over lakes caused errors
for (s in 1:length(species)){
  
  S1<-paste("./input/species/species_",species[s], ".config.txt",sep="")
  
  ## Create config files LAKES ----
  L1<-c()
  for (n in 1:length(lakes)){
    LAK=paste("./input/lakes/lake_",lakes[n], ".config.txt",sep="")
    L1<-cbind(L1, LAK)
  }

  ## Combine general config file 
  to_print <- c(
    paste0("modelrun ", paste0(modelrun, collapse = " ")),
    paste0("years ", paste0(years, collapse = " ")),
    paste0("depths ", paste0(depths, collapse = " ")),
    paste0("yearsoutput ", paste0(yearsoutput, collapse = " ")),
    paste0("lakes ", paste0(L1, collapse = " ")),
    paste0("species ", paste0(S1, collapse = " "))
  )
  
  ## Write general config file
  writeLines(text = to_print)
  writeLines(text = to_print, con = paste0(wd,"/input/general.config.txt"))
  
  ## Run model ----
  model<-julia_eval("CHARISMA_biomass_parallel()") 
  model<-as.data.table(model)
  
  model <- model %>% rename(specNr=V5, 
                            lakeNr=V6,
                            depth_1=V1,
                            depth_2=V2,
                            depth_3=V3,
                            depth_4=V4)
  
  model <- model %>% mutate(depth_1=ifelse(depth_1<1,0,depth_1),
                   depth_2=ifelse(depth_2<1,0,depth_2),
                   depth_3=ifelse(depth_3<1,0,depth_3),
                   depth_4=ifelse(depth_4<1,0,depth_4))
  
  print(model)

  ## Save output for each lake ----
  if(!dir.exists("output")){dir.create("output")}
  if(!dir.exists(paste0("output/",modelrun))){dir.create(paste0("output/",modelrun))}
  save(model, file = paste0(wd,"/output/",modelrun,"/result_species_",species[s],".Rdata"), compress = "gzip")
  
}






