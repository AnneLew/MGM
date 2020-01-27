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

#using Plots
#plot(getDaylength, 1, 365)


function getTemperature(day;yearlength::Int64=365,
    					tempDev::Float64=1.0, maxTemp::Float64=18.8, minTemp::Float64=1.1, tempDelay::Int64=23)
	tempDev * (maxTemp - ((maxTemp-minTemp)/2)*(1+cos((2*pi/yearlength)*(day-tempDelay))))
end

#plot(getTemperature, 1, 365)

function getSurfaceIrradianceDay(day; yearlength::Int64=365,
    					maxI::Float64=868.0, minI::Float64=96.0, iDelay::Int64=-10)
		maxI - (((maxI-minI)/2) * (1+cos((2*pi/yearlength)*(day-iDelay))))
end

#plot(getSurfaceIrradianceDay, 1,365)

function getWaterlevel(day; yearlength::Int64=365,
						maxW::Float64=0.3, minW::Float64=-0.3, wDelay::Int64=40,levelCorrection::Float64=0.0)
		levelCorrection + (maxW - (maxW-minW)/2 * (1 + cos((2*pi/yearlength)*(day-wDelay))))
end

#plot(getWaterlevel, 1, 365)


function getSurfaceIrradianceHour(day, hour; yearlength::Int64=365,latitude::Float64=47.8,
    					maxI::Float64=868.0, minI::Float64=96.0, iDelay::Int64=-10) #times in hour after sunset
	irradianceD = getSurfaceIrradianceDay(day, yearlength=yearlength, maxI=maxI, minI=minI, iDelay=iDelay)
	daylength = getDaylength(day, latitude=latitude)
	((pi*irradianceD)/(2*daylength))*sin((pi*hour)/daylength)
end


#plot(x -> getSurfaceIrradianceHour(x,3), 1:365)

function getLightAttenuation(day; kdDev::Float64=1.0, maxKd::Float64=2.0, minKd::Float64=2.0,
	yearlength::Int=365, kdDelay::Float64=-10.0)
	kdDev * (maxKd - (maxKd-minKd)/2*(2*pi/yearlength)*(day-kdDelay))  #+ Kdisorg + Kparticulates <- TUBRIDITY
end
#plot(getLightAttenuation, 1:365)


#MISSING: Calculation of higherbiomass

function getWaterDepth(day; LevelOfGrid::Float64=-1.0, yearlength::Int64=365,
						maxW::Float64=0.1, minW::Float64=-0.1, wDelay::Int64=40,levelCorrection::Float64=0.0)
	WaterDepth = getWaterlevel(day, yearlength=yearlength, maxW=maxW, minW=minW, wDelay=wDelay,
	levelCorrection=levelCorrection) - LevelOfGrid
end

#plot(x -> getWaterDepth(x, LevelOfGrid=-1.45), 1, 365)

function distPlantTopFromSurface(day, height; LevelOfGrid::Float64=-1.0, yearlength::Int64=365,
						maxW::Float64=0.0, minW::Float64=-0.0, wDelay::Int64=40,levelCorrection::Float64=0.0)
   distPlantTopFromSurface = getWaterDepth(day, LevelOfGrid=LevelOfGrid, yearlength=yearlength,
   maxW=maxW, minW=minW, wDelay=wDelay, levelCorrection=levelCorrection) - height ##Aktuelle Höhe einfügen
end

#plot(x -> distPlantTopFromSurface(x, 0.50, LevelOfGrid=-1.0), 1, 365)

####
# The Effect of vegetation on light attenuation : Reduction of turbidity due to plants
function getReducedLightAttenuation(day, Biomass;
	yearlength::Int64=365, kdDev::Float64=1.0, maxKd::Float64=2.0, minKd::Float64=2.0,kdDelay::Float64=-10.0,
	backgrKd::Float64=1.0, hTurbReduction::Float64=40.0, pTurbReduction::Float64=1.0)
		lightAttenuCoef = getLightAttenuation(day, kdDev=kdDev, maxKd=maxKd, minKd=minKd, yearlength=yearlength,kdDelay=kdDelay)
		lightAttenuCoefAdjusted = backgrKd + (lightAttenuCoef - backgrKd) * (hTurbReduction ^ pTurbReduction) / (Biomass ^ pTurbReduction + hTurbReduction ^ pTurbReduction)
end

#getReducedLightAttenuation(100,5)
#getLightAttenuation(100)


function getBiomassAboveZ(distWaterSurface, height, waterdepth, biomass) #[g / m^2]
	BiomassAboveZ = (height - (waterdepth- distWaterSurface)) / height * biomass
end

getBiomassAboveZ(3,2,4,40)

