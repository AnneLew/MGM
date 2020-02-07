"""
Default settings

Defines the list of configuration variables and returns their default values
in a Dict.
"""

function defaultSettings()
    # Return the default settings. All parameters must be registered here.
    Dict(
    ##ENVIRONMENTAL VARIABLES
    #GENERAL
    "years" => 15,
    "yearlength" => 365, #Number of days each year [n]; in general on earth
    "LevelOfGrid" => -1.0,
    #CARBONATE
    #"maxCarbonate"
    #LIGHT
    "fracReflected" => 0.1, # light reflection at the water surface [-]; 0.1 in CHARISMA
    "iDelay" => -10, #days after 1st of January where I is minimal [d]; -10 in CHARISMA
    "iDev" => 0.0, #Deviation factor to change total irradiation [-]; 0.0 in CHARISMA
    "latitude" => 47.5, #Latitude of corresponding lake; [°]; 47.8 = Chiemsee; 47.5 = Starnberger See
    "maxI" => 1000.0, #Maximal Irradiance in [µE m^-2 s^-1]; 868 in CHARISMA
    "minI" => 150.0, #Minimal Irradiance [µE m^-2 s^-1]; 96 in CHARISMA
    "parFactor" => 0.5, # fraction of total irradiation that is PAR [-]; 0.5 in CHARISMA
    #NUTRIENT
    "maxNutrient" => 0.5, #Conc of limiting nutrient in water without plants
    #TEMPERATURE
    "maxTemp" => 18.8, #max mean daily temperature of a year in [°C]; 18.8 in CHARISMA
    "minTemp" => 0.0, #min mean daily temperature of a year in [°C]; 1.1 in CHARISMA
    "tempDelay" => 23, #days after 1st of January where Temp is minimal [d]; 23 in CHARISMA
    "tempDev" => 1.0, #share of temp [-]; 1 in CHARISMA
    #VERTUCAL LIGHT ATTENUATION / TURBIDITY
    "backgrKd" => 1.0,
    #"clearWaterFraction"
    #"clearWaterPeriod"
    #"clearWaterTiming"
    #"kd"
    "kdDelay" => -10.0, #Delay, the day number with the minimal light attenuation coefficient [d]; -10 in CHARISMA
    "kdDev" => 1.0, #Deviation factor, a factor between 0 and 1 to change the whole light attenuation range [-]; 1.0 in CHARISMA
    #"kdDiffusion"
    #kdRange
    "maxKd" => 1.0, #Maximum light attenuation coefficient [m^-1]; 2.0 in CHARISMA
    "minKd" => 1.0, #Minimum light attenuation coefficient [m^-1]; 2.0 in CHARISMA
    # WATER LEVEL
    "levelCorrection" => 0.0,
    "maxW" => 0.0,
    "minW" => -0.0,
    "wDelay" => 0,
    #"wDev"

    ###########################################################
    ###########################################################
    ##SPECIES SPECIFIC VARIABLES #Exemplarisch für Chara aspera
    #BIOMASS PARTIONING
    "seedsEndAge" => 60, #
    "seedsStartAge" => 30, #
    #"TuberEndAge" => 60, #
    #"TuberEndAge" => 30, #

    #CARBONATE
    #"hCarbonate" => 30, #
    #"hCarboReduction" => 30, #
    #"pCarbonate" => 1, #

    #GROWTH
    "cTuber" => 0.1, #
    "pMax" => 0.125, #  # !!SPECspec!! specific daily production of the plant top at 20Â°C in the absence of light limitation; [g g^-1 h^-1]; 0.006 in CHARISMA for C.aspera
    "q10" => 2.0, # !!SPECspec!! []; 2.0 in CHARISMA for C.aspera
    "resp20" => 0.00193, #!!SPECspec!! []; 0.00193 in CHARISMA for C.aspera

    #GROWTH FORM
    "heightMax" => 0.35,  # Spec Spec; 0.35 in CHARISMA for C.aspera
    "maxWeightLenRatio" => 0.001,# Spec Spec; 0.03 in CHARISMA for C.aspera
    "rootShootRatio" => 0.1, #!SPECspec! [-]; 0.1 för C.aspera in CHARISMA
    "spreadFrac" => 0.7, #!SPECspec! [-]; 0.5 för P.pectinatus in CHARISMA

    #LIGHT
    "fracPeriphyton" => 0.2, # !!SPECIES SPECIFIC!!; [-]; 0.2 in CHARISMA for C.aspera
    "hPhotoDist" => 1.0, # !!SPECspec!! [m] ; 1.0 in CHARISMA for C.aspera
    "hPhotoLight" => 14.0, #!!SPECspec!!; [µE m^-2 s^-1] ; 14.0 in CHARISMA for C.aspera
    "hPhotoTemp" => 14.0, # !!SPECspec!! [°C]; 14.0 in CHARISMA  for C.aspera
    "hTurbReduction" => 40.0, #40.0 in CHARISMA  for C.aspera
    "plantK" => 0.02, #!!SPECIES SPECIFIC!!; [m^2/g]; 0.02 in CHARISMA for C.aspera
    "pPhotoTemp" => 3.0 , # !!SPECspec!! []; 3 in CHARISMA for C.aspera
    "pTurbReduction" => 1.0, #1.0 in CHARISMA  for C.aspera
    "sPhotoTemp" => 1.35,  # !!SPECspec!! []; 1.35 in CHARISMA for C.aspera

    #MORTALITY
    "BackgroundMort" => 0.0, #
    #"CThin"
    #"HWaveMort"
    "maxAge" => 175, # Spec Spec; 175 in CHARISMA for C.aspera
    #"maxDryDays"
    #"maxWaveMort"
    #"pWaveMort"
    #"ThinAdjWeight"
    "thinning" => "FALSE",

    #NUTRIENT
    #"hNutrient" => , #
    "hNutrReduction" => 200.0,
    #"pNutrient" => , #

    #REPRODUCTION
    "germinationDay" => 114,  # Spec Spec growth start day; 114 in CHARISMA for C.aspera
    "reproDay" => 250, #250 in CHARISMA for C.aspera
    "seedBiomass" => 0.00002, # Spec Spec; 0.00002 in CHARISMA for C.aspera
    "seedFraction" => 0.13,
    "seedGermination" => 0.2,
    #"SeedGrazingThres"
    #"SeedImport"
    "seedInitialBiomass" => 2.0, # Spec Spec; 2 in CHARISMA for C.aspera
    "SeedMortality" => 0.0, # daily mortality of seeds; Spec Spec; 0.0018972 in CHARISMA for C.aspera
    #"SeedRadius"
    #"TuberBiomass" => 0.00002 # Spec Spec; 0.00002 in CHARISMA for C.aspera
    #"TuberFraction"
    #"TuberGermination"
    #"TuberGerminationDay"
    #"TuberGrazingThres"
    #"TuberImport"
    #"TuberInitialBiomass" => 2.0 # Spec Spec; 0.00002 in CHARISMA for C.aspera
    #"TuberMortality"

    #TECHNICAL
    #"DiscrBord"
    #"FixInitWeight"
    #"initBiomass" => 0.3, # Spec Spec; 0.3 in CHARISMA for C.aspera
    #"KillNumber"
    #"SplitNumber"
    )
end

#a=defaultSettings()

#get(a, "lat", "NA")
#a["lat"]
