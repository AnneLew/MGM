# Output functions for normal modelrun

#using DelimitedFiles
#using Dates

function writeOutputMacrophytes(
    PlantResults1...
)
    homdir = pwd()
    dirname = Dates.format(now(), "yyyy_m_d_ HH_MM_SS") # "folder" * * string(settings["latitude"])
    cd(".\\output")
    mkdir(dirname)
    cd(dirname)
    for n in 1:n(results)
        writelm(...)

    end
    writedlm("Plants.csv", PlantResults1[:, :, 1], ',') #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
    #writedlm("Plants_2m.csv", PlantResults2[:, :, 1], ',') #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
    #writedlm("Plants_3m.csv", PlantResults3[:, :, 1], ',') #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
    #writedlm("Plants_4m.csv", PlantResults4[:, :, 1], ',') #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass


    cd(homdir)
end



function writeOutputEnvironmentSettings(
    Env,
    Settings,
)
    homdir = pwd()
    dirname = Dates.format(now(), "yyyy_m_d_ HH_MM_SS") # "folder" * * string(settings["latitude"])
    cd(".\\output")
    mkdir(dirname)
    cd(dirname)
    writedlm("Temp.csv", Env[1], ',')
    writedlm("Irradiance.csv", Env[2], ',')
    writedlm("Waterlevel.csv", Env[3], ',')
    writedlm("lightAttenuation.csv", Env[4], ',')

    writedlm("Settings.csv", Settings, ',')

    cd(homdir)
end
