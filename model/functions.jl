
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

Return: daylength [h]
"""
function getDaylength(day, settings::Dict{String, Any})
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


"""
    getTemperature(day; settings)

Temperature gets modeled with a cosine function

Source: van Nes et al

Arguments used from settings: yearlength,tempDev,maxTemp,minTemp,tempDelay

Result: Daily water temperature [°C]
"""
function getTemperature(day, settings::Dict{String, Any})
    Temperature =
        settings["tempDev"] * (
            settings["maxTemp"] -
            ((settings["maxTemp"] - settings["minTemp"]) / 2) *
            (1 + cos((2 * pi / settings["yearlength"]) * (day - settings["tempDelay"])))
        )
    return (Temperature)
end



"""
    getSurfaceIrradianceDay(day; settings)

Modeled with cosine function

Source: van Nes

Arguments used from settings:  yearlength, maxI, minI, iDelay

Result: daily SurfaceIrradiance [μE m^-2 s^-1]
"""
function getSurfaceIrradianceDay(day, settings::Dict{String, Any})
    SurfaceIrradianceDay =
        settings["maxI"] - (
            ((settings["maxI"] - settings["minI"]) / 2) *
            (1 + cos((2 * pi / settings["yearlength"]) * (day - settings["iDelay"])))
        )
    return (SurfaceIrradianceDay)
end



"""
    getWaterlevel(day; settings)

Modeled with cosine function

Source:

Arguments used from settings: yearlength, maxW, minW, wDelay, levelCorrection

Result: Waterlevel above / below mean water level [m]
"""
function getWaterlevel(day, settings::Dict{String, Any})
    Waterlevel =
        - settings["levelCorrection"] + (
            settings["maxW"] -
            (settings["maxW"] - settings["minW"]) / 2 *
            (1 + cos((2 * pi / settings["yearlength"]) * (day - settings["wDelay"])))
        )
    return (Waterlevel) #[m]
end



"""
    reduceNutrientConcentration(Biomass; settings)

Reduction of Nutrient content if there is vegetation

Source: van Nes

Arguments used from settings: maxNutrient, hNutrReduction

Result: NutrientConcAdj [mg / l]
"""
function reduceNutrientConcentration(Biomass, settings::Dict{String, Any})
    NutrientConcAdj =
        settings["maxNutrient"] * settings["hNutrReduction"] /
        (settings["hNutrReduction"] + Biomass)
    return (NutrientConcAdj) #[mg / l]
end


"""
    getSurfaceIrradianceHour(day, hour; settings)

Daily total irradiation modeled as sine wave over the year

Source: van Nes

Arguments used from settings: yearlength,latitude,maxI,minI,iDelay

Result: SurfaceIrradianceHour [μE m^-2 s^-1]
"""
function getSurfaceIrradianceHour(day, hour, settings::Dict{String, Any}) #times in hour after sunset
    irradianceD = getSurfaceIrradianceDay(day, settings)
    daylength = getDaylength(day, settings)
    SurfaceIrradianceHour =
        ((pi * irradianceD) / (2 * daylength)) * sin((pi * hour) / daylength)
    return (SurfaceIrradianceHour) #[μE m^-2 s^-1]
end


"""
    getLightAttenuation(day; settings)

Modeled with a cosine function

Source: van Nes

Arguments used from settings:kdDev, maxKd, minKd, yearlength, kdDelay

Returns: LightAttenuationCoefficient [m^-1]
"""
function getLightAttenuation(day, settings::Dict{String, Any})
    LightAttenuation = (
        settings["kdDev"] * (
            settings["maxKd"] -
            (settings["maxKd"] - settings["minKd"]) / 2 *
            (1 + cos((2 * pi / settings["yearlength"]) * (day - settings["kdDelay"])))
        )
    )
    return (LightAttenuation) # [m^-1]
end



"""
    getWaterDepth(day; settings)

Calcuates waterdepth dependent on Waterlevel and LevelOfGrid

Source: van Nes

Arguments used from settings: (yearlength,maxW,minW,wDelay,levelCorrection)

Returns: Waterdepth [m]
"""
function getWaterDepth(day, LevelOfGrid, settings::Dict{String, Any})
    WaterDepth = getWaterlevel(day, settings) - LevelOfGrid
    return (WaterDepth) #[m]
end



"""
    getReducedLightAttenuation(day, Biomass; settings)

The Effect of vegetation on light attenuation : Reduction of turbidity due to plant Biomass ;
unabhängig von Growthform

Source: van Nes

Arguments used from settings: yearlength,kdDev,maxKd,minKd,kdDelay, backgrKd,hTurbReduction,pTurbReduction

