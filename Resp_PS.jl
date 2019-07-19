"""
CHARISMA in JULIA
Functions for Respiration and Photosynthesis
"""

function getRespiration(Temper; resp20::Float64=0.024, q10::Float64=2.0, t1::Float64=20.0)
    return resp20 * q10^((Temper - t1)/10)
end

"""
Temper = Float64[0.1,8.0,3.5]
getRespiration.(Temper)

"""

#Photosynthesis (Biomass brutto growth) (g g^-1 h^-1)
function getPhotosynthesis(temp, lightPlantHour, dist; hPhotoLight::Float64=14.0,
                         sPhotoTemp::Float64=1.35, pPhotoTemp::Float64=14.0, hPhotoTemp::Float64=14.0,
                         hPhotoDist::Float64=1.0,
                         #bicarbonateConc, hCarbonate, pCarbonate,
                         #nutrientConc, pNutrient, hNutrient,
                         pMax::Float64=0.006)
  lightFactor = lightPlantHour / (lightPlantHour + hPhotoLight) #ÂµE m^-2 s^-1); The default half-saturation constants (C aspera 14 yE m-2s-1; P pectinatus 52) are based on growth experiments
  tempFactor = (sPhotoTemp * temp ^ pPhotoTemp) / (temp ^ pPhotoTemp + hPhotoTemp ^ pPhotoTemp) #Â°C
  distFactor = hPhotoDist / (hPhotoDist + dist) #m
  #bicarbFactor = bicarbonateConc ^ pCarbonate / (bicarbonateConc ^ pCarbonate + hCarbonate ^ pCarbonate) # C.aspera hCarbonate=30 mg/l; P.pectinatus hCarbonate=60 mg/l
  #nutrientFactor <- nutrientConc ^ pNutrient / (nutrientConc ^ pNutrient + hNutrient ^ pNutrient)
  psHour = pMax * lightFactor * tempFactor * distFactor #* bicarbFactor #* nutrientFactor #(g g^-1 h^-1)
  return (psHour)
end

"""
#Testing
getPhotosynthesis(13.0, 8.0, 1.0)
"""

###Growth
function growWeight(weight1, dailyPS, dailyRES; rootShootRatio::Float64=0.1, mortalityRate::Float64=0.0)
  weight = (1-rootShootRatio)*weight1*dailyPS - weight1*(dailyRES + mortalityRate)
  return (weight)
end

"""
#Testing
growWeight(10,14.0,7.9)
"""

function growHeight(height1::Float64, weight2::Float64, weight1::Float64)
  height = height1*(weight2 / weight1)#*MaxWeightLenRatio
  return height
end

"""
#Testing
growHeight(10.0,7.0,6.0)
"""
