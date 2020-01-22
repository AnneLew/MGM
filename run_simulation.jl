"""
SIMULATION START
"""

include("Initialisation.jl")
include("Resp_PS.jl")
include("defaults.jl")
include("input.jl")

settings = getsettings()


#function simulate(settings::Dict{String, Any})
# Initialize Climate
worldlist = initializeClim(yearlength=settings["yearlength"], tempDev=settings["tempDev"], tempMax=settings["tempMax"],
    tempMin=settings["tempMin"], tempLag=settings["tempLag"],	maxI=settings["maxI"], minI=settings["minI"],
    iDelay=settings["iDelay"], lat=settings["lat"])
temp = worldlist[1]
irradianceTotal = worldlist[2]
daylength = worldlist[3]

# Initialize empty Data structures
weight = zeros(Float64, settings["yearlength"])
height = zeros(Float64, settings["yearlength"])
photosynDay = zeros(Float64, settings["yearlength"])

#lightPlantHr = matrix(data=0, nrow = 24, ncol=yearlength)
lightPlantHr = Array{Float64}[]
#photosynHr = zeros(Float64, settings["yearlength"])
photosynHr = Array{Float64}[]

irradHr = Array{Float64}[]
for d in 1:(settings["growthStart"]-1)
  push!(irradHr, [0.0])
  push!(lightPlantHr, [0.0])
  push!(photosynHr, [0.0])
end

#Calculate Respiration
respiration = getRespiration.(temp, resp20=settings["resp20"], q10=settings["q10"], t1=settings["t1"])

# Befor growth starts
for d in 1:settings["growthStart"]
  height[d] = settings["lengthInit"]
  weight[d] = settings["weightInit"]
end

for d in settings["growthStart"]:(settings["yearlength"]-1)
  #Check for plant growth parameter
  if settings["heightMax"] > settings["depthWater"]
    settings["heightMax"] = settings["depthWater"]
  end
  #Height growth limitation
  if height[d] >= settings["heightMax"]
    height[d] = settings["heightMax"]
  end
  if height[d] < 0
    height[d] = 0
  end

  x = initializeIrradianceD(daylength, d, irradianceTotal)
  push!(irradHr, x)
  lightPlantHr = getLightD.(irradHr[d], parFactor=settings["parFactor"], fracReflected=settings["fracReflected"], sunDev=settings["sunDev"],
                         kdDev=settings["kdDev"], maxKd=settings["maxKd"], minKd=settings["minKd"], yearlength=settings["yearlength"], kdDelay=settings["kdDelay"],
                         distWaterSurface=(settings["depthWater"]), plantK=settings["plantK"], higherbiomass=0.0, fracPeriphyton=settings["fracPeriphyton"], day=d) ##MISSING: different depths
  photosynHr = getPhotosynthesis.(temp[d], lightPlantHr, 1.0, hPhotoLight=settings["hPhotoLight"],
                                    sPhotoTemp=settings["sPhotoTemp"], pPhotoTemp=settings["pPhotoTemp"], hPhotoTemp=settings["hPhotoTemp"],
                                    hPhotoDist=settings["hPhotoDist"], pMax=settings["pMax"])
#  for i in [0.0:0.1:height[d];]
#    lightPlantHr = getLightD.(irradHr[d], parFactor=settings["parFactor"], fracReflected=settings["fracReflected"], sunDev=settings["sunDev"],
#                       kdDev=settings["kdDev"], maxKd=settings["maxKd"], minKd=settings["minKd"], yearlength=settings["yearlength"], kdDelay=settings["kdDelay"],
#                       distWaterSurface=(settings["depthWater"]-i), plantK=settings["plantK"], higherbiomass=0.0, fracPeriphyton=settings["fracPeriphyton"], day=d) ##MISSING: different depths
#    #photosynHrDepth = 0
#    photosynHrDepth = photosynHrDepth + ((1/(height[d]/0.1)) * getPhotosynthesis.(temp[d], lightPlantHr, 1.0, hPhotoLight=settings["hPhotoLight"],
#                             sPhotoTemp=settings["sPhotoTemp"], pPhotoTemp=settings["pPhotoTemp"], hPhotoTemp=settings["hPhotoTemp"],
#                             hPhotoDist=settings["hPhotoDist"], pMax=settings["pMax"]))
#  end

  photosynDay[d] = sum(photosynHr)

  weight[d+1] = weight[d] + growWeight.(weight[d], photosynDay[d], respiration[d]) #
  height[d+1] = growHeight.(height[d], weight[d+1], weight[d])
end
weight[365] = weight[364]
height[365] = height[364]
photosynDay[365] = photosynDay[364]

return(weight, height, photosynDay)
#end

#result = simulate(settings)


using Plots
pyplot() # Choose the Plotly.jl backend for web interactivity
#plot(result[1],linewidth=2,label="weight")
#plot(result[2], linewidth=2, label="height")
#plot(result[3],linewidth=2,label="PS")


plot(weight,linewidth=2,label="weight")
plot(height, linewidth=2, label="height")
plot(photosynDay,linewidth=2,label="PS")

