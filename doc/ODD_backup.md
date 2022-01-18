ODD
================

# Model description MGM (ODD)

*Anne Lewerentz*

The model MGM (<u>M</u>acrophytes <u>G</u>rowth <u>M</u>odel) is a
simplified version of a model Charisma, developed by van Nes et al
(2003), which combines the previous models MEGAPLANT (Scheffer et al
1993) and ArtiVeg (VanNes & Scheffer 1996) (see Fig 1). A explicit
manual of Charisma 2.0 can be found here:
<https://www.projectenaew.wur.nl/charisma/>

In the following sections a short model description of the reimplemented
version is given. The model description follows the ODD (Overview,
Design concepts, Details) protocol (Grimm et al. 2006, 2010, 2020).
Furthermore, in an additional section the differences between MGM and
Charisma 2.0 are explained.

## 1. Purpose

This model is designed to simulate the growth of submerged macrophytes
under different environmental conditions in multiple depth. For this,
the model considers eco-physiological processes of macrophytes.

## 2. Entities, state variables, and scales

### Agents:

The model simulates the life cycle of submerged macrophytes in a lake.
One time step represents one day. The model uses the super-individual
concept (see section 4.). Every super-individual is defined by its

1.  biomass (*biomass*),

2.  number of represented individua (*N*),

3.  individual weight (*indWeight*),

4.  height (*height*) and

5.  allocated biomass for seed or tuber production (*allocBiomassSeed* /
    *allocBiomassTuber*).

Before growing, the super-individual starts as corresponding **seeds
and/or tubers \[EXPLAIN how it is understood\],** defined by its

1.  biomass (*biomass*),

2.  number of seeds/tubers (*N*) and

3.  allocated Biomass that will germinate in the respective year
    (*SeedGermBiomass*).

Each species is defined by set of species specific parameters listed in
Table x1 (TODO).

\[TODO: if growth from tubers and seeds - two super-individuals with
competition; not applied in my research\]

### Spatial units:

The model is not spatially explicit. Different depths are modeled
simultaneously without interaction.

### Environment:

Lakes are defined by lake specific parameters listed in Table x2 (TODO).
Those define the annual course of

-   water temperature (*minTemp*, *maxTemp* and *tempDelay*),

-   water level (*minW*, *maxW*, *wDelay* and *levelCorrection*),

-   water turbidity (*minKd*, *maxKd*, *kdDelay* and *backgrKd*),

-   growth limiting nutrient content (*maxNutrient*) and

-   irradiance at the water surface (*maxI* and *minI*).

Further lake specific parameters are used to calculate the hourly
photosynthetic active light reaching the macrophyte dependent on depth
(*fracReflected*, *latitude* and *parFactor*).

## 3. Process overview and scheduling

In each daily time step each superindividuum will - dependent on the day
and/or the age of the plant - undergo the following processes: (TODO add
figure showing that)

1.  Germination

    -   if day = *germinationDay*

    -   seedBiomass is transfered in macrophyteBiomass dependent on
        *seedGermination* and *cTuber*

2.  Growth

    -   if *germinationDay* =&lt; day &lt;= *germinationDay + maxAge*

    -   dependent on Photosynthesis and Respiration rate

3.  Mortality

    -   if *germinationDay* =&lt; day &lt;= *germinationDay + maxAge*

    -   from thinning, negative growth (TODO check), wave mortality or
        background mortality

4.  Allocation of biomass for seed / tuber production

    -   *seedsStartAge* &lt; *PlantAge* &lt; *seedsEndAge*

    -   daily, a part of the macrophyteBiomass is allocated untill
        *seedFraction* / *tuberFraction* is reached

    -   allocated means, that biomass is not doing photosynthesis any
        more

5.  Seed release

    -   if day = *reproDay*

    -   the allocated biomass for seed / tuber production is transfered
        into seedBiomass / tuberBiomass

6.  Seasonal die-off

    -   if age = *maxAge*

    -   all macrophyteBiomass is killed

## 4. Design concepts

The model is designed as **deterministic** model, no probabilities and
stochastic processes are included. Thus, all results are completely
reproducible.

The model uses the **super-individual approach** (Scheffer et al. 1995).
Each super-individual represents an amount of individuals which all have
the same growth rates, individual weight and height. The advantage is to
reduce computational time. As MGM is not spatially explicit, one
super-individual is used per simulation run. If multiple depth are
simulated, each depth is represented by one super-individual. \[If
growth from seeds and tubers is used, the model uses two
super-individuals, one from growth of seeds, and another one from
tubers. \]

## 5. Initialization

Each species is initialized with a distinct seed and/or tuber biomass
(*seedInitialBiomass* / *tuberInitialBiomass*). \[What else?\]

## 6. Input data

To specify the input, input files to define the

-   general settings,

-   lake parameters and

-   species parameters

can be used. Their possible options are explained in the following three
subsections. They have to be placed in the folder “input”. If not given,
the default settings from *defaults.jl* are set.

### General settings

General settings can be set in a file named *general.config.txt*. The
following parameters can be set here:

-   years: Number of years to get simulated.

-   depths: Depths below mean water level to get simulated for. Multiple
    depth can be given here.