function getEffectiveIrradianceHour(day, hour, distWaterSurface; Biomass::Float64=0.0, height::Float64=1.0,
		parFactor::Float64=0.5, fracReflected::Float64=0.1, iDev::Float64=0.0,
		plantK::Float64=0.02, fracPeriphyton::Float64=0.2,
		latitude::Float64=47.8,maxI::Float64=868.0, minI::Float64=96.0, iDelay::Int64=-10, yearlength::Int64=365,
		kdDev::Float64=1.0, maxKd::Float64=2.0, minKd::Float64=2.0,kdDelay::Float64=-10.0,
		backgrKd::Float64=1.0,hTurbReduction::Float64=40.0,pTurbReduction::Float64=1.0,
		LevelOfGrid::Float64=-1.0,
		maxW::Float64=0.1, minW::Float64=-0.1, wDelay::Int64=40,levelCorrection::Float64=0.0)

		irrSurfHr = getSurfaceIrradianceHour(day, hour, yearlength=yearlength,latitude=latitude,
    					maxI=maxI, minI=minI, iDelay=iDelay)
		 irrSubSurfHr = irrSurfHr * (1 - parFactor) * (1 - fracReflected) * (1 - iDev) # ÂµE/m^2*s
		 lightAttenuCoef = getReducedLightAttenuation(day, Biomass, yearlength=yearlength, kdDev=kdDev, maxKd=maxKd, minKd=minKd,
		 	kdDelay=kdDelay; backgrKd=backgrKd, hTurbReduction=hTurbReduction, pTurbReduction=pTurbReduction)
		 #lightAttenuCoef = getLightAttenuation(day, kdDev=kdDev, maxKd=maxKd, minKd=minKd, yearlength=yearlength,kdDelay=kdDelay) #ohne feedback auf kd durch Pflanzen
		 waterdepth=getWaterDepth(day, LevelOfGrid=LevelOfGrid, yearlength=yearlength, maxW=maxW, minW=minW, wDelay=wDelay, levelCorrection=levelCorrection)
		 higherbiomass = getBiomassAboveZ(distWaterSurface,height,waterdepth,Biomass)
	     lightWater = irrSubSurfHr * exp(1)^(- lightAttenuCoef * distWaterSurface - plantK * higherbiomass) # LAMBERT BEER # ÂµE/m^2*s # MÃ¶glichkeit im Exponenten: (absorptivity*c_H2O_pure*dist_water_surface))
	     lightPlantHour = lightWater - (lightWater * fracPeriphyton) ## ÂµE/m^2*s
	return lightPlantHour
end

#getEffectiveIrradianceHour(150, 6, 0.5, latitude=14.0, maxKd=2.4)



"""
Functions |  Growth
"""
function getRespiration(day; resp20::Float64=0.00193, q10::Float64=2.0) #DAILY VALUE
    Temper = getTemperature(day)
	resp20 * q10^((Temper - 20.0)/10)
end
#getRespiration(180)

