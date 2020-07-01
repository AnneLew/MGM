
"""
CHARISMA in JULIA
Functions | ENVIRONMENT
"""
#include("defaults.jl")
#include("input.jl")
#settings = getsettings()


"""
    getDaylength(day; settings)

Takes a day and calculates for a distinct latitude the daylength.

Source:  R III Author: Robert J. Hijmans, r.hijmans@gmail.com # License GPL3 # Version 0.1  January 2009
Forsythe, William C., Edward J. Rykiel Jr., Randal S. Stahl, Hsin-i Wu and Robert M. Schoolfield, 1995.
A model comparison for daylength as a function of latitude and day of the year. Ecological Modeling 80:87-95.

Arguments used from settings: latitude
Return: Daylength [h]
"""
function getDaylength(day; settings = settings)
    settings["latitude"] > 90.0 ||
        settings["latitude"] < -90.0 &&
            return error("latitude must be between 90.0 & -90.0 Degree")
    p = asin(0.39795 * cos(0.2163108 + 2 * atan(0.9671396 * tan(0.00860 * (day - 186)))))
    a =
        (sin(0.8333 * pi / 180) + sin(settings["latitude"] * pi / 180) * sin(p)) /
        (cos(settings["latitude"] * pi / 180) * cos(p))
    if a < -1
        a = -1
    elseif a > 1
        a = 1
    end
    daylength::Float64 = 24 - (24 / pi) * acos(a)
    return (daylength) #[h]
end

#getDaylength(50)
#using Plots
#plot(getDaylength, 1, 365)


"""
    getTemperature(day; settings)

Description

Source:
Arguments used from settings: yearlength,tempDev,maxTemp,minTemp,tempDelay
Result: Daily water temperature [°C]
"""
function getTemperature(day; settings = settings)
    Temperature =
        settings["tempDev"] * (
            settings["maxTemp"] -
            ((settings["maxTemp"] - settings["minTemp"]) / 2) *
            (1 + cos((2 * pi / settings["yearlength"]) * (day - settings["tempDelay"])))
        )
    return (Temperature)  #[°C]
end

#getTemperature(1)
#plot(getTemperature, 1, 365)
#using HCubature
#hcubature(getTemperature,0,365)

"""
    getSurfaceIrradianceDay(day; settings)

Description

Source:
Arguments used from settings:  yearlength, maxI, minI, iDelay
Result: daily SurfaceIrradiance [μE m^-2 s^-1]
"""
function getSurfaceIrradianceDay(day; settings = settings)
    SurfaceIrradianceDay =
        settings["maxI"] - (
            ((settings["maxI"] - settings["minI"]) / 2) *
            (1 + cos((2 * pi / settings["yearlength"]) * (day - settings["iDelay"])))
        )
    return (SurfaceIrradianceDay) #[μE m^-2 s^-1]
end

#plot(getSurfaceIrradianceDay, 1,365)

"""
    getWaterlevel(day; settings)

Description

Source:
Arguments used from settings: yearlength, maxW, minW, wDelay, levelCorrection
Result: Waterlevel above / below mean water level [m]
"""
function getWaterlevel(day; settings = settings)
    Waterlevel =
        settings["levelCorrection"] + (
            settings["maxW"] -
            (settings["maxW"] - settings["minW"]) / 2 *
            (1 + cos((2 * pi / settings["yearlength"]) * (day - settings["wDelay"])))
        )
    return (Waterlevel) #[m]
end

#plot(getWaterlevel, 1, 365)

"""
    reduceNutrientConcentration(Biomass; settings)

Description

Source:
Arguments used from settings: maxNutrient,hNutrReduction
Result: NutrientConcAdj [mg / l]
"""
function reduceNutrientConcentration(Biomass; settings = settings)
    NutrientConcAdj =
        settings["maxNutrient"] * settings["hNutrReduction"] /
        (settings["hNutrReduction"] + Biomass)
    return (NutrientConcAdj) #[mg / l]
end

#reduceNutrientConcentration(20)

"""
    getSurfaceIrradianceHour(day, hour; settings)

Description

Source:
Arguments used from settings: yearlength,latitude,maxI,minI,iDelay
Result: SurfaceIrradianceHour [μE m^-2 s^-1]
"""
function getSurfaceIrradianceHour(day, hour; settings = settings) #times in hour after sunset
    irradianceD = getSurfaceIrradianceDay(day)
    daylength = getDaylength(day)
    SurfaceIrradianceHour =
        ((pi * irradianceD) / (2 * daylength)) * sin((pi * hour) / daylength)
    return (SurfaceIrradianceHour) #[μE m^-2 s^-1]
