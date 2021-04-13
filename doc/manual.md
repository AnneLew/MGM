# Manual for simplified CHARISMA version in julia

## Original model van Nes 2001
TODO add short description in one words

## Differences

### Not (yet) multiple species at once

### Not spatially explicit
Not spatially explicit, just calculation of single patches for multiple depths at once. Thus, no seed dispersal is included, no mixing effect for light attenuation or nutrients is included
### No carbon limitation, but nutrient (phosphor) limitation
Primary production depends on maximum production rate (Pmax), in-situ light (I), temperature (T), the distance (D) from the tissue to the top of the plant and limiting nurtient concentration (N).
Bicarbonate concentration as limiting factor is ignored as the studied lakes are all not carbon limitated.

`P = Pmax * f(I) * f(T) * f(D) * f(N)`

#### Mortality
- No grazing
- backround mortality and wave mortality lead to a loss in number of plants and biomass
- Negative growth (Respiration > Photosynthesis) leads to a loss in biomass

#### Further excluded:
- The effect of vegetation on the light attenuation



### Implementation
