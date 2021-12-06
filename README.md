# MGM
MGM (Macrophytes Growth Model) is a process-based, eco-physiological model for the growth of submerged macrophytes. It was originally published as Charisma 2.0 by van Nes et al. (2003); the code in this repository is a simplified re-implementation in Julia language.

For a comprehensive description of the original model, see the model's manual that can be downloaded from the [project webpage](https://www.projectenaew.wur.nl/charisma/). 
For documentation of differences from this version to the original one see the manual in the *doc* folder. For the source code, see the *model* folder.

Exemplary input files for lake and species parameter sets can be found in the *input_examples* folder. To run the model, the folder has to be renamed into *input*. 

Furthermore, R code for sensitivity analysis and parameter optimization can be found in the respective folders.

## Documentation
For documentation, see: 
- [`USAGE.md`](https://github.com/AnneLew/MGM/blob/master/USAGE.md) 
  how to set up and run simulations with MGM.
- [`docs/ODD.md`](https://github.com/AnneLew/MGM/blob/master/doc/ODD.md) 
  "Overview, Design concepts, and Details" document describing the concept of the model including differences to the original version from van Nes et al 2003.

## References

- van Nes, E.H.; Scheffer, M.; van den Berg, M.S.; Coops, H. (2003) "Charisma:
  a spatial explicit simulation model of submerged macrophytes" 
  *Ecological Modelling* 159, 103-116
