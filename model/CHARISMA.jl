"""
Model for macrophyte growth, similar to CHARISMA (van Nes 2003)
"""

#module CHARISMA

cd(dirname(@__DIR__)) #Set dir to home_dir of file

#load packages
using
    HCubature, #for Integration
    DelimitedFiles,
    Dates,
    Distributions, Random #for killWithProbability

# Include functions
include("defaults.jl")
include("input.jl")
include("functions.jl")
include("run_simulation.jl")
include("output.jl")

folder = string(Dates.format(now(), "yyyy_m_d_HH_MM")) #Create uniform Output Folder name

# Give input files for selected Lakes
Lakes = (
    #".\\input\\lakes\\Testsee.config.txt",
    #".\\input\\lakes\\WagingerSee.config.txt",
    #".\\input\\lakes\\Chiemsee.config.txt",
    #".\\input\\lakes\\Koenigssee.config.txt",
    #".\\input\\lakes\\Hopfensee.config.txt",
    ".\\input\\lakes\\LakeCharisma.config.txt",
    ".\\input\\lakes\\ClearWarmLake.config.txt",
)

# Give input files for selected Species; no competition included, for all species individually
Species =
    (".\\input\\species\\CharaAspera.config.txt",
    ".\\input\\species\\PotamogetonPerfoliatus.config.txt",
    ".\\input\\species\\PotamogetonPectinatus.config.txt",
    )

#settings = getsettings(Lakes[1], Species[2])
#settings["hWaveMort"]
#settings["pWaveMort"]

# Select depth to run the model for
depths=[-0.5,-1.0,-1.5,-3.0,-5.0]

# Loop for model run for different Lakes and Species
for l in 1:length(Lakes)
    for s in 1:length(Species)
        #Get settings
        settings = getsettings(Lakes[l], Species[s])

        # Get climate for default variables . !Gives just one year as environment is not yet changing between years
        environment = simulateEnvironment(settings)
        # Output: temp, irradiance, waterlevel, lightAttenuation

        # Get macrophytes in 4 depths
        result = simulateMultipleDepth(depths,settings)
        # Output: Res[year][dataset][day,parameter,year] \ parameters: Biomass, Number, indWeight, Height, allocatedBiomassSeeds, allocatedBiomassTubers

        # Save results as .csv files in new folder
        writeOutput(settings, depths, environment, result, folder)
    end
end
