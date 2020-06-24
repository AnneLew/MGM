"""
Model for macrophyte growth, similar to CHARISMA (van Nes 2003)
"""

include("defaults.jl")
#get(defaultSettings(), "lat", "NA")
settings = getsettings()

include("Initialisation.jl")
include("Resp_PS.jl")
include("run_simulation.jl")

Clim = initializeClim(yearlength=settings["yearlength"],tempDev=settings["tempDev"],tempMax=settings["maxTemp"], tempMin=settings["minTemp"], tempLag=settings["tempDelay"],
    					maxI=settings["maxI"], minI=settings["minI"], iDelay=settings["iDelay"],
						maxW=settings["maxW"], minW=settings["minW"], wDelay=settings["wDelay"],
						levelCorrection=settings["levelCorrection"],
    					lat=settings["latitude"]) #temp, irra, daylength, waterlevel

Res = simulate4depths() #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass



cd("C:\\Users\\anl85ck\\Desktop\\PhD\\4_Modellierung\\2_CHARISMA\\2_Macroph\\output")
using DelimitedFiles
function write4depths(Result)
 writedlm( "Plant_1m.csv",  Result[1][:,:,1], ',')
 writedlm( "Plant_2m.csv",  Result[2][:,:,1], ',')
 writedlm( "Plant_3m.csv",  Result[3][:,:,1], ',')
 writedlm( "Plant_4m.csv",  Result[4][:,:,1], ',')
end

write4depths(Res)

function writeClim(Results)
	writedlm( "Temp.csv",  Results[1], ',')
	writedlm( "Irradiance.csv",  Results[2], ',')
	writedlm( "Daylength.csv",  Results[3], ',')
	writedlm( "Waterlevel.csv",  Results[4], ',')
end

writeClim(Clim)


#Pkg.add("JLD")
#using JLD
#r = rand(3, 3, 3)
#save("data.jld", "data", Res)
#load("data.jld")["data"]
