## Sensitivity analysis of CHARISMA
## Script source: Florian Hartig

## Check - natürlich immer nur für eine Art in einem See
## Check general.config.file!!
## Set parameter selected here

# Packages
library(JuliaCall) 
#library(tidyverse)
library(here)
#library(foreach)
library(sensitivity)

# Set working directory 
#set_here(path = "..", verbose = TRUE)
wd<-here()
#wd<-"C:/Users/anl85ck/Desktop/PhD/4_Modellierung/2_CHARISMA/2_Macroph/"
setwd(wd)

# Setup integration of julia
julia_setup(JULIA_HOME = "C:\\Users\\anl85ck\\AppData\\Local\\Programs\\Julia-1.6.0\\bin",
            installJulia = F)
#julia_setup(installJulia = F)
julia <- julia_setup()

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

# # Write general.config file
# years = 5
# yearsoutput = 2
#depth = -1.0
spec <- "species_3" #TODO check in general.config.file
#lake = "lake_2"

#config<-data.table::fread("input/general.config.txt")
#config[config$V1=="depths"][,2]<-depth
#config[config$V1=="lakes"][,2]<-paste0(".\\input\\lakes\\",lake,".config.txt")
#config[config$V1=="species"][,2]<-paste0(".\\input\\species\\",spec,".config.txt")
#data.table::fwrite(config,file="input/general.config.txt",
#                   col.names=F, sep = " ")

# Import parameterspace
space<-data.table::fread("input/parameterspace_broad_all.csv") #_broad

## Define parameter values (default values, upper and lower boundary of each parameter)
parNames <- space$V1
default <- space$V4 
names(default) <- parNames
lower <- space$V2
names(lower) <- parNames
upper <- space$V3
names(upper) <- parNames
refPar <- data.frame(default, lower, upper, row.names = parNames)
parSel = c(1:28) # TODO set parameters that are selected

#parSel = c(2)

# Define steps for local sensitivity analysis
steps = 10 #TODO set


## FUNCTIONS ----
# Define function to run the model
MyModel <- function(...){
  setwd(wd)
  changedparameter <- list(...) #...
  
  # Import template for species specific parameters
  para <- data.table::fread(paste0(wd,"/input/template/template_",spec, ".txt"),
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
                     file=paste0(wd,"/input/species/",spec,".config.txt"),
                     col.names=F, sep = " ")
  
  # Run Model in julia
  model<-julia_eval("@invokelatest CHARISMA_biomass_onedepth()") #CHARISMA_biomass
  model<-as.data.frame(model)
  
  # Status report
  print("Model & Virtual Ecologist done")
  
  #Output
  return(model$V1) # TODO set! Summer Mean Biomasse in x. Tiefenstufe
}


MyModel(germinationDay=70)




