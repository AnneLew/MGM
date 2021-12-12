
include("structs.jl")


alaldict = Dict{Int16, DayData}()

alaldict[1] = DayData()

alaldict[1].daylength = 1.1

if ismissing(alaldict[1].waterlevel)
    println("waterlvl is missing!")
    alaldict[1].waterlevel = 5.2
end

if ismissing(alaldict[1].waterlevel)
    println("waterlvl is missing!")
    alaldict[1].waterlevel = 5.2
else
    println(alaldict[1].waterlevel)
end

print(alaldict[1])

data = DayData()

println(data)

"""
include("defaults.jl")
include("input.jl")
include("functions.jl")
include("run_simulation.jl")
include("output.jl")

function setdir()
    cd(dirname(@__DIR__))
end

function get_settings()
    cd(dirname(@__DIR__))
    GeneralSettings = parseconfigGeneral("./input/general.config.txt")
    settings = getsettings(GeneralSettings["lakes"][1], GeneralSettings["species"][1])
    cd("model\\")
    return settings
end

function test_runtime(settings)
    dict = Dict{Int16, Float64}()
    for d = 2:settings["yearlength"]
          dict[d] = getSurfaceIrradianceDay(d, settings)
    end
    return dict
end

function test_dict_runtime(settings::Dict{String, Any}, dict::Dict{Int16, Float64})
    dict2 = Dict{Int16, Float64}()
    for d = 2:settings["yearlength"]
          dict2[d] = dict[d]
    end
end

function getSurfaceIrradianceDay(day, settings::Dict{String, Any})
    SurfaceIrradianceDay =
        settings["maxI"] - (
            ((settings["maxI"] - settings["minI"]) / 2) *
            (1 + cos((2 * pi / settings["yearlength"]) * (day - settings["iDelay"])))
        )
    return (SurfaceIrradianceDay)
end
"""


## Test / Plot getEffectiveIrradianceHour
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
#depths = parse.(Float64, GeneralSettings["depths"])



using Plots, LaTeXStrings

plotlyjs()

## Effective Irradiance Function at ground
fig = plot(ratio=0.05, xlims=(0, 10), ylims=(0, 70)); # produces an empty plot
for l in 1:length(GeneralSettings["lakes"])
    s=1
    settings = getsettings(GeneralSettings["lakes"][l], GeneralSettings["species"][s])
    dynamicData = Dict{Int16, DayData}()
    environment = simulateEnvironment(settings, dynamicData)
    plot!(fig, 0:0.1:10, x -> getEffectiveIrradianceHour(90, 8, x, 0.0, 0.0, 0.0, 0.0, -x, settings, dynamicData), xlabel="depth [m]",ylabel="EffectiveIrradianceHour [µE m^-2 s^-1]",label=L"lakeID = %$l",legend=false) # the loop fills in the plot with this
end
fig
savefig("doc/TRACE_figures\\getEffectiveIrradianceHour_day90_hour8.html")


# Effective Irradiance in one depths
fig = plot(ratio=00, xlims=(0, 365), ylims=(0, 80)); # produces an empty plot
for l in 1:length(GeneralSettings["lakes"])
    s=1
    settings = getsettings(GeneralSettings["lakes"][l], GeneralSettings["species"][s])
    dynamicData = Dict{Int16, DayData}()
    environment = simulateEnvironment(settings, dynamicData)
    plot!(fig, 1:1:365, x -> getEffectiveIrradianceHour(x, 8, 5.0, 0.0, 0.0, 0.0, 0.0, -5.0, settings, dynamicData), xlabel="day",ylabel="EffectiveIrradianceHour [µE m^-2 s^-1]",label=L"lakeID = %$l",legend=false) # the loop fills in the plot with this
end
fig
savefig("doc/TRACE_figures\\getEffectiveIrradianceHour_depth5m_hour8.html")

# TEMPERATURE
function tempFAC(day,settings, dynamicData)
    temp = getTemperature(day, settings, dynamicData)
    tempFactor =
        (settings["sPhotoTemp"] * (temp^settings["pPhotoTemp"])) /
        ((temp^settings["pPhotoTemp"]) + (settings["hPhotoTemp"]^settings["pPhotoTemp"]))
end
#tempFAC(60, settings, dynamicData)

fig = plot(ratio=100, xlims=(0, 365), ylims=(0, 1)); # produces an empty plot
for l in 1:length(GeneralSettings["lakes"])

    println(GeneralSettings["lakes"][l])
    s=1
    settings = getsettings(GeneralSettings["lakes"][l], GeneralSettings["species"][s])
    dynamicData = Dict{Int16, DayData}()
    environment = simulateEnvironment(settings, dynamicData)


    plot!(fig, 1:1:365, x -> tempFAC(x, settings, dynamicData), xlabel="days",ylabel="tempFAC",label=L"lakeID = %$l",legend=false) # the loop fills in the plot with this

