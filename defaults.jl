"""
Default settings

Defines the list of configuration variables and returns their default values
in a Dict.
"""

function defaultSettings()
    # Return the default settings. All parameters must be registered here.
    Dict(
    "lat" => 47.8, #Latitude of corresponding lake; [°] II 47.8 = Chiemsee
    #"doy" => , #actual day - has to be flexible
    "yearlength" => 365, #Number of days each year [n]
    "TempDev" => 1.0, #share of temp (??) []
    "TempMax" => 30.0, #max mean daily temperature of a year in [°C]
    "TempMin" => 5.0, #min mean daily temperature of a year in [°C]
    "TempLag" => 0.0, #days after 1st of January where Temp is minimal [n]
    "MaxI" => 2000.0, #Maximal Irradiance in [µE m^-2 s^-1]
    "MinI" => 300.0, #Minimal Irradiance [µE m^-2 s^-1]
    "IDelay" => 0.0, #days after 1st of January where I is minimal [n]
    "PARFactor" => 0.5,
    "fracPeriphyton" => 0.1,
    "SunDev" => 0.0,
    "KdDev" => 1.0,
    "maxKd" => 2.0,
    "minKd" => 2.0,
    "KdDelay" => -10.0,
    "dist_water_surface" => 1,
    "PlantK" => 0.02,
    "higherbiomass" => 0.0,
    "fracPeriphyton" => 0.2
    )
end

#a=defaultSettings()

#get(a, "lat", "NA")
#a["lat"]
