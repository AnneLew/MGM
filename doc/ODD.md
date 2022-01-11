---
editor_options: 
  markdown: 
    wrap: 72
---

# Model description (ODD)

The model is a simplified version of a model from van Nes et al (2003)
called Charisma which bases on the model Megaplant (see Fig 1). A manual
for the Charisma model version can be found here:
<https://www.projectenaew.wur.nl/charisma/> In the following section a
short model description is given. The model description follows the ODD
(Overview, Design concepts, Details) protocol (Grimm et al. 2006, 2010).
Furthermore, in an additional section the differences between this model
version on van Nes et al (2003) are explained.

## 1. Purpose

This model is designed to simulate the growth of submerged macrophytes
under different environmental conditions in multiple depth. For this,
the model considers eco-physiological processes of macrophytes.

## 2. Entities, state variables, and scales

### Agents:

The model simulates the life cycle of submerged macrophytes in a lake.
One time step represents one day. The model uses the superindividuum
concept (REF). Every superindividuum is defined by a biomass, a number
of represented individua, a individual weight and a height. Each species
is defined by set of species specific parameters listed in Table x1
(TODO).

### Spatial units:

The model is not spatially explicit. Different depths are modeled
simultaneously without interaction.

### Environment:

Lakes are defined by lake specific parameters listed in Table x2 (TODO).
Those define the annual course of

-   water temperature (*minTemp*, *maxTemp* and *tempDelay*)

-   water level (*minW*, *maxW*, *wDelay* and *levelCorrection*)

-   water turbidity (*minKd*, *maxKd*, *kdDelay* and *backgrKd*)

-   growth limiting nutrient content (*maxNutrient*)

-   irradiance at the water surface (*maxI* and *minI*)

-   Further lake specific parameters are used to calculate the hourly
    photosynthetic active light reaching the macrophyte dependent on
    depth (*fracReflected*, *latitude* and *parFactor*).

## 3. Process overview and scheduling

In each daily time step each superindividuum will - dependent on the
date or the age of the plant - undergo the following processes: -
Germination (if day=*germinationDay*) - Growth (dependent on
Photosynthesis and Respiration) - Mortality (from thinning, negative
growth, wave mortality or background mortality) - Allocation of biomass
for seed / tuber production (*seedsStartAge* \< *PlantAge* \<
*seedsEndAge*) - Seed release (if d=*reproDay*) - Seasonal die-off (if
age=*maxAge*)

## 4. Design concepts

Deterministic model

## 5. Initialization

Each species is initialized with a distinct seed biomass (seedBiomass).

## 6. Input data

To specify the, input files for general settings, lake parameters and
species parameters can be used. If not given, the default settings from
*defaults.jl* are set.

### General settings

General settings can be set in a file named *general.config.txt*. The
following parameters can be set here: - years: Number of years to get
simulated - depths: Depths below mean water level to get simulated for.
Multiple depth can be given here. - yearsoutput: Number of last
simulated years that get saved in the output files. - species: relative
paths to the species config files\
- lakes: relative paths to the lakes config files - modelrun: folder
name of modelrun in output folder

### Species settings

TODO: Add table of Model parameters with variable names as used in the
source code.

### Lake settings

TODO: Add table of Model parameters with variable names as used in the
source code.

## 7. Submodels

## Output

The main simulation output consists of different files per species, lake
and depths. The main output types are descibed in the following table.
Each line in every output file represents one day, exept of the settings
file. The columns are described in the table.

