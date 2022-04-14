# Optimization workflow for MGM with DEOptim

# Before running this script: 
# (1) Specify general configurations
# (2) Check if corresponding species and lake files are correct!

#### General configurations ----
setting = "local" # SET working environment "HPC" or "local"
modelrun = "Optim_March22" #Set Name of experiment
species_id <- c(3) # Set species ID for optimization
species = paste0("species_", species_id)
lakeSel = c(1:3) # Set lake IDs used for optimization
lakes = lakeSel
depths = c(-0.5, -1.5, -3.0, -5.0) # Set depth used for optimization
ndepths = length(depths)
parSel = c(9) # Set parameters that are selected: max c(1:28)
parameterspace = "parameterspace_march22" #"parameterspace_broad_all" # Set filename that defines the parameterspace
iterMax = 10 #100 # Set Number of Iterations for DEoptim
NPfactor = 10 # Set Number of Populations for DEOptim; Minimum: 10
minimumBiomass = 1 # Set minimum Biomass that gets identified
years = 10 # Set number of years to get simulated [n]
yearsoutput = 2 # Set number of output years; not necessary
nthreads = as.character(120) #Set number of of kernels to be used in julia; max nlakes*ndepths
LLfunction ="1_weighted" #options: "1_not-weighted", "1_weighted", "2_not-weighted"
PresAbsFactor=3 # If weighted penalization is used 


#### Setup of Julia ----
Sys.setenv(JULIA_NUM_THREADS = nthreads) #Sets number of threads
library(JuliaCall) #Load package
#Set location of julia
if (setting == "local")
  julia_setup(JULIA_HOME = "C:\\Users\\anl85ck\\AppData\\Local\\Programs\\Julia-1.6.0\\bin", installJulia = F)
if (setting == "HPC")
  julia_setup(JULIA_HOME = "/home/anl85ck/.julia/bin", installJulia = F) #on HPC
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

#### Setup of R ----
library(tidyverse)
library(DEoptim)
library(data.table)
library(here)
#library(sensitivity)
#library(foreach)

# Set working directories
if (setting == "local") {
  setwd('../')
  wd <- getwd()
  if (str_sub(wd, start = -9) != "2_Macroph") {
    print("Wrong path!")
    quit(save = "no")
  }
  print(wd)
}
if (setting == "HPC") {
  wd <- here::here()
  setwd(wd)
  print(wd)
  #if (str_sub(wd, start= -9) != "2_Macroph") print("Wrong path!")
}

