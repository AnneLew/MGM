"""
CHARISMA in JULIA
Initialisation of Climate, Daylength, Irradiance, Light
"""
# FUNCTION DAYLENGTH FROM R III Author: Robert J. Hijmans, r.hijmans@gmail.com # License GPL3 # Version 0.1  January 2009
# Forsythe, William C., Edward J. Rykiel Jr., Randal S. Stahl, Hsin-i Wu and Robert M. Schoolfield, 1995.
# A model comparison for daylength as a function of latitude and day of the year. Ecological Modeling 80:87-95.

function initializeDaylength(;lat::Float64=47.8, doy::Int64)
#	if (class(doy) == 'Date' | class(doy) == 'character')
#		doy = as.character(doy)
#		doy = as.numeric(format(as.Date(doy), "%j"))
#	 else
#		doy = (doy-1) %% 365 + 1
#	end
	lat >90.0 || lat <-90.0 && return error("lat must be between 90.0 & -90.0 Degree")
	p = asin(0.39795 * cos(0.2163108 + 2 * atan(0.9671396 * tan(0.00860*(doy-186)))))
	a =  (sin(0.8333 * pi/180) + sin(lat * pi/180) * sin(p)) / (cos(lat * pi/180) * cos(p))
	if a < -1
		a = -1
	elseif a > 1
		a = 1
	end
	return(dl::Float64 = 24 - (24/pi) * acos(a))
end

"""
#Testing
testdaylength = initializeDaylength(doy=180)
"""

function initializeClim(;yearlength::Int64=365,
    					tempDev::Float64=1.0, tempMax::Float64=18.8, tempMin::Float64=1.1, tempLag::Int64=23,
    					maxI::Float64=868.0, minI::Float64=96.0, iDelay::Int64=-10,
    					lat::Float64=47.8)
	temp = Float64[]
	irra = Float64[]
	daylength = Float64[]
	for d::Int64 in 1:yearlength
		push!(temp, tempDev * (tempMax - ((tempMax-tempMin)/2)*(1+cos((2*pi/yearlength)*(d-tempLag)))))
		push!(irra, maxI - (((maxI-minI)/2) * (1+cos((2*pi/yearlength)*(d-iDelay)))))
		push!(daylength, initializeDaylength(lat=lat,doy=d))
	end
	return(temp, irra, daylength)
end

"""
#Testing
Init_Clim = initializeClim(tempDev=1.0, tempMax=30.0, tempMin=2.0, tempLag=0,
    					maxI=2000.0, minI=50.0,
    					lat=50.0)



#using Pkg
#Pkg.add("Plots")
using Plots
pyplot() # Choose the Plotly.jl backend for web interactivity
p1 = plot(Init_Clim[1],linewidth=2,label="Temperature [°C]")
p1 = plot!(Init_Clim[3],linewidth=2,label="Daylength [h]")
p2 = plot(Init_Clim[2],linewidth=2,label="Irradiance [?]")
plot(p1,p2,layout=(2,1))
"""

function initializeIrradianceD(daylength, day::Int64, irradianceD)
	irraH = Float64[]
	for h in 1:(daylength[day])
		push!(irraH, ((pi*irradianceD[day])/(2*daylength[day]))*sin((pi*h)/daylength[day]))
	end
	return irraH
end

"""
#Testing
testDay=180
test_Irr = initializeIrradianceD(Init_Clim[3], testDay, Init_Clim[2])
plot(test_Irr)

"""

function getLightD(;irradianceH::Array{Float64}=test_Irr, parFactor::Float64=0.5, fracReflected::Float64=0.1, sunDev::Float64=0.0,
                 kdDev::Float64=1.0, maxKd::Float64=2.0, minKd::Float64=2.0, yearlength::Float64=365.0, kdDelay::Float64=-10.0,
                 distWaterSurface::Float64=1.0, plantK::Float64=0.02, higherbiomass::Float64=0.0, fracPeriphyton::Float64=0.2, day::Float64=180.0)
		 irrSurf = irradianceH * (1 - parFactor) * (1 - fracReflected) * (1 - sunDev) # ÂµE/m^2*s
		 #lightAttenuCoef: External light attenuation coefficient (extinction coefficient), that is the light attenuation without the effect of vegetation on turbidity [m^-1]
	     lightAttenuCoef = kdDev * (maxKd - (maxKd-minKd)/2*(2*pi/yearlength)*(day-kdDelay)) #+ Kdisorg + Kparticulates <- TUBRIDITY
	     lightWater = irrSurf * exp(1)^(- lightAttenuCoef * distWaterSurface - plantK * higherbiomass) # LAMBERT BEER # ÂµE/m^2*s # MÃ¶glichkeit im Exponenten: (absorptivity*c_H2O_pure*dist_water_surface))
	     lightPlantHour = lightWater - (lightWater * fracPeriphyton) ## ÂµE/m^2*s
	return lightPlantHour
end


"""
getLightD()
test_Light = getLightD(irradianceH=test_Irr; parFactor=0.1)
plot(test_Light)

"""