sensitivityTarget <- function(parameters){
  # copy default values of the parameter
  x = refPar$default
  # change parameter
  x[parSel] = parameters
  # run model
  Biomass<-MyModel(
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
  print(Biomass)
  return(Biomass)
}
#sensitivityTarget(50)

# LOCAL SENSITIVITY ANALYSIS
localSensitivity <- function(n, steps) {
  # generate sequence of values for parameter n in the given boundaries
  parSen <- seq(lower[n], upper[n], len = steps)
  # copy default parameter values
  params <- default[parSel]
  # run the model with default values and changed values for the selected parameter
  post <- rep(NA, steps)
  for (i in 1:steps) {
    print(paste0("step ", i))
    params[n] <- parSen[i]
    post[i] <- sensitivityTarget(params)
  }
  return(data.frame(parameter = n, value = parSen, predict = post))
}

try(localSensitivity("pMax",2), silent=TRUE)
localSensitivity("pMax",2)

# # Run local sensitivity for all selected parameters
# sens_local <- foreach(
#   i=parNames[parSel],
#   .combine = rbind
# ) %do% {
#   print(i)
#   localSensitivity(i, steps = steps)
# }
# 
# #steps=3
# ## TODO CHANGE NAMES before SAVING!!!
# data.table::fwrite(sens_local, file = paste0("./sensitivity/output/localsensitivity_2mdepth_alpseeschongau_all_corrMort.csv"))
# 
# 
# 
# default<-refPar[parSel,] %>% select(default) %>% tibble::rownames_to_column(var = "parameter") 
# ggplot(data=sens_local, aes(x=value, y=predict)) + #slice(sens_local, -c(31,271))
#   geom_line()+  
#   theme_classic() +
#   geom_vline(data=default, mapping=aes(xintercept=default),
#              color = "red", size=0.5)+
#   facet_wrap(~parameter, scales="free")+
#   labs(title="Local sensitivity, Alpsee bei Schongau, -2.0m depth")
# 
# #paste0("Local sensitivity, ", lake,depth,"depth")
# 
# 
# ## PLOT two sens together
# sens_local$depth<-2.0
# senslocal05m<-data.table::fread(file = "./sensitivity/output/localsensitivity_1stdepth_alpseeschongau_all_corrMort.csv")
# senslocal05m$depth<-0.5
# senslocal4m<-data.table::fread(file = "./sensitivity/output/localsensitivity_4mdepth_alpseeschongau_all_corrMort.csv")
# senslocal4m$depth<-4
# sensloc<-rbind(senslocal1m,senslocal4m,sens_local)
# ggplot(data=sensloc, aes(x=value, y=predict, group=depth, col=as.factor(depth))) + #slice(sens_local, -c(31,271))
#   geom_line()+  
#   theme_classic() +
#   scale_color_viridis_d() +
#   geom_vline(data=default, mapping=aes(xintercept=default),
#              color = "red", size=0.5)+
#   facet_wrap(~parameter, scales="free")+
#   labs(title="Local sensitivity, Alpsee bei Schongau")

###########################################################################
## GLOBAL SENSITIVITY ANALYSIS: account for interactions between parameters


# define a target function that applies the sensitivity target function to all parameter combinations (columns represent different parameters and rows represent different parameter combinations)
targetFunction <- function(parmatrix) {
  apply(parmatrix, 1, sensitivityTarget)
}
# Modelruns = r*Nparameters+1
# run the morris screening
morrisOut <- morris(model = targetFunction, factors = rownames(refPar[parSel, ]), r = 100, 
                    design = list(type = "oat", levels = 5, grid.jump = 3), 
                    binf = refPar$lower[parSel], bsup = refPar$upper[parSel], scale = TRUE) # scale = TRUE > is relative to its uncertainty
par(mfrow = c(1,1))
plot(morrisOut)
print(morrisOut)
#plot3d(morrisOut)

save(morrisOut, file = here::here("sensitivity/output/morris_screen_1mdepths_alpsee.Rdata"), compress = "gzip")
#load("./sensitivity/output/morris_sens_2nddepths_abtsdorfer.Rdata")



## Source https://cran.r-project.org/web/packages/r3PG/vignettes/r3PG-ReferenceManual.html
# summarise the moris output
# morrisOut.df <- data.frame(
#   parameter = parNames[parSel],
#   mu.star = apply(abs(morrisOut$ee), 2, mean, na.rm = T),
#   sigma = apply(morrisOut$ee, 2, sd, na.rm = T)
# ) %>%
#   arrange( mu.star )
# 
# morrisOut.df %>%
#   gather(variable, value, -parameter) %>%
#   ggplot(aes(reorder(parameter, value), value, fill = variable), color = NA)+
#   geom_bar(position = position_dodge(), stat = 'identity') +
#   scale_fill_brewer("", labels = c('mu.star' = expression(mu * "*"), 'sigma' = expression(sigma)), palette="Dark2") +
#   theme_classic() +
#   theme(
#     axis.text = element_text(size = 6),
#     axis.text.x = element_text(angle=90, hjust=1, vjust = 0.5),
#     axis.title = element_blank(),
#     legend.position = c(0.05 ,0.95),legend.justification = c(0.05,0.95))
