# Model description for simplified CHARISMA version

The model is a simplified version of a model from van Nes et al (2003) called Charisma which bases on the
model Megaplant (see Fig 1). A manual for the Charisma model version can be found here: https://www.projectenaew.wur.nl/charisma/
In the following section a short ODD protocol is given. Furthermore, in a extra section the differences between this model version on van Nes et al (2003) are explained.

## ODD
The model description follows the ODD (Overview, Design concepts, Details) protocol (Grimm et al. 2006, 2010).

### Purpose
This model is designed to simulate the growth of submerged macrophytes under different environmental conditions. For this, the model considers ecophysiological processes of macrophytes.


### Entities, state variables, and scales
The model simulates the life cycle of submerged macrophytes in a lake. The model uses the superindividuum concept (REF). Every superindividuum is defined by a biomass, a number of represented individua, a individual weight and a height.
Plant species are defined by species specific parameters listed in Table x1.

Lakes are defined by lake specific parameters listed in Table x2.  

### Process overview and scheduling
In each daily timestep each superindividuum will dependent on the date or the age of the plant undergo the following processes:
- Germination (if day=germinationDay)
- Growth (dependent on Photosynthesis and Respiration)
- Mortality (from thinning, negative growth, wave mortality or background mortality)
- Allocation of biomass for seed / tuber production (seedsStartAge < PlantAge < seedsEndAge)
- Seed release (if d=reproDay)
- Seasonal die-off (if age=maxAge)



### Design concepts
Deterministic model

### Initialization

### Input
To specify the, input files for general settings, lake parameters and species parameters can be used. If not given, the default settings from *defaults.jl* are set.

#### General settings
General settings can be set in a file named *general.config.txt*. The following parameters can be set here:
- years: Number of years to get simulated
- depths: Depths below mean water level to get simulated for. Multiple depth can be given here.
- yearsoutput: Number of last simulated years that get saved in the output files.
- species: relative paths to the species config files  
- lakes: relative paths to the lakes config files
- modelrun: folder name of modelrun in output folder

#### Species settings
ToDo: Add table of Model parameters with variable names as used in the source code.
#### Lake settings
ToDo: Add table of Model parameters with variable names as used in the source code.


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


## Differences to original model of van Nes 2001

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


## References
van Nes, E.H.; Scheffer, M.; van den Berg, M.S.; Coops, H. (2003) "Charisma: a spatial explicit simulation model of submerged macrophytes" Ecological Modelling 159, 103-116
