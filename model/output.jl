# Output functions for normal modelrun

using DelimitedFiles


function writeOutput(PlantResults, ClimResults, Settings)
	writedlm( "Plants_1m.csv",  PlantResults[1][:,:,1], ',') #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
    writedlm( "Plants_2m.csv",  PlantResults[2][:,:,1], ',') #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
    writedlm( "Plants_3m.csv",  PlantResults[3][:,:,1], ',') #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
    writedlm( "Plants_4m.csv",  PlantResults[4][:,:,1], ',') #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass

	writedlm( "Temp.csv",  ClimResults[1], ',')
	writedlm( "Irradiance.csv",  ClimResults[2], ',')
	writedlm( "Daylength.csv",  ClimResults[3], ',')
	writedlm( "Waterlevel.csv",  ClimResults[4], ',')

	writedlm( "Settings.csv",  Settings, ',')
end


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
