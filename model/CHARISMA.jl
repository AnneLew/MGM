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

#Create output folder
folder = string(Dates.format(now(), "yyyy_m_d_HH_MM"))

#Get Settings for selection of lakes, species & depth
GeneralSettings = parseconfigGeneral(".\\input\\general.config.txt")
depths = parse.(Float64, GeneralSettings["depths"])

#settings = getsettings(GeneralSettings["lakes"][1], GeneralSettings["species"][1])


# Loop for model run for different Lakes and Species
for l in 1:length(GeneralSettings["lakes"])
    for s in 1:length(GeneralSettings["species"])
        #Get settings
        settings = getsettings(GeneralSettings["lakes"][l], GeneralSettings["species"][s])
        push!(settings, "years" => parse.(Int64,GeneralSettings["years"])[1]) #add "years" from GeneralSettings

        # Get climate for default variables . !Gives just one year as environment is not yet changing between years
        environment = simulateEnvironment(settings)
        # Output: temp, irradiance, waterlevel, lightAttenuation

        # Get macrophytes in 4 depths
        result = simulateMultipleDepth(depths,settings)
        # Output: Res[year][dataset][day,parameter,year] \ parameters: Biomass, Number, indWeight, Height, allocatedBiomassSeeds, allocatedBiomassTubers

        # Save results as .csv files in new folder
        writeOutput(settings, depths, environment, result, GeneralSettings, folder)
    end
end
