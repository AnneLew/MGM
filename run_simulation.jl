"""
SIMULATION
"""

include("CHARISMA.jl")
include("defaults.jl")
include("input.jl")

settings = getsettings()

using Plots
using QuadGK

function simulate(;years::Int64=settings["years"],yearlength::Int64=settings["yearlength"],germinationDay::Int64=settings["germinationDay"],
	heightMax::Float64=settings["heightMax"],rootShootRatio::Float64=settings["rootShootRatio"],
	BackgroundMort::Float64=settings["BackgroundMort"],
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
	SeedMortality::Float64=settings["SeedMortality"],spreadFrac::Float64=settings["spreadFrac"],
	backgrKd::Float64=settings["backgrKd"],hTurbReduction::Float64=settings["hTurbReduction"],pTurbReduction::Float64=settings["pTurbReduction"],
	thinning::String=settings["thinning"])

	#Initialisation
	seeds = zeros(Float64, yearlength, 3, years) #SeedBiomass, SeedNumber, SeedsGerminatingBiomass
	superInd = zeros(Float64, yearlength, 6, years) #Biomass, Number, indWeight, Height, allocatedBiomass, SpreadBiomass
	memory = zeros(Float64, yearlength, 2, years) #dailyPS, dailyRES



	for y in 1:years
		if y==1
			seeds[1,1,1] = seedInitialBiomass #initial SeedBiomass
			#superInd[1,1] = 0  #initial Biomass
			seeds[1,2,1]=getNumberOfSeeds(seeds[1,1,1], seedBiomass=seedBiomass) #initial SeedNumber
		else
			seeds[1,1,y] = seeds[yearlength,1,y-1]
			#superInd[1,1] = 0  #initial Biomass
			seeds[1,2,y]=getNumberOfSeeds(seeds[1,1,y], seedBiomass=seedBiomass)
		end
		#Until Germination Starts
		for d in 2:germinationDay
		  seeds[d,1,y] = seeds[d-1,1,y] - seeds[d-1,1,y] * SeedMortality #minus SeedMortality #SeedBiomass
		  seeds[d,2,y]=getNumberOfSeeds(seeds[d,1,y], seedBiomass=seedBiomass) #SeedNumber
		end

		#GERMINATION
		seeds[germinationDay,3,y] = seeds[germinationDay-1,1,y] * seedGermination #20% of the SeedsBiomass are transformed to SeedsGerminatingBiomass
		seeds[germinationDay,1,y] = seeds[germinationDay-1,1,y] - seeds[germinationDay,3,y] - seeds[germinationDay-1,1,y] * SeedMortality#Remaining SeedsBiomass
		superInd[germinationDay,2,y] = getNumberOfSeeds(seeds[germinationDay,3,y], seedBiomass=seedBiomass) #Germinated Individuals

		superInd[germinationDay,1,y] = seeds[germinationDay,3,y]*cTuber
		superInd[germinationDay,3,y] =  getIndividualWeight(superInd[germinationDay,1,y], superInd[germinationDay,2,y]) #individualWeight = Biomass /

		# Thinning, optional
		if thinning == "TRUE"
			thin = dieThinning(superInd[germinationDay,2,y],superInd[germinationDay,3,y]) #Adapts number of individuals [/m^2]& individual weight
			if (thin[1]<superInd[germinationDay,2,y])
				superInd[germinationDay,2,y] = thin[1]
				superInd[germinationDay,3,y] = thin[2]
			end
		end

		superInd[germinationDay,4,y] = growHeight(superInd[germinationDay,3,y],maxWeightLenRatio=maxWeightLenRatio)

		#GROWTH
		for d in (germinationDay+1):(germinationDay+maxAge)
			seeds[d,1,y] = seeds[d-1,1,y] - seeds[d-1,1,y] * SeedMortality #minus SeedMortality #SeedBiomass
			seeds[d,3,y] = (1-cTuber)*seeds[d-1,3,y] #Reduction of allocatedBiomass untill it is used
			seeds[d,2,y]=getNumberOfSeeds(seeds[d,1,y], seedBiomass=seedBiomass) #SeedNumber
			superInd[d,2,y] = superInd[d-1,2,y] #PlantNumber stays the same ??!!! MORTALITY ?????

			#GROWTH
			dailyRES = getRespiration(d, resp20=resp20, q10=q10) #[g / g*d]
			memory[d,2,y] =dailyRES
			dailyPS = getPhotosynthesisPLANTDay(d, superInd[d-1,4,y], Biomass=(1-rootShootRatio)*superInd[d-1,1,y], latitude=latitude, LevelOfGrid=LevelOfGrid, yearlength=yearlength,
		      	maxW=maxW, minW=minW, wDelay=wDelay, levelCorrection=levelCorrection,
			  	hPhotoDist=hPhotoDist, parFactor=parFactor, fracReflected=fracReflected, iDev=iDev, plantK=plantK, fracPeriphyton=fracPeriphyton,
			  	minI=minI, maxI=maxI, iDelay=iDelay, kdDev=kdDev, maxKd=maxKd, minKd=minKd, kdDelay=kdDelay, hPhotoLight=hPhotoLight,
				backgrKd=backgrKd, hTurbReduction=hTurbReduction,pTurbReduction=pTurbReduction,
				tempDev=tempDev, maxTemp=maxTemp, minTemp=minTemp, tempDelay=tempDelay, sPhotoTemp=sPhotoTemp, pPhotoTemp=pPhotoTemp, hPhotoTemp=hPhotoTemp, pMax=pMax)[1]
			memory[d,1,y]=dailyPS #Just to controll

			#Biomass calc
			dailyGrowth = seeds[d,3,y]*cTuber + (((1-rootShootRatio)*superInd[d-1,1,y] - superInd[d-1,5,y])*dailyPS - superInd[d-1,1,y]*(dailyRES + BackgroundMort))

			#SPREAD UNDER WATER SURFACE
			if superInd[d-1,4,y] == getWaterDepth(d-1, LevelOfGrid=LevelOfGrid, yearlength=yearlength, maxW=maxW, minW=minW, wDelay=wDelay, levelCorrection=levelCorrection)
		  	superInd[d,1,y] = superInd[d-1,1,y] + (1 - spreadFrac) * dailyGrowth #Aufteilung der Production in shoots & under surface
				superInd[d,6,y] = superInd[d-1,6,y] + spreadFrac * dailyGrowth
			else
				superInd[d,1,y] = superInd[d-1,1,y] + dailyGrowth
			end

			superInd[d,3,y] =  getIndividualWeight(superInd[d,1,y], superInd[d,2,y]) #individualWeight = Biomass / Number

			#Thinning, optional
			if thinning == "TRUE"
				thin = dieThinning(superInd[d,2,y],superInd[d,3,y]) #Adapts number of individuals [/m^2]& individual weight
				if (thin[1]<superInd[d,2,y]) #&& (Thinning[2] > 0)
					superInd[d,2,y] = thin[1] #N
		  			superInd[d,3,y] = thin[2] #indWeight#
				end
			end

			#Height calc
			superInd[d,4,y] = growHeight(superInd[d,3,y], maxWeightLenRatio=maxWeightLenRatio) #!!!QUATSCH??
			if superInd[d,4,y] >= heightMax
				superInd[d,4,y] = heightMax
			end
			WaterDepth = getWaterDepth(d, LevelOfGrid=LevelOfGrid, yearlength=yearlength, maxW=maxW, minW=minW, wDelay=wDelay, levelCorrection=levelCorrection)
					if superInd[d,4,y] >= WaterDepth
				superInd[d,4,y] = WaterDepth
			end

			#ALLOCATION OF BIOMASS FOR SEED PRODUCTION
			if d > (germinationDay + seedsStartAge) && d < (germinationDay + seedsEndAge)
				superInd[d,5,y] = superInd[d-1,5,y] + superInd[d,1,y]*seedFraction / (seedsEndAge - seedsStartAge) #allocatedBiomass Stimmt das so???
			end
			if d >= (germinationDay + seedsEndAge) && d <= reproDay
				superInd[d,5,y] = superInd[d,1,y]*seedFraction #allocatedBiomass - Fraction remains
			end
			#TRANSFORMATION OF ALLOCATED BIOMASS IN SEEDS
			if d == reproDay
				seeds[d,1,y] = seeds[d-1,1,y] + superInd[d,5,y] - seeds[d-1,1,y] * SeedMortality
			end

		end
		#WINTER
		for d in (germinationDay+maxAge+1):365
			superInd[d,4,y]=0
			superInd[d,1,y]=0
			superInd[d,2,y] = 0 #minus Mortality
			seeds[d,1,y] = seeds[d-1,1,y] - seeds[d-1,1,y] * SeedMortality #minus SeedMortality
			seeds[d,2,y]=getNumberOfSeeds(seeds[d,1,y], seedBiomass=seedBiomass)
		end
	end
	return (superInd, seeds, memory)
