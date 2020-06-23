# Output functions for

"""
function writedata(world::Array{Patch,1}, settings::Dict{String, Any}, timestep::Int)
        filename = "Macro" * string(settings["latitude"]) #Nonsense, just for testing
        filename = joinpath(string(settings["BackgroundMort"]), filename)
        filename = filename * ".tsv"
        simlog("Writing data \"$filename\"", settings)
        open(filename, "w") do file
            dumpinds(Res1, Res2)
        end
   end
"""