end

#getSurfaceIrradianceHour(30,4)
#getSurfaceIrradianceDay(180)
#getSurfaceIrradianceHour(180,1)
#hcubature(x -> getSurfaceIrradianceHour(180.0, x), xmin=0.01, xmax=15.9)
#plot(x -> getSurfaceIrradianceHour(180,x), 0, 15.9)

"""
    getLightAttenuation(day; settings)

Description

Source:
Arguments used from settings:kdDev,maxKd,minKd,yearlength,kdDelay
Returns: LightAttenuationCoefficient [m^-1]
"""
function getLightAttenuation(day; settings = settings)
    LightAttenuation = (
        settings["kdDev"] * (
            settings["maxKd"] -
            (settings["maxKd"] - settings["minKd"]) / 2 *
            (2 * pi / settings["yearlength"]) *
            (day - settings["kdDelay"])
        )
    )
    return (LightAttenuation) # [m^-1]
end
#plot(getLightAttenuation, 1:365)

"""
    getWaterDepth(day; settings)

Description

Source:
Arguments used from settings: LevelOfGrid,(yearlength,maxW,minW,wDelay,levelCorrection)
Returns: Waterdepth [m]
"""
function getWaterDepth(day; settings = settings)
    WaterDepth = getWaterlevel(day) - settings["LevelOfGrid"]
    return (WaterDepth) #[m]
end

#plot(x -> getWaterDepth(x), 1, 365)

"""
    distPlantTopFromSurface(day, height; settings)

Description

Source:
Arguments used from settings: LevelOfGrid,yearlength,maxW,minW,wDelay,levelCorrection
Returns: (distPlantTopFromSurface) #[m]
"""
function distPlantTopFromSurface(day, height; settings = settings)
    distPlantTopFromSurface = getWaterDepth(day) - height
    return (distPlantTopFromSurface) #[m]
end

#plot(x -> distPlantTopFromSurface(x, 0.50), 1, 365)

"""
    getReducedLightAttenuation(day, Biomass; settings)

Description

Source:
Arguments used from settings: yearlength,kdDev,maxKd,minKd,kdDelay, backgrKd,hTurbReduction,pTurbReduction
Returns:  lightAttenuCoefAdjusted #[m^-1]
"""
# The Effect of vegetation on light attenuation : Reduction of turbidity due to plants ; unabhängig von Growthform
function getReducedLightAttenuation(day, Biomass; settings = settings)
    lightAttenuCoef = getLightAttenuation(day)
    lightAttenuCoefAdjusted =
        settings["backgrKd"] +
        (lightAttenuCoef - settings["backgrKd"]) *
        (settings["hTurbReduction"]^settings["pTurbReduction"]) / (
            Biomass^settings["pTurbReduction"] +
            settings["hTurbReduction"]^settings["pTurbReduction"]
        )
    return (lightAttenuCoefAdjusted) #[m^-1]
end

getReducedLightAttenuation(100,5)
#getLightAttenuation(100)

"""
    getBiomassAboveZ(distWaterSurface, height, waterdepth, biomass)

Description

Source:
Arguments: none
Result: BiomassAboveZ[g/m^2]
"""
function getBiomassAboveZ(distWaterSurface, height, waterdepth, biomass)
    #waterdepth = getWaterDepth(day)
    BiomassAboveZ = (height - (waterdepth - distWaterSurface)) / height * biomass
    return (BiomassAboveZ) #[g/m^2]
end

""" Alternative with Spread
function getBiomassAboveZ(distWaterSurface, height, waterdepth, biomass, spreadFrac) #[g / m^2]
	if spreadFrac =0.0
		BiomassAboveZ = (height - (waterdepth- distWaterSurface)) / height * biomass
	else
		BiomassAboveZ =

end
"""

