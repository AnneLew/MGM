Model description MGM (ODD)
================
Anne Lewerentz
2022-04-14

MGM (Macrophytes Growth Model) is a process-based, eco-physiological
model simulating the growth of submerged macrophytes under different
environemntal conditions. MGM is a simplified re-implementation of
Charisma 2.0 (van Nes et al. 2003)in Julia language (Bezanson et al.
2017).

Charisma combined the previous models MEGAPLANT (Scheffer, Bakema, and
Wortelboer 1993) and ArtiVeg (VanNes & Scheffer 1996). A explicit manual
of Charisma 2.0 can be found here at the [project
website](https://www.projectenaew.wur.nl/charisma/) .

In the following sections a short model description of the
re-implemented version is given. The model description follows the ODD
(Overview, Design concepts, Details) protocol (Grimm et al. 2006, 2010).
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
subsections. They have to be placed in the folder “input.” If not given,
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

## 7. Submodels

Output

The main simulation output consists of different files per species, lake
and depths. The main output types are described in the following table.
Each line in every output file represents one day, except of the
settings file. The columns are described in the table.

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
+————-+———————-+—————————+

## 8. Differences to Charisma

### No multiple species

The version of the model cannot be executed for multiple species. It
calculates growth of Biomass, Number of subindividuals, Individual
weight and height for two superindividua from the same species, one
originated from seeds, one from tubers. Not spatially explicit

### Not spatially explicit

Not spatially explicit, just calculation of single patches for multiple
depths at once. Thus, no seed dispersal is included, no mixing effect
for light attenuation or nutrients is included. No carbon limitation,
but nutrient (phosphor) limitation

### Primary production

Primary production depends on maximum production rate (Pmax), in-situ
light (I), temperature (T), the distance (D) from the tissue to the top
of the plant and limiting nutrient concentration (N). Bicarbonate
concentration as limiting factor is ignored as the studied lakes are all
not carbon limited.

*P* = *P*<sub>*m**a**x*</sub> \* *f*(*I*) \* *f*(*T*) \* *f*(*D*) \* *f*(*N*)

### Mortality

Background mortality and wave mortality lead to a loss in number of
plants and biomass

Negative growth (Respiration &gt; Photosynthesis) leads to a loss in
biomass

### Further excluded processes

-   The effect of vegetation on the light attenuation

-   Herbivory

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
