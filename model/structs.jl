"""
Structs for more efficiently storing dynamic data
"""

Base.@kwdef mutable struct DayData
        # getSurfaceIrradianceDay(day, settings::Dict{String, Any})
        surfaceIrradiance::Union{Missing, Float64} = missing

        # getSurfaceIrradianceHour(day, hour, settings::Dict{String, Any}) #times in hour after sunset
        surfaceIrradianceHour::Dict{Int8, Float64} = Dict{Int8, Float64}()

        # getTemperature(day, settings::Dict{String, Any})
        temperature::Union{Missing, Float64} = missing

        # getDaylength(day, settings::Dict{String, Any})
        daylength::Union{Missing, Float64} = missing

        # getWaterlevel(day, settings::Dict{String, Any})
        waterlevel::Union{Missing, Float64} = missing

        # getLightAttenuation(day, settings::Dict{String, Any})
        lightAttenuation::Union{Missing, Float64} = missing
end
