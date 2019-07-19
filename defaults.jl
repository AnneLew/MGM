"""
Default settings

Defines the list of configuration variables and returns their default values
in a Dict.
"""

function defaultSettings()
    # Return the default settings. All parameters must be registered here.
    Dict(

    #ENVIRONMENTAL VARIABLES
    "lat" => 47.8, #Latitude of corresponding lake; [°]; 47.8 = Chiemsee
    #"doy" => , #actual day - has to be flexible
    "yearlength" => 365, #Number of days each year [n]; in general on earth
    "tempDev" => 1.0, #share of temp [-]; 1 in CHARISMA
    "tempMax" => 18.8, #max mean daily temperature of a year in [°C]; 18.8 in CHARISMA
    "tempMin" => 1.1, #min mean daily temperature of a year in [°C]; 1.1 in CHARISMA
    "tempLag" => 23, #days after 1st of January where Temp is minimal [d]; 23 in CHARISMA
    "maxI" => 2000.0, #Maximal Irradiance in [µE m^-2 s^-1]; 868 in CHARISMA
    "minI" => 300.0, #Minimal Irradiance [µE m^-2 s^-1]; 96 in CHARISMA
    "iDelay" => 0.0, #days after 1st of January where I is minimal [d]; -10 in CHARISMA

    "parFactor" => 0.5, # fraction of total irradiation that is PAR [-]; 0.5 in CHARISMA
    "fracReflected" => 0.1, # light reflection at the water surface [-]; 0.1 in CHARISMA
    "sunDev" => 0.0, #Deviation factor to change total irradiation [-]; 0.0 in CHARISMA
    "kdDev" => 1.0, #Deviation factor, a factor between 0 and 1 to change the whole light attenuation range [-]; 1.0 in CHARISMA
    "maxKd" => 2.0, #Maximum light attenuation coefficient [m^-1]; 2.0 in CHARISMA
    "minKd" => 2.0, #Minimum light attenuation coefficient [m^-1]; 2.0 in CHARISMA
    "kdDelay" => -10.0, #Delay, the day number with the minimal light attenuation coefficient [d]; -10 in CHARISMA
    "distWaterSurface" => 1,
    "plantK" => 0.02, #!!SPECIES SPECIFIC!!; [m^2/g]; 0.02 in CHARISMA for C.aspera
    "higherbiomass" => 0.0,

    "fracPeriphyton" => 0.2, # !!SPECIES SPECIFIC!!; [-]; 0.2 in CHARISMA for C.aspera

    "resp20" => 0.00193, #!!SPECspec!! []; 0.00193 in CHARISMA for C.aspera
    "q10" => 2.0, # !!SPECspec!! []; 2.0 in CHARISMA for C.aspera
    "t1" => 20.0,

    #"lightPlantHour" => , #
    "hPhotoLight" => 14.0, #!!SPECspec!!; [µE m^-2 s^-1] ; 14.0 in CHARISMA for C.aspera
    #"temp" => , #
    "sPhotoTemp" => 1.35,  # !!SPECspec!! []; 1.35 in CHARISMA for C.aspera
    "pPhotoTemp" => 3.0 , # !!SPECspec!! []; 3 in CHARISMA for C.aspera
    "hPhotoTemp" => 14.0, # !!SPECspec!! [°C]; 14.0 in CHARISMA  for C.aspera
    "hPhotoDist" => 1.0, # !!SPECspec!! [m] ; 1.0 in CHARISMA for C.aspera
    #"dist" => , #
    #"bicarbonateConc" => , #
    #"hCarbonate" => , #
    #"pCarbonate" => , #
    #"nutrientConc" => , #
    #"pNutrient" => , #
    #"hNutrient" => , #
    "pMax" => 0.006, #  # !!SPECspec!! specific daily production of the plant top at 20Â°C in the absence of light limitation; [g g^-1 h^-1]; 0.006 in CHARISMA for C.aspera


    #"weight1" => ,#
    #"dailyPS" => ,#
    #"dailyRES" => ,#
    "rootShootRatio" => 0.1, #!SPECspec! [-]; 0.1 för C.aspera in CHARISMA
    "mortalityRate" => 0.0 #


    #SPECIES SPECIFIC VARIABLES
    )
end

#a=defaultSettings()

#get(a, "lat", "NA")
#a["lat"]