end
fig
savefig("doc/TRACE_figures\\fig_tempFAC.html")


# NUTRIENTS

function nutFAC(settings)
    nutrientConc=settings["maxNutrient"]
    nutrientFactor =
        (nutrientConc^settings["pNutrient"]) /
        (nutrientConc^settings["pNutrient"] + settings["hNutrient"]^settings["pNutrient"])
end

fig = plot(ratio=100, xlims=(0, 365), ylims=(0, 1)); # produces an empty plot
for l in 1:length(GeneralSettings["lakes"])
    s=1
    settings = getsettings(GeneralSettings["lakes"][l], GeneralSettings["species"][s])
    #dynamicData = Dict{Int16, DayData}()
    #environment = simulateEnvironment(settings, dynamicData)


    plot!(fig, 1:1:365, x -> nutFAC(settings), xlabel="days",ylabel="nutFAC",label=L"lakeID = %$l",legend=false) # the loop fills in the plot with this

end
fig
savefig("doc/TRACE_figures\\fig_nutFAC_exemplSpec.html")



# PHOTOSYNTHESIS hour
fig = plot(ratio=10, xlims=(0, 10), ylims=(0, 0.5)); # produces an empty plot
for l in 1:length(GeneralSettings["lakes"])
    s=1
    settings = getsettings(GeneralSettings["lakes"][l], GeneralSettings["species"][s])
    dynamicData = Dict{Int16, DayData}()
    environment = simulateEnvironment(settings, dynamicData)

    plot!(fig, 0:0.1:10.0, x -> getPhotosynthesis(180, 8, 0, 0.0,0.0,0,0,-x, settings,dynamicData),
        xlabel="depths",ylabel="PS",label=L"lakeID = %$l",legend=false) # the loop fills in the plot with this

end
fig
savefig("doc/TRACE_figures\\fig_PShour_day180_hour8_exemplSpec_atPlanttop.html")


# PS daily
fig = plot(ratio=10, xlims=(0, 10), ylims=(0, 1.2)); # produces an empty plot
for l in 1:length(GeneralSettings["lakes"])
    s=1
    settings = getsettings(GeneralSettings["lakes"][l], GeneralSettings["species"][s])
    dynamicData = Dict{Int16, DayData}()
    environment = simulateEnvironment(settings, dynamicData)

    plot!(fig, 0.3:0.1:10.0, x -> getPhotosynthesisPLANTDay(180, 0.35, 0.35,1.0,1.0,-x, settings,dynamicData),
        xlabel="depths",ylabel="PS daily",label=L"lakeID = %$l",legend=false) # the loop fills in the plot with this

end
fig
savefig("doc/TRACE_figures\\fig_PSdaily_day180_exemplSpec_Height0.35_Biomass1.0.html")

# PS daily over year
fig = plot(ratio=150, xlims=(0, 365), ylims=(0, 0.7)); # produces an empty plot
for l in 1:length(GeneralSettings["lakes"])
    s=1
    settings = getsettings(GeneralSettings["lakes"][l], GeneralSettings["species"][s])
    dynamicData = Dict{Int16, DayData}()
    environment = simulateEnvironment(settings, dynamicData)

    plot!(fig, 1:1:365, x -> getPhotosynthesisPLANTDay(x, 0.35, 0.35,1.0,1.0,-3.0, settings,dynamicData),
        xlabel="depths",ylabel="PS daily",label=L"lakeID = %$l",legend=false) # the loop fills in the plot with this

end
fig
savefig("doc/TRACE_figures\\fig_PSdaily_exemplSpec_Height0.35_Biomass1.0_withoutGrowth_depth3m.html")


# Respiration
fig = plot(ratio=1000, xlims=(0, 365), ylims=(0, 0.1)); # produces an empty plot
for l in 1:length(GeneralSettings["lakes"])
    s=1
    settings = getsettings(GeneralSettings["lakes"][l], GeneralSettings["species"][s])
    dynamicData = Dict{Int16, DayData}()
    environment = simulateEnvironment(settings, dynamicData)

    plot!(fig, 1:1:365, x -> getRespiration(x, settings,dynamicData),
        xlabel="depths",ylabel="Resp daily",label=L"lakeID = %$l",legend=false) # the loop fills in the plot with this

end
fig
savefig("doc/TRACE_figures\\fig_Respiration_exemplSpec.html")

# GROWTH
function getDailyGrowth(
    seeds::Float64,
    biomass1::Float64,
    allocatedBiomass1::Float64,
    dailyPS::Float64,
    dailyRES::Float64,
    settings::Dict{String,Any},
)