Returns:  lightAttenuCoefAdjusted #[m^-1]
"""
function getReducedLightAttenuation(day, Biomass, settings::Dict{String, Any})
    lightAttenuCoef = getLightAttenuation(day, settings)
    lightAttenuCoefAdjusted =
        settings["backgrKd"] +
        (lightAttenuCoef - settings["backgrKd"]) *
        (settings["hTurbReduction"]^settings["pTurbReduction"]) / (
            Biomass^settings["pTurbReduction"] +
            settings["hTurbReduction"]^settings["pTurbReduction"]
        )
    return (lightAttenuCoefAdjusted) #[m^-1]
end



"""
    getBiomassAboveZ(distWaterSurface, height1, height2, waterdepth, biomass1, biomass2)

Returns share of Biomass above distinct distance from water surface

Source: -

Arguments used from settings: none

Result: BiomassAboveZ [g/m^2]
"""
function getBiomassAboveZ(distWaterSurface, height1, height2, waterdepth, biomass1, biomass2)
    if height1>0
        BiomassAboveZ_1 = ((height1 - (waterdepth - distWaterSurface)) / height1) * biomass1
    else
        BiomassAboveZ_1 =0
    end
    if BiomassAboveZ_1 <0
        BiomassAboveZ_1=0
    end
    if height2>0
        BiomassAboveZ_2 = ((height2 - (waterdepth - distWaterSurface)) / height2) * biomass2
    else
        BiomassAboveZ_2=0
    end
    if BiomassAboveZ_2 <0
        BiomassAboveZ_2=0
    end
    BiomassAboveZ = BiomassAboveZ_1 + BiomassAboveZ_2
    return (BiomassAboveZ) #[g/m^2]
end


#getBiomassAboveZ(1.0,1.5,0.5,2.0,5.0,1.0)

"""
    getEffectiveIrradianceHour(day,hour,distWaterSurface,Biomass1, Biomass2,height1, height2; settings)

Description

Source: van Nes

Arguments from settings: parFactor, fracReflected, iDev, plantK, fracPeriphyton, latitude, maxI, minI, iDelay,
yearlength,kdDev, maxKd, minKd, kdDelay, backgrKd, hTurbReduction, pTurbReduction, LevelOfGrid,
maxW, minW, wDelay, levelCorrection

Result: lightPlantHour=effectiveIrradiance #[µE/m^2*s]
"""
function getEffectiveIrradianceHour(
    day,
    hour,
    distWaterSurface,
    Biomass1,
    Biomass2,
    height1,
    height2,
    LevelOfGrid,
    settings::Dict{String, Any}
)
    irrSurfHr = getSurfaceIrradianceHour(day, hour, settings) #(µE m^-2*s^-1)
    irrSubSurfHr =
        irrSurfHr *
        (1 - settings["parFactor"]) * #PAR radiation
        (1 - settings["fracReflected"]) * # Reflection at water surface
        settings["iDev"] # Deviation factor
    lightAttenuCoef = getReducedLightAttenuation(day, (Biomass1+Biomass2), settings)
    #lightAttenuCoef = getLightAttenuation(day, settings) #ohne feedback auf kd durch Pflanzen
    waterdepth = getWaterDepth(day,LevelOfGrid, settings)
    if height1>waterdepth
        height1=waterdepth
    end
    higherbiomass = getBiomassAboveZ(distWaterSurface, height1, height2, waterdepth, Biomass1, Biomass2)
    lightWater =
        irrSubSurfHr *
        exp(1)^(-lightAttenuCoef * distWaterSurface - settings["plantK"] * higherbiomass) # LAMBERT BEER # ÂµE/m^2*s # MÃ¶glichkeit im Exponenten: (absorptivity*c_H2O_pure*dist_water_surface))
    lightPlantHour = lightWater - (lightWater * settings["fracPeriphyton"]) ## µE/m^2*s
    return lightPlantHour #[µE/m^2*s]
end

#getEffectiveIrradianceHour(180, 8, 1.0, 100.05, 50.05, 1.0, 1.2, -2.0,settings)




"""
    getRespiration(day, settings)

Temperature dependence of maintenance respiration is formulated using a Q10 of 2

Source: van Nes

Arguments from settings: resp20, q10

Result: (Respiration) #[g g^-1 d^-1]
"""
function getRespiration(day, settings::Dict{String, Any}) #DAILY VALUE
    Temper = getTemperature(day, settings)
    Respiration = settings["resp20"] * settings["q10"]^((Temper - 20.0) / 10)
    return (Respiration) #[g g^-1 d^-1]
end


"""
    getPhotosynthesis(day,hour,distWaterSurf,Biomass1, Biomass2, height1, height2,settings)

