
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
