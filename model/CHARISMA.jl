#Macrophyte Growth Model (MGM)
#
#Anne Lewerentz <anne.lewerentz@uni-wuerzburg.de>
#(c) 2021-2022, licensed under the terms of the MIT license
#
#Contains all functions to run this depth-explicit macrophytes growth model.

#Set dir to home_dir of file
cd(dirname(@__DIR__))

#load packages
using
    HCubature, #for Integration
    DelimitedFiles, # for function writedlm, used to write output files
    Dates, #to create output folder
    Distributions, Random #for killWithProbability

# Include functions
include("structs.jl")
include("defaults.jl")
include("input.jl")
include("functions.jl")
include("run_simulation.jl")
include("output.jl")

# Get Settings for selection of lakes, species & depth
GeneralSettings = parseconfigGeneral("./input/general.config.txt")
depths = parse.(Float64, GeneralSettings["depths"])

# Create output folder name
#folder = string(Dates.format(now(), "yyyy_m_d_HH_MM"))
folder = GeneralSettings["modelrun"][1]

# Single Threaded Loop for model run for selected lakes, species and depths
for l in 1:length(GeneralSettings["lakes"])

    println(GeneralSettings["lakes"][l])

    for s in 1:length(GeneralSettings["species"])

        println(GeneralSettings["species"][s])

        #Get settings
        settings = getsettings(GeneralSettings["lakes"][l], GeneralSettings["species"][s])
        push!(settings, "years" => parse.(Int64,GeneralSettings["years"])[1]) #add "years" from GeneralSettings
        push!(settings, "yearsoutput" => parse.(Int64,GeneralSettings["yearsoutput"])[1]) #add "years" from GeneralSettings
        push!(settings, "modelrun" => GeneralSettings["modelrun"][1]) #add "modelrun" from GeneralSettings

        dynamicData = Dict{Int16, DayData}()

        # Get climate for default variables . !Gives just one year as environment is not yet changing between years
        environment = simulateEnvironment(settings, dynamicData)
        # Output: temp, irradiance, waterlevel, lightAttenuation

        # Get macrophytes in multiple depths
        result = simulateMultipleDepth_parallel(depths,settings, dynamicData) #Biomass, Number, indWeight, Height,
        # Save results as .csv files in new folder;
        writeOutput(settings, depths, environment, result, GeneralSettings, folder)

    end
end



"""
# Multi Threaded Loop for model run for selected lakes, species and depths
write_lock = ReentrantLock()

Threads.@threads for l in 1:length(GeneralSettings["lakes"])
    println(GeneralSettings["lakes"][l])

    for s in 1:length(GeneralSettings["species"])

        println(GeneralSettings["species"][s])

        #Get settings
        settings = getsettings(GeneralSettings["lakes"][l], GeneralSettings["species"][s])
        push!(settings, "years" => parse.(Int64,GeneralSettings["years"])[1]) #add "years" from GeneralSettings
        push!(settings, "yearsoutput" => parse.(Int64,GeneralSettings["yearsoutput"])[1]) #add "years" from GeneralSettings
        push!(settings, "modelrun" => GeneralSettings["modelrun"][1]) #add "modelrun" from GeneralSettings

        dynamicData = Dict{Int16, DayData}()

        # Get climate for default variables . !Gives just one year as environment is not yet changing between years
        # also used to Initialize dynamicData
        environment = simulateEnvironment(settings, dynamicData)
        # Output: temp, irradiance, waterlevel, lightAttenuation

        # Get macrophytes in multiple depths
        result = simulateMultipleDepth_parallel(depths,settings, dynamicData) #Biomass, Number, indWeight, Height,

        lock(write_lock)
        try
            # Save results as .csv files in new folder;
            writeOutput(settings, depths, environment, result, GeneralSettings, folder)
        finally
            unlock(write_lock)
        end
    end
end

println("Done with MultiThreaded Lake Loop")
"""
