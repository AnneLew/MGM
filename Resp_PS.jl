"""
CHARISMA in JULIA
Functions for Respiration and Photosynthesis
"""

function Respiration(Temper::Array{Float64,1}; Resp20::Float64=0.024, Q10::Float64=2.0, T1::Float64=20.0)
    return Resp20 * Q10^((Temper - T1)/10)
end

#Tempe = Float64[0.1,0.5,0.3]

#Respiration(Temper=Tempe)


#Photosynthesis (Biomass brutto growth) (g g^-1 h^-1)
#Pmax: g g^-1 h^-1 ; specific daily production of the plant top at 20Â°C in the absence of light limitation
function Photosynthesis(light_plant_hour, hPhotoLight,
                         Temp, sPhotoTemp, pPhotoTemp, hPhotoTemp,
                         hPhotoDist, dist,
                         bicarbonate_conc, hCarbonate, pCarbonate,
                         #Nutrient_conc, pNutrient, hNutrient,
                         Pmax)
  Light_factor = (light_plant_hour / (light_plant_hour + hPhotoLight)) #ÂµE m^-2 s^-1); The default half-saturation constants (C aspera 14 yE m-2s-1; P pectinatus 52) are based on growth experiments
  Temp_factor = (sPhotoTemp * Temp ^ pPhotoTemp) / (Temp ^ pPhotoTemp + hPhotoTemp ^ pPhotoTemp) #Â°C
  Dist_factor = (hPhotoDist / (hPhotoDist + dist)) #m
  Bicarb_factor = bicarbonate_conc ^ pCarbonate / (bicarbonate_conc ^ pCarbonate + hCarbonate ^ pCarbonate) # C.aspera hCarbonate=30 mg/l; P.pectinatus hCarbonate=60 mg/l
  #Nutrient_factor <- Nutrient_conc ^ pNutrient / (Nutrient_conc ^ pNutrient + hNutrient ^ pNutrient)
  PS_hour = Pmax * Light_factor * Temp_factor * Dist_factor * Bicarb_factor #* Nutrient_factor #(g g^-1 h^-1)
  return (PS_hour)
end