"""
function runsim(yearlength, tempMax, tempMin, tempLag, tempDev, maxI, minI, sIDelay, sLatitude, #Initialisation
                       init_weight, init_length,Start_of_growth, Water_depth, max_Plant_height,
                       sResp20, sQ10, sT1, #RESPIRATION
                       sIrradiance_hour, sPARFactor, sFracReflected, sSunDev, sKdDev, smaxKd, sminKd, sday, sKdDelay, sdist_water_surface, sPlantK, shigherbiomass,sfracPeriphyton, #LIGHT
                       light_plant_hour, shPhotoLight, ssPhotoTemp, spPhotoTemp, shPhotoTemp, shPhotoDist, sPmax, sbicarbonate_conc, shCarbonate, spCarbonate, #Nutrient_conc, pNutrient, hNutrient, #PHOTOSYNTHESIS
                       sRootShootRatio, sMortality_rate)
  #worldlist = initializeClim(days = yearlength, TempMax = tempMax, TempMin=tempMin, TempLag = tempLag, TempDev=tempDev, maxI=maxI, minI=minI, IDelay=sIDelay, Latitude=sLatitude)
  #temp = worldlist[1]
  #irradianceTotal = worldlist[2]
  #daylength = worldlist[3]
  #Plant_weight = vector(mode="numeric",length=(yearlength-1))
  #Plant_height = vector(mode="numeric",length=(yearlength-1))
  #PSrate = vector(mode="numeric",length=yearlength-1)
  #Resp<-Respiration(Resp20=sResp20, Q10=sQ10, Temp, T1=sT1)
  #for (d in 1:(Start_of_growth)){
  #  Plant_height[d] = init_length
  #  Plant_weight[d] = init_weight
  #}
  #Irrad_hour = matrix(data=0, nrow = 24, ncol=yearlength)
  #light_pla = matrix(data=0, nrow = 24, ncol=yearlength)
  #PSrate_hour = matrix(data=0, nrow = 24, ncol=yearlength)
  for (d in Start_of_growth:(yearlength-1)){
    #Check for plant growth parameter
    #if (max_Plant_height>Water_depth){
    #  max_Plant_height = Water_depth
    #}
    #Height growth limitation
    #if (Plant_height[d] >= max_Plant_height){
    #  Plant_height[d] = max_Plant_height
    #}
    #if (Plant_height[d] < 0){
    #  Plant_height[d] = 0
    #}

    #Irrad_hour[,d] = Irradiance_hr(Day_length=Daylength_value, day=d, Irradiance_total=Irradiance_tot)


    for (i in seq(0, Plant_height[d], by=0.1)){
      light_pla[,d] = Light(Irradiance_hour=Irrad_hour[,d], PARFactor=sPARFactor, FracReflected=sFracReflected, SunDev=sSunDev,
                             dist_water_surface=(Water_depth-i), PlantK=sPlantK, higherbiomass=shigherbiomass, #depth_planttop[d] muss ersetzt werden
                             fracPeriphyton=sfracPeriphyton, KdDev=sKdDev, maxKd=smaxKd, minKd=sminKd, day=d, KdDelay=sKdDelay, days=yearlength)
      PSrate_hour[,d] = 0
      PSrate_hour[,d] = (PSrate_hour[,d] + ((1/ (Plant_height[d]/0.1))*Photosynthesis(light_plant=light_pla[,d], hPhotoLight=shPhotoLight, Temp=Temp[d], hPhotoDist=shPhotoDist, dist=(Plant_height[d]-i), Pmax=sPmax,sPhotoTemp=ssPhotoTemp, pPhotoTemp=spPhotoTemp, hPhotoTemp=shPhotoTemp,
                                        bicarbonate_conc=sbicarbonate_conc, hCarbonate=shCarbonate, pCarbonate=spCarbonate))) #,Nutrient_conc, pNutrient, hNutrient))
      #PSrate_hour[,d] = PSrate_hour[,d] / (Plant_height[d]/0.1)
      }

    #PSrate[d] = sum(PSrate_hour[,d])
    #Plant_weight[d+1] = Plant_weight[d] + Plants_Weight_Growth(Pla_weight=Plant_weight[d], PS_daily=PSrate[d], RES=Resp[d], RootShootRatio=sRootShootRatio, Mortality_rate=sMortality_rate) #
    #Plant_height[d+1] = Plant_height[d] + Plants_Height_Growth(Pla_height=Plant_height[d], Plant_weight_future=Plant_weight[d+1], Plant_weight_now=Plant_weight[d]) #MaxWeightLenRatio=sMaxWeightLenRatio,
    }

  #PSrate[yearlength] = PSrate[yearlength -1]
  #Resp[yearlength] = Resp[yearlength -1]
  #Plant_height[yearlength] = Plant_height[yearlength-1]

  #Result
  time = c(1:yearlength)
  result = data.frame(time, Irradiance_tot, Temp, Plant_weight, Plant_height, PSrate, Resp, Daylength_value)
  Visualisation(Res=result, Tim=time, Irr=Irradiance_tot, Tem=Temp, PSrate=PSrate, P_we=Plant_weight, P_he=Plant_height, pla_dep=Water_depth)
  return(result)
end
"""
