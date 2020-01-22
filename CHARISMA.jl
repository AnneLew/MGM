"""
CHARISMA in JULIA
Initialisation of Temperature, Daylength, Irradiance, Light, Water Level
"""
# FUNCTION DAYLENGTH FROM R III Author: Robert J. Hijmans, r.hijmans@gmail.com # License GPL3 # Version 0.1  January 2009
# Forsythe, William C., Edward J. Rykiel Jr., Randal S. Stahl, Hsin-i Wu and Robert M. Schoolfield, 1995.
# A model comparison for daylength as a function of latitude and day of the year. Ecological Modeling 80:87-95.

function getDaylength(day;lat::Float64=47.8)
#	if (class(doy) == 'Date' | class(doy) == 'character')
#		doy = as.character(doy)
#		doy = as.numeric(format(as.Date(doy), "%j"))
#	 else
#		doy = (doy-1) %% 365 + 1
#	end
	lat >90.0 || lat <-90.0 && return error("lat must be between 90.0 & -90.0 Degree")
	p = asin(0.39795 * cos(0.2163108 + 2 * atan(0.9671396 * tan(0.00860*(day-186)))))
	a =  (sin(0.8333 * pi/180) + sin(lat * pi/180) * sin(p)) / (cos(lat * pi/180) * cos(p))
	if a < -1
		a = -1
	elseif a > 1
		a = 1
	end
	return(dl::Float64 = 24 - (24/pi) * acos(a))
end

getDaylength(180)


function getTemperature(day;yearlength::Int64=365,
    					tempDev::Float64=1.0, tempMax::Float64=18.8, tempMin::Float64=1.1, tempLag::Int64=23)
	tempDev * (tempMax - ((tempMax-tempMin)/2)*(1+cos((2*pi/yearlength)*(day-tempLag))))
end

getTemperature(180)

function getSurfaceIrradianceDay(day;yearlength::Int64=365,
    					maxI::Float64=868.0, minI::Float64=96.0, iDelay::Int64=-10)
		maxI - (((maxI-minI)/2) * (1+cos((2*pi/yearlength)*(day-iDelay))))
end

getSurfaceIrradianceDay(60)
using Plots
plot(getSurfaceIrradianceDay, 1:365)

function getWaterlevel(day; yearlength::Int64=365,
						maxW::Float64=0.3, minW::Float64=-0.3, wDelay::Int64=40,levelCorrection::Float64=0.0)
		levelCorrection + (maxW - (maxW-minW)/2 * (1 + cos((2*pi/yearlength)*(day-wDelay))))
end

getWaterlevel(60)


function getSurfaceIrradianceHour(day, hour) #times in hour after sunset
	irradianceD = getSurfaceIrradianceDay(day)
	daylength = getDaylength(day)
	((pi*irradianceD)/(2*daylength))*sin((pi*hour)/daylength)
end

getSurfaceIrradianceHour(50,5)

function getLightAttenuation(day; kdDev::Float64=1.0, maxKd::Float64=2.0, minKd::Float64=2.0,
	yearlength::Int=365, kdDelay::Float64=-10.0)
	kdDev * (maxKd - (maxKd-minKd)/2*(2*pi/yearlength)*(day-kdDelay))  #+ Kdisorg + Kparticulates <- TUBRIDITY
end
plot(getLightAttenuation, 1:365)


#MISSING: Calculation of higherbiomass


function getEffectiveIrradianceHour(day, hour, distWaterSurface;
	parFactor::Float64=0.5, fracReflected::Float64=0.1, sunDev::Float64=0.0,
	plantK::Float64=0.02, higherbiomass::Float64=0.0, fracPeriphyton::Float64=0.2)
		 irrSurfHr = getSurfaceIrradianceHour(day, hour)
		 irrSubSurfHr = irrSurfHr * (1 - parFactor) * (1 - fracReflected) * (1 - sunDev) # ÂµE/m^2*s
		 #lightAttenuCoef: External light attenuation coefficient (extinction coefficient), that is the light attenuation without the effect of vegetation on turbidity [m^-1]
	     lightAttenuCoef = getLightAttenuation(day)
	     lightWater = irrSubSurfHr * exp(1)^(- lightAttenuCoef * distWaterSurface - plantK * higherbiomass) # LAMBERT BEER # ÂµE/m^2*s # MÃ¶glichkeit im Exponenten: (absorptivity*c_H2O_pure*dist_water_surface))
	     lightPlantHour = lightWater - (lightWater * fracPeriphyton) ## ÂµE/m^2*s
	return lightPlantHour