Calculation of PS every hour dependent on light, temperature, dist (plant aging), [Carbonate, Nutrients]

Source: van Nes

Arguments from settings: yearlength, maxW, minW, wDelay, levelCorrection, hPhotoDist, parFactor,
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
    distFromPlantTop,
    Biomass1,
    Biomass2,
    height1,
    height2,
    LevelOfGrid,
    settings::Dict{String,Any},
)

    waterdepth = getWaterDepth(day, LevelOfGrid, settings)
    distWaterSurf = waterdepth - height1 + distFromPlantTop
    if height1 > waterdepth
        height1 = waterdepth
    end
    distFactor = settings["hPhotoDist"] / (settings["hPhotoDist"] + distFromPlantTop) #m

    lightPlantHour = getEffectiveIrradianceHour(
        day,
        hour,
        distWaterSurf,
        Biomass1,
        Biomass2,
        height1,
        height2,
        LevelOfGrid,
        settings,
    )
    lightFactor = lightPlantHour / (lightPlantHour + settings["hPhotoLight"]) #ÂµE m^-2 s^-1); The default half-saturation constants (C aspera 14 yE m-2s-1; P pectinatus 52) are based on growth experiments

    temp = getTemperature(day, settings)
    tempFactor =
        (settings["sPhotoTemp"] * (temp^settings["pPhotoTemp"])) /
        ((temp^settings["pPhotoTemp"]) + (settings["hPhotoTemp"]^settings["pPhotoTemp"])) #Â°C

    #bicarbFactor = bicarbonateConc ^ pCarbonate / (bicarbonateConc ^ pCarbonate + hCarbonate ^ pCarbonate) # C.aspera hCarbonate=30 mg/l; P.pectinatus hCarbonate=60 mg/l

    nutrientConc = reduceNutrientConcentration((Biomass1 + Biomass2), settings)
    nutrientFactor =
        (nutrientConc^settings["pNutrient"]) /
        (nutrientConc^settings["pNutrient"] + settings["hNutrient"]^settings["pNutrient"])

    psHour = settings["pMax"] * lightFactor * tempFactor * distFactor * nutrientFactor #* bicarbFactor # #(g g^-1 h^-1)

    return (psHour) ##[g / g * h]
end


"""
    getPhotosynthesisPLANTDay(day, height, Biomass; settings)

Calculation of daily PS

Source:

Arguments used from settings: latitude,LevelOfGrid,yearlength,maxW, minW, wDelay, levelCorrection,
parFactor, fracReflected, iDev, plantK, fracPeriphyton, maxI, minI, iDelay, kdDev, maxKd, minKd,
kdDelay, backgrKd, hTurbReduction, pTurbReduction, hPhotoDist, hPhotoLight, tempDev,
maxTemp, minTemp, tempDelay, sPhotoTemp, pPhotoTemp, hPhotoTemp, pMax

Returns: PS daily [g / g * d]
"""
#using QuadGK
#using HCubature
function getPhotosynthesisPLANTDay(
    day,
    height1,
    height2,
    Biomass1,
    Biomass2,
    LevelOfGrid,
    settings::Dict{String,Any},
)

    daylength = getDaylength(day, settings)
    waterdepth = getWaterDepth((day), LevelOfGrid, settings)
    distPlantTopFromSurf = waterdepth - height1
    if height1 > waterdepth
        height1 = waterdepth
    end
    PS = 0
    if Biomass1 > 0.0
        for i = 1:floor(daylength) #Rundet ab # Loop über alle Stunden
            PS =
                PS + hquadrature( #Integral from distPlantTopFromSurf till waterdepth
                    x -> getPhotosynthesis(
                        day,
                        i,
                        x,
                        Biomass1,
                        Biomass2,
                        height1,
                        height2,
                        LevelOfGrid,
                        settings,
                    ),
                    distPlantTopFromSurf,
                    waterdepth,
                )[1]
        end
    else
        PS = 0
    end
    return PS
end

#getPhotosynthesis(180,5,1.0,100.0,0.0,1.0,1.5,-2.0,settings)


"""
    growHeight(biomass; settings)

Height growth of plants

Source:

Arguments used from settings: maxWeightLenRatio

Returns: height [m]
"""
function growHeight(indBiomass::Float64, settings::Dict{String, Any})
    if indBiomass > 0
        height2 = indBiomass / settings["maxWeightLenRatio"]
    else
        height2 = 0
    end
    return height2
end


