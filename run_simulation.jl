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
	superInd = zeros(Float64, yearlength, 5) #Biomass, Number, indWeight, Height, allocatedBiomass, 
	photosynDay = zeros(Float64, settings["yearlength"])

	Seeds[1,1] = seedInitialBiomass #initial SeedBiomass
	superInd[1,1] = 0 #initBiomass #initial Biomass
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

	superInd[germinationDay,1] = superInd[germinationDay-1,1] + Seeds[germinationDay,3]*cTuber
	superInd[germinationDay+1,1] = superInd[germinationDay,1]
	superInd[germinationDay,3] =  getIndividualWeight(superInd[germinationDay,1], superInd[germinationDay,2]) #individualWeight = Biomass /

	Thinning = dieThinning(superInd[germinationDay,2],superInd[germinationDay,3]) #Adapts number of individuals [/m^2]& individual weight
	if (Thinning[1]<superInd[germinationDay,2])
		superInd[germinationDay,2] = Thinning[1]
		superInd[germinationDay,3] = Thinning[2]
	end

	superInd[germinationDay,4]=growHeight(superInd[germinationDay-1,4],superInd[germinationDay,3],maxWeightLenRatio=maxWeightLenRatio)

	#GROWTH
	for d in (germinationDay+1):(germinationDay+maxAge)
		Seeds[d,1] = Seeds[d-1,1] - Seeds[d-1,1] * SeedMortality #minus SeedMortality #SeedBiomass
		Seeds[d,3] = (1-cTuber)*Seeds[d-1,3] #Reduction of allocatedBiomass untill it is used
		Seeds[d,2]=getNumberOfSeeds(Seeds[d,1]) #SeedNumber
		Seeds[d,4]=getNumberOfSeeds(Seeds[d,3]) #allocatedSeedNumber
		superInd[d,2] = superInd[d-1,2] #PlantNumber stays the same !!! MORTALITY ?????


		#GROWTH
		dailyRES = getRespiration(d, resp20=resp20, q10=q10) #[g / g*d]
	  dailyPS = getPhotosynthesisPLANTDay(d, superInd[d-1,4], Biomass=superInd[d-1,1], latitude=latitude, LevelOfGrid=LevelOfGrid, yearlength=yearlength,
	      maxW=maxW, minW=minW, wDelay=wDelay, levelCorrection=levelCorrection,
		  	hPhotoDist=hPhotoDist, parFactor=parFactor, fracReflected=fracReflected, iDev=iDev, plantK=plantK, fracPeriphyton=fracPeriphyton,
		  	minI=minI, maxI=maxI, iDelay=iDelay, kdDev=kdDev, maxKd=maxKd, minKd=minKd, kdDelay=kdDelay, hPhotoLight=hPhotoLight,
				backgrKd=backgrKd, hTurbReduction=hTurbReduction,pTurbReduction=pTurbReduction,
				tempDev=tempDev, maxTemp=maxTemp, minTemp=minTemp, tempDelay=tempDelay, sPhotoTemp=sPhotoTemp, pPhotoTemp=pPhotoTemp, hPhotoTemp=hPhotoTemp, pMax=pMax)[1]
		photosynDay[d]=dailyPS #Just to controll

		#Biomass calc
	  superInd[d,1] = superInd[d-1,1] + Seeds[d,3]*cTuber +
			(((1-rootShootRatio)*superInd[d-1,1] - superInd[d-1,5])*dailyPS - superInd[d-1,1]*(dailyRES + BackgroundMort))

		superInd[d,3] =  getIndividualWeight(superInd[d,1], superInd[d,2]) #individualWeight = Biomass / Number

		#Thinning
		Thinning = dieThinning(superInd[d,2],superInd[d,3]) #Adapts number of individuals [/m^2]& individual weight
		if (Thinning[1]<superInd[d,2]) #&& (Thinning[2] > 0)
			superInd[d,2] = Thinning[1] #N
  		superInd[d,3] = Thinning[2] #indWeight#
		end

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

	return (superInd, Seeds,photosynDay)
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

plot(Res[3], label = "PS Rate")
