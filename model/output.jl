"""
    writeOutputMacrophytes(PlantResults)

Output functions for normal modelrun
Code inspiration: GeMM by Ludwig&Daniel
"""

function writeOutputMacrophytes(PlantResults,depths)
    #homdir = pwd()
    #dirname = settings["Lake"] * "_" *settings["Species"] * "_" *Dates.format(now(), "yyyy_m_d_HH_MM") # "folder" * * string(settings["latitude"])
    #cd(".\\output")
    #mkdir(dirname)
    #cd(dirname)

    for i in 1:length(depths)
        j=depths[i]
        writedlm("superInd$j.csv", PlantResults[i][1][:, :, 1], ',') #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
        writedlm("superIndSeed$j.csv", PlantResults[i][2][:, :, 1], ',') #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
        writedlm("superIndTuber$j.csv", PlantResults[i][3][:, :, 1], ',') #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
        writedlm("seeds$j.csv", PlantResults[i][4][:, :, 1], ',') #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
        writedlm("tubers$j.csv", PlantResults[i][5][:, :, 1], ',') #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
        writedlm("growthSeeds$j.csv", PlantResults[i][6][:, :, 1], ',') #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
        writedlm("growthTubers$j.csv", PlantResults[i][7][:, :, 1], ',') #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
    end
    #cd(homdir)
end





"""
    writeOutputEnvironmentSettings(Env,Settings,)

Code inspiration: GeMM by Ludwig&Daniel

"""

function writeOutputEnvironmentSettings(
    Env,
    Settings,
)
    #homdir = pwd()
    #dirname = settings["Lake"] * "_" *settings["Species"] * "_" *Dates.format(now(), "yyyy_m_d_HH_MM") # "folder" * * string(settings["latitude"])
    #cd(".\\output")
    #mkdir(dirname)
    #cd(dirname)
    writedlm("Temp.csv", Env[1], ',')
    writedlm("Irradiance.csv", Env[2], ',')
    writedlm("Waterlevel.csv", Env[3], ',')
    writedlm("lightAttenuation.csv", Env[4], ',')

    writedlm("Settings.csv", Settings, ',')

    #cd(homdir)
end

"""
    writeGeneralSettings(Env,Settings,)

Code inspiration: GeMM by Ludwig&Daniel

"""

function writeGeneralSettings(
    GeneralSettings,
)
    #homdir = pwd()
    #dirname = settings["Lake"] * "_" *settings["Species"] * "_" *Dates.format(now(), "yyyy_m_d_HH_MM") # "folder" * * string(settings["latitude"])
    #cd(".\\output")
    #mkdir(dirname)
    #cd(dirname)
    writedlm("GeneralSettings.csv", GeneralSettings, ',')
    #cd(homdir)
end

"""
    writesettings(settings)

Record the settings actually used for a simulation run (cf. `getsettings`).
Creates a config file that can be used for future replicate runs.
Also records a time stamp and the current git commit.

Code source: GeMM by Ludwig&Daniel

"""

#function writesettings(settings::Dict{String, Any})
#    if isempty(basename(settings["config"]))
#        settingspath = "settings.conf"
#    else
#        settingspath = basename(settings["config"])
#    end
#    open(joinpath(settings["dest"], settingspath), "w") do f
#        println(f, "#\n# --- Island speciation model settings ---")
#        println(f, "# This file was generated automatically.")
#        println(f, "# Simulation run on $(Dates.format(Dates.now(), "d u Y HH:MM:SS"))")
#        #println(f, "# $(split(read(pipeline(`git log`, `head -1`), String), "\n")[1])\n")
#        for k in keys(settings)
#            value = settings[k]
#            if isa(value, String)
#                value = "\"" * value * "\""
#            elseif isa(value, Array)
#                vstr = "\""
#                        for x in value
#                            vstr *= string(x) * ","
#                        end
#                        value = vstr[1:end-1] * "\""
#            end
#            println(f, "$k $value")
#        end
#    end
#end


"""
    writeOutput(settings::Dict{String, Any}, Env,PlantResults)

Creates the output directory and copies relevant files into it.

Souce: GeMM by Leidinger&Vedder
"""

function writeOutput(settings::Dict{String, Any}, depth, Env, PlantResults, GeneralSettings,dest)
    homdir = pwd()
    cd(".\\output")

    dirname = dest
    if isdir(dirname)
        @warn "$(settings["dest"]) exists. Continuing anyway. Overwriting of files possible."
    else
        mkpath(dirname)
    end

    cd(dirname)
    writeGeneralSettings(GeneralSettings)
    dirname2 = settings["Lake"] * "_" *settings["Species"]
    if isdir(dirname)
        @warn "$(settings["dest"]) exists. Continuing anyway. Overwriting of files possible."
    else
        mkpath(dirname2)
    end
    cd(dirname2)
    #simlog("Setting up output directory $(settings["dest"])", settings)
    writeOutputEnvironmentSettings(Env, settings)
    writeOutputMacrophytes(PlantResults, depths)
    cd(homdir)

end
