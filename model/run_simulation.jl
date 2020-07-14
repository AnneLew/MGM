
#include("defaults.jl")
#include("input.jl")

#settings = getsettings()
#include("functions.jl")

#using QuadGK

"""
    simulate(LevelOfGrid; settings)

Simulation function for growth of macrophytes in one depth

Source: following van Nes (2003)

Arguments used from settings:
years, yearlength, germinationDay, heightMax, rootShootRatio, BackgroundMort, resp20,
q10, latitude, maxW, minW, wDelay, levelCorrection, parFactor, fracReflected,
iDev, plantK, fracPeriphyton, maxI, minI, iDelay, kdDev, maxKd, minKd, kdDelay,
hPhotoDist, hPhotoLight, tempDev, maxTemp, minTemp, tempDelay, sPhotoTemp,
pPhotoTemp, hPhotoTemp, pMax, maxAge, maxWeightLenRatio, seedInitialBiomass,
seedFraction, cTuber, seedGermination, seedBiomass, seedsStartAge, seedsEndAge,
reproDay, SeedMortality, spreadFrac, backgrKd, hTurbReduction, pTurbReduction,
thinning

Returns: [superInd]
"""
function simulate(LevelOfGrid, settings::Dict{String, Any})
    #simlog("Starting simulation.", settings)
    #Initialisation
    seeds = zeros(Float64, settings["yearlength"], 3, settings["years"]) #SeedBiomass, SeedNumber, SeedsGerminatingBiomass
    superInd = zeros(Float64, settings["yearlength"], 6, settings["years"]) #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
    memory = zeros(Float64, settings["yearlength"], 2, settings["years"]) #dailyPS, dailyRES
    lightAttenuation = zeros(Float64, settings["yearlength"], 1, settings["years"]) #reducedlightAttenuation
    for y = 1:settings["years"]
        if y == 1
            seeds[1, 1, 1] = settings["seedInitialBiomass"] #initial SeedBiomass
            #superInd[1,1] = 0  #initial Biomass
            seeds[1, 2, 1] = getNumberOfSeeds(seeds[1, 1, 1],settings) #initial SeedNumber
        else
            seeds[1, 1, y] = seeds[settings["yearlength"], 1, y-1] # get biomass of last day of last year
            #superInd[1,1] = 0  #initial Biomass
            seeds[1, 2, y] = getNumberOfSeeds(seeds[1, 1, y],settings)
        end
        lightAttenuation[1, 1, y] = getReducedLightAttenuation(1, superInd[1, 1, y],settings)
        #Until Germination Starts
        for d = 2:settings["germinationDay"]
            seeds[d, 1, y] = seeds[d-1, 1, y] - seeds[d-1, 1, y] * settings["SeedMortality"] #minus SeedMortality #SeedBiomass
            seeds[d, 2, y] = getNumberOfSeeds(seeds[d, 1, y],settings) #SeedNumber
            lightAttenuation[d, 1, y] = getReducedLightAttenuation(d, superInd[d, 1, y],settings)
        end

        #GERMINATION
        seeds[settings["germinationDay"], 3, y] =
            seeds[settings["germinationDay"]-1, 1, y] * settings["seedGermination"] #20% of the SeedsBiomass are transformed to SeedsGerminatingBiomass
        seeds[settings["germinationDay"], 1, y] =
            seeds[settings["germinationDay"]-1, 1, y] -
            seeds[settings["germinationDay"], 3, y] -
            seeds[settings["germinationDay"]-1, 1, y] * settings["SeedMortality"]#Remaining SeedsBiomass
        superInd[settings["germinationDay"], 2, y] =
            getNumberOfSeeds(seeds[settings["germinationDay"], 3, y],settings) #Germinated Individuals

        superInd[settings["germinationDay"], 1, y] =
            seeds[settings["germinationDay"], 3, y] * settings["cTuber"]
        superInd[settings["germinationDay"], 3, y] = getIndividualWeight(
            superInd[settings["germinationDay"], 1, y],
            superInd[settings["germinationDay"], 2, y],
        ) #individualWeight = Biomass /

        # Thinning, optional
        if settings["thinning"] == true
            thin =
                dieThinning(superInd[settings["germinationDay"], 2, y], superInd[settings["germinationDay"], 3, y]) #Adapts number of individuals [/m^2]& individual weight
            if (thin[1] < superInd[settings["germinationDay"], 2, y])
                superInd[settings["germinationDay"], 2, y] = thin[1]
                superInd[settings["germinationDay"], 3, y] = thin[2]
            end
        end

        superInd[settings["germinationDay"], 4, y] =
            growHeight(superInd[settings["germinationDay"], 3, y],settings)

        #GROWTH
        for d =
            (settings["germinationDay"]+1):(settings["germinationDay"]+settings["maxAge"])
            seeds[d, 1, y] = seeds[d-1, 1, y] - seeds[d-1, 1, y] * settings["SeedMortality"] #minus SeedMortality #SeedBiomass
            seeds[d, 3, y] = (1 - settings["cTuber"]) * seeds[d-1, 3, y] #Reduction of allocatedBiomass untill it is used
            seeds[d, 2, y] = getNumberOfSeeds(seeds[d, 1, y],settings) #SeedNumber
            superInd[d, 2, y] = superInd[d-1, 2, y] #PlantNumber stays the same ??!!! MORTALITY ?????

            #GROWTH
            dailyRES = getRespiration(d,settings) #[g / g*d]
            memory[d, 2, y] = dailyRES
            dailyPS = getPhotosynthesisPLANTDay(
                d,
                superInd[d-1, 4, y], #height
                ((1 - settings["rootShootRatio"]) * superInd[d-1, 1, y]), #biomass
                LevelOfGrid,
                settings,
            )[1]
            memory[d, 1, y] = dailyPS #Just to controll

            #Biomass calc
            dailyGrowth =
                seeds[d, 3, y] * settings["cTuber"] + (
                    (
                        (1 - settings["rootShootRatio"]) * superInd[d-1, 1, y] -
                        superInd[d-1, 5, y]
                    ) * dailyPS -
                    superInd[d-1, 1, y] * (dailyRES + settings["BackgroundMort"])
                )

            #SPREAD UNDER WATER SURFACE
            if superInd[d-1, 4, y] == getWaterDepth(d - 1, LevelOfGrid,settings)
                superInd[d, 1, y] =
                    superInd[d-1, 1, y] + (1 - settings["spreadFrac"]) * dailyGrowth #Aufteilung der Production in shoots & under surface
                superInd[d, 6, y] =
                    superInd[d-1, 6, y] + settings["spreadFrac"] * dailyGrowth
            else
                superInd[d, 1, y] = superInd[d-1, 1, y] + dailyGrowth
            end

            superInd[d, 3, y] = getIndividualWeight(superInd[d, 1, y], superInd[d, 2, y]) #individualWeight = Biomass / Number

            #Thinning, optional
            if settings["thinning"] == true
                thin = dieThinning(superInd[d, 2, y], superInd[d, 3, y]) #Adapts number of individuals [/m^2]& individual weight
                if (thin[1] < superInd[d, 2, y]) #&& (Thinning[2] > 0)
                    superInd[d, 2, y] = thin[1] #N
                    superInd[d, 3, y] = thin[2] #indWeight#
                end
            end

            #Height calc
            superInd[d, 4, y] = growHeight(superInd[d, 3, y],settings) #!!!QUATSCH??
            if superInd[d, 4, y] >= settings["heightMax"]
                superInd[d, 4, y] = settings["heightMax"]
            end
            WaterDepth = getWaterDepth(d, LevelOfGrid,settings)
            if superInd[d, 4, y] >= WaterDepth
                superInd[d, 4, y] = WaterDepth
            end

            #ALLOCATION OF BIOMASS FOR SEED PRODUCTION
            if d > (settings["germinationDay"] + settings["seedsStartAge"]) &&
               d < (settings["germinationDay"] + settings["seedsEndAge"])
                superInd[d, 5, y] =
                    superInd[d-1, 5, y] +
                    superInd[d, 1, y] * settings["seedFraction"] /
                    (settings["seedsEndAge"] - settings["seedsStartAge"]) #allocatedBiomass Stimmt das so???
            end
            if d >= (settings["germinationDay"] + settings["seedsEndAge"]) &&
               d <= settings["reproDay"]
                superInd[d, 5, y] = superInd[d, 1, y] * settings["seedFraction"] #allocatedBiomass - Fraction remains
            end
            #TRANSFORMATION OF ALLOCATED BIOMASS IN SEEDS
            if d == settings["reproDay"]
                seeds[d, 1, y] =
                    seeds[d-1, 1, y] + superInd[d, 5, y] -
                    seeds[d-1, 1, y] * settings["SeedMortality"]
            end
            lightAttenuation[d, 1, y] = getReducedLightAttenuation(d, superInd[d, 1, y],settings)
        end
        #WINTER
        for d = (settings["germinationDay"]+settings["maxAge"]+1):365
            superInd[d, 4, y] = 0
            superInd[d, 1, y] = 0
            superInd[d, 2, y] = 0 #minus Mortality
            seeds[d, 1, y] = seeds[d-1, 1, y] - seeds[d-1, 1, y] * settings["SeedMortality"] #minus SeedMortality
            seeds[d, 2, y] = getNumberOfSeeds(seeds[d, 1, y],settings)
            lightAttenuation[d, 1, y] = getReducedLightAttenuation(d, superInd[d, 1, y],settings)
        end
    end

    return (superInd) #seeds, , memory, lightAttenuation