"""
    getEffectiveIrradianceHour(day,hour,distWaterSurface,Biomass,height; settings)

Description

Source:
Arguments: parFactor, fracReflected, iDev, plantK, fracPeriphyton, latitude, maxI, minI, iDelay,
yearlength,kdDev, maxKd, minKd, kdDelay, backgrKd, hTurbReduction, pTurbReduction, LevelOfGrid,
maxW, minW, wDelay, levelCorrection
Result: lightPlantHour=effectiveIrradiance #[µE/m^2*s]
"""
function getEffectiveIrradianceHour(
    day,
    hour,
    distWaterSurface,
    Biomass,
    height;
    settings = settings,
)
    irrSurfHr = getSurfaceIrradianceHour(day, hour)
    irrSubSurfHr =
        irrSurfHr *
        (1 - settings["parFactor"]) *
        (1 - settings["fracReflected"]) *
        (1 - settings["iDev"]) # ÂµE/m^2*s
    lightAttenuCoef = getReducedLightAttenuation(day, Biomass)
    #lightAttenuCoef = getLightAttenuation(day, kdDev=kdDev, maxKd=maxKd, minKd=minKd, yearlength=yearlength,kdDelay=kdDelay) #ohne feedback auf kd durch Pflanzen
    waterdepth = getWaterDepth(day)
    higherbiomass = getBiomassAboveZ(distWaterSurface, height, waterdepth, Biomass)
    lightWater =
        irrSubSurfHr *
        exp(1)^(-lightAttenuCoef * distWaterSurface - settings["plantK"] * higherbiomass) # LAMBERT BEER # ÂµE/m^2*s # MÃ¶glichkeit im Exponenten: (absorptivity*c_H2O_pure*dist_water_surface))
    lightPlantHour = lightWater - (lightWater * settings["fracPeriphyton"]) ## µE/m^2*s
    return lightPlantHour #[µE/m^2*s]
end

#getEffectiveIrradianceHour(150, 6, 0.5, height=1.0, Biomass=0.05)




## Functions |  Growth

"""
    getRespiration(day, settings)

Description

Source:
Arguments: resp20, q10
Result: (Respiration) #[g g^-1 d^-1]
"""
function getRespiration(day; settings=settings) #DAILY VALUE
    Temper = getTemperature(day)
    Respiration = settings["resp20"] * settings["q10"]^((Temper - 20.0) / 10)
    return (Respiration) #[g g^-1 d^-1]
end


"""
    getPhotosynthesis(day,hour,distWaterSurf,height,Biomass,settings)

Description

Source:
Arguments: LevelOfGrid, yearlength, maxW, minW, wDelay, levelCorrection, hPhotoDist, parFactor,
fracReflected, iDev, plantK, fracPeriphyton, latitude, maxI, minI, iDelay, kdDev, maxKd, minKd,
kdDelay, backgrKd, hTurbReduction, pTurbReduction, hPhotoLight, tempDev, maxTemp, minTemp,
tempDelay, sPhotoTemp, pPhotoTemp, hPhotoTemp, #bicarbonateConc, #hCarbonate, #pCarbonate,
#nutrientConc, #pNutrient, #hNutrient, pMax
Result: psHour [g / g * h]
"""
#Photosynthesis (Biomass brutto growth) (g g^-1 h^-1)
function getPhotosynthesis(
    day,
    hour,
    distWaterSurf,
    height,
    Biomass,
    settings = settings,
)

    distFromPlantTop = distWaterSurf - distPlantTopFromSurface(day, height)
    if distFromPlantTop < 0
        return error("ERROR DISTFROMPLANTTOP")
    end

    distFactor = settings["hPhotoDist"] / (settings["hPhotoDist"] + distFromPlantTop) #m

    lightPlantHour = getEffectiveIrradianceHour(
        day,
        hour,
        distWaterSurf,
        Biomass = Biomass,
        height = height,
    )
    lightFactor = lightPlantHour / (lightPlantHour + settings["hPhotoLight"]) #ÂµE m^-2 s^-1); The default half-saturation constants (C aspera 14 yE m-2s-1; P pectinatus 52) are based on growth experiments

    temp = getTemperature(day)
    tempFactor =
        (settings["sPhotoTemp"] * (temp^settings["pPhotoTemp"])) /
        ((temp^settings["pPhotoTemp"]) + (settings["hPhotoTemp"]^settings["pPhotoTemp"])) #Â°C

    #bicarbFactor = bicarbonateConc ^ pCarbonate / (bicarbonateConc ^ pCarbonate + hCarbonate ^ pCarbonate) # C.aspera hCarbonate=30 mg/l; P.pectinatus hCarbonate=60 mg/l
    #nutrientFactor <- hNutrient ^ pNutrient / (nutrientConc ^ pNutrient + hNutrient ^ pNutrient)

    psHour = settings["pMax"] * lightFactor * tempFactor * distFactor #* nutrientFactor #* bicarbFactor # #(g g^-1 h^-1)
    return (psHour) ##[g / g * h]
