# Output functions for normal modelrun

using DelimitedFiles
using Dates

function writeOutput4Depths(PlantResults1, PlantResults2, PlantResults3, PlantResults4,
	Temp, Irra, Waterl, lightAttenu, Settings)
	homdir = pwd()
	dirname = Dates.format(now(), "yyyy_m_d_ HH_MM_SS") # "folder" * * string(settings["latitude"])
	cd(".\\output")
	mkdir(dirname)
    cd(dirname)
	writedlm( "Plants_1m.csv",  PlantResults1[:,:,1], ',') #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
    writedlm( "Plants_2m.csv",  PlantResults2[:,:,1], ',') #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
    writedlm( "Plants_3m.csv",  PlantResults3[:,:,1], ',') #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
    writedlm( "Plants_4m.csv",  PlantResults4[:,:,1], ',') #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass

	writedlm( "Temp.csv",  Temp, ',')
	writedlm( "Irradiance.csv",  Irra, ',')
	writedlm( "Waterlevel.csv",  Waterl, ',')
	writedlm( "lightAttenuation.csv",  lightAttenu, ',')

	writedlm( "Settings.csv",  Settings, ',')

	cd(homdir)
end
