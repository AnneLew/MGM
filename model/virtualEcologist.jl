"""
 VirtualEcologist

Virtual ecologist approach transforming output biomass of fieldday found with a
defined probablity of last simulated year into Kohler Number

Input: Takes outputs of modelrun from general.config.file to run
Outputs: (1) file with lake dependent probability to find species &
(2) table with Kohler number for 4 depth, species number and lake number
"""

#Set dir to home_dir of file
cd(dirname(@__DIR__))

# Include functions
include("defaults.jl")
include("input.jl")

#load packages
using Distributions
using CSV
using DataFrames
using StatsBase

# Import general Settings of modelrun
GeneralSettings = parseconfigGeneral("./input/general.config.txt")
nlakes = length(GeneralSettings["lakes"])
nspecies = length(GeneralSettings["species"])

# WD settings
homdir = pwd()
outputdir = "output"
rundir = GeneralSettings["modelrun"][1]

# Set VE parameters - have to be output in the end
Kohler5=zeros(Float64,nspecies)
for s = 1:nspecies
        settings = getsettings(GeneralSettings["species"][s])
        Kohler5[s]=settings["Kohler5"][1]
end


# Definition of probability to find species, lake dependent
pFindSpecies = rand(Uniform(0.5,1.0),nlakes)
fieldday = 226 # Fieldday for sampling

# Import modelruns
cd(homdir)
cd(outputdir)
cd(rundir)
parent_dir = pwd()
modelruns = filter(x -> isdir(joinpath(parent_dir, x)), readdir(parent_dir))

jmax=length(modelruns) # number of combinations of lakes and species

# Create empty datatable to save VE output
mappedMacroph = zeros(Float64, jmax, (length(GeneralSettings["depths"])+2))

# Loop for all combinations of lakes and species to fill mappedMacroph
for j = 1:jmax
        cd(homdir)
        cd(outputdir)
        cd(rundir)
        # Extract all lake * species combinations and their names and numbers
        lakespeciesdir = filter(x -> isdir(joinpath(pwd(), x)), readdir(pwd()))[j]
        lake = split(lakespeciesdir, "_s")[1]
        lakeN = parse(Int64, split(lake,"_")[2])
        species = "s"*split(lakespeciesdir, "_s")[2]
        speciesN = parse(Int64, split(species,"_")[2])

        cd(lakespeciesdir)

        # Import model output files
        files = readdir()
        superind = ["./superIndSeed-0.5.csv","./superIndSeed-1.5.csv","./superIndSeed-3.0.csv","./superIndSeed-5.0.csv",
                        "./superIndTuber-0.5.csv","./superIndTuber-1.5.csv","./superIndTuber-3.0.csv","./superIndTuber-5.0.csv"]
        #if (all(superind %in% files)==FALSE) next

        # Extract data of common superindividuum in all depth
        superIndiv = zeros((parse.(Int32,GeneralSettings["yearsoutput"])*365)[1]+1,6,length(superind))

        superIndSeed05 = (DataFrame(CSV.File.(superind[1],header=false)))
        superIndSeed15 = (DataFrame(CSV.File.(superind[2],header=false)))
        superIndSeed30 = (DataFrame(CSV.File.(superind[3],header=false)))
        superIndSeed50 = (DataFrame(CSV.File.(superind[4],header=false)))
        superIndTuber05 = (DataFrame(CSV.File.(superind[5],header=false)))
        superIndTuber15 = (DataFrame(CSV.File.(superind[6],header=false)))
        superIndTuber30 = (DataFrame(CSV.File.(superind[7],header=false)))
        superIndTuber50 = (DataFrame(CSV.File.(superind[8],header=false)))

        #Create Data structure
        BiomNHeight = zeros(4,4) #biomass, N, indWeight, Height =rows; 4depths = columns

        ## Import Biomass as sum of superIndSeedBiomass and superIndTuberBiomass
        for i = 1:4
                BiomNHeight[i,1] = superIndSeed05[fieldday,i]+superIndTuber05[fieldday,i]
                BiomNHeight[i,2] = superIndSeed15[fieldday,i]+superIndTuber15[fieldday,i]
                BiomNHeight[i,3] = superIndSeed30[fieldday,i]+superIndTuber30[fieldday,i]
                BiomNHeight[i,4] = superIndSeed50[fieldday,i]+superIndTuber50[fieldday,i]
        end

        # Check if Biomass < 0.01 and N<1 -> cannot be found
        for i = 1:4
                if BiomNHeight[1,i]<0.01 && BiomNHeight[2,i]<1
                        for j = 1:4
                                BiomNHeight[j,i]=0
                        end
                end
        end

        #Create Data structure
        BiomNHeightMapped = zeros(4,4) #biomass, N, indWeight, Height =rows; 4depths = columns

        # Find with probability
        found =sample([1, 0], Weights([pFindSpecies[nlakes], 1-pFindSpecies[nlakes]]), 1)[1]
        for i=1:4
                if found == 1
                        BiomNHeightMapped[1,i]=BiomNHeight[1,i]
                end
                for j = 2:4
                        if BiomNHeightMapped[1,i] == 0
                                BiomNHeightMapped[j,i] == 0
                        else BiomNHeightMapped[j,i] =BiomNHeight[j,i]
                        end
                end
        end

        mappedMacroph[j,5]=speciesN
        mappedMacroph[j,6]=lakeN

        Kohler5_s = Kohler5[speciesN]
        Kohler4 = Kohler5_s*64/125
        Kohler3 = Kohler5_s*27/125
        Kohler2 = Kohler5_s*8/125

        for i = 1:4
                if BiomNHeightMapped[1,i]==0
                        mappedMacroph[j,i] == 0
                elseif BiomNHeightMapped[1,i]>Kohler5_s
                        mappedMacroph[j,i] == 5
                elseif BiomNHeightMapped[1,i]>Kohler4
                        mappedMacroph[j,i] == 4
                elseif BiomNHeightMapped[1,i]>Kohler3
                        mappedMacroph[j,i] == 3
                elseif BiomNHeightMapped[1,i]>Kohler2
                        mappedMacroph[j,i] == 2
                elseif BiomNHeightMapped[1,i]>0
                        mappedMacroph[j,i] == 1
                end
        end

end
mappedMacroph

cd(homdir)
cd(outputdir)
cd(rundir)

writedlm("pFindSpecies.csv",pFindSpecies, ',')
#writedlm("Kohler5.csv",Kohler5, ',') #TODO should be input variable ?
writedlm("MappedMacrophytes.csv", mappedMacroph, ',')