#Photosynthesis (Biomass brutto growth) (g g^-1 h^-1)
function getPhotosynthesis(day, hour, distWaterSurf; height::Float64=1.0, Biomass::Float64=1.0,
	LevelOfGrid::Float64=-1.0, yearlength::Int64=365,maxW::Float64=0.3, minW::Float64=-0.3, wDelay::Int64=40,levelCorrection::Float64=0.0,
	    hPhotoDist::Float64=1.0,
	parFactor::Float64=0.5, fracReflected::Float64=0.1, iDev::Float64=0.0,plantK::Float64=0.02, fracPeriphyton::Float64=0.2,
	latitude::Float64=47.8,maxI::Float64=868.0, minI::Float64=96.0, iDelay::Int64=-10,kdDev::Float64=1.0, maxKd::Float64=2.0, minKd::Float64=2.0,kdDelay::Float64=-10.0,
	backgrKd::Float64=1.0,hTurbReduction::Float64=40.0,pTurbReduction::Float64=1.0,
	hPhotoLight::Float64=14.0,
	tempDev::Float64=1.0, maxTemp::Float64=18.8, minTemp::Float64=1.1, tempDelay::Int64=23,
    sPhotoTemp::Float64=1.35, pPhotoTemp::Float64=3.0, hPhotoTemp::Float64=14.0,
    #bicarbonateConc, hCarbonate, pCarbonate,
    #nutrientConc, pNutrient, hNutrient,
    pMax::Float64=0.006) ##Einheit: g / g * h

  distFromPlantTop = distWaterSurf - distPlantTopFromSurface(day, height, LevelOfGrid=LevelOfGrid, yearlength=yearlength, maxW=maxW, minW=minW, wDelay=wDelay, levelCorrection=levelCorrection)
	if distFromPlantTop < 0
		return error("ERROR DISTFROMPLANTTOP")
	end

  distFactor = hPhotoDist / (hPhotoDist + distFromPlantTop) #m

  lightPlantHour = getEffectiveIrradianceHour(day, hour, distWaterSurf, Biomass=Biomass, height=height, parFactor=parFactor, fracReflected=fracReflected, iDev=iDev, plantK=plantK, fracPeriphyton=fracPeriphyton,
  	latitude=latitude, maxI=maxI, minI=minI, iDelay=iDelay, yearlength=yearlength, kdDev=kdDev, maxKd=maxKd, minKd=minKd, kdDelay=kdDelay,
	backgrKd=backgrKd,hTurbReduction=hTurbReduction,pTurbReduction=pTurbReduction,LevelOfGrid=LevelOfGrid,maxW=maxW,minW=minW,wDelay=wDelay,levelCorrection=levelCorrection)
  lightFactor = lightPlantHour / (lightPlantHour + hPhotoLight) #ÂµE m^-2 s^-1); The default half-saturation constants (C aspera 14 yE m-2s-1; P pectinatus 52) are based on growth experiments

  temp = getTemperature(day, yearlength=yearlength, tempDev=tempDev, maxTemp=maxTemp, minTemp=minTemp, tempDelay=tempDelay)
  tempFactor = (sPhotoTemp * temp ^ pPhotoTemp) / (temp ^ pPhotoTemp + hPhotoTemp ^ pPhotoTemp) #Â°C

  #bicarbFactor = bicarbonateConc ^ pCarbonate / (bicarbonateConc ^ pCarbonate + hCarbonate ^ pCarbonate) # C.aspera hCarbonate=30 mg/l; P.pectinatus hCarbonate=60 mg/l
  #nutrientFactor <- nutrientConc ^ pNutrient / (nutrientConc ^ pNutrient + hNutrient ^ pNutrient)

  psHour = pMax * lightFactor * tempFactor #* distFactor #* bicarbFactor #* nutrientFactor #(g g^-1 h^-1)
  return (psHour) ##Einheit: g / g * h
end


#getPhotosynthesis(180, 12, 2.0, height=3.1, LevelOfGrid=-4.0, latitude=22.0)

#using Plots
#plot(x -> getPhotosynthesis(140,5,x), 0, 2)
#plot(x -> getPhotosynthesis(140,x,1.5), 0, 15)
#plot(x -> getPhotosynthesis(x,5,1.5), 100, 300)

#INTEGRATION ÜBER TIEFE VON WaterDepth bis distPlantTopFromSurface
#INTEGRATION Über daylength
using HCubature
function getPhotosynthesisPLANTDay(day, height;Biomass::Float64=1.0,
	latitude::Float64=47.8, LevelOfGrid::Float64=-1.0, yearlength::Int64=365,maxW::Float64=0.3, minW::Float64=-0.3, wDelay::Int64=40,levelCorrection::Float64=0.0,
	parFactor::Float64=0.5, fracReflected::Float64=0.1, iDev::Float64=0.0,plantK::Float64=0.02, fracPeriphyton::Float64=0.2,
	maxI::Float64=868.0, minI::Float64=96.0, iDelay::Int64=-10,kdDev::Float64=1.0, maxKd::Float64=2.0, minKd::Float64=2.0,kdDelay::Float64=-10.0,
	backgrKd::Float64=1.0,hTurbReduction::Float64=40.0,pTurbReduction::Float64=1.0,
	hPhotoDist::Float64=1.0, hPhotoLight::Float64=14.0,
	tempDev::Float64=1.0, maxTemp::Float64=18.8, minTemp::Float64=1.1, tempDelay::Int64=23,
	sPhotoTemp::Float64=1.35, pPhotoTemp::Float64=3.0, hPhotoTemp::Float64=14.0,
	pMax::Float64=0.006)

	daylength = getDaylength(day, latitude=latitude)
	waterdepth = getWaterDepth(day, LevelOfGrid=LevelOfGrid, yearlength=yearlength, maxW=maxW, minW=minW, wDelay=wDelay, levelCorrection=levelCorrection)
	distPlantTopFromSurf = waterdepth - height
	hcubature(x -> getPhotosynthesis(day, x[1], x[2], height=height, Biomass=Biomass, LevelOfGrid=LevelOfGrid, yearlength=yearlength,
		maxW=maxW, minW=minW, wDelay=wDelay, levelCorrection=levelCorrection,
		hPhotoDist=hPhotoDist, parFactor=parFactor, fracReflected=fracReflected, iDev=iDev, plantK=plantK, fracPeriphyton=fracPeriphyton,
		latitude=latitude, minI=minI, maxI=maxI, iDelay=iDelay, kdDev=kdDev, maxKd=maxKd, minKd=minKd, kdDelay=kdDelay, hPhotoLight=hPhotoLight,
		backgrKd=backgrKd, hTurbReduction=hTurbReduction,pTurbReduction=pTurbReduction,
		tempDev=tempDev, maxTemp=maxTemp, minTemp=minTemp, tempDelay=tempDelay, sPhotoTemp=sPhotoTemp, pPhotoTemp=pPhotoTemp, hPhotoTemp=hPhotoTemp, pMax=pMax
		),[0,distPlantTopFromSurf], [daylength,waterdepth])[1]
