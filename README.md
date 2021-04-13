# CharismaBiodiv
Charisma is a process-based, eco-physiological model for the growth of submerged macrophytes. It was originally published by van Nes et al. (2003); the code in this repository is a simplified re-implementation in Julia language.

For a comprehensive description of the original model, see the model's manual that can be downloaded from the [project webpage](https://www.projectenaew.wur.nl/charisma/). 
For documentation of differences from this version to the original one see the manual in the *doc* folder. For the source code, see the *model* folder.

Exemplary input files for lake and species parameter sets can be found in the *input_examples* folder. To run the model, the folder has to be renamed into *input*. 

Furthermore, R code for sensitivity analysis and parameter optimization can be found in the respective folders.

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

Download CHARISMA by running

```
git clone https://github.com/AnneLew/CharismaBiodiv
```


## Instructions for use
Enter the directory and rename the folder *input_examples* as *input*. Replace or adapt input files if necessary (See manual in *doc*). Go to the folder *model* and run
```
julia CHARIMSA.jl
```
to run the model. 

If you want ro use the virtual Ecologist approach (see description in *doc*) run in the *model* folder
```
julia virtualEcologist.jl
```

## References

- van Nes, E.H.; Scheffer, M.; van den Berg, M.S.; Coops, H. (2003) "Charisma:
  a spatial explicit simulation model of submerged macrophytes" 
  *Ecological Modelling* 159, 103-116