end

PMAX=0.7
Res1 = simulate(LevelOfGrid=-1.0,pMax=PMAX)
Res2 = simulate(LevelOfGrid=-2.0,pMax=PMAX)
Res3 = simulate(LevelOfGrid=-3.0,pMax=PMAX)
Res4 = simulate(LevelOfGrid=-4.0,pMax=PMAX)


###########################################################################
### PLOTS
###########################################################################
Plots.scalefontsizes(2)
pyplot()
YEAR=1
maxBiomass=8100
maxN=20000
maxHeight=0.35
maxSeeds=1000

p1_1=plot(Res1[1][:,1,YEAR], label = 1, ylabel = "Biomass (g)", ylims=(0,maxBiomass), title="1m depth")
p1_2=plot(Res2[1][:,1,YEAR], label = 1, ylims=(0,maxBiomass), title="2m depth")
p1_3=plot(Res3[1][:,1,YEAR], label = 1, ylims=(0,maxBiomass), title="3m depth")
p1_4=plot(Res4[1][:,1,YEAR], label = 1, ylims=(0,maxBiomass), title="4m depth")

p2_1=plot(Res1[1][:,2,YEAR], label = 1, ylabel = "Individuals (N)", ylims=(0,maxN))
p2_2=plot(Res2[1][:,2,YEAR], label = 1, ylims=(0,maxN))
p2_3=plot(Res3[1][:,2,YEAR], label = 1, ylims=(0,maxN))
p2_4=plot(Res4[1][:,2,YEAR], label = 1, ylims=(0,maxN))

