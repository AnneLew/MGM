# MGM
MGM (Macrophytes Growth Model) is a process-based, eco-physiological model simulating the growth of submerged macrophytes under different environemntal conditions. MGM is a simplified re-implementation of Charisma 2.0 (van Nes et al. 2003) in Julia language.

**For documentation, see:** 
- [`docs/ODD.md`](https://github.com/AnneLew/MGM/blob/master/doc/ODD.md) 
  "Overview, Design concepts, and Details" document describing the concept of the model including differences between MGM and Charisma 2.0.
- [`Charisma 2.0`](https://www.projectenaew.wur.nl/charisma/) A comprehensive description of Charisma 2.0 including model's manual.
- [`USAGE.md`](https://github.com/AnneLew/MGM/blob/master/USAGE.md) 
  how to set up and run simulations with MGM.
- [`LICENSE.md`](https://github.com/AnneLew/MGM/blob/master/LICENSE.txt) text of the open-source software license.


**Folder structure:**
- [`data`](https://github.com/AnneLew/MGM/blob/master/data) Mapped distribution of macrophyte species from Bavaria. *Data source*: Bayerische Landesamt für Umwelt 
- [`doc`](https://github.com/AnneLew/MGM/blob/master/data) Documentation of the model
- [`experiment`](https://github.com/AnneLew/MGM/blob/master/experiment)
- [`input_examples`](https://github.com/AnneLew/MGM/blob/master/input_examples) Exemplaric input files. To run the model, the folder has to be renamed in *input*.
- [`model`](https://github.com/AnneLew/MGM/blob/master/model) Source code files of the model.
- [`optimizer`](https://github.com/AnneLew/MGM/blob/master/optimizer)
- [`sensitivity`](https://github.com/AnneLew/MGM/blob/master/sensitivity)


## Reference

- van Nes, E.H.; Scheffer, M.; van den Berg, M.S.; Coops, H. (2003) "Charisma:
  a spatial explicit simulation model of submerged macrophytes" 
  *Ecological Modelling* 159, 103-116

---

