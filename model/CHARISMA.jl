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

#settings = getsettings(Lakes[2], Species[2])

for l in 1:length(Lakes)
    for s in 1:length(Species)
        #Get settings
        settings = getsettings(Lakes[l], Species[s])

        # Get climate for default variables . !Gives just one year as environment is not yet changing between years
        environment = simulateEnvironment(settings)
        # Output: temp, irradiance, waterlevel, lightAttenuation

        # Get macrophytes in 4 depths
        result = simulateDepth(settings) #-0.5; -1.0; -3.0; -5.0
        # Output: Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass

        # Save results as .csv files in new folder
        writeOutput(settings, environment, result, folder)
    end
end
