# Model description for simplified CHARISMA version

## Differences Original model of van Nes 2001

### Not (yet) multiple species
The version of the model cannot be executed for multiple species. It calculates growth of Biomass, Number of subindividuals, Individual weight and height for two superindividua from the same species, one originated from seeds, one from tubers.


### Not spatially explicit
Not spatially explicit, just calculation of single patches for multiple depths at once. Thus, no seed dispersal is included, no mixing effect for light attenuation or nutrients is included.

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

## ODD
The model description follows the ODD (Overview, Design concepts, Details) protocol (Grimm et al. 2006, 2010).

### Purpose
This model is designed to simulate the growth of submerged macrophytes under different environmental conditions. For this, the model considers ecophysiological processes of macrophytes.


### Entities, state variables, and scales
The model simulates the life cycle of submerged macrophytes in a lake. The model uses the superindividuum concept (REF). Every superindividuum is defined by a biomass, a number of represented individua, a individual weight and a height.
Plant species are defined by species specific parameters listed in xxx

Lakes are defined by lake specific parameters listed in x2.  

### Process overview and scheduling
Who (i.e., what entity) does what, and in what order? When are state variables updated? How is time modeled, as discrete steps or as a continuum over which both continuous processes and discrete events can occur? Except for very simple schedules, one should use pseudo-code to describe the schedule in every detail, so that the model can be reimplemented from this code. Ideally, the pseudo-code corresponds fully to the actual code used in the program implementing the ABM.

### Design concepts

### Initialization

### Input
The model


### Submodels


#### Virtual Ecologist Approach

### Output

The main simulation output consists of different files per species, lake and depths. The main output types are descibed in the following table. Each line in every output file represents one day, exept of the settings file. The columns are described in the table.


Type        | Name           | Description  | Columns
------------- |:-------------:| -----:|
Macrophytes| growthSeeds | Daily Growth rates for superindividuum from seeds for selected output years | PS - Resp - Growthrate
| growthTubers | Growth rates for superindividuum from tubers | PS - Resp - Growthrate
| seeds | Seedbank daily values| SeedBiomass - SeedNumber - SeedsGerminatingBiomass
| tubers | Tuberband daily values | TuberBiomass - TuberNumber - TuberGerminatingBiomass
| superInd | Daily values for superIndividuum as sum of superIndSeed and superIndTuber | Biomass - Number of subind - individual Weight - height - allocatedSeedBiomass - allocatedTubersBiomass  
| superIndSeed | Daily values for superIndividuum from seeds | Biomass - Number of subind - individual Weight - height - allocatedSeedBiomass - allocatedTubersBiomass  
| superIndTubers | Daily values for superIndividuum from tubers | Biomass - Number of subind - individual Weight - height - allocatedSeedBiomass - allocatedTubersBiomass  
Environment | Temp | Daily value | [°C]
| Waterlevel | Daily value | []
| Irradiance | Daily value | []
| Light Attenuation | Daily value | []
Settings | Settings | Storage of all used input parameters | List