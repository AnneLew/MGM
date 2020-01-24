"""
CHARISMA in JULIA
Functions | ENVIRONMENT
"""
# FUNCTION DAYLENGTH FROM R III Author: Robert J. Hijmans, r.hijmans@gmail.com # License GPL3 # Version 0.1  January 2009
# Forsythe, William C., Edward J. Rykiel Jr., Randal S. Stahl, Hsin-i Wu and Robert M. Schoolfield, 1995.
# A model comparison for daylength as a function of latitude and day of the year. Ecological Modeling 80:87-95.

function getDaylength(day; latitude::Float64=47.8)
#	if (class(doy) == 'Date' | class(doy) == 'character')
#		doy = as.character(doy)
#		doy = as.numeric(format(as.Date(doy), "%j"))
#	 else
#		doy = (doy-1) %% 365 + 1
#	end
	latitude >90.0 || latitude <-90.0 && return error("latitude must be between 90.0 & -90.0 Degree")
	p = asin(0.39795 * cos(0.2163108 + 2 * atan(0.9671396 * tan(0.00860*(day-186)))))
	a =  (sin(0.8333 * pi/180) + sin(latitude * pi/180) * sin(p)) / (cos(latitude * pi/180) * cos(p))
	if a < -1
		a = -1
	elseif a > 1
		a = 1
	end
	return(dl::Float64 = 24 - (24/pi) * acos(a))
end

using Plots
plot(getDaylength, 1, 365)


function getTemperature(day;yearlength::Int64=365,
    					tempDev::Float64=1.0, maxTemp::Float64=18.8, minTemp::Float64=1.1, tempDelay::Int64=23)
	tempDev * (maxTemp - ((maxTemp-minTemp)/2)*(1+cos((2*pi/yearlength)*(day-tempDelay))))
end

plot(getTemperature, 1, 365)

function getSurfaceIrradianceDay(day; yearlength::Int64=365,
    					maxI::Float64=868.0, minI::Float64=96.0, iDelay::Int64=-10)
		maxI - (((maxI-minI)/2) * (1+cos((2*pi/yearlength)*(day-iDelay))))
end

plot(getSurfaceIrradianceDay, 1,365)

function getWaterlevel(day; yearlength::Int64=365,
						maxW::Float64=0.3, minW::Float64=-0.3, wDelay::Int64=40,levelCorrection::Float64=0.0)
		levelCorrection + (maxW - (maxW-minW)/2 * (1 + cos((2*pi/yearlength)*(day-wDelay))))
end

plot(getWaterlevel, 1, 365)


function getSurfaceIrradianceHour(day, hour; yearlength::Int64=365,latitude::Float64=47.8,
    					maxI::Float64=868.0, minI::Float64=96.0, iDelay::Int64=-10) #times in hour after sunset
	irradianceD = getSurfaceIrradianceDay(day, yearlength=yearlength, maxI=maxI, minI=minI, iDelay=iDelay)
	daylength = getDaylength(day, latitude=latitude)
	((pi*irradianceD)/(2*daylength))*sin((pi*hour)/daylength)
end


plot(x -> getSurfaceIrradianceHour(x,3), 1:365)

function getLightAttenuation(day; kdDev::Float64=1.0, maxKd::Float64=2.0, minKd::Float64=2.0,
	yearlength::Int=365, kdDelay::Float64=-10.0)
	kdDev * (maxKd - (maxKd-minKd)/2*(2*pi/yearlength)*(day-kdDelay))  #+ Kdisorg + Kparticulates <- TUBRIDITY
end
plot(getLightAttenuation, 1:365)


#MISSING: Calculation of higherbiomass

function getWaterDepth(day; LevelOfGrid::Float64=-1.0, yearlength::Int64=365,
						maxW::Float64=0.1, minW::Float64=-0.1, wDelay::Int64=40,levelCorrection::Float64=0.0)
	WaterDepth = getWaterlevel(day, yearlength=yearlength, maxW=maxW, minW=minW, wDelay=wDelay,
	levelCorrection=levelCorrection) - LevelOfGrid
end

plot(x -> getWaterDepth(x, LevelOfGrid=-1.45), 1, 365)

function distPlantTopFromSurface(day, height; LevelOfGrid::Float64=-1.0, yearlength::Int64=365,
						maxW::Float64=0.3, minW::Float64=-0.3, wDelay::Int64=40,levelCorrection::Float64=0.0)
   distPlantTopFromSurface = getWaterDepth(day, LevelOfGrid=LevelOfGrid, yearlength=yearlength,
   maxW=maxW, minW=minW, wDelay=wDelay, levelCorrection=levelCorrection) - height ##Aktuelle Höhe einfügen
