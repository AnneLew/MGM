# Types for CHARISMA 3

"""
A struct that defines the environmental variables of lakes
"""

mutable struct Lake
    ##ENVIRONMENTAL VARIABLES
    #GENERAL
    LevelOfGrid::Float64 ## as array? raster? #Depth below mean water level [m]
    #CARBONATE
    #maxCarbonate
    #LIGHT
    fracReflected::Float64 # light reflection at the water surface [-]; 0.1 in CHARISMA
    iDelay::Int #days after 1st of January where I is minimal [d]; -10 in CHARISMA
    iDev::Float64 #Deviation factor to change total irradiation [-]; 0.0 in CHARISMA
    latitude::Float64 #Latitude of corresponding lake; [°]; 47.8 = Chiemsee; 47.5 = Starnberger See
    maxI::Float64 #Maximal Irradiance in [µE m^-2 s^-1]; 868 in CHARISMA
    minI::Float64 #Minimal Irradiance [µE m^-2 s^-1]; 96 in CHARISMA
    parFactor::Float64 # fraction of total irradiation that is PAR [-]; 0.5 in CHARISMA
    #NUTRIENT
    maxNutrient::Float64 #Conc of limiting nutrient in water without plants
    #TEMPERATURE
    maxTemp::Float64 #max mean daily temperature of a year in [°C]; 18.8 in CHARISMA
    minTemp::Float64 #min mean daily temperature of a year in [°C]; 1.1 in CHARISMA
    tempDelay::Int #days after 1st of January where Temp is minimal [d]; 23 in CHARISMA
    tempDev::Float64 #share of temp [-]; 1 in CHARISMA
    #VERTUCAL LIGHT ATTENUATION / TURBIDITY
    backgrKd::Float64 #Background light attenuation of water (Vertical light attenuation, turbidity)
    #clearWaterFraction
    #clearWaterPeriod
    #clearWaterTiming
    #kd => 2.0, #Mean light attenuation coefficient (Kd) (cosine) []
    kdDelay::Float64 #Delay, the day number with the minimal light attenuation coefficient [d]; -10 in CHARISMA
    kdDev ::Float64 #Deviation factor, a factor between 0 and 1 to change the whole light attenuation range [-]; 1.0 in CHARISMA
    #kdDiffusion
    #kdRange
    #KdStochastic
    maxKd::Float64 #Maximum light attenuation coefficient [m^-1]; 2.0 in CHARISMA
    minKd::Float64 #Minimum light attenuation coefficient [m^-1]; 2.0 in CHARISMA
    # WATER LEVEL
    levelCorrection::Float64 #Correction for reference level [m]
    maxW::Float64 #Maximal water level [m]
    minW::Float64 #Minimal water level [m]
    #WaterChange
    #WaterChangePeriod
    #...
    wDelay::Int #Delay of cosine of water level [m]
    #wDev
end

Chiemsee = Lake(-1.0,0.1,-10,-0.0,47.5,1000.0,150.0,0.5,0.5,18.8,0.0,23,1.0,1.0,-10.0,0.5,8.0,2.0,0.0,0.0,0.0,280)
Eibsee = Lake(-1.0,0.1,-10,-0.0,46.5,1000.0,150.0,0.5,0.5,15.8,0.0,23,1.0,1.0,-10.0,0.5,8.0,2.0,0.0,0.0,0.0,280)

mutable struct Species
    #BIOMASS PARTIONING
    seedsEndAge::Int #
    seedsStartAge::Int #
    #TuberEndAge::Int #
    #TuberEndAge::Int #

    #CARBONATE
    #hCarbonate::Int #
    #hCarboReduction::Int #
    #pCarbonate::Int #

    #GROWTH
    cTuber::Float64 #
    pMax::Float64#  # specific daily production of the plant top at 20Â°C in the absence of light limitation; [g g^-1 h^-1]; 0.006 in CHARISMA for C.aspera
    q10::Float64 # []; 2.0 in CHARISMA for C.aspera
    resp20::Float64 #[]; 0.00193 in CHARISMA for C.aspera

    #GROWTH FORM
    heightMax::Float64  #0.35 in CHARISMA for C.aspera
    maxWeightLenRatio::Float64# 0.03 in CHARISMA for C.aspera
    rootShootRatio::Float64 #[-]; 0.1 för C.aspera in CHARISMA
    spreadFrac::Float64 #[-]; 0.5 för P.pectinatus in CHARISMA

    #LIGHT
    fracPeriphyton::Float64 # [-]; 0.2 in CHARISMA for C.aspera
    hPhotoDist::Float64 # [m] ; 1.0 in CHARISMA for C.aspera
    hPhotoLight::Float64 #[µE m^-2 s^-1] ; 14.0 in CHARISMA for C.aspera
    hPhotoTemp::Float64 # [°C]; 14.0 in CHARISMA  for C.aspera
    hTurbReduction::Float64 #40.0 in CHARISMA  for C.aspera
    plantK::Float64 #[m^2/g]; 0.02 in CHARISMA for C.aspera
    pPhotoTemp::Float64 # []; 3 in CHARISMA for C.aspera
    pTurbReduction::Float64 #1.0 in CHARISMA  for C.aspera
    sPhotoTemp::Float64  # 1.35 in CHARISMA for C.aspera

    #MORTALITY
    BackgroundMort::Float64 #
    #CThin
    #HWaveMort
    maxAge::Int # 175 in CHARISMA for C.aspera
    #maxDryDays
    #maxWaveMort
    #pWaveMort
    #ThinAdjWeight
    thinning::Bool #MODELLPARAMETER??

    #NUTRIENT
    #hNutrient => , #
    hNutrReduction::Float64
    #pNutrient => , #

    #REPRODUCTION
    germinationDay::Int  # Spec Spec growth start day; 114 in CHARISMA for C.aspera
    reproDay::Int #250 in CHARISMA for C.aspera
    seedBiomass::Float64 # 0.00002 in CHARISMA for C.aspera
    seedFraction::Float64
    seedGermination::Float64
    #SeedGrazingThres
    #SeedImport
    seedInitialBiomass::Float64 # 2 in CHARISMA for C.aspera
    SeedMortality::Float64 # daily mortality of seeds; Spec Spec; 0.0018972 in CHARISMA for C.aspera
    #SeedRadius
    #TuberBiomass => 0.00002 # 0.00002 in CHARISMA for C.aspera
    #TuberFraction
    #TuberGermination
    #TuberGerminationDay
    #TuberGrazingThres
    #TuberImport
    #TuberInitialBiomass => 2.0 # 0.00002 in CHARISMA for C.aspera
    #TuberMortality
end

CharaAspera = Species(60,30,0.1,1.7,2.0,0.00193,0.35,0.001,0.1,0.7,0.2,1.0,14.0,14.0,40.0,0.02,3.0,1.0,1.35,0.0,175,false,200.0,114,250,0.00002,0.13,0.2,2.0,0.0)

CharaAspera.seedsEndAge


lakeslist = [Chiemsee, Eibsee]

bla = zeros(Float64,1)
for l in lakeslist
    push!(bla, l.latitude)
end

bla
