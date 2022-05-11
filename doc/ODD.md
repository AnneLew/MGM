Macrophyte Growth Model - ODD document
================
Anne Lewerentz
2022-05-11

The Macrophytes Growth Model (MGM) is a process-based, eco-physiological
model that is able to simulate the growth of submerged macrophytes under
different environmental conditions.

MGM is a simplified re-implementation of the model Charisma 2.0 (van Nes
et al. 2003) in the programming language *julia* (Bezanson et al. 2017).
Charisma 2.0 based on the previous model MEGAPLANT (Marten Scheffer,
Bakema, and Wortelboer 1993) (Figure 1 a). A explicit manual of Charisma
2.0 can be found on the [project
website](https://www.projectenaew.wur.nl/charisma/).

In the following sections a model description of the MGM is presented.
The model description based on the ODD (Overview, Design concepts,
Details) protocol (Grimm et al. 2006, 2010) since the original model
already has a documentation. Furthermore, the differences between MGM
and Charisma 2.0 are explained in an additional section.

## 1. Purpose

MGM is designed to simulate the growth of submerged macrophytes under
different environmental conditions in multiple depth. The model
considers eco-physiological processes of macrophytes mainly depend on
the availability of the resources light, nutrients and water temperature
(Figure 1 b).

<figure>
<img src="ODD_Figures/fig1.PNG" id="MGM" alt="Figure 1: Model phylogeny of MGM (a) and simplified model scheme (b)" /><figcaption aria-hidden="true">Figure 1: Model phylogeny of MGM (a) and simplified model scheme (b)</figcaption>
</figure>

## 2. Entities, state variables, and scales

### Agents

The model simulates the annual life cycle of submerged macrophytes in a
lake. One time step represents one day. The model uses the
super-individual concept (see [4. Design concepts](#design-concepts)).
Every super-individual is defined by its biomass, number of represented
individuals, its individual weight, height, and the allocated biomass
for seed or tuber production.

Two different reproductive strategies are implemented: Reproduction via
seeds or / and via tubers. Dependent on the selected reproductive
strategy, there can be up to two super-individuals, one from
reproduction via seeds and one from reproduction via tubers. Both are
competing for light.

Each species is defined by a set of species specific parameters listed
in the section [6. Input data](#Input).

Different species are not competing for ressources, they are simulated
simultaneously.

### Spatial units

The model is not spatially explicit. Different depths are modeled
simultaneously without interaction.

### Environment

Lakes are defined by lake specific parameters listed in section [6.
Input data](#input). Those define the annual course of

-   water temperature,

-   water level,

-   water turbidity,

-   nutrient content, and

-   irradiance at the water surface.

Further lake specific parameters are used to calculate the hourly
photosynthetic active light reaching the species dependent on water
depth.

## 3. Process overview and scheduling

Per daily time step each super-individual undergoes the following
processes ([see Fig. 2](#processe)). They depend on the day and on the
age of the species:

**Germination** starts at *germinationDay*. On that day, the seed
biomass or tuber biomass is transferred in macrophyte biomass dependent
on a species-specific ratio (*cTuber*)*.* From this day, daily
**growth** dependent on photosynthesis rate and respiration rate starts.
The species can grow until its maximal age (*maxAge*) is reached. Then,
a complete die-off event occurs. Other processes of **mortality** during
the life-span of the species can be thinning, negative growth
(respiration rate &gt; photosynthesis rate), wave mortality and
background mortality. **Reproduction** takes place in a defined
time-span (between *seedsStartAge* and *seedsEndAge*). In that
time-span, a part of the macrophyte biomass is daily allocated until a
predefined fraction is reached (*seedFraction* / *tuberFraction*). The
allocated biomass is not photosynthetically active.  
The seeds / tubers are released on a predefined day (*reproDay*): the
allocated biomass for seed / tuber production is transferred into seed
biomass / tuber biomass. The species life-cycle within the following
year starts with the produced seedBiomass / tuberBiomass of the previous
year.

<figure>
<img src="ODD_Figures/Fig2.PNG" id="processe" alt="Figure 2: MGM scheduling and daily processes within the annual cycle." /><figcaption aria-hidden="true">Figure 2: MGM scheduling and daily processes within the annual cycle.</figcaption>
</figure>

## 4. Design concepts

The model is designed as **deterministic** model, no probabilities and
stochastic processes are included. Thus, all results are completely
reproducible.

The model uses the **super-individual approach** (M. Scheffer et al.
1995). Each super-individual represents an amount of individuals which
all have the same growth rate, individual weight, and height. The
advantage is that computational time is reduced. As MGM is not spatially
explicit, one super-individual is simulated per run representing the
growth at 1m². Since the environmental conditions within on depths in
the whole lake are identical, this patch represents the corresponding
depth in the whole lake. If multiple depths are simulated, each depth is
represented by one super-individual. If growth from seeds and tubers is
used, the model uses two super-individuals, one from growth of seeds,
and another one from tubers.

## 5. Initialization

Each species is initialized with a distinct seed and/or tuber biomass
(*seedInitialBiomass* / *tuberInitialBiomass*).

Each lake is initialized with a deterministic annual course of water
temperature, water level, water turbidity, nutrient content, and
irradiance at the water surface.

## 6. Input data

To specify the input, input files defining the general settings, lake
parameters, and species parameters are necessary. Their parameters are
explained in the following three subsections. They have to be placed in
the folder “input.” If not given, the default settings from
*defaults.jl* are used.

### General settings

General settings can be defined in a file named *general.config.txt*.
The following parameters are included:

| Parameter   | Unit | Description                                                                 |
|:------------|:-----|:----------------------------------------------------------------------------|
| years       | n    | Number of years to simulate                                                 |
| depths      | m    | Depths below mean water level to simulate. Multiple depth can be given here |
| yearsoutput | n    | Number of last simulated years that get saved in the output files           |
| species     | \-   | Relative paths to the species configuration files                           |
| lakes       | \-   | Relative paths to the lakes configuration files                             |
| modelrun    | \-   | Folder name of the modelrun in the output folder (is created automatically) |

### Species settings

Species specific settings can be set in the files in the *species*
folder. For each species one file is necessary. The following parameters
can be set:

| Parameter           | Unit                                       | Description                                                             |
|:--------------------|:-------------------------------------------|:------------------------------------------------------------------------|
| seedsStartAge       | *d**a**y**s*                               | Age of the plants where seed formation starts                           |
| seedsEndAge         | *d**a**y**s*                               | Age of the plants where seedFraction is reached                         |
| tuberStartAge       | *d**a**y**s*                               | Age of the plants where tuber formation starts                          |
| tuberEndAge         | *d**a**y**s*                               | Age of the plants where tuberFraction is reached                        |
| cTuber              | *f**r**a**c**t**i**o**n*                   | Fraction of tuber weight lost daily when sprouts starts growing         |
| pMax                | *h*<sup> − 1</sup>                         | Maximal gross photosynthesis                                            |
| q10                 | \-                                         | Q10 for maintenance respiration                                         |
| resp20              | *d*<sup> − 1</sup>                         | Respiration at 20°C                                                     |
| heightMax           | *m*                                        | Maximal height                                                          |
| maxWeightLenRatio   | *g*                                        | Weight of 1 m young sprout                                              |
| rootShootRatio      | *f**r**a**c**t**i**o**n*                   | Proportion of plant allocated to the roots                              |
| fracPeriphyton      | *f**r**a**c**t**i**o**n*                   | Fraction of light reduced by periphyton                                 |
| hPhotoDist          | *m*                                        | Distance from plant top at which the photosynthesis is reduced factor 2 |
| hPhotoLight         | *µ**E**m*<sup> − 2</sup>*s*<sup> − 1</sup> | Half-saturation light intensity (PAR) for photosynthesis                |
| hPhotoTemp          | °*C*                                       | Half-saturation temperature for photosynthesis                          |
| plantK              | *m*<sup> − 2</sup> \* *g*<sup> − 1</sup>   | Extinction coefficient of plant issue                                   |
| pPhotoTemp          | \-                                         | Exponent in temp. effect (Hill function) for photosynthesis             |
| sPhotoTemp          | \-                                         | Scaling of temperature effect for photosynthesis                        |
| BackgroundMort      | *d*<sup> − 1</sup>                         | Background mortality                                                    |
| cThinning           | \-                                         | c factor of thinning function                                           |
| hWaveMort           | *m*                                        | Half-saturation depth for mortality                                     |
| germinationDay      | *d*                                        | Day of germination of seeds                                             |
| reproDay            | *d*                                        | Day of dispersal of seeds                                               |
| maxAge              | *d*                                        | Maximal plant age                                                       |
| maxWaveMort         | *d*<sup> − 1</sup>                         | Maximum loss of weight in shallow areas                                 |
| pWaveMort           | \-                                         | Power of Hill function for wave mortality                               |
| thinning            | \-                                         | If thinning is applied (TRUE / FALSE)                                   |
| hNutrient           | *m**g**l*<sup>−</sup>1                     | Half-saturation nutrient concentration for photosynthesis               |
| pNutrient           | *m**g**l*<sup>−</sup>1                     | Power of Hill function for nutrient                                     |
| seedBiomass         | *g*                                        | Individual weight of seeds                                              |
| seedFraction        | *y**e**a**r*<sup> − 1</sup>                | Fraction of plant weight allocated to seeds                             |
| seedGermination     | *y**e**a**r*<sup> − 1</sup>                | Fraction of seeds that germinate                                        |
| seedInitialBiomass  | *g*                                        | Initial biomass of seeds                                                |
| seedMortality       | *d*<sup> − 1</sup>                         | Daily mortality of seeds                                                |
| tuberBiomass        | *g*                                        | Individual weight of tubers                                             |
| tuberFraction       | *y**e**a**r*<sup> − 1</sup>                | Fraction of plant weight allocated to tubers                            |
| tuberGermination    | *y**e**a**r*<sup> − 1</sup>                | Fraction of tubers that germinate                                       |
| tuberGerminationDay | *d**a**y**n**o*                            | The day that tubers germinate                                           |
| tuberInitialBiomass | *g**m*<sup> − 2</sup>                      | Initial biomass of tubers                                               |
| tuberMortality      | *d*<sup> − 1</sup>                         | Mortality of tubers                                                     |

### Lake settings

Lake specific settings can be defined in the files in the *lakes*
folder. One file per lake is necessary. The following parameters can be
set:

| Parameter       | Unit                                       | Description                                                                            |
|:----------------|:-------------------------------------------|:---------------------------------------------------------------------------------------|
| fracReflected   | \-                                         | Light reflection at the water surface                                                  |
| iDelay          | *d*                                        | Days after 1st of January where I is minimal                                           |
| iDev            | \-                                         | Deviation factor to change total irradiation                                           |
| latitude        | °                                          | Latitude of corresponding lake                                                         |
| maxI            | *µ**E**m*<sup> − 2</sup>*s*<sup> − 1</sup> | Maximal Irradiance                                                                     |
| minI            | *µ**E**m*<sup> − 2</sup>*s*<sup> − 1</sup> | Minimal Irradiance                                                                     |
| parFactor       | \-                                         | Fraction of total irradiation that is PAR                                              |
| maxNutrient     | *m**g**l*<sup> − 1</sup>                   | Concentration of limiting nutrient in water                                            |
| maxTemp         | °*C*                                       | Maximal mean daily temperature of a year                                               |
| minTemp         | °*C*                                       | Minimal mean daily temperature of a year                                               |
| tempDelay       | *d*                                        | Days after 1st of January where Temp is minimal                                        |
| tempDev         | \-                                         | Share of temp                                                                          |
| backgrKd        | *m*<sup> − 1</sup>                         | Background light attenuation of water (Vertical light attenuation, turbidity)          |
| kdDelay         | *d*                                        | Delay, the day number with the minimal light attenuation coefficient                   |
| kdDev           | \-                                         | Deviation factor, a factor between 0 and 1 to change the whole light attenuation range |
| maxKd           | *m*<sup> − 1</sup>                         | Maximum light attenuation coefficient                                                  |
| minKd           | *m*<sup> − 1</sup>                         | Minimum light attenuation coefficient                                                  |
| levelCorrection | *m*                                        | Correction for reference level (MWL)                                                   |
| maxW            | *m*                                        | Maximal water level above MWL                                                          |
| minW            | *m*                                        | Minimal water level below MWL                                                          |
| wDelay          | *m*                                        | Delay of cosine of water level                                                         |

## 7. Submodels

See detailed description of all functions in the
[`manual of Charisma 2.0`](https://www.projectenaew.wur.nl/charisma/download/charisma_manual.pdf).
All differences and simplifications are described in section \[9.
Differences to Charisma\].

## 8. Output

The main simulation output consists of different files per species, lake
and depths. The main output types are described in the following table.
Each line in every output file represents one day, except of the
settings file. The columns are described in the table.

| File name     | Description                                                                  | Columns within files                                                                      | Units                                                                       |
|:--------------|:-----------------------------------------------------------------------------|:------------------------------------------------------------------------------------------|:----------------------------------------------------------------------------|
| growthSeeds   | Daily Growth rates for superindividuum from seeds for selected output years  | Photosynthesis rate, Respiration rate, Growth rate                                        | *g* \* (*g* \* *d*)<sup> − 1</sup>, *g* \* (*g* \* *d*)<sup> − 1</sup>, *g* |
| growthTubers  | Daily Growth rates for superindividuum from tubers for selected output years | Photosynthesis rate, Respiration rate, Growth rate                                        | *g* \* (*g* \* *d*)<sup> − 1</sup>, *g* \* (*g* \* *d*)<sup> − 1</sup>, *g* |
| seeds         | Seedbank daily                                                               | SeedBiomass, SeedNumber, GerminatingBiomass                                               | *g*, *g*, *g*                                                               |
| tubers        | Tuberbank daily                                                              | TuberBiomass, TuberNumber, GerminatingBiomass                                             | *g*, *g*, *g*                                                               |
| superInd      | Sum of superIndSeed and superIndTuber, daily values                          | Biomass, Number, individual Weight, Height, allocatedSeedBiomass, allocatedTurionsBiomass | *g*, *N*, *g*, *m*, *g*, *g*                                                |
| superIndSeed  | Superindividuum from Seeds                                                   | Biomass, Number, individual Weight, Height, allocatedSeedBiomass, allocatedTurionsBiomass | *g*, *N*, *g*, *m*, *g*, *g*                                                |
| superIndTuber | Superindividuum from Tubers                                                  | Biomass, Number, individual Weight, Height, allocatedSeedBiomass, allocatedTurionsBiomass | *g*, *N*, *g*, *m*, *g*, *g*                                                |
| Temp          | Daily value of water temperature                                             | Water temperature                                                                         | °*C*                                                                        |
| Waterlevel    | Daily value of water level                                                   | Waterlevel                                                                                | *m**a**s**l*                                                                |
| Irradiance    | Daily value of irradiance at water surface                                   | Irradiance                                                                                | *µ**E* \* *m*<sup> − 2</sup> \* *s*<sup> − 1</sup>                          |
| Light         | Daily value of light                                                         | Light                                                                                     | *µ**E* \* *m*<sup> − 2</sup> \* *s*<sup> − 1</sup>                          |
| Attenuation   | Daily value of light attenuation                                             | Attenuation                                                                               | *m*<sup> − 1</sup>                                                          |
| Settings      | Storage of all used input parameters                                         | Settings                                                                                  | \-                                                                          |

## 9. Differences to Charisma 2.0

This parts follows the sections within the
[`manual of Charisma 2.0`](https://www.projectenaew.wur.nl/charisma/download/charisma_manual.pdf)
and highlights the changes we implemented in MGM. All changes were made
mainly to simplify the model and to reduce the number of species
specific parameters.

This version of the model cannot be executed for multiple species. It
calculates growth of biomass, number of subindividuals, individual
weight and height for two super-individuals from the same species, one
originated from seeds, one from tubers.

### The grid

MGM is not spatially explicit. But is it depth explicit (calculation of
single patches for multiple depths at once). Thus, no seed dispersal,
and no mixing effect for light attenuation or nutrients are included.

### Vegetation

#### Overwintering structures

No changes are made, but seed dispersal is not included as MGM is not
spatially explicit.

#### Growth form

The spreading of shoots under the water surface is not included.

#### Respiration

No changes are made.

#### Primary production

Primary production depends on maximum production rate
(*P*<sub>*m**a**x*</sub>), in-situ light (I), temperature (T), the
distance (D) from the tissue to the top of the plant, and limiting
nutrient concentration (N) (Figure 3). Bicarbonate concentration as
limiting factor is ignored as the studied lakes are all not carbon
limited.

*P* = *P*<sub>*m**a**x*</sub> \* *f*(*I*) \* *f*(*T*) \* *f*(*D*) \* *f*(*N*)

<figure>
<img src="ODD_Figures/Fig3.PNG" id="PP" alt="Figure 2: Primary production within MGM." /><figcaption aria-hidden="true">Figure 2: Primary production within MGM.</figcaption>
</figure>

#### Mortality factors

The changed mortality factors are:

-   Background mortality and wave mortality lead to a loss in number of
    plants and biomass.

-   Negative growth (Respiration &gt; Photosynthesis) results in a loss
    of biomass.

#### Grazing

Grazing is completely excluded.

#### Seasonal die-off

No changes.

### Environment

#### Light

No changes were made: The daily total irradiation follows a sine wave
over the year.

#### The effective irradiation

No changes.

#### Vertical light attenuation of the water

The extinction is modeled with a cosine function, as suggested in
Charisma 2.0

Options and processes from Charisma 2.0 that are excluded:

-   Read in daily data.

-   Clear water periods.

-   The effect of vegetation on the light attenuation.

-   Mixing the light attenuation coefficient in grids.

#### Temperature

No changes were made. The daily water temperature follows a cosine wave
over the year.

The option to import data is not implemented.

#### The water depth

No changes.

#### The level of the grid

Excluded, as MGM is not spatially explicit.

#### Water level

No changes were made. The daily water level values follow a cosine wave
over the year.

The option to import data is not implemented.

#### Bicarbonate

Excluded.

#### Limiting nutrient

No changes.

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-bezanson2017" class="csl-entry">

Bezanson, Jeff, Alan Edelman, Stefan Karpinski, and Viral B. Shah. 2017.
“Julia: A Fresh Approach to Numerical Computing.” *SIAM Review* 59 (1):
65–98. <https://doi.org/10.1137/141000671>.

</div>

<div id="ref-grimm2006" class="csl-entry">

Grimm, Volker, Uta Berger, Finn Bastiansen, Sigrunn Eliassen, Vincent
Ginot, Jarl Giske, John Goss-Custard, et al. 2006. “A Standard Protocol
for Describing Individual-Based and Agent-Based Models.” *Ecological
Modelling* 198 (1-2): 115–26.
<https://doi.org/10.1016/j.ecolmodel.2006.04.023>.

</div>

<div id="ref-grimm2010" class="csl-entry">

Grimm, Volker, Uta Berger, Donald L. DeAngelis, J. Gary Polhill, Jarl
Giske, and Steven F. Railsback. 2010. “The ODD Protocol: A Review and
First Update.” *Ecological Modelling* 221 (23): 2760–68.
<https://doi.org/10.1016/j.ecolmodel.2010.08.019>.

</div>

<div id="ref-scheffer1995" class="csl-entry">

Scheffer, M., J. M. Baveco, D. L. DeAngelis, K. A. Rose, and E. H. van
Nes. 1995. “Super-Individuals a Simple Solution for Modelling Large
Populations on an Individual Basis.” *Ecological Modelling* 80 (2):
161–70. <https://doi.org/10.1016/0304-3800(94)00055-M>.

</div>

<div id="ref-scheffer1993" class="csl-entry">

Scheffer, Marten, Aldrik H. Bakema, and Frederick G. Wortelboer. 1993.
“MEGAPLANT: A Simulation Model of the Dynamics of Submerged Plants.”
*Aquatic Botany* 45 (4): 341–56.
<https://doi.org/10.1016/0304-3770(93)90033-S>.

</div>

<div id="ref-vannes2003" class="csl-entry">

van Nes, Egbert H., Marten Scheffer, Marcel S. van den Berg, and Hugo
Coops. 2003. “Charisma: A Spatial Explicit Simulation Model of Submerged
Macrophytes.” *Ecological Modelling* 159 (2): 103–16.
<https://doi.org/10.1016/S0304-3800(02)00275-2>.

</div>

</div>
