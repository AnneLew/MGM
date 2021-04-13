# Manual for simplified CHARISMA version in julia

## Original model van Nes 2001


## Differences

### Not spatially explicit
Not spatially explicit, just calculation of single patches for multiple depths at once. Thus, no seed dispersal is included
### Primary production
Primary production depends on maximum production rate (Pmax), in-situ light (I), temperature (T), the distance (D) from the tissue to the top of the plant and limiting nurtient concentration (N).
Bicarbonate concentration as limiting factor is ignored as the studied lakes are all not carbon limitated.

`P = Pmax * f(I) * f(T) * f(D) * f(N)`
####



### Implementation