"""
    getDailyGrowth(seeds, biomass1, allocatedBiomass1, dailyPS, dailyRES, settings)

Calcualtion of daily growth

Source:

Arguments used from settings: cTuber, rootShootRatio

Returns: daily biomass increase [g]
"""
function getDailyGrowth(
    seeds::Float64,
    biomass1::Float64,
    allocatedBiomass1::Float64,
    dailyPS::Float64,
    dailyRES::Float64,
    settings::Dict{String,Any},
)
    dailyGrowth =
        seeds * settings["cTuber"] + #Growth from seedBiomass
        (
            ((1 - settings["rootShootRatio"]) * biomass1 - allocatedBiomass1) * dailyPS - #GrossProduction : Growth from sprout
            biomass1 * dailyRES #Respiration
        )
    #if dailyGrowth > 0 # No negative growth allowed
    #    dailyGrowth = dailyGrowth
    #else
    #    dailyGrowth = 0
    #end
    return dailyGrowth
end


"""
    getNumberOfSeedsProducedByOnePlant(day, settings)

Description
Not used in that form in the code

Source: van Nes

Arguments used from settings: seedFraction,seedBiomass

Returns: seedNumber [N]
"""
function getNumberOfSeedsProducedByOnePlant(Biomass, settings::Dict{String, Any})
    seedNumber = settings["seedFraction"] * Biomass / settings["seedBiomass"]
    #return round(seedNumber)
    return seedNumber
end

#getNumberOfSeedsProducedByOnePlant(0.4, settings)


"""
    getNumberOfSeeds(seedBiomass; settings)

Calculates number of Seeds by single seed biomass

Source: van Nes

Arguments used from settings:

Returns: []
"""
function getNumberOfSeeds(seedBiomass, settings::Dict{String, Any})
    if settings["seedBiomass"]== 0
        seedNumber =0
    else
        seedNumber = seedBiomass / settings["seedBiomass"]
    end

    #return round(seedNumber)
    return (seedNumber)
end

"""
    getNumberOfTubers(tubersBiomass; settings)

Calculates number of Seeds by single seed biomass

Source: van Nes

Arguments used from settings:

Returns: []
"""
function getNumberOfTubers(tubersBiomass, settings::Dict{String, Any})
    if settings["tuberBiomass"]==0
        tubersNumber=0
    else
        tubersNumber = tubersBiomass / settings["tuberBiomass"]
    end
    #return round(tubersNumber)
    return (tubersNumber)
end


"""
    getIndividualWeight(Biomass, Number)

Returns inidividual Weight of each plant represented by the Super-Individuum

Source: van Nes

Arguments used from settings: none

Returns: indWeight [g]
"""
function getIndividualWeight(Biomass, Number)
    indWeight = Biomass / Number
    return indWeight
end



"""
    dieThinning(number, individualWeight)

Mortality due to competition at high plant denisties

Source: van Nes

Arguments used from settings: none

Returns: numberAdjusted, individualWeightADJ []
"""
function dieThinning(number, individualWeight, settings::Dict{String, Any})
    numberAdjusted = (settings["cThinning"] / individualWeight)^(2 / 3)
    if numberAdjusted<1.0
        numberAdjusted=1.0
    end
    individualWeightADJ = (number / numberAdjusted) * individualWeight
    #return (round(numberAdjusted), individualWeightADJ)
    return (numberAdjusted, individualWeightADJ)
end

"""
    dieWaves(day,LevelOfGrid,settings)

Mortality due to wave damage; loss in number of plants untill reached water surface; Adult plants only lose weight

Source: van Nes

Arguments used from settings: maxWaveMort,hWaveMort,pWaveMort

Returns: wave mortality [d^-1]
"""
function dieWaves(day, LevelOfGrid, settings)
    waterdepth = getWaterDepth(day, LevelOfGrid, settings)
    waveMortality =
        settings["maxWaveMort"] * (settings["hWaveMort"]^settings["pWaveMort"]) /
        ((settings["hWaveMort"]^settings["pWaveMort"]) + (waterdepth^settings["pWaveMort"]))
    return waveMortality
end




"""
    killWithProbability(Mort, N1)

Killing number of Plants by using a random number from Poisson distribution

Source: van Nes

Arguments used from settings: none

Returns: Number of plants reduced
"""
function killWithProbability(Mort, N1)
    N2=0
    for i in 1:N1
        N2 = N2+rand(Binomial(1,1-Mort))[1]
    end
    return(N2)
end


"""
    killN(Mort, N1)

Killing number of Plants

Source: van Nes

Arguments used from settings: Mort

Returns: Number of plants reduced
"""
function killN(Mort, N1)
    #N2=0
    N2= (1-Mort)*N1
    return(N2)
end