+--------------------------+------------------------------+-----------+
| Type                     | Name                         | De        |
|                          |                              | scription |
+==========================+:============================:+==========:+
| Macrophytes              | growthSeeds                  | Daily     |
|                          |                              | Growth    |
|                          |                              | rates for |
|                          |                              | superi    |
|                          |                              | ndividuum |
|                          |                              | from      |
|                          |                              | seeds for |
|                          |                              | selected  |
|                          |                              | output    |
|                          |                              | years     |
+--------------------------+------------------------------+-----------+
| growthTubers             | Growth rates for             | PS - Resp |
|                          | superindividuum from tubers  | -         |
|                          |                              | G         |
|                          |                              | rowthrate |
+--------------------------+------------------------------+-----------+
| seeds                    | Seedbank daily values        | Se        |
|                          |                              | edBiomass |
|                          |                              | -         |
|                          |                              | S         |
|                          |                              | eedNumber |
|                          |                              | -         |
|                          |                              | Seeds     |
|                          |                              | Germinati |
|                          |                              | ngBiomass |
+--------------------------+------------------------------+-----------+
| tubers                   | Tuberband daily values       | Tub       |
|                          |                              | erBiomass |
|                          |                              | -         |
|                          |                              | Tu        |
|                          |                              | berNumber |
|                          |                              | -         |
|                          |                              | Tuber     |
|                          |                              | Germinati |
|                          |                              | ngBiomass |
+--------------------------+------------------------------+-----------+
| superInd                 | Daily values for             | Biomass - |
|                          | superIndividuum as sum of    | Number of |
|                          | superIndSeed and             | subind -  |
|                          | superIndTuber                | i         |
|                          |                              | ndividual |
|                          |                              | Weight -  |
|                          |                              | height -  |
|                          |                              | al        |
|                          |                              | locatedSe |
|                          |                              | edBiomass |
|                          |                              | -         |
|                          |                              | allo      |
|                          |                              | catedTube |
|                          |                              | rsBiomass |
+--------------------------+------------------------------+-----------+
| superIndSeed             | Daily values for             | Biomass - |
|                          | superIndividuum from seeds   | Number of |
|                          |                              | subind -  |
|                          |                              | i         |
|                          |                              | ndividual |
|                          |                              | Weight -  |
|                          |                              | height -  |
|                          |                              | al        |
|                          |                              | locatedSe |
|                          |                              | edBiomass |
|                          |                              | -         |
|                          |                              | allo      |
|                          |                              | catedTube |
|                          |                              | rsBiomass |
+--------------------------+------------------------------+-----------+
| superIndTubers           | Daily values for             | Biomass - |
|                          | superIndividuum from tubers  | Number of |
|                          |                              | subind -  |
|                          |                              | i         |
|                          |                              | ndividual |
|                          |                              | Weight -  |
|                          |                              | height -  |
|                          |                              | al        |
|                          |                              | locatedSe |
|                          |                              | edBiomass |
|                          |                              | -         |
|                          |                              | allo      |
|                          |                              | catedTube |
|                          |                              | rsBiomass |
+--------------------------+------------------------------+-----------+
| Environment              | Temp                         | Daily     |
|                          |                              | value     |
+--------------------------+------------------------------+-----------+
| Waterlevel               | Daily value                  | []        |
+--------------------------+------------------------------+-----------+
| Irradiance               | Daily value                  | []        |
+--------------------------+------------------------------+-----------+
| Light Attenuation        | Daily value                  | []        |
+--------------------------+------------------------------+-----------+
| Settings                 | Settings                     | Storage   |
|                          |                              | of all    |
|                          |                              | used      |
|                          |                              | input     |
|                          |                              | p         |
|                          |                              | arameters |
+--------------------------+------------------------------+-----------+

# Differences to original model of van Nes 2001

## Not (yet) multiple species

The version of the model cannot be executed for multiple species. It
calculates growth of Biomass, Number of subindividuals, Individual
weight and height for two superindividua from the same species, one
originated from seeds, one from tubers.

## Not spatially explicit

Not spatially explicit, just calculation of single patches for multiple
depths at once. Thus, no seed dispersal is included, no mixing effect
for light attenuation or nutrients is included.

## No carbon limitation, but nutrient (phosphor) limitation

Primary production depends on maximum production rate (Pmax), in-situ
light (I), temperature (T), the distance (D) from the tissue to the top
of the plant and limiting nurtient concentration (N). Bicarbonate
concentration as limiting factor is ignored as the studied lakes are all
not carbon limitated.

`P = Pmax * f(I) * f(T) * f(D) * f(N)`

### Mortality

-   No grazing
-   backround mortality and wave mortality lead to a loss in number of
    plants and biomass
-   Negative growth (Respiration \> Photosynthesis) leads to a loss in
    biomass

### Further excluded:

-   The effect of vegetation on the light attenuation

## References

van Nes, E.H.; Scheffer, M.; van den Berg, M.S.; Coops, H. (2003)
"Charisma: a spatial explicit simulation model of submerged macrophytes"
Ecological Modelling 159, 103-116

Grimm et al 2006, 2010
