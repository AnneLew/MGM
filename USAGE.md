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
to run the model. 



If you want to run the model as function you can use *CHARISMA_function.jl* eg to call them from R like in the sensitivity analysis or the optimization workflow. Three different function are provided (see description in src code): 
- CHARISMA_biomass_onedepth()
- CHARISMA_biomass()


## References

- van Nes, E.H.; Scheffer, M.; van den Berg, M.S.; Coops, H. (2003) "Charisma:
  a spatial explicit simulation model of submerged macrophytes" 
  *Ecological Modelling* 159, 103-116
