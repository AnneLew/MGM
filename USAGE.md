# MGM usage

## Setting up the model

### System requirements
The model has successfully been tested on different Linux machines (64 bit) and Windows 10. To use the model `julia` (>=1.6) [https://julialang.org/downloads/](https://julialang.org/downloads/) and dependent packages are obligatory. 


## Installation guide
[Download and extract julia](https://julialang.org/downloads/). Enter the created directory and run
```
bin/julia
```
to launch the REPL. Press ] to enter the Pkg REPL and run

```
add Distributions
add HCubature
add DelimitedFiles
add Dates
add Random
add CSV
add DataFrames
add StatsBase
``` 
Press backspace or ^C to get back to the Julia REPL.

Download MGM by running

```
git clone https://github.com/AnneLew/MGM.git
```


## Instructions for basic use
Enter the directory and rename the folder *input_examples* as *input*. Replace or adapt input files if necessary (See manual in *doc*). Go to the folder *model* and run
```
julia CHARIMSA.jl
```
to execute the model. 
An output folder is automatically created, containing a subfolder for the simulated experiment with subfolder for each species and each lake. There, output files for macrophytes and environmental values for all selected depth can be found. 



## Instructions for use via function (e.g. from R)
If you want to run the model as function you can use *CHARISMA_function.jl* eg to call them from R like in the sensitivity analysis or the optimization workflow. 

Three different function are provided (see detailed description in src code): 
- CHARISMA_biomass() : Returns mean summer biomass for all lakes, species, and multiple depths in the last year of simulation
- CHARISMA_biomass_parallel() : same output, but runs in parallel
- CHARISMA_biomass_parallel_lastNyears(): same output, but output for multiple years (set the numbers of *yearsoutput* in `general.config.txt`)
- CHARISMA_biomass_onedepth() : same output, but just for one depth


