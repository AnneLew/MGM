"""
Model for macrophyte growth, similar to CHARISMA (van Nes 2003)
"""
using QuadGK
using DelimitedFiles
using Dates

include("defaults.jl")
include("input.jl")
settings = getsettings("Chiemsee.config.txt", "CharaAspera.config.txt")


include("functions.jl")
include("run_simulation.jl")
#include("output.jl")

# Get climate for default variables
Environment = simulateEnvironment()

# Get macrophytes in 4 depths for default variables
Res1 = simulate(-1.0) # Output: Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
Res2 = simulate(-2.0) # Output: Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
Res3 = simulate(-3.0) # Output: Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
Res4 = simulate(-4.0) # Output: Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass

# Save results as .csv files in new folder
#cd("C:\\Users\\anl85ck\\Desktop\\PhD\\4_Modellierung\\2_CHARISMA\\2_Macroph") #No complete paths

#writeOutputMacrophytes(Res)
#writeOutputEnvironmentSettings(Environment, settings)

plot(Res1[2][:,1,1]) #LightAttenuation
plot(Res1[1][:,1,1]) #Biomass
plot(Res1[1][:,4,1])  #Height

#Pkg.add("JLD")
#using JLD
#r = rand(3, 3, 3)
#save("data.jld", "data", Res)
#load("data.jld")["data"]