end

plot(x -> distPlantTopFromSurface(x, 0.50, LevelOfGrid=-1.0), 1, 365)

#### TODO #####
function getBiomassAboveZ(distWaterSurface, ) #[g / m^2]
end

function getBiomass() #[g / m^2]
end

####
# The Effect of vegetation on light attenuation : Reduction of turbidity due to plants
function getReducedLightAttenuation(day;
	yearlength::Int64=365, kdDev::Float64=1.0, maxKd::Float64=2.0, minKd::Float64=2.0,kdDelay::Float64=-10.0,
	BackgrKd::Float64=1.0, HTurbReduction::Float64=40.0, pTurbReduction::Float64=1.0)
		Biomass = 0 #getBiomass()
		lightAttenuCoef = getLightAttenuation(day, kdDev=kdDev, maxKd=maxKd, minKd=minKd, yearlength=yearlength,kdDelay=kdDelay)
		lightAttenuCoefAdjusted = BackgrKd + (lightAttenuCoef - BackgrKd) * (HTurbReduction ^ pTurbReduction) / (Biomass ^ pTurbReduction + HTurbReduction ^ pTurbReduction)
end

getReducedLightAttenuation(100)
getLightAttenuation(100)



function getEffectiveIrradianceHour(day, hour, distWaterSurface;
		parFactor::Float64=0.5, fracReflected::Float64=0.1, iDev::Float64=0.0,
		plantK::Float64=0.02, fracPeriphyton::Float64=0.2,
		latitude::Float64=47.8,maxI::Float64=868.0, minI::Float64=96.0, iDelay::Int64=-10, yearlength::Int64=365,
		kdDev::Float64=1.0, maxKd::Float64=2.0, minKd::Float64=2.0,kdDelay::Float64=-10.0)
		irrSurfHr = getSurfaceIrradianceHour(day, hour, yearlength=yearlength,latitude=latitude,
    					maxI=maxI, minI=minI, iDelay=iDelay)
		 irrSubSurfHr = irrSurfHr * (1 - parFactor) * (1 - fracReflected) * (1 - iDev) # ÂµE/m^2*s
		 #lightAttenuCoef = getReducedLightAttenuation()
		 lightAttenuCoef = getLightAttenuation(day, kdDev=kdDev, maxKd=maxKd, minKd=minKd, yearlength=yearlength,kdDelay=kdDelay)
		 higherbiomass = 0 #getBiomassAboveZ()
	     lightWater = irrSubSurfHr * exp(1)^(- lightAttenuCoef * distWaterSurface - plantK * higherbiomass) # LAMBERT BEER # ÂµE/m^2*s # MÃ¶glichkeit im Exponenten: (absorptivity*c_H2O_pure*dist_water_surface))
	     lightPlantHour = lightWater - (lightWater * fracPeriphyton) ## ÂµE/m^2*s
	return lightPlantHour
end

getEffectiveIrradianceHour(150, 6, 0.5, latitude=14.0, maxKd=2.4)



"""
Functions |  Growth
"""
function getRespiration(day; resp20::Float64=0.00193, q10::Float64=2.0) #DAILY VALUE
    Temper = getTemperature(day)
	resp20 * q10^((Temper - 20.0)/10)
end
getRespiration(180)

