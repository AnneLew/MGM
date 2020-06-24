"""
Model for macrophyte growth, similar to CHARISMA (van Nes 2003)
"""

include("defaults.jl")
include("input.jl")
settings = getsettings()

include("run_simulation.jl")
include("output.jl")

# Get climate for default variables
Environment = simulateEnvironment()

# Get macrophytes in 4 depths for default variables
Res1 = simulate(LevelOfGrid=-1.0) # Output: Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
Res2 = simulate(LevelOfGrid=-2.0) # Output: Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
Res3 = simulate(LevelOfGrid=-3.0) # Output: Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
Res4 = simulate(LevelOfGrid=-4.0) # Output: Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass

# Save results as .csv files in new folder
cd("C:\\Users\\anl85ck\\Desktop\\PhD\\4_Modellierung\\2_CHARISMA\\2_Macroph")
writeOutput4Depths(Res1, Res2, Res3, Res4, Environment, settings)





#Pkg.add("JLD")
#using JLD
#r = rand(3, 3, 3)
#save("data.jld", "data", Res)
#load("data.jld")["data"]
