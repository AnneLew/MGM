"""
Model for submerged macrophyte growth, simplified version of CHARISMA (van Nes 2003)
"""
#Set dir to home_dir of file
cd(dirname(@__DIR__))

#load packages
using
    HCubature, #for Integration
    DelimitedFiles, # for function writedlm, used to write output files
    Dates, #to create output folder
    Distributions, Random #for killWithProbability

# Include functions
include("defaults.jl")
include("input.jl")
include("functions.jl")
include("run_simulation.jl")
include("output.jl")

#Create output folder name
folder = string(Dates.format(now(), "yyyy_m_d_HH_MM"))

#Get Settings for selection of lakes, species & depth
GeneralSettings = parseconfigGeneral(".\\input\\general.config.txt")
depths = parse.(Float64, GeneralSettings["depths"])

#settings = getsettings(GeneralSettings["lakes"][1], GeneralSettings["species"][1])


# Loop for model run for selected lakes, species and depths
for l in 1:length(GeneralSettings["lakes"])
    println(GeneralSettings["lakes"][l])
    for s in 1:length(GeneralSettings["species"])

        #Get settings
        settings = getsettings(GeneralSettings["lakes"][l], GeneralSettings["species"][s])
        push!(settings, "years" => parse.(Int64,GeneralSettings["years"])[1]) #add "years" from GeneralSettings
        #println(GeneralSettings["species"][s])

        # Get climate for default variables . !Gives just one year as environment is not yet changing between years
        environment = simulateEnvironment(settings)
        # Output: temp, irradiance, waterlevel, lightAttenuation

        # Get macrophytes in multiple depths
        result = simulateMultipleDepth(depths,settings)
        # Output: Res[year][dataset][day,parameter,year] \ parameters: Biomass, Number, indWeight, Height, allocatedBiomassSeeds, allocatedBiomassTubers

        # Save results as .csv files in new folder
        writeOutput(settings, depths, environment, result, GeneralSettings, folder)

    end
end
