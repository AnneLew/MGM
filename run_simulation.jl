"""
SIMULATION
"""

include("CHARISMA.jl")
include("defaults.jl")
include("input.jl")

settings = getsettings()

using Plots

function simulate(;yearlength::Int64=settings["yearlength"],
	initBiomass::Float64=settings["initBiomass"], germinationDay::Int64=settings["germinationDay"], heightMax::Float64=settings["heightMax"],
	rootShootRatio::Float64=settings["rootShootRatio"], BackgroundMort::Float64=settings["BackgroundMort"],
	resp20::Float64=settings["resp20"], q10::Float64=settings["q10"],
	latitude::Float64=settings["latitude"], LevelOfGrid::Float64=settings["LevelOfGrid"], maxW::Float64=settings["maxW"],
	minW::Float64=-settings["minW"], wDelay::Int64=settings["wDelay"],levelCorrection::Float64=settings["levelCorrection"],
	parFactor::Float64=settings["parFactor"], fracReflected::Float64=settings["fracReflected"], iDev::Float64=settings["iDev"],
	plantK::Float64=settings["plantK"], fracPeriphyton::Float64=settings["fracPeriphyton"],
	maxI::Float64=settings["maxI"], minI::Float64=settings["minI"], iDelay::Int64=settings["iDelay"],
	kdDev::Float64=settings["kdDev"], maxKd::Float64=settings["maxKd"], minKd::Float64=settings["minKd"],kdDelay::Float64=settings["kdDelay"],
	hPhotoDist::Float64=settings["hPhotoDist"], hPhotoLight::Float64=settings["hPhotoLight"],
	tempDev::Float64=settings["tempDev"], maxTemp::Float64=settings["maxTemp"], minTemp::Float64=settings["minTemp"], tempDelay::Int64=settings["tempDelay"],
	sPhotoTemp::Float64=settings["sPhotoTemp"], pPhotoTemp::Float64=settings["pPhotoTemp"], hPhotoTemp::Float64=settings["hPhotoTemp"],
	pMax::Float64=settings["pMax"], maxAge::Int64=settings["maxAge"],maxWeightLenRatio::Float64=settings["maxWeightLenRatio"],
	seedInitialBiomass::Float64=settings["seedInitialBiomass"],seedFraction::Float64=settings["seedFraction"],
	cTuber::Float64=settings["cTuber"], seedGermination::Float64=settings["seedGermination"],seedBiomass::Float64=settings["seedBiomass"],
	seedsStartAge::Int64=settings["seedsStartAge"],seedsEndAge::Int64=settings["seedsEndAge"],reproDay::Int64=settings["reproDay"],
	SeedMortality::Float64=settings["SeedMortality"],
		backgrKd::Float64=settings["backgrKd"],hTurbReduction::Float64=settings["hTurbReduction"],pTurbReduction::Float64=settings["pTurbReduction"])

	#Initialisation
	Seeds = zeros(Float64, yearlength, 4) #SeedBiomass, SeedNumber, SeedsGerminatingBiomass, SeedsGerminatingNumber
	superInd = zeros(Float64, yearlength, 5) #Biomass, Number, indWeight, Height, allocatedBiomass

	Seeds[1,1] = seedInitialBiomass #initial SeedBiomass
	superInd[1,1] = initBiomass #initial Biomass
	Seeds[1,2]=getNumberOfSeeds(Seeds[1,1]) #initial SeedNumber

	#Until Germination Starts
	for d in 2:germinationDay
	  Seeds[d,1] = Seeds[d-1,1] - Seeds[d-1,1] * SeedMortality #minus SeedMortality #SeedBiomass
	  superInd[d,1] = superInd[d-1,1] #Plant Biomass
	  Seeds[d,2]=getNumberOfSeeds(Seeds[d,1]) #SeedNumber
	  Seeds[d,4]=getNumberOfSeeds(Seeds[d,3]) #SeedsGerminatingNumber
	end

	#GERMINATION
	Seeds[germinationDay,3] = Seeds[germinationDay-1,1] * seedGermination #20% of the SeedsBiomass are transformed to SeedsGerminatingBiomass
	Seeds[germinationDay,1] = Seeds[germinationDay-1,1] - Seeds[germinationDay,3] - Seeds[germinationDay-1,1] * SeedMortality#Remaining SeedsBiomass
	superInd[germinationDay,2] = getNumberOfSeeds(Seeds[germinationDay,3]) #Germinated Individuals
	superInd[germinationDay,1] = superInd[germinationDay-1,1]
	superInd[germinationDay+1,1] = superInd[germinationDay,1]
	superInd[germinationDay,3] =  getIndividualWeight(superInd[germinationDay,1], superInd[germinationDay,2]) #individualWeight = Biomass /

	#GROWTH
	for d in (germinationDay+1):(germinationDay+maxAge)
		Seeds[d,1] = Seeds[d-1,1] - Seeds[d-1,1] * SeedMortality #minus SeedMortality #SeedBiomass
		Seeds[d,3] = (1-cTuber)*Seeds[d-1,3] #Reduction of allocatedBiomass untill it is used
		Seeds[d,2]=getNumberOfSeeds(Seeds[d,1]) #SeedNumber
		Seeds[d,4]=getNumberOfSeeds(Seeds[d,3]) #allocatedSeedNumber
		superInd[d,2] = superInd[d-1,2] #PlantNumber stays the same !!! MORTALITY ?????


		#GROWTH
		dailyRES = getRespiration(d, resp20=resp20, q10=q10)
	  dailyPS = getPhotosynthesisPLANTDay(d, superInd[d-1,4], biomass=superInd[d-1,1],latitude=latitude, LevelOfGrid=LevelOfGrid, yearlength=yearlength,
	      maxW=maxW, minW=minW, wDelay=wDelay, levelCorrection=levelCorrection,
		  	hPhotoDist=hPhotoDist, parFactor=parFactor, fracReflected=fracReflected, iDev=iDev, plantK=plantK, fracPeriphyton=fracPeriphyton,
		  	minI=minI, maxI=maxI, iDelay=iDelay, kdDev=kdDev, maxKd=maxKd, minKd=minKd, kdDelay=kdDelay, hPhotoLight=hPhotoLight,
		backgrKd=backgrKd, hTurbReduction=hTurbReduction,pTurbReduction=pTurbReduction,
				tempDev=tempDev, maxTemp=maxTemp, minTemp=minTemp, tempDelay=tempDelay, sPhotoTemp=sPhotoTemp, pPhotoTemp=pPhotoTemp, hPhotoTemp=hPhotoTemp, pMax=pMax)[1]

		#Biomass calc
	  superInd[d,1] = superInd[d-1,1] + Seeds[d,3]*cTuber +
			(((1-rootShootRatio)*superInd[d-1,1] - superInd[d-1,5])*dailyPS - superInd[d-1,1]*(dailyRES + BackgroundMort))

		superInd[d,3] =  getIndividualWeight(superInd[d,1], superInd[d,2]) #individualWeight = Biomass / Number

		#Thinning
		#Thinning = dieTinning(superInd[d,2],superInd[d,3]) #Adapts number of individuals [/m^2]& individual weight
		#superInd[d,2] = Thinning[1]
		#superInd[d,3] = Thinning[2]

		#Height calc
		superInd[d,4] = growHeight(superInd[d-1,4], superInd[d,3], maxWeightLenRatio=maxWeightLenRatio) #!!!QUATSCH??
		if superInd[d,4] >= heightMax
			superInd[d,4] = heightMax
		end
		WaterDepth = getWaterDepth(d, LevelOfGrid=LevelOfGrid, yearlength=yearlength, maxW=maxW, minW=minW, wDelay=wDelay, levelCorrection=levelCorrection)
		if superInd[d,4] >= WaterDepth
			superInd[d,4] = WaterDepth
		end

		#ALLOCATION OF BIOMASS FOR SEED PRODUCTION
		if d > (germinationDay + seedsStartAge) && d < (germinationDay + seedsEndAge)
			superInd[d,5] = superInd[d-1,5] + superInd[d,1]*seedFraction / (seedsEndAge- seedsStartAge) #allocatedBiomass Stimmt das so???
		end
		if d >= (germinationDay + seedsEndAge) && d <= reproDay
			superInd[d,5] = superInd[d,1]*seedFraction #allocatedBiomass - Fraction remains
		end
		#TRANSFORMATION OF ALLOCATED BIOMASS IN SEEDS
		if d == reproDay
			Seeds[d,1] = Seeds[d-1,1] + superInd[d,5] - Seeds[d-1,1] * SeedMortality
		end

	end
	#WINTER
	for d in (germinationDay+maxAge+1):(365)
		superInd[d,4]=0
		superInd[d,1]=0
		superInd[d,2] = 0 #minus Mortality
		Seeds[d,1] = Seeds[d-1,1] - Seeds[d-1,1] * SeedMortality #minus SeedMortality
		Seeds[d,2]=getNumberOfSeeds(Seeds[d,1])
		Seeds[d,4]=getNumberOfSeeds(Seeds[d,3])
	end
	#BRINGT NICHT SO VIEL? :/

  	return (superInd, Seeds)
end

Res = simulate()

plot(Res[1][:,1], label = "biomass")
plot(Res[1][:,2], label = "N")
plot(Res[1][:,3], label = "indWeight")
plot(Res[1][:,4], label = "height")
plot(Res[1][:,5], label = "allocatedBiomass")
plot(Res[2][:,1], label = "SeedsBiomass")
plot(Res[2][:,2], label = "SeedsNR")
plot(Res[2][:,3], label = "SeedsGerminatingBiomass")
plot(Res[2][:,4], label = "SeedsGerminatingNr")



"""
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
