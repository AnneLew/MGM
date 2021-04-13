# CharismaBiodiv
Charisma is a IBM for submerged macrophytes. It was originally published by van Nes et al. (2003); the code in this repository is a simplified re-implementation in Julia language.

For a comprehensive description of the original model, see the model's manual that can be downloaded here: https://www.projectenaew.wur.nl/charisma/ 
For documentation of differences from this version to the original one see the manual in the *doc* folder. For the source code, see the *model* folder.

Exemplary input files for lake and species parameter sets can be found in the *input_examples* folder. To run the model, the folder has to be renamed into *input*. 

## Installation guide
Download and extract julia from https://julialang.org/downloads/. Enter the created directory and run

bin/julia

to launch the REPL. Press ] to enter the Pkg REPL and run

add Distributions
add HCubature
add DelimitedFiles
add Dates
add Random

Press backspace or ^C to get back to the Julia REPL (https://docs.julialang.org/en/v1/stdlib/Pkg/index.html).

Download CHARISMA by running

git clone https://github.com/AnneLew/CharismaBiodiv

Enter the directory and run

julia CHARIMSA.jl

to test if it works.

## References

- van Nes, E.H.; Scheffer, M.; van den Berg, M.S.; Coops, H. (2003) "Charisma:
  a spatial explicit simulation model of submerged macrophytes" 
  *Ecological Modelling* 159, 103-116