p3_1=plot(Res1[1][:,4,YEAR], label = 1, ylabel = "Height (m)", ylims=(0,maxHeight))
p3_2=plot(Res2[1][:,4,YEAR], label = 1, ylims=(0,maxHeight))
p3_3=plot(Res3[1][:,4,YEAR], label = 1, ylims=(0,maxHeight))
p3_4=plot(Res4[1][:,4,YEAR], label = 1, ylims=(0,maxHeight))

p4_1=plot(Res1[2][:,1,YEAR], label = 1, ylabel = "Seed biomass (g)", ylims=(0,maxSeeds), xlabel="Time (days)")
p4_2=plot(Res2[2][:,1,YEAR], label = 1, ylims=(0,maxSeeds), xlabel="Time (days)")
p4_3=plot(Res3[2][:,1,YEAR], label = 1, ylims=(0,maxSeeds), xlabel="Time (days)")
p4_4=plot(Res4[2][:,1,YEAR], label = 1, ylims=(0,maxSeeds), xlabel="Time (days)")


FIN=plot(p1_1,p1_2,p1_3,p1_4,
			#p2_1,p2_2,p2_3,p2_4,
			p3_1,p3_2,p3_3,p3_4,
			p4_1,p4_2,p4_3,p4_4,
		layout=(3,4), legend=false,size=(1400,1000)) #size=(800,600)

png("C:\\Users\\anl85ck\\Desktop\\PhD\\4_Modellierung\\2_CHARISMA\\99_Figures\\plot_all.png")