end



"""
#INTEGRATION ÜBER TIEFE VON WaterDepth bis distPlantTopFromSurface
#INTEGRATION Über daylength
function getUpperlayerPhotosynthesis(day, hour, distWaterSurf; height::Float64=1.0, Biomass::Float64=1.0,
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

  lightPlantHour = getEffectiveIrradianceHour(day, hour, distWaterSurf, Biomass=Biomass, height=height, parFactor=parFactor, fracReflected=fracReflected, iDev=iDev, plantK=plantK, fracPeriphyton=fracPeriphyton,
  	latitude=latitude, maxI=maxI, minI=minI, iDelay=iDelay, yearlength=yearlength, kdDev=kdDev, maxKd=maxKd, minKd=minKd, kdDelay=kdDelay,
	backgrKd=backgrKd,hTurbReduction=hTurbReduction,pTurbReduction=pTurbReduction,LevelOfGrid=LevelOfGrid,maxW=maxW,minW=minW,wDelay=wDelay,levelCorrection=levelCorrection)
  lightFactor = lightPlantHour / (lightPlantHour + hPhotoLight) #ÂµE m^-2 s^-1); The default half-saturation constants (C aspera 14 yE m-2s-1; P pectinatus 52) are based on growth experiments

  temp = getTemperature(day, yearlength=yearlength, tempDev=tempDev, maxTemp=maxTemp, minTemp=minTemp, tempDelay=tempDelay)
  tempFactor = (sPhotoTemp * (temp ^ pPhotoTemp)) / ((temp ^ pPhotoTemp) + (hPhotoTemp ^ pPhotoTemp)) #Â°C

  #bicarbFactor = bicarbonateConc ^ pCarbonate / (bicarbonateConc ^ pCarbonate + hCarbonate ^ pCarbonate) # C.aspera hCarbonate=30 mg/l; P.pectinatus hCarbonate=60 mg/l
  #nutrientFactor <- hNutrient ^ pNutrient / (nutrientConc ^ pNutrient + hNutrient ^ pNutrient)

  psHour = pMax * lightFactor * tempFactor * distFactor #* nutrientFactor #* bicarbFactor # #(g g^-1 h^-1)
  return (psHour) ##[g / g * h]
end
"""

"""
using HCubature
function getPhotosynthesisPLANTDay(day, height; Biomass::Float64=1.0,
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
"""

"""
    getPhotosynthesisPLANTDay(day, height, Biomass; settings)

Description

Source:
Arguments used from settings: latitude,LevelOfGrid,yearlength,maxW, minW, wDelay, levelCorrection,
parFactor, fracReflected, iDev, plantK, fracPeriphyton, maxI, minI, iDelay, kdDev, maxKd, minKd,
kdDelay, backgrKd, hTurbReduction, pTurbReduction, hPhotoDist, hPhotoLight, tempDev,
maxTemp, minTemp, tempDelay, sPhotoTemp, pPhotoTemp, hPhotoTemp, pMax
Returns: PS dailiy [g / g * d]
"""
#using QuadGK
function getPhotosynthesisPLANTDay(day, height, Biomass; settings = settings)
    daylength = getDaylength(day)
    waterdepth = getWaterDepth(day)
    distPlantTopFromSurf = waterdepth - height
    PS = 0
    for i = 1:floor(daylength) #Rundet ab
        PS =
            PS + quadgk( #Integral from distPlantTopFromSurf till waterdepth
                x -> getPhotosynthesis(day, i, x, height = height, Biomass = Biomass),
                distPlantTopFromSurf,
                waterdepth,
            )[1]
    end
    return PS
end

getPhotosynthesisPLANTDay(215, 0.34, 3.0)

