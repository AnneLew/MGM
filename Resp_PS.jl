"""
CHARISMA in JULIA
Functions for Respiration and Photosynthesis
"""

function getRespiration(Temper::Float64; resp20::Float64=0.024, q10::Float64=2.0, t1::Float64=20.0)
    return resp20 * q10^((Temper - t1)/10)
end

"""
Temper = 0.1
getRespiration(Temper)
"""

#Photosynthesis (Biomass brutto growth) (g g^-1 h^-1)
#Pmax: g g^-1 h^-1 ; specific daily production of the plant top at 20Â°C in the absence of light limitation
function getPhotosynthesis(lightPlantHour, hPhotoLight,
                         temp, sPhotoTemp, pPhotoTemp, hPhotoTemp,
                         hPhotoDist, dist,
                         #bicarbonateConc, hCarbonate, pCarbonate,
                         #nutrientConc, pNutrient, hNutrient,
                         pMax)
  lightFactor = (lightPlantHour / (lightPlantHour + hPhotoLight)) #ÂµE m^-2 s^-1); The default half-saturation constants (C aspera 14 yE m-2s-1; P pectinatus 52) are based on growth experiments
  tempFactor = (sPhotoTemp * temp ^ pPhotoTemp) / (temp ^ pPhotoTemp + hPhotoTemp ^ pPhotoTemp) #Â°C
  distFactor = (hPhotoDist / (hPhotoDist + dist)) #m
  bicarbFactor = bicarbonateConc ^ pCarbonate / (bicarbonateConc ^ pCarbonate + hCarbonate ^ pCarbonate) # C.aspera hCarbonate=30 mg/l; P.pectinatus hCarbonate=60 mg/l
  #nutrientFactor <- nutrientConc ^ pNutrient / (nutrientConc ^ pNutrient + hNutrient ^ pNutrient)
  psHour = pMax * lightFactor * tempFactor * distFactor #* bicarbFactor #* nutrientFactor #(g g^-1 h^-1)
  return (psHour)
end