#Animation
Plots.scalefontsizes(0.8)
p = plot(1,layout = (3,4), label="")
anim = @animate for x=80:365
  #push!(p, 1, Res[1][x,1,5])
  plot!(p[1],  Res1[1][1:x,1,YEAR], ylabel="Plant Biomass (g)", ylims=(0,maxBiomass),label="", title="1m")
  plot!(p[2],  Res2[1][1:x,1,YEAR], label="", title="2m",ylims=(0,maxBiomass))
  plot!(p[3],  Res3[1][1:x,1,YEAR], label="", title="3m",ylims=(0,maxBiomass))
  plot!(p[4],  Res4[1][1:x,1,YEAR], label="", title="4m",ylims=(0,maxBiomass))

  #plot!(p[3],  Res1[1][1:x,2,5], ylabel="Plant individuals (N)", label="")
  #plot!(p[4],  Res2[1][1:x,2,5], label="")

  plot!(p[5],  Res1[1][1:x,4,YEAR], ylabel="Plant height (m)", label="", ylims=(0,maxHeight))
  plot!(p[6],  Res2[1][1:x,4,YEAR], label="", ylims=(0,maxHeight))
  plot!(p[7],  Res3[1][1:x,4,YEAR], label="", ylims=(0,maxHeight))
  plot!(p[8],  Res4[1][1:x,4,YEAR], label="", ylims=(0,maxHeight))

  plot!(p[9],  Res1[2][1:x,1,YEAR], ylabel="Seeds Biomass (g)", label="", xlabel="Time (days)", ylims=(0,maxSeeds))
  plot!(p[10],  Res2[2][1:x,1,YEAR], label="", xlabel="Time (days)", ylims=(0,maxSeeds))
  plot!(p[11],  Res3[2][1:x,1,YEAR], label="", xlabel="Time (days)", ylims=(0,maxSeeds))
  plot!(p[12],  Res4[2][1:x,1,YEAR], label="", xlabel="Time (days)", ylims=(0,maxSeeds))
end
#gif(C:\\Users\\anl85ck\\Desktop\\PhD\\4_Modellierung\\2_CHARISMA\\99_Figures\\anim_1m,fps=5)
gif(anim,fps=5)

"""
p1=plot(Res[1][:,1,1], label = 1, title = "Biomass")
for y in 2:settings["years"]
	display(plot!(Res[1][:,1,y], label = y))
end

p2=plot(Res[1][:,2,1], label = 1, title = "N")
for y in 2:settings["years"]
	display(plot!(Res[1][:,2,y], label = y))
end

p3=plot(Res[1][:,3,1], label = 1, title = "indWeight")
for y in 2:settings["years"]
	display(plot!(Res[1][:,3,y], label = y))
end
p4=plot(Res[1][:,4,1], label = 1, title = "height")
for y in 2:settings["years"]
	display(plot!(Res[1][:,4,y], label = y))
end
p5=plot(Res[1][:,5,1], label = 1, title = "allocatedBiomass")
for y in 2:settings["years"]
	display(plot!(Res[1][:,5,y], label = y))
end


#plot(Res[1][:,6], label = "SpreadFraction")

p6=plot(Res[2][:,1,1], label = 1, title = "SeedsBiomass")
for y in 2:settings["years"]
	display(plot!(Res[2][:,1,y], label = y))
end
p7=plot(Res[2][:,2,1], label = 1, title = "SeedsNR")
for y in 2:settings["years"]
	display(plot!(Res[2][:,2,y], label = y))
end
p8=plot(Res[2][:,3,1], label = 1, title = "SeedsGerminatingBiomass")
for y in 2:settings["years"]
	display(plot!(Res[2][:,3,y], label = y))
end


p9=plot(Res[3][:,1,1], label = 1, title = "PS Rate")
for y in 2:settings["years"]
	display(plot!(Res[3][:,1,y], label = y))
end
p10=plot(Res[3][:,2,1], label = 1, title = "Res Rate")
for y in 2:settings["years"]
	display(plot!(Res[3][:,2,y], label = y))
end

pfin = plot(p1,p2,p3,p4,p5,p6,p9,p10,layout=(4,2),legend=false)

png("C:\\Users\\anl85ck\\Desktop\\PhD\\4_Modellierung\\2_CHARISMA\\99_Figures\\plot_1m.png")


"""
"""


p = plot(1,layout = (4,1), label="")

anim = @animate for x=1:365
  #push!(p, 1, Res[1][x,1,5])
  plot!(p[2],  Res[1][1:x,1,5], title="Plant Biomass (g)", label="")
  plot!(p[3],  Res[1][1:x,2,5], title="Plant individuals (N)", label="")
  plot!(p[4],  Res[1][1:x,4,5], title="Plant height (m)", label="", xlabel="Time (days)")
  plot!(p[1],  Res[2][1:x,1,5], title="Seeds Biomass (g)", label="")
end
gif(anim,fps=5)


plt = plot(1, ylim=(0,2000),title = "Plant Biomass (g)", label="",xlabel="Time (days)")
ani = @animate for j=1:settings["years"]
		for i=1:settings["yearlength"]
			push!(plt, 1, Res[1][i,1,j])
	end
end
gif(ani, fps=1)

"""