end


"""
    simulateFourDepth(settings)

Simulates 4 depth and returns ..
"""
# Cleverer schreiben
function simulateDepth(settings::Dict{String, Any})
    Res1 = simulate(-0.5,settings)
    Res2 = simulate(-1.5,settings)
    Res3 = simulate(-3.0,settings)
    Res4 = simulate(-5.0,settings)
    Res5 = simulate(-10.0,settings)
    Res1a=Res1[:,:,1]
    Res2a=Res2[:,:,1]
    Res3a=Res3[:,:,1]
    Res4a=Res4[:,:,1]
    Res5a=Res5[:,:,1]
    for y in 2:settings["years"]
        Res1a= vcat(Res1a, Res1[:,:,y],)
        Res2a= vcat(Res2a, Res2[:,:,y],)
        Res3a= vcat(Res3a, Res3[:,:,y],)
        Res4a= vcat(Res4a, Res4[:,:,y],)
        Res5a= vcat(Res5a, Res5[:,:,y],)
    end
    return Res1a,Res2a,Res3a,Res4a,Res5a
end



"""
    simulateEnvironment(settings)

Function to calculate the environment with identical input variables as function simulate

Source: following van Nes (2003)
Arguments used from settings: yearlength, ...

Returns: temp, irradiance, waterlevel, lightAttenuation []
"""

function simulateEnvironment(settings::Dict{String, Any})
    temp = Float64[]
    irradiance = Float64[]
    waterlevel = Float64[]
    lightAttenuation = Float64[]
    #for y = 1:settings["years"]
        for d = 1:settings["yearlength"]
            push!(temp, getTemperature(d,settings))
            push!(irradiance, getSurfaceIrradianceDay(d,settings))
            push!(waterlevel, getWaterlevel(d,settings))
            push!(lightAttenuation, getLightAttenuation(d,settings))
        end
    #end
    return (temp, irradiance, waterlevel, lightAttenuation)
end
