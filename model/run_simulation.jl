"""
SIMULATION Function
"""


include("defaults.jl")
include("input.jl")

settings = getsettings()
include("functions.jl")

using QuadGK

"""
Arguments used from settings: years

yearlength::Int64 = settings["yearlength"],
germinationDay::Int64 = settings["germinationDay"],
heightMax::Float64 = settings["heightMax"],
rootShootRatio::Float64 = settings["rootShootRatio"],
BackgroundMort::Float64 = settings["BackgroundMort"],
resp20::Float64 = settings["resp20"],
q10::Float64 = settings["q10"],
latitude::Float64 = settings["latitude"],
LevelOfGrid::Float64 = settings["LevelOfGrid"],
maxW::Float64 = settings["maxW"],
minW::Float64 = -settings["minW"],
wDelay::Int64 = settings["wDelay"],
levelCorrection::Float64 = settings["levelCorrection"],
parFactor::Float64 = settings["parFactor"],
fracReflected::Float64 = settings["fracReflected"],
iDev::Float64 = settings["iDev"],
plantK::Float64 = settings["plantK"],
fracPeriphyton::Float64 = settings["fracPeriphyton"],
maxI::Float64 = settings["maxI"],
minI::Float64 = settings["minI"],
iDelay::Int64 = settings["iDelay"],
kdDev::Float64 = settings["kdDev"],
maxKd::Float64 = settings["maxKd"],
minKd::Float64 = settings["minKd"],
kdDelay::Float64 = settings["kdDelay"],
hPhotoDist::Float64 = settings["hPhotoDist"],
hPhotoLight::Float64 = settings["hPhotoLight"],
tempDev::Float64 = settings["tempDev"],
maxTemp::Float64 = settings["maxTemp"],
minTemp::Float64 = settings["minTemp"],
tempDelay::Int64 = settings["tempDelay"],
sPhotoTemp::Float64 = settings["sPhotoTemp"],
pPhotoTemp::Float64 = settings["pPhotoTemp"],
hPhotoTemp::Float64 = settings["hPhotoTemp"],
pMax::Float64 = settings["pMax"],
maxAge::Int64 = settings["maxAge"],
maxWeightLenRatio::Float64 = settings["maxWeightLenRatio"],
seedInitialBiomass::Float64 = settings["seedInitialBiomass"],
seedFraction::Float64 = settings["seedFraction"],
cTuber::Float64 = settings["cTuber"],
seedGermination::Float64 = settings["seedGermination"],
seedBiomass::Float64 = settings["seedBiomass"],
seedsStartAge::Int64 = settings["seedsStartAge"],
seedsEndAge::Int64 = settings["seedsEndAge"],
reproDay::Int64 = settings["reproDay"],
SeedMortality::Float64 = settings["SeedMortality"],
spreadFrac::Float64 = settings["spreadFrac"],
backgrKd::Float64 = settings["backgrKd"],
hTurbReduction::Float64 = settings["hTurbReduction"],
pTurbReduction::Float64 = settings["pTurbReduction"],
thinning::String = settings["thinning"],
"""
function simulate(settings=settings)
    #Initialisation
    seeds = zeros(Float64, settings["yearlength"], 3, settings["years"]) #SeedBiomass, SeedNumber, SeedsGerminatingBiomass
    superInd = zeros(Float64, settings["yearlength"], 6, settings["years"]) #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
    memory = zeros(Float64, settings["yearlength"], 2, settings["years"]) #dailyPS, dailyRES

    for y = 1:settings["years"]
        if y == 1
            seeds[1, 1, 1] = settings["seedInitialBiomass"] #initial SeedBiomass
            #superInd[1,1] = 0  #initial Biomass
            seeds[1, 2, 1] = getNumberOfSeeds(seeds[1, 1, 1]) #initial SeedNumber
        else
            seeds[1, 1, y] = seeds[settings["yearlength"], 1, y-1] # get biomass of last day of last year
            #superInd[1,1] = 0  #initial Biomass
            seeds[1, 2, y] = getNumberOfSeeds(seeds[1, 1, y])
        end
        #Until Germination Starts
        for d = 2:settings["germinationDay"]
            seeds[d, 1, y] = seeds[d-1, 1, y] - seeds[d-1, 1, y] * settings["SeedMortality"] #minus SeedMortality #SeedBiomass
            seeds[d, 2, y] = getNumberOfSeeds(seeds[d, 1, y]) #SeedNumber
        end

        #GERMINATION
        seeds[settings["germinationDay"], 3, y] =
            seeds[settings["germinationDay"]-1, 1, y] * settings["seedGermination"] #20% of the SeedsBiomass are transformed to SeedsGerminatingBiomass
        seeds[settings["germinationDay"], 1, y] =
            seeds[settings["germinationDay"]-1, 1, y] -
            seeds[settings["germinationDay"], 3, y] -
            seeds[settings["germinationDay"]-1, 1, y] * settings["SeedMortality"]#Remaining SeedsBiomass
        superInd[settings["germinationDay"], 2, y] =
            getNumberOfSeeds(seeds[settings["germinationDay"], 3, y]) #Germinated Individuals

        superInd[settings["germinationDay"], 1, y] =
            seeds[settings["germinationDay"], 3, y] * settings["cTuber"]
        superInd[settings["germinationDay"], 3, y] = getIndividualWeight(
            superInd[settings["germinationDay"], 1, y],
            superInd[settings["germinationDay"], 2, y],
        ) #individualWeight = Biomass /

        # Thinning, optional
        if settings["thinning"] == "TRUE"
            thin =
                dieThinning(superInd[germinationDay, 2, y], superInd[germinationDay, 3, y]) #Adapts number of individuals [/m^2]& individual weight
            if (thin[1] < superInd[germinationDay, 2, y])
                superInd[germinationDay, 2, y] = thin[1]
                superInd[germinationDay, 3, y] = thin[2]
            end
        end

        superInd[settings["germinationDay"], 4, y] =
            growHeight(superInd[settings["germinationDay"], 3, y])

        #GROWTH
        for d =
            (settings["germinationDay"]+1):(settings["germinationDay"]+settings["maxAge"])
            seeds[d, 1, y] = seeds[d-1, 1, y] - seeds[d-1, 1, y] * settings["SeedMortality"] #minus SeedMortality #SeedBiomass
            seeds[d, 3, y] = (1 - settings["cTuber"]) * seeds[d-1, 3, y] #Reduction of allocatedBiomass untill it is used
            seeds[d, 2, y] = getNumberOfSeeds(seeds[d, 1, y]) #SeedNumber
            superInd[d, 2, y] = superInd[d-1, 2, y] #PlantNumber stays the same ??!!! MORTALITY ?????

            #GROWTH
            dailyRES = getRespiration(d) #[g / g*d]
            memory[d, 2, y] = dailyRES
            dailyPS = getPhotosynthesisPLANTDay(
                d,
                superInd[d-1, 4, y], #height
                ((1 - settings["rootShootRatio"]) * superInd[d-1, 1, y]), #biomass
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
            if superInd[d-1, 4, y] == getWaterDepth(d - 1)
                superInd[d, 1, y] =
                    superInd[d-1, 1, y] + (1 - settings["spreadFrac"]) * dailyGrowth #Aufteilung der Production in shoots & under surface
                superInd[d, 6, y] =
                    superInd[d-1, 6, y] + settings["spreadFrac"] * dailyGrowth
            else
                superInd[d, 1, y] = superInd[d-1, 1, y] + dailyGrowth
            end

            superInd[d, 3, y] = getIndividualWeight(superInd[d, 1, y], superInd[d, 2, y]) #individualWeight = Biomass / Number

            #Thinning, optional
            if settings["thinning"] == "TRUE"
                thin = dieThinning(superInd[d, 2, y], superInd[d, 3, y]) #Adapts number of individuals [/m^2]& individual weight
                if (thin[1] < superInd[d, 2, y]) #&& (Thinning[2] > 0)
                    superInd[d, 2, y] = thin[1] #N
                    superInd[d, 3, y] = thin[2] #indWeight#
                end
            end

            #Height calc
            superInd[d, 4, y] = growHeight(superInd[d, 3, y]) #!!!QUATSCH??
            if superInd[d, 4, y] >= settings["heightMax"]
                superInd[d, 4, y] = settings["heightMax"]
            end
            WaterDepth = getWaterDepth(d)
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

        end
        #WINTER
        for d = (settings["germinationDay"]+settings["maxAge"]+1):365
            superInd[d, 4, y] = 0
            superInd[d, 1, y] = 0
            superInd[d, 2, y] = 0 #minus Mortality
            seeds[d, 1, y] = seeds[d-1, 1, y] - seeds[d-1, 1, y] * settings["SeedMortality"] #minus SeedMortality
            seeds[d, 2, y] = getNumberOfSeeds(seeds[d, 1, y])
        end
    end
    return (superInd) #seeds, , memory
end

simulate()


# Function to calculate the environment with identical input variables as function simulate
function simulateEnvironment()
    temp = Float64[]
    irradiance = Float64[]
    waterlevel = Float64[]
    lightAttenuation = Float64[]

    for d = 1:settings["yearlength"]
        push!(temp, getTemperature(d))
        push!(irradiance, getSurfaceIrradianceDay(d))
        push!(waterlevel, getWaterlevel(d))
        push!(lightAttenuation, getLightAttenuation(d))
    end

    return (temp, irradiance, waterlevel, lightAttenuation)

end