end

getEffectiveIrradianceHour(150, 6, 0.5)


function getRespiration(day; resp20::Float64=0.024, q10::Float64=2.0, t1::Float64=20.0) #DAILY VALUE
    Temper = getTemperature(day)
	resp20 * q10^((Temper - t1)/10)
end
getRespiration(180)



function getWaterDepth(day; LevelOfGrid::Float64=-2.0)
	WaterDepth = getWaterlevel(day) - LevelOfGrid
end

getWaterDepth(80)

function distPlantTopFromSurface(day, height)
   distPlantTopFromSurface = getWaterDepth(day) - height ##Aktuelle Höhe einfügen
end

distPlantTopFromSurface(180, 0.80)


#Photosynthesis (Biomass brutto growth) (g g^-1 h^-1)
function getPhotosynthesis(day, hour, distFromPlantTop; hPhotoLight::Float64=14.0,
                         sPhotoTemp::Float64=1.35, pPhotoTemp::Float64=3.0, hPhotoTemp::Float64=14.0,
                         hPhotoDist::Float64=1.0, distWaterSurf::Float64=0,
                         #bicarbonateConc, hCarbonate, pCarbonate,
                         #nutrientConc, pNutrient, hNutrient,
                         pMax::Float64=0.006)
  distWaterSurf = 
  distFromPlantTop = distWaterSurf -
  lightPlantHour = getEffectiveIrradianceHour(day, hour, distWaterSurf)
  lightFactor = lightPlantHour / (lightPlantHour + hPhotoLight) #ÂµE m^-2 s^-1); The default half-saturation constants (C aspera 14 yE m-2s-1; P pectinatus 52) are based on growth experiments

  temp = getTemperature(day)
  tempFactor = (sPhotoTemp * temp ^ pPhotoTemp) / (temp ^ pPhotoTemp + hPhotoTemp ^ pPhotoTemp) #Â°C

  distFactor = hPhotoDist / (hPhotoDist + distFromPlantTop) #m
  #bicarbFactor = bicarbonateConc ^ pCarbonate / (bicarbonateConc ^ pCarbonate + hCarbonate ^ pCarbonate) # C.aspera hCarbonate=30 mg/l; P.pectinatus hCarbonate=60 mg/l
  #nutrientFactor <- nutrientConc ^ pNutrient / (nutrientConc ^ pNutrient + hNutrient ^ pNutrient)
  psHour = pMax * lightFactor * tempFactor * distFactor #* bicarbFactor #* nutrientFactor #(g g^-1 h^-1)
  return (psHour)
end

getPhotosynthesis(180,12,0)

using Plots
plot(x -> getPhotosynthesis(140,5,x), 0, 5)
plot(x -> getPhotosynthesis(140,x,0), 0, 15)
plot(x -> getPhotosynthesis(x,5,0), 100, 250)

#INTEGRATION ÜBER TIEFE VON WaterDepth bis distPlantTopFromSurface
#INTEGRATION Über daylength
using HCubature
function getPhotosynthesisPLANT(day)
	daylength = getDaylength(day)
	hcubature(x -> getPhotosynthesis(day,x[1],x[2]), [0,4],[daylength,1])
end
#!! Achtung bis maxDaylength integrieren!
getPhotosynthesisPLANT(190)


###Growth
function growWeight(weight1, day, rootShootRatio::Float64=0.1, mortalityRate::Float64=0.0)
  dailyRES = getRespiration(day)
  dailyPS = getPhotosynthesisPLANT(day)[1]
  weight = (1-rootShootRatio)*weight1*dailyPS - weight1*(dailyRES + mortalityRate)
  return (weight)
end

"""
#Testing
growWeight(10,190)
"""

function growHeight(height1::Float64, weight2::Float64, weight1::Float64)
  height = height1*(weight2 / weight1)#*MaxWeightLenRatio
  return height
end

"""
#Testing
growHeight(10.0,7.0,6.0)
"""