#Photosynthesis (Biomass brutto growth) (g g^-1 h^-1)
function getPhotosynthesis(day, hour, distWaterSurf; height::Float64=0.3,
	LevelOfGrid::Float64=-1.0, yearlength::Int64=365,maxW::Float64=0.3, minW::Float64=-0.3, wDelay::Int64=40,levelCorrection::Float64=0.0,
	    hPhotoDist::Float64=1.0,
	parFactor::Float64=0.5, fracReflected::Float64=0.1, iDev::Float64=0.0,plantK::Float64=0.02, fracPeriphyton::Float64=0.2,
	latitude::Float64=47.8,maxI::Float64=868.0, minI::Float64=96.0, iDelay::Int64=-10,kdDev::Float64=1.0, maxKd::Float64=2.0, minKd::Float64=2.0,kdDelay::Float64=-10.0,
	hPhotoLight::Float64=14.0,
	tempDev::Float64=1.0, maxTemp::Float64=18.8, minTemp::Float64=1.1, tempDelay::Int64=23,
    sPhotoTemp::Float64=1.35, pPhotoTemp::Float64=3.0, hPhotoTemp::Float64=14.0,
    #bicarbonateConc, hCarbonate, pCarbonate,
    #nutrientConc, pNutrient, hNutrient,
    pMax::Float64=0.006) ##Einheit: g / g * h

  distFromPlantTop = distWaterSurf - distPlantTopFromSurface(day, height, LevelOfGrid=LevelOfGrid, yearlength=yearlength, maxW=maxW, minW=minW, wDelay=wDelay, levelCorrection=levelCorrection)
  distFactor = hPhotoDist / (hPhotoDist + distFromPlantTop) #m

  lightPlantHour = getEffectiveIrradianceHour(day, hour, distWaterSurf, parFactor=parFactor, fracReflected=fracReflected, iDev=iDev, plantK=plantK, fracPeriphyton=fracPeriphyton,
  	latitude=latitude, maxI=maxI, minI=minI, iDelay=iDelay, yearlength=yearlength, kdDev=kdDev, maxKd=maxKd, minKd=minKd, kdDelay=kdDelay)
  lightFactor = lightPlantHour / (lightPlantHour + hPhotoLight) #ÂµE m^-2 s^-1); The default half-saturation constants (C aspera 14 yE m-2s-1; P pectinatus 52) are based on growth experiments

  temp = getTemperature(day, yearlength=yearlength, tempDev=tempDev, maxTemp=maxTemp, minTemp=minTemp, tempDelay=tempDelay)
  tempFactor = (sPhotoTemp * temp ^ pPhotoTemp) / (temp ^ pPhotoTemp + hPhotoTemp ^ pPhotoTemp) #Â°C

  #bicarbFactor = bicarbonateConc ^ pCarbonate / (bicarbonateConc ^ pCarbonate + hCarbonate ^ pCarbonate) # C.aspera hCarbonate=30 mg/l; P.pectinatus hCarbonate=60 mg/l
  #nutrientFactor <- nutrientConc ^ pNutrient / (nutrientConc ^ pNutrient + hNutrient ^ pNutrient)

  psHour = pMax * lightFactor * tempFactor * distFactor #* bicarbFactor #* nutrientFactor #(g g^-1 h^-1)
  return (psHour) ##Einheit: g / g * h
end


getPhotosynthesis(180, 12, 0.1, height=0.1, LevelOfGrid=-4.0, latitude=22.0)

using Plots
plot(x -> getPhotosynthesis(140,5,x), 0, 2)
plot(x -> getPhotosynthesis(140,x,1.5), 0, 15)
plot(x -> getPhotosynthesis(x,5,1.5), 100, 300)

#INTEGRATION ÜBER TIEFE VON WaterDepth bis distPlantTopFromSurface
#INTEGRATION Über daylength
using HCubature
function getPhotosynthesisPLANTDay(day, height;
	latitude::Float64=47.8, LevelOfGrid::Float64=-1.0, yearlength::Int64=365,maxW::Float64=0.3, minW::Float64=-0.3, wDelay::Int64=40,levelCorrection::Float64=0.0,
	    parFactor::Float64=0.5, fracReflected::Float64=0.1, iDev::Float64=0.0,plantK::Float64=0.02, fracPeriphyton::Float64=0.2,
		maxI::Float64=868.0, minI::Float64=96.0, iDelay::Int64=-10,kdDev::Float64=1.0, maxKd::Float64=2.0, minKd::Float64=2.0,kdDelay::Float64=-10.0,
		hPhotoDist::Float64=1.0, hPhotoLight::Float64=14.0,
		tempDev::Float64=1.0, maxTemp::Float64=18.8, minTemp::Float64=1.1, tempDelay::Int64=23,
	    sPhotoTemp::Float64=1.35, pPhotoTemp::Float64=3.0, hPhotoTemp::Float64=14.0,
	    pMax::Float64=0.006)

	daylength = getDaylength(day, latitude=latitude)
	waterdepth = getWaterDepth(day, LevelOfGrid=LevelOfGrid, yearlength=yearlength, maxW=maxW, minW=minW, wDelay=wDelay, levelCorrection=levelCorrection)
	distPlantTopFromSurf = waterdepth - height
	hcubature(x -> getPhotosynthesis(day, x[1],x[2], height=height, LevelOfGrid=LevelOfGrid, yearlength=yearlength, maxW=maxW, minW=minW, wDelay=wDelay, levelCorrection=levelCorrection,
		hPhotoDist=hPhotoDist, parFactor=parFactor, fracReflected=fracReflected, iDev=iDev, plantK=plantK, fracPeriphyton=fracPeriphyton,
		latitude=latitude, minI=minI, maxI=maxI, iDelay=iDelay, kdDev=kdDev, maxKd=maxKd, minKd=minKd, kdDelay=kdDelay, hPhotoLight=hPhotoLight,
		tempDev=tempDev, maxTemp=maxTemp, minTemp=minTemp, tempDelay=tempDelay, sPhotoTemp=sPhotoTemp, pPhotoTemp=pPhotoTemp, hPhotoTemp=hPhotoTemp, pMax=pMax
		),[0,distPlantTopFromSurf], [daylength,waterdepth])[1]