"""
function getPhotosynthesisPLANTSPREADDay(day; Biomass::Float64=1.0,
	latitude::Float64=47.8, LevelOfGrid::Float64=-1.0, yearlength::Int64=365,maxW::Float64=0.3, minW::Float64=-0.3, wDelay::Int64=40,levelCorrection::Float64=0.0,
	parFactor::Float64=0.5, fracReflected::Float64=0.1, iDev::Float64=0.0,plantK::Float64=0.02, fracPeriphyton::Float64=0.2,
	maxI::Float64=868.0, minI::Float64=96.0, iDelay::Int64=-10,kdDev::Float64=1.0, maxKd::Float64=2.0, minKd::Float64=2.0,kdDelay::Float64=-10.0,
	backgrKd::Float64=1.0,hTurbReduction::Float64=40.0,pTurbReduction::Float64=1.0,
	hPhotoDist::Float64=1.0, hPhotoLight::Float64=14.0,
	tempDev::Float64=1.0, maxTemp::Float64=18.8, minTemp::Float64=1.1, tempDelay::Int64=23,
	sPhotoTemp::Float64=1.35, pPhotoTemp::Float64=3.0, hPhotoTemp::Float64=14.0,
	pMax::Float64=0.006)

	daylength = getDaylength(day, latitude=latitude)
	#waterdepth = getWaterDepth(day, LevelOfGrid=LevelOfGrid, yearlength=yearlength, maxW=maxW, minW=minW, wDelay=wDelay, levelCorrection=levelCorrection)
	#distPlantTopFromSurf = waterdepth - height
	PS = 0
	for i in 1:floor(daylength) #Rundet ab
		PS = PS + quadgk(x -> getPhotosynthesis(day, i, x, height=height, Biomass=Biomass, LevelOfGrid=LevelOfGrid, yearlength=yearlength,
		maxW=maxW, minW=minW, wDelay=wDelay, levelCorrection=levelCorrection,
		hPhotoDist=hPhotoDist, parFactor=parFactor, fracReflected=fracReflected, iDev=iDev, plantK=plantK, fracPeriphyton=fracPeriphyton,
		latitude=latitude, minI=minI, maxI=maxI, iDelay=iDelay, kdDev=kdDev, maxKd=maxKd, minKd=minKd, kdDelay=kdDelay, hPhotoLight=hPhotoLight,
		backgrKd=backgrKd, hTurbReduction=hTurbReduction,pTurbReduction=pTurbReduction,
		tempDev=tempDev, maxTemp=maxTemp, minTemp=minTemp, tempDelay=tempDelay, sPhotoTemp=sPhotoTemp, pPhotoTemp=pPhotoTemp, hPhotoTemp=hPhotoTemp, pMax=pMax
		),distPlantTopFromSurf, waterdepth)[1]
	end
	return PS
end
"""

## Growth
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

"""
    growHeight(biomass; settings)

Description

Source:
Arguments used from settings: maxWeightLenRatio
Returns: height [m]
"""
function growHeight(biomass2::Float64; settings=settings) #,weight1::Float64), height1::Float64,
    #height2 = height1 + biomass2 / maxWeightLenRatio
    height2 = biomass2 / settings["maxWeightLenRatio"]
    # height = height1*(biomassB2 / biomassB1) #*MaxWeightLenRatio
    return height2
end


#growHeight(0.05)

"""
    getNumberOfSeedsProducedByOnePlant(day, settings)

Description

Source:
Arguments used from settings: seedFraction,seedBiomass
Returns: seedNumber [N]
"""
function getNumberOfSeedsProducedByOnePlant(Biomass; settings = settings)
    seedNumber = settings["seedFraction"] * Biomass / settings["seedBiomass"]
    return seedNumber
end
#getNumberOfSeedsProducedByOnePlant(0.2)


"""
    getNumberOfSeeds(seedBiomass; settings)

Description

Source:
Arguments used from settings:
Returns: []
"""
function getNumberOfSeeds(seedBiomass; settings=settings)
    seedNumber = seedBiomass / settings["seedBiomass"]
    return seedNumber
end

#getNumberOfSeeds(5)

"""
    getIndividualWeight(Biomass, Number)

Returns inidividual Weight of each plant represented by the Super-Individuum

Source:
Arguments used from settings: none
Returns: indWeight [g]
"""
function getIndividualWeight(Biomass, Number)
    indWeight = Biomass / Number
    return indWeight
end



## Mortality
"""
    dieThinning(number, individualWeight)

Description

Source:
Arguments used from settings: none
Returns: numberAdjusted, individualWeightADJ []
"""
function dieThinning(number, individualWeight)
    numberAdjusted = (5950 / individualWeight)^(2 / 3)
    individualWeightADJ = (number / numberAdjusted) * individualWeight
    return (numberAdjusted, individualWeightADJ)
end


"""
function dieThinning(individualWeight)
	numberAdjusted = (7000 / individualWeight)^(-3/2)
	#individualWeightADJ = number / numberAdjusted * individualWeight
	#return(numberAdjusted, individualWeightADJ)
end
"""
#dieThinning(20000,0.00004)
