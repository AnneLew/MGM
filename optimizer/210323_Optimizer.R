###############################################
# Workflow to optimize Charisma model for WFD data in Bavaria
# Anne Lewerentz (anne.lewerentz@uni-wuerzburg.de)
# 23.03.2021
###############################################


# Set working directories 
wd<-"C:/Users/anl85ck/Desktop/PhD/4_Modellierung/2_CHARISMA/2_Macroph/"
name_experiment<-"optimization" #TODO import from settings
setwd(wd)

# Packages
library(JuliaCall) 
library(tidyverse)
library("DEoptim")

# Setup integration of julia
julia_setup(installJulia = F)
julia <- julia_setup()

# Import real world data
data<-data.table::fread("data/species_3.txt", header = T) # TODO Change for Name of species

# Import parameterspace
space<-data.table::fread("input/parameterspace.csv")

# FUNCTION LIKELIHOOD
likelihood = function(...){ #...
  setwd(wd)
  changedparameter <- list(...) #...
  
  # Import template for species specific parameters
  para <- data.table::fread(paste0(wd,"input/template/parameterTemplate.txt"), 
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
                     file=paste0(wd,"input/species/species_1.config.txt"), 
                     col.names=F, sep = " ") #TODO change name of species here? Than change also general.config
  
  # Run Model in julia
  julia_source("model/CHARISMA.jl")
  
  # Run virtual Ecologist in julia
  julia_source("model/virtualEcologist.jl")
  
  # Status report
  print("Model & Virtual Ecologist done")
  
  # Import Output of VE
  model<-data.table::fread(paste0(wd,"output/",name_experiment,"/MappedMacrophytes.csv")) 
  
  # Sort model output and real world data by lake number
  model <- model %>% arrange(V6)
  data <- data %>% arrange(lakeID)
  
  ## Comparison
  LL = 0
  
  for (d in 1:4){ #TODO 4=ndepths
    dat<-as.vector(unlist(data[,d]))
    mod<-as.vector(unlist(model[,d]))
    LL = LL + sum((dat-mod)^2) # sum over lakes
  }
  return(LL)
}

#likelihood(pMax=0.01)

# Workaround function to give the likelihood function the changed parameters
# #space$V1
# likelihoodOPT = function(x){
#   L<-likelihood(cThinning=x[1],
#                 germinationDay=x[2],
#                 hNutrient=x[3],
#                 hPhotoLight=x[4],
#                 hPhotoTemp=x[5],
#                 hWaveMort=x[6],
#                 maxAge=x[7],
#                 maxWaveMort=x[8],
#                 pMax=x[9],
#                 pNurtient=x[10],
#                 pPhotoTemp=x[11],
#                 pWaveMort=x[12],
#                 q10=x[13],
#                 reproDay=x[14],
#                 resp20=x[15],
#                 seedBiomass=x[16],
#                 seedFraction=x[17],
#                 seedsStartAge=x[18],
#                 seedsEndAge=x[19],
#                 sPhotoTemp=x[20],
#                 Kohler5=x[21])
#   return(L)
# }

#space$V1
likelihoodOPT = function(x){
  L<-likelihood(#cThinning=x[1],
                #germinationDay=x[2],
                hNutrient=x[3],
                #hPhotoLight=x[4],
                #hPhotoTemp=x[5],
                #hWaveMort=x[6],
                #maxAge=x[7],
                #maxWaveMort=x[8],
                pMax=x[9],
                #pNurtient=x[10],
                #pPhotoTemp=x[11],
                #pWaveMort=x[12],
                #q10=x[13],
                #reproDay=x[14],
                resp20=x[15],
                #seedBiomass=x[16],
                #seedFraction=x[17],
                #seedsStartAge=x[18],
                #seedsEndAge=x[19],
                #sPhotoTemp=x[20],
                Kohler5=x[21])
  return(L)
}


# Optimization
lower_parameters <- space$V2[c(3,9,15,21)] 
upper_parameters <- space$V3[c(3,9,15,21)] 

optim_param = DEoptim(fn=likelihoodOPT, 
                      lower = lower_parameters, upper = upper_parameters, 
                      control = list(NP=4,itermax = 3, parallelType=1)) #, method = "L-BFGS-B"; trace = FALSE, 


plot(optim_param)
summary(optim_param)

