"""
Model for macrophyte growth, similar to CHARISMA (van Nes 2003)
"""

#module CHARISMA

using
    QuadGK,
    DelimitedFiles,
    Dates

# Give input files for selected Lakes
Lakes = (
    ".\\input\\WagingerSee.config.txt",
    ".\\input\\Chiemsee.config.txt",
    ".\\input\\Koenigssee.config.txt",
    ".\\input\\Hopfensee.config.txt",
)

# Give input files for selected Species; no competition included, for all species individually
Species =
    (".\\input\\CharaAspera.config.txt",
    ".\\input\\PotamogetonPectinatusAsSeed.config.txt")

# Include functions
include("defaults.jl")
include("input.jl")
include("functions.jl")
include("run_simulation.jl")
include("output.jl")

#Create uniform Output Folder name
folder = string(Dates.format(now(), "yyyy_m_d_HH_MM"))
cd("C:\\Users\\anl85ck\\Desktop\\PhD\\4_Modellierung\\2_CHARISMA\\2_Macroph") #TODO Rewrite
# Loop for model run for different Lakes and Species

settings = Dict()

for l in 1:length(Lakes)
    for s in 1:length(Species)
        #Get settings
        settings = getsettings(Lakes[l], Species[s])

        # Get climate for default variables . !Gives just one year as environment is not yet changing between years
        environment = simulateEnvironment()
        # Output: temp, irradiance, waterlevel, lightAttenuation

        # Get macrophytes in 4 depths
        result = simulateFourDepth() #-0.5; -1.0; -3.0; -5.0
        # Output: Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass

        # Save results as .csv files in new folder
        writeOutput(settings, environment, result, folder)
    end
end


## JUST for checking
#using Plots
#Plots.scalefontsizes(2)
#pyplot()

#p1_1 = plot(result[1][:, 1], label = 1, ylabel = "Biomass (g)", title = "0.5m depth", ylims=(0,findmax(result[1][:, 1])[1]))
#p1_2 = plot(result[2][:, 1], label = 1, title = "2m depth",ylims=(0,findmax(result[1][:, 1])[1]))
#p1_3 = plot(result[3][:, 1], label = 1, title = "5m depth",ylims=(0,findmax(result[1][:, 1])[1]))
#p1_4 = plot(result[4][:, 1], label = 1, title = "10m depth",ylims=(0,findmax(result[1][:, 1])[1]))

#p2_1=plot(result[1][:,2], label = 1, ylabel = "Number of Individ",ylims=(0,findmax(result[1][:, 2])[1]))
#p2_2=plot(result[2][:,2], label = 1,ylims=(0,findmax(result[1][:, 2])[1]))
#p2_3=plot(result[3][:,2], label = 1,ylims=(0,findmax(result[1][:, 2])[1]))
#p2_4=plot(result[4][:,2], label = 1,ylims=(0,findmax(result[1][:, 2])[1]))

#p3_1=plot(result[1][:,4], label = 1, ylabel = "Height (m)",ylims=(0,findmax(result[1][:, 4])[1]))
#p3_2=plot(result[2][:,4], label = 1,ylims=(0,findmax(result[1][:, 4])[1]))
#p3_3=plot(result[3][:,4], label = 1,ylims=(0,findmax(result[1][:, 4])[1]))
#p3_4=plot(result[4][:,4], label = 1,ylims=(0,findmax(result[1][:, 4])[1]))

#FIN = plot(
#    p1_1,p1_2, p1_3,p1_4,
#    p2_1,p2_2,p2_3,p2_4,
#    p3_1,p3_2,p3_3,p3_4,
#    #p4_1,p4_2,p4_3,p4_4,
#    layout = (3, 4),
#    legend = false,
#    size = (1800, 1000),
#)