end

getPhotosynthesisPLANTDay(190, 0.5, latitude=43.1, LevelOfGrid=-4.0)



###Growth
function growBiomass(biomass1, day, height; rootShootRatio::Float64=0.1, BackgroundMort::Float64=0.0,
	resp20::Float64=0.00193, q10::Float64=2.0,
	latitude::Float64=47.8, LevelOfGrid::Float64=-1.0, yearlength::Int64=365,maxW::Float64=0.3, minW::Float64=-0.3, wDelay::Int64=40,levelCorrection::Float64=0.0,
	parFactor::Float64=0.5, fracReflected::Float64=0.1, iDev::Float64=0.0,plantK::Float64=0.02, fracPeriphyton::Float64=0.2,
	maxI::Float64=868.0, minI::Float64=96.0, iDelay::Int64=-10,kdDev::Float64=1.0, maxKd::Float64=2.0, minKd::Float64=2.0,kdDelay::Float64=-10.0,
	hPhotoDist::Float64=1.0, hPhotoLight::Float64=14.0,
	tempDev::Float64=1.0, maxTemp::Float64=18.8, minTemp::Float64=1.1, tempDelay::Int64=23,
	sPhotoTemp::Float64=1.35, pPhotoTemp::Float64=3.0, hPhotoTemp::Float64=14.0,
	pMax::Float64=0.006)

  	dailyRES = getRespiration(day, resp20=resp20, q10=q10)
  	dailyPS = getPhotosynthesisPLANTDay(day, height, latitude=latitude, LevelOfGrid=LevelOfGrid, yearlength=yearlength,
      maxW=maxW, minW=minW, wDelay=wDelay, levelCorrection=levelCorrection,
	  hPhotoDist=hPhotoDist, parFactor=parFactor, fracReflected=fracReflected, iDev=iDev, plantK=plantK, fracPeriphyton=fracPeriphyton,
	  minI=minI, maxI=maxI, iDelay=iDelay, kdDev=kdDev, maxKd=maxKd, minKd=minKd, kdDelay=kdDelay, hPhotoLight=hPhotoLight,
	  tempDev=tempDev, maxTemp=maxTemp, minTemp=minTemp, tempDelay=tempDelay, sPhotoTemp=sPhotoTemp, pPhotoTemp=pPhotoTemp, hPhotoTemp=hPhotoTemp, pMax=pMax)[1]
  biomassGrowth = (1-rootShootRatio)*biomass1*dailyPS - biomass1*(dailyRES + BackgroundMort)
  return (biomassGrowth)
end

growBiomass(5,190,0.5)



function growHeight(height1::Float64, biomass2::Float64, maxWeightLenRatio::Float64=0.03) #,weight1::Float64)
	height = height1 + biomass2 / maxWeightLenRatio
 # height = height1*(biomassB2 / biomassB1) #*MaxWeightLenRatio
  return height
end

growHeight(0.5, 0.01)


function getNumberOfSeedsProducedByOnePlant(Biomass; seedFraction::Float64=0.13, seedBiomass::Float64=0.00002)
	seedNumber = seedFraction * Biomass / seedBiomass
end
getNumberOfSeedsProducedByOnePlant(0.2)

function getNumberOfSeeds(Biomass; seedBiomass::Float64=0.00002)
	seedNumber = Biomass / seedBiomass
end



###############################################################################
###############################################################################
###############################################################################
"""
SIMULATION
"""

include("defaults.jl")
include("input.jl")

settings = getsettings()