end


#getPhotosynthesisPLANTDay(190, 0.5, latitude=43.1, LevelOfGrid=-4.0)



###Growth
"""
function growBiomass(biomass1, day, height; rootShootRatio::Float64=0.1, BackgroundMort::Float64=0.0,
	resp20::Float64=0.00193, q10::Float64=2.0,
	latitude::Float64=47.8, LevelOfGrid::Float64=-1.0, yearlength::Int64=365,maxW::Float64=0.3, minW::Float64=-0.3, wDelay::Int64=40,levelCorrection::Float64=0.0,
	parFactor::Float64=0.5, fracReflected::Float64=0.1, iDev::Float64=0.0,plantK::Float64=0.02, fracPeriphyton::Float64=0.2,
	maxI::Float64=868.0, minI::Float64=96.0, iDelay::Int64=-10,kdDev::Float64=1.0, maxKd::Float64=2.0, minKd::Float64=2.0,kdDelay::Float64=-10.0,
	backgrKd::Float64=1.0,hTurbReduction::Float64=40.0,pTurbReduction::Float64=1.0,
	hPhotoDist::Float64=1.0, hPhotoLight::Float64=14.0,
	tempDev::Float64=1.0, maxTemp::Float64=18.8, minTemp::Float64=1.1, tempDelay::Int64=23,
	sPhotoTemp::Float64=1.35, pPhotoTemp::Float64=3.0, hPhotoTemp::Float64=14.0,
	pMax::Float64=0.006)

  	dailyRES = getRespiration(day, resp20=resp20, q10=q10)
  	dailyPS = getPhotosynthesisPLANTDay(day, height, biomass=biomass1, latitude=latitude, LevelOfGrid=LevelOfGrid, yearlength=yearlength,
      maxW=maxW, minW=minW, wDelay=wDelay, levelCorrection=levelCorrection,
	  hPhotoDist=hPhotoDist, parFactor=parFactor, fracReflected=fracReflected, iDev=iDev, plantK=plantK, fracPeriphyton=fracPeriphyton,
	  minI=minI, maxI=maxI, iDelay=iDelay, kdDev=kdDev, maxKd=maxKd, minKd=minKd, kdDelay=kdDelay, hPhotoLight=hPhotoLight,
	  backgrKd=backgrKd, hTurbReduction=hTurbReduction, pTurbReduction=pTurbReduction,
	  tempDev=tempDev, maxTemp=maxTemp, minTemp=minTemp, tempDelay=tempDelay, sPhotoTemp=sPhotoTemp, pPhotoTemp=pPhotoTemp, hPhotoTemp=hPhotoTemp, pMax=pMax)[1]
  biomassGrowth = (1-rootShootRatio)*biomass1*dailyPS - biomass1*(dailyRES + BackgroundMort)
  return (biomassGrowth)
end

#growBiomass(5,190,0.5)
"""


function growHeight(height1::Float64, biomass2::Float64; maxWeightLenRatio::Float64=0.03) #,weight1::Float64)
	height2 = height1 + biomass2 / maxWeightLenRatio
 # height = height1*(biomassB2 / biomassB1) #*MaxWeightLenRatio
  return height2
end

#growHeight(0.5, 0.01)


function getNumberOfSeedsProducedByOnePlant(Biomass; seedFraction::Float64=0.13, seedBiomass::Float64=0.00002)
	seedNumber = seedFraction * Biomass / seedBiomass
end
getNumberOfSeedsProducedByOnePlant(0.2)

function getNumberOfSeeds(Biomass; seedBiomass::Float64=0.00002)
	seedNumber = Biomass / seedBiomass
end

function getIndividualWeight(Biomass, Number)
	indWeight = Biomass/Number
end

##?????WAS macht das genau?
function dieThinning(number,individualWeight)
	numberAdjusted = (5950 / individualWeight)^(2/3)
	individualWeightADJ = number / numberAdjusted * individualWeight
	return(numberAdjusted, individualWeightADJ)
end

#dieThinning(300000000, 0.01)