"""
CHARISMA in JULIA
Initialisation of Climate, Daylength, Irradiance, Light
"""
# FUNCTION DAYLENGTH FROM R III Author: Robert J. Hijmans, r.hijmans@gmail.com # License GPL3 # Version 0.1  January 2009
# Forsythe, William C., Edward J. Rykiel Jr., Randal S. Stahl, Hsin-i Wu and Robert M. Schoolfield, 1995.
# A model comparison for daylength as a function of latitude and day of the year. Ecological Modeling 80:87-95.

function daylength(lat, doy)
#	if (class(doy) == 'Date' | class(doy) == 'character')
#		doy = as.character(doy)
#		doy = as.numeric(format(as.Date(doy), "%j"))
#	 else
#		doy = (doy-1) %% 365 + 1
#	end
#	lat[lat > 90 | lat < -90] = NA
	P::Float64 = asin(0.39795 * cos(0.2163108 + 2 * atan(0.9671396 * tan(0.00860*(doy-186)))))
	a =  (sin(0.8333 * pi/180) + sin(lat * pi/180) * sin(P)) / (cos(lat * pi/180) * cos(P))
#	a = pmin(pmax(a, -1), 1)
	DL = 24 - (24/pi) * acos(a)
	return(DL)
end

"""
#Testing
testDay=180
testLat=45
testdaylength = daylength(testLat,testDay)
"""

function Initialisation_Clim(yearlength::Float64=365.0,
    					TempDev::Float64=1.0, TempMax::Float64=30.0, TempMin::Float64=2.0, TempLag::Float64=0.0,
    					MaxI::Float64=2000.0, MinI::Float64=50.0, IDelay::Float64=0.0,
    					Latitude::Float64=50.0)
	Tem = Float64[]
	Irr = Float64[]
	Day_length = Float64[]
	for d in 1:yearlength
		push!(Tem, TempDev * (TempMax - ((TempMax-TempMin)/2)*(1+cos((2*pi/yearlength)*(d-TempLag)))))
		push!(Irr, MaxI - (((MaxI-MinI)/2) * (1+cos((2*pi/yearlength)*(d-IDelay)))))
		push!(Day_length, daylength(Latitude,d))
	end
	return(Tem, Irr, Day_length)
end


"""
#Testing
Temp = Initialisation_Clim()[1]
Irra = Initialisation_Clim()[2]
DL = Initialisation_Clim()[3]

using Pkg
Pkg.add("Plots")
using Plots
pyplot() # Choose the Plotly.jl backend for web interactivity
p1 = plot(Temp,linewidth=2,label="Temperature [°C]")
p1 = plot!(DL,linewidth=2,label="Daylength [h]")
p2 = plot(Irra,linewidth=2,label="Irradiance [?]")
plot(p1,p2,layout=(2,1))
"""

function Irradiance_hr(Day_length, day, Irr)
	Irr_hr = Float64[]
	for h in 1:(Day_length[day])
		push!(Irr_hr, ((pi*Irr[day])/(2*Day_length[day]))*sin((pi*h)/Day_length[day]))
	end
	return Irr_hr
end

"""
#Testing
test_Irr = Irradiance_hr(DL, testDay, Irra)
plot(test_Irr)
"""

"""
#Pre-testing the Light function
PARFactor=0.5
FracReflected=0.1
SunDev=0.0
KdDev=1.0
maxKd=2.0
minKd=2.0
days=365.0
KdDelay=-10.0
day=testDay
dist_water_surface=1.0
PlantK=0.02
higherbiomass=0.0
fracPeriphyton=0.2
Irr_surf = test_Irr * (1 - PARFactor) * (1 - FracReflected) * (1 - SunDev)
lightAttenuCoef = KdDev * (maxKd - (maxKd-minKd)/2*(2*pi/days)*(day-KdDelay))
Light_water = Irr_surf * exp(1)^(- lightAttenuCoef * dist_water_surface - PlantK * higherbiomass)
light_plant_hour = Light_water - (Light_water * fracPeriphyton)

plot(test_Irr)
plot!(Irr_surf)
plot!(Light_water)
plot!(light_plant_hour)

#is working!
"""

function Light(Irradiance_hour::Array{Float64}=test_Irr, PARFactor::Float64=0.5, FracReflected::Float64=0.1, SunDev::Float64=0.0,
                 KdDev::Float64=1.0, maxKd::Float64=2.0, minKd::Float64=2.0, days::Float64=365.0, KdDelay::Float64=-10.0,
                 dist_water_surface::Float64=1.0, PlantK::Float64=0.02, higherbiomass::Float64=0.0, fracPeriphyton::Float64=0.2, day::Float64=180.0)
		 Irr_surf = Irradiance_hour * (1 - PARFactor) * (1 - FracReflected) * (1 - SunDev) # ÂµE/m^2*s
	     lightAttenuCoef = KdDev * (maxKd - (maxKd-minKd)/2*(2*pi/days)*(day-KdDelay)) #+ Kdisorg + Kparticulates <- TUBRIDITY
	     Light_water = Irr_surf * exp(1)^(- lightAttenuCoef * dist_water_surface - PlantK * higherbiomass) # LAMBERT BEER # ÂµE/m^2*s # MÃ¶glichkeit im Exponenten: (absorptivity*c_H2O_pure*dist_water_surface))
	     light_plant_hour = Light_water - (Light_water * fracPeriphyton) ## ÂµE/m^2*s
	return light_plant_hour
end

"""
test_Light = Light(Irradiance_hour=test_Irr)
# Funktionniert nur, wenn Light() ?!
"""