function simulate(;yearlength::Int64=settings["yearlength"], lenthInit::Float64=settings["lengthInit"],
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
	pMax::Float64=settings["pMax"], maxAge::Int64=settings["maxAge"],
	seedInitialBiomass::Float64=settings["seedInitialBiomass"],
	cTuber::Float64=settings["cTuber"], seedGermination::Float64=settings["seedGermination"],seedBiomass::Float64=settings["seedBiomass"],
	seedsStartAge::Int64=settings["seedsStartAge"],seedsEndAge::Int64=settings["seedsEndAge"],reproDay::Int64=settings["reproDay"])

	SeedBank = zeros(Float64, yearlength) #Biomass
	SeedsGerminating = zeros(Float64, yearlength) #Biomass
	biomass = zeros(Float64, yearlength)
	height = zeros(Float64, yearlength)
	allocatedBiomass= zeros(Float64, yearlength) #Biomass
#Initialisation
	SeedBank[1] = seedInitialBiomass
	biomass[1] = initBiomass

#Until Germination Starts
	for d in 2:germinationDay
	  SeedBank[d] = SeedBank[d-1] #minus SeedMortality
	  biomass[d] = biomass[d-1]
	end

	#GERMINATION
	SeedsGerminating[germinationDay] = SeedBank[germinationDay-1] * seedGermination #20% of the seeds germinate
	#PlantNr = SeedsGerminating[germinationDay] / seedBiomass
	SeedBank[germinationDay] = (1-SeedsGerminating[germinationDay])*SeedBank[germinationDay-1]

	#GROWTH
	for d in (germinationDay):(germinationDay+maxAge)
		SeedBank[d+1] = SeedBank[d] #minus SeedMortality
		SeedsGerminating[d+1] = (1-cTuber)*SeedsGerminating[d]

		dailyRES = getRespiration(d, resp20=resp20, q10=q10)
	  	dailyPS = getPhotosynthesisPLANTDay(d, height[d-1], latitude=latitude, LevelOfGrid=LevelOfGrid, yearlength=yearlength,
	      maxW=maxW, minW=minW, wDelay=wDelay, levelCorrection=levelCorrection,
		  hPhotoDist=hPhotoDist, parFactor=parFactor, fracReflected=fracReflected, iDev=iDev, plantK=plantK, fracPeriphyton=fracPeriphyton,
		  minI=minI, maxI=maxI, iDelay=iDelay, kdDev=kdDev, maxKd=maxKd, minKd=minKd, kdDelay=kdDelay, hPhotoLight=hPhotoLight,
		  tempDev=tempDev, maxTemp=maxTemp, minTemp=minTemp, tempDelay=tempDelay, sPhotoTemp=sPhotoTemp, pPhotoTemp=pPhotoTemp, hPhotoTemp=hPhotoTemp, pMax=pMax)[1]

	  	biomass[d+1] = biomass[d] + SeedsGerminating[d]*cTuber +
			((1-rootShootRatio)*biomass[d] - allocatedBiomass[d])*dailyPS - biomass[d]*(dailyRES + BackgroundMort)

	  	height[d] = growHeight(height[d-1], biomass[d], biomass[d-1])
	  	if height[d] >= heightMax
			height[d] = heightMax
		end
		WaterDepth = getWaterDepth(d, LevelOfGrid=LevelOfGrid, yearlength=yearlength, maxW=maxW, minW=minW, wDelay=wDelay, levelCorrection=levelCorrection)
		if height[d] >= WaterDepth
			height[d] = WaterDepth
		end
		#ALLOCATION OF BIOMASS FOR SEED PRODUCTION
		if d > germinationDay + seedsStartAge && d < germinationDay + seedsEndAge
			allocatedBiomass[d] = allocatedBiomass[d-1] + biomass[d]*0.08 #???
		end
		if d >= germinationDay + seedsEndAge
			allocatedBiomass[d] = allocatedBiomass[d-1]
			#TRANSFORMATION OF ALLOCATED BIOMASS IN SEEDS
			if d == reproDay
				SeedBank[d+1] = SeedBank[d] + allocatedBiomass[d]
			end
		end
	end
	#WINTER
	for d in (germinationDay+maxAge+1):(365-1)
		height[d]=0
		biomass[d]=0
		SeedBank[d+1] = SeedBank[d] #minus SeedMortality
	end
	#RESULT
  	return (biomass, height,SeedBank, SeedsGerminating,allocatedBiomass)
end

Res = simulate()
plot(Res[1], label = "biomass")
plot(Res[2], label = "height")
plot(Res[3], label = "SeedBank")
plot(Res[4], label = "SeedsGermination")
plot(Res[5], label = "allocatedBiomass")

Res[6]
