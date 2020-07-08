"""
Model for macrophyte growth, similar to CHARISMA (van Nes 2003)
"""
using QuadGK, DelimitedFiles, Dates

#pwd()
include("defaults.jl")
include("input.jl")
settings = getsettings(".\\input\\Chiemsee.config.txt", ".\\input\\CharaAspera.config.txt")

#settings["Lake"]
#settings["species"]

include("functions.jl")
include("run_simulation.jl")
include("output.jl")

# Get climate for default variables
environment = simulateEnvironment()

# Get macrophytes in 4 depths
result = simulateFourDepth() #-0.5; -1.0; -3.0; -5.0
# Output: Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass

# Save results as .csv files in new folder
#cd("C:\\Users\\anl85ck\\Desktop\\PhD\\4_Modellierung\\2_CHARISMA\\2_Macroph") #No complete paths
writeOutput(settings, environment, result)


## JUST for checking
using Plots
Plots.scalefontsizes(2)
pyplot()

p1_1 = plot(result[1][:, 1], label = 1, ylabel = "Biomass (g)", title = "0.5m depth")
p1_2 = plot(result[2][:, 1], label = 1, title = "1m depth")
p1_3 = plot(result[3][:, 1], label = 1, title = "3m depth")
p1_4 = plot(result[4][:, 1], label = 1, title = "5m depth")

p2_1=plot(result[1][:,2], label = 1, ylabel = "Number of Individ")
p2_2=plot(result[2][:,2], label = 1)
p2_3=plot(result[3][:,2], label = 1)
p2_4=plot(result[4][:,2], label = 1)

p3_1=plot(result[1][:,4], label = 1, ylabel = "Height (m)")
p3_2=plot(result[2][:,4], label = 1)
p3_3=plot(result[3][:,4], label = 1)
p3_4=plot(result[4][:,4], label = 1)

FIN = plot(
    p1_1,p1_2, p1_3,p1_4,
    p2_1,p2_2,p2_3,p2_4,
    p3_1,p3_2,p3_3,p3_4,
    #p4_1,p4_2,p4_3,p4_4,
    layout = (3, 4),
    legend = false,
    size = (1800, 1000),
)