#### Setup of model input ----
# Write general.config-file
S1 <- c()
for (n in 1:length(species_id)) {
  SPEC = paste("./input/species/species_",
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

# Import julia functions
julia_source("model/CHARISMA_function.jl")
julia_source("model/structs.jl")
julia_source("model/defaults.jl")
julia_source("model/input.jl")
julia_source("model/functions.jl")
julia_source("model/run_simulation.jl")
julia_source("model/output.jl")

# Import real world data
data <-
  data.table::fread(paste0("data/", species, ".txt", sep = ""), header = T) # TODO Change for Name of species
data <- data[lakeSel]

# Import parameterspace
space <- data.table::fread(paste0("input/", parameterspace, ".csv"))


# Write species specific input file with base values
para <- data.table::fread(paste0(wd,"/input/template/species/",species,".config.txt"), 
                          header = F)

# Write species specific parameters 
data.table::fwrite(para, 
                   file=paste0(wd,"/input/species/",species,".config.txt"), 
                   col.names=F, sep = " ") #TODO change name of species here? Than change also general.config





# Define parameter values (default values, upper and lower boundary of each parameter)
parNames <- space$V1
default <- space$V4
names(default) <- parNames
lower <- space$V2
names(lower) <- parNames
upper <- space$V3
names(upper) <- parNames
refPar <- data.frame(default, lower, upper, row.names = parNames)

paraStart <-
  data.table::fread(paste0(wd, "/input/species/", species, ".config.txt"),
                    header = F)
counter = 0
counter_pre = 0

#### Define function ----
likelihood = function(parameters) {
  counter = counter + 1
  assign('counter', counter, envir = .GlobalEnv)

  setwd(wd)
  
  # Import template for species specific parameters
  para <-
    data.table::fread(paste0(wd, "/input/species/", species, ".config.txt"),
                      header = F)
  
  # Replace given values with parameters of function
  to_change <- data.table(V1 = parNames[parSel], V2 = parameters)
  para[to_change, c("V1", "V2") := .(i.V1, i.V2), on = "V1"] #join of data.table
  
  
  # Round distinct parameters
  roundparameters <-
    list(
      "germinationDay",
      "seedsStartAge",
      "seedsEndAge",
      "cThinning",
      "maxAge",
      "pWaveMort",
      "pNutrient",
      "reproDay"
    ) # [+Tuber]
  for (p in roundparameters) {
    para[para$V1 == p]$V2 <- round(as.numeric(para[para$V1 == p]$V2))
  }
  
  # Overwrite species specific parameters
  data.table::fwrite(
    para,
    file = paste0(wd, "/input/species/", species, ".config.txt"),
    col.names = F,
    sep = " "
  ) #TODO change name of species here? Than change also general.config
  
  # Run Model in julia
  model <- julia_eval("CHARISMA_biomass_parallel()")
  model <- as.data.table(model)
  
  # Sort model output and real world data by lake number
  model <- setDT(model) %>% arrange(V6)
  data <- setDT(data) %>% dplyr::arrange(lakeID)
  
  # If Biomass < minimumBiomass: Species is not found/detected
  for (d in 1:ndepths) {
    for (l in 1:length(lakeSel)) {
      if (model[l, d, with = F] < minimumBiomass) {
        model[l, d] = 0
      }
    }
  }

  
  # Compare Model and Real World data
  weight = (length(lakeSel) * ndepths) / (2)
  
  
  if (LLfunction =="1_not-weighted"){
    LL_presabs = 0
    for (d in 1:ndepths) {
      for (l in 1:length(lakeSel)) {
        if (model[l, d, with = F] == 0 &&
            data[l, d, with = F] > 0) {
          #if observed but not predicted: penalization
          LL_presabs = LL_presabs + 1
        }
        if (model[l, d, with = F] > 0 &&
            data[l, d, with = F] == 0) {
          #if predicted, but not observed: penalization
          LL_presabs = LL_presabs + 1
        }
      }
    }
    LL_presabs # Anzahl an Seen*Tiefen, wo Pres/Abs-Muster in dieser Tiefe nicht stimmt
  } else if (LLfunction =="1_weighted") {

  # Compare Model and Real World data, weighted penalization
  
    LL_presabs_w = 0
    for (d in 1:ndepths) {
      for (l in 1:length(lakeSel)) {
        if (model[l, d, with = F] == 0 &&
            data[l, d, with = F] > 0) {
          #if observed but not predicted: penalization
          LL_presabs_w = LL_presabs_w + PresAbsFactor
        }
        if (model[l, d, with = F] > 0 &&
            data[l, d, with = F] == 0) {
          #if predicted, but not observed: penalization
          LL_presabs_w = LL_presabs_w + 1
        }
      }
    }
    LL_presabs = LL_presabs_w / PresAbsFactor # to obtain the same range for the output
  } else if (LLfunction == "2_not-weighted") {
  
  # Third option for likelihood 
    LL_presabs0_2 = 0
    LL_presabs1_2 = 0
    data_0 = 0
    data_1 = 1
    for (d in 1:ndepths) {
      for (l in 1:length(lakeSel)) {
        if (model[l, d, with = F] == 0 &&
            data[l, d, with = F] == 0) {
          #if not observed AND not predicted: NICE
          LL_presabs0_2 = LL_presabs0_2 + 1
        }
        if (data[l, d, with = F] == 0) {
          data_0 = data_0 + 1
        }
        if (model[l, d, with = F] > 0 &&
            data[l, d, with = F] > 0) {
          #if predicted AND observed: NICE
          LL_presabs1_2 = LL_presabs1_2 + 1
        }
        if (data[l, d, with = F] > 0) {
          data_1 = data_1 + 1
        }
      }
    }
    LL2_presabs = 2 - ((LL_presabs0_2 / data_0) + 
                         (LL_presabs1_2 / data_1))
    # "2-" to make it minimaziable; Output range: best [0 - 2] worst
    
    LL_presabs = LL2_presabs * weight #[Range from 0 to ndepth*nlakes]
    LL_presabs 
  }
  
  # DEPTH DEPENDENT CORRELATION
  # LL_corr=0
  # for (d in 1:ndepths){
  #   r=1-cor(model[,d, with=F], data[,d, with=F]^3) # Melzer
  #   if(is.na(r)) r=2
  #   LL_corr=sum(LL_corr,r, na.rm = T)
  # }
  
  # Better alternative: DEPTH inDEPENDENT CORRELATION
  # LL_corr <- 1 - cor(c(as.matrix(model[, 1:4, with = F])),
  #                    c(as.matrix(data[, 1:4, with = F] ^ 3)))
  # if (is.na(LL_corr))
  #   LL_corr = 2
  
  # Even better alternative: depth independent RangCorrelation 
  LL_corr <- 1 - cor(c(as.matrix(model[, 1:4, with = F])),
                     c(as.matrix(data[, 1:4, with = F])), method="spearman")
  if (is.na(LL_corr)) LL_corr = 2
  
  # Sum
  LL = LL_presabs + LL_corr * weight #[Range from 0 to 2*ndepth*nlakes]
  
  
  # Growing?
  if (sum(c(as.matrix(model[, 1:4, with = F]))) > 0){
    counter_pre = counter_pre + 1
  }
  assign('counter_pre', counter_pre, envir = .GlobalEnv)
  
  # Print Result
  print(paste0("Run: ",counter," - LL: ",LL," - Growing combinations: ", counter_pre))
  print(model)
  
  return(LL)
}


#### Set initial population ----
NP<-length(parSel) * NPfactor
inipop<-t(matrix( as.vector(default[parSel]), length(as.vector(default[parSel])) , NP))

for (i in 1:length(parSel)){
  inipop[2:NP,i] <- runif(length(inipop[2:NP,i]), lower[parSel][i], upper[parSel][i])
}


#### Optimization ----
#start.time <- Sys.time()
optim_param = DEoptim(
  fn = likelihood,
  lower = lower[parSel],
  upper = upper[parSel],
  control = list(NP = length(parSel) * NPfactor, itermax = iterMax, initialpop = inipop) #does that make sense?? , 
) #, method = "L-BFGS-B"; trace = FALSE,
#end.time <- Sys.time()
#time.taken <- end.time - start.time
#time.taken

# Write output
if (!dir.exists("optimizer/output")) {
  dir.create("optimizer/output")
}
save(optim_param,
     file = here::here(
       paste0("optimizer/output/DEOptim_", species, "_backup.Rdata")
     ),
     compress = "gzip")


#### Add further information to optim_param object ----
namesparsel <- space$V1[parSel]
parafin <- paraStart
for (p in namesparsel) {
  parafin[parafin$V1 == p]$V2 <- optim_param$optim$bestmem[[p]]
}

optim_param$meta <- list(
  setting = setting,
  lakeSel = lakeSel,
  parSel = parSel,
  namesparsel = namesparsel,
  parameterspace = parameterspace,
  #iterMax=iterMax,
  parafin = parafin,
  #All parameters with best value
  space = space
)

save(optim_param,
     file = here::here(
       paste0("optimizer/output/DEOptim_", species, "_complete_test.Rdata")
     ),
     compress = "gzip")