-   yearsoutput: Number of last simulated years that get saved in the
    output files.

-   species: relative paths to the species config files.

-   lakes: relative paths to the lakes config files.

-   modelrun: folder name of modelrun in output folder

### Species settings

TODO: Add table of Model parameters with variable names as used in the
source code.

Cite again van Nes?

| Parameter      | Unit           | Description                                                     | App lied in MGM |
|----------------|----------------|-----------------------------------------------------------------|-----------------|
| seed sStartAge | days           | Age of the plants where seed formation starts                   |                 |
| se edsEndAge   | days           | Age of the plants where SeedFraction is reached                 |                 |
| tube rStartAge | days           | Age of the plants where tuber formation starts                  | x               |
| tu berEndAge   | days           | Age of the plants where TuberFraction is reached                | x               |
| cTuber         | fra ction      | Fraction of tuber weight lost daily when sprouts starts growing |                 |
| pMax           | h<sup>-1</sup> | Maximal gross photosynthesis                                    |                 |
| q10            | \-             | Q10 for maintenance respiration                                 |                 |
| resp20         | da             | Respiration at 20                                               |                 |

### Lake settings

TODO: Add table of Model parameters with variable names as used in the
source code.

#### 7. Submodels

Output

The main simulation output consists of different files per species, lake
and depths. The main output types are descibed in the following table.
Each line in every output file represents one day, exept of the settings
file. The columns are described in the table.

+————-+———————-+—————————+ \| Type \| Name \| Description \|
+=============+:====================:+==========================:+ \|
Macrophytes \| growthSeeds \| Daily Growth rates for \| \| \| \|
superindividuum from \| \| \| \| seeds for selected output \| \| \| \|
years \| +————-+———————-+—————————+ \| g \| Growth rates for \| PS -
Resp \| \| rowthTubers \| superindividuum from \| \| \| \| tubers \| G
rowthrate \| +————-+———————-+—————————+ \| seeds \| Seedbank daily \| Se
edBiomass - S \| \| \| values \| eedNumber - Seeds \| \| \| \| Germinati
ngBiomass \| +————-+———————-+—————————+ \| tubers \| Tuberband daily \|
Tub erBiomass - Tu \| \| \| values \| berNumber - Tuber \| \| \| \|
Germinati ngBiomass \| +————-+———————-+—————————+ \| superInd \| Daily
values for \| Biomass - Number of \| \| \| superIndividuum as \| subind
- i ndividual \| \| \| sum of superIndSeed \| Weight - height - al \| \|
\| and superIndTuber \| locatedSe edBiomass - \| \| \| \| allo catedTube
rsBiomass \| +————-+———————-+—————————+ \| s \| Daily values for \|
Biomass - Number of \| \| uperIndSeed \| superIndividuum from \| subind
- i ndividual \| \| \| seeds \| Weight - height - al \| \| \| \|
locatedSe edBiomass - \| \| \| \| allo catedTube rsBiomass \|
+————-+———————-+—————————+ \| sup \| Daily values for \| Biomass -
Number of \| \| erIndTubers \| superIndividuum from \| subind - i
ndividual \| \| \| tubers \| Weight - height - al \| \| \| \| locatedSe
edBiomass - \| \| \| \| allo catedTube rsBiomass \|
+————-+———————-+—————————+ \| Environment \| Temp \| Daily value \|
+————-+———————-+—————————+ \| Waterlevel \| Daily value \| \[\] \|
+————-+———————-+—————————+ \| Irradiance \| Daily value \| \[\] \|
+————-+———————-+—————————+ \| Light \| Daily value \| \[\] \| \|
Attenuation \| \| \| +————-+———————-+—————————+ \| Settings \| Settings
\| Storage of all used input \| \| \| \| p arameters \|
+————-+———————-+—————————+ Differences to original model of van Nes 2001
Not (yet) multiple species

The version of the model cannot be executed for multiple species. It
calculates growth of Biomass, Number of subindividuals, Individual
weight and height for two superindividua from the same species, one
originated from seeds, one from tubers. Not spatially explicit

Not spatially explicit, just calculation of single patches for multiple
depths at once. Thus, no seed dispersal is included, no mixing effect
for light attenuation or nutrients is included. No carbon limitation,
but nutrient (phosphor) limitation

Primary production depends on maximum production rate (Pmax), in-situ
light (I), temperature (T), the distance (D) from the tissue to the top
of the plant and limiting nurtient concentration (N). Bicarbonate
concentration as limiting factor is ignored as the studied lakes are all
not carbon limitated.

P = Pmax \* f(I) \* f(T) \* f(D) \* f(N) Mortality

    No grazing
    backround mortality and wave mortality lead to a loss in number of plants and biomass
    Negative growth (Respiration > Photosynthesis) leads to a loss in biomass

Further excluded:

    The effect of vegetation on the light attenuation

References

van Nes, E.H.; Scheffer, M.; van den Berg, M.S.; Coops, H. (2003)
“Charisma: a spatial explicit simulation model of submerged macrophytes”
Ecological Modelling 159, 103-116

Grimm et al 2006, 2010
