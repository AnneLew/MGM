# CHARISMA (and VirtualEcologist) as one function
# Output Kohler value of x depths for 1 species in one ? lake


#load packages
using
    HCubature, #for Integration
    DelimitedFiles, # for function writedlm, used to write output files
    Dates, #to create output folder
    Distributions, Random, #for killWithProbability
    CSV, #For virtual Ecologist
    DataFrames, #For virtual Ecologist
    StatsBase #For virtual Ecologist

function CHARISMA_VE()
    #Set dir to home_dir of file
        cd(dirname(@__DIR__))
        cd("model")

        # Include functions
        include("defaults.jl")
        include("input.jl")
        include("functions.jl")
        include("run_simulation.jl")
        include("output.jl")

        # Get Settings for selection of lakes, species & depth
        cd(dirname(@__DIR__))
        GeneralSettings = parseconfigGeneral("./input/general.config.txt")
        depths = parse.(Float64, GeneralSettings["depths"])
        nyears = parse.(Int64, GeneralSettings["years"])
        nlakes = length(GeneralSettings["lakes"]) #VE
        nspecies = length(GeneralSettings["species"]) #VE

        # Set VE parameters - have to be output in the end
        pFindSpecies = rand(Uniform(0.5,1.0),nlakes)
        fieldday = 226 #

        # Define output structure
        mappedMacroph = zeros(Float64, (nspecies*nlakes), (length(GeneralSettings["depths"])+2))
        j=0 # counter

        # Loop for model run for selected lakes, species and depths
        for l in 1:length(GeneralSettings["lakes"])

            println(GeneralSettings["lakes"][l])

            for s in 1:length(GeneralSettings["species"])
                j=j+1 #counter
                println(GeneralSettings["species"][s])

                #Get settings
                settings = getsettings(GeneralSettings["lakes"][l], GeneralSettings["species"][s])
                push!(settings, "years" => parse.(Int64,GeneralSettings["years"])[1]) #add "years" from GeneralSettings
                push!(settings, "yearsoutput" => parse.(Int64,GeneralSettings["yearsoutput"])[1]) #add "years" from GeneralSettings
                push!(settings, "modelrun" => GeneralSettings["modelrun"][1]) #add "modelrun" from GeneralSettings

                # Get macrophytes in multiple depths
                result = simulateMultipleDepth(depths,settings) #Biomass, Number, indWeight, Height,
                # [depths][1=superInd][day*year,parameter]]

                # Virtual Ecologist
                # (select total (seed+tuber) biomass [or all values] of fieldday of last year of simulation for all depths)
                day=nyears[1]*365-(365-fieldday) #N of output day

                #Create Data structure & import data
                BiomNHeight = zeros(4,4) #biomass, N, indWeight, Height =rows; 4depths = columns

                for i = 1:4
                        BiomNHeight[i,:] = result[i][1][day,1:4]
                end

                # Check if Biomass < 0.01 and N<1 -> cannot be found
                for i = 1:4
                            if BiomNHeight[1,i]<0.01 && BiomNHeight[2,i]<1
                                    for j = 1:4
                                            BiomNHeight[j,i]=0
                                    end
                            end
                end

                # Find with probability
                #Create Data structure
                BiomNHeightMapped = zeros(4,4) #biomass, N, indWeight, Height =rows; 4depths = columns

                # Find with probability
                found =sample([1, 0], Weights([pFindSpecies[nlakes], 1-pFindSpecies[nlakes]]), 1)[1]
                for i=1:4 #TODO ndepths
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

                mappedMacroph[j,5]=s
                mappedMacroph[j,6]=l

                # Transform into Kohler value
                Kohler5_s = settings["Kohler5"]
                Kohler4 = Kohler5_s*64/125
                Kohler3 = Kohler5_s*27/125
                Kohler2 = Kohler5_s*8/125

                for d = 1:4
                        if BiomNHeightMapped[d,1]==0
                                mappedMacroph[j,d] = 0
                                #
                        elseif BiomNHeightMapped[d,1]>Kohler5_s
                                mappedMacroph[j,d] = 5
                        elseif BiomNHeightMapped[d,1]>Kohler4
                                mappedMacroph[j,d] = 4
                        elseif BiomNHeightMapped[d,1]>Kohler3
                                mappedMacroph[j,d] = 3
                        elseif BiomNHeightMapped[d,1]>Kohler2
                                mappedMacroph[j,d] = 2
                        elseif BiomNHeightMapped[d,1]>0
                                mappedMacroph[j,d] = 1
                        end
                end

            end
            # Combine result for all lakes
        end
    return (mappedMacroph) #For all lakes (&species) together
end

#CHARISMA_VE()



function CHARISMA_biomass()
    #Set dir to home_dir of file
        cd(dirname(@__DIR__))
        cd("model")

        # Include functions
        include("defaults.jl")
        include("input.jl")
        include("functions.jl")
        include("run_simulation.jl")
        include("output.jl")

        # Get Settings for selection of lakes, species & depth
        cd(dirname(@__DIR__))
        GeneralSettings = parseconfigGeneral("./input/general.config.txt")
        depths = parse.(Float64, GeneralSettings["depths"])
        nyears = parse.(Int64, GeneralSettings["years"])
        nlakes = length(GeneralSettings["lakes"]) #VE
        nspecies = length(GeneralSettings["species"]) #VE


        # Define output structure
        Macroph = zeros(Float64, (nspecies*nlakes), (length(GeneralSettings["depths"])+2))
        j=0 # counter

        # Loop for model run for selected lakes, species and depths
        for l in 1:length(GeneralSettings["lakes"])

            println(GeneralSettings["lakes"][l])

            for s in 1:length(GeneralSettings["species"])
                j=j+1 #counter
                println(GeneralSettings["species"][s])

                #Get settings
                settings = getsettings(GeneralSettings["lakes"][l], GeneralSettings["species"][s])
                push!(settings, "years" => parse.(Int64,GeneralSettings["years"])[1]) #add "years" from GeneralSettings
                push!(settings, "yearsoutput" => parse.(Int64,GeneralSettings["yearsoutput"])[1]) #add "years" from GeneralSettings
                push!(settings, "modelrun" => GeneralSettings["modelrun"][1]) #add "modelrun" from GeneralSettings

                # Get macrophytes in multiple depths
                result = simulateMultipleDepth(depths,settings) #Biomass, Number, indWeight, Height,
                # [depths][1=superInd][day*year,parameter]]

                # Virtual Ecologist
                # (select total (seed+tuber) biomass [or all values] of fieldday of last year of simulation for all depths)
                junefirst=nyears[1]*365-(365-152) #N of output day
                augustlast=nyears[1]*365-(365-243) #N of output day

                # Export summer mean of total Biomass for each depth
                for i = 1:4 #depths
                        Macroph[j,i] = mean(result[i][1][junefirst:augustlast,1]) #result[i][1][day,1:4]
                end

                Macroph[j,5]=s #species Number
                Macroph[j,6]=l #lake Number

            end
        end
    return (Macroph) #Table For all lakes (&species) together
end

#CHARISMA_biomass()

function CHARISMA_biomass_onedepth()
    #Set dir to home_dir of file
        cd(dirname(@__DIR__))
        cd("model")

        # Include functions
        include("defaults.jl")
        include("input.jl")
        include("functions.jl")
        include("run_simulation.jl")
        include("output.jl")

        # Get Settings for selection of lakes, species & depth
        cd(dirname(@__DIR__))
        GeneralSettings = parseconfigGeneral("./input/general.config.txt")
        depths = parse.(Float64, GeneralSettings["depths"])[1] #da nur 1 depth
        nyears = parse.(Int64, GeneralSettings["years"])
        nlakes = length(GeneralSettings["lakes"]) #VE
        nspecies = length(GeneralSettings["species"]) #VE


        # Define output structure
        Macroph = zeros(Float64, (nspecies*nlakes), 3) #1depth,
        j=0 # counter

        # Loop for model run for selected lakes, species and depths
        for l in 1:length(GeneralSettings["lakes"])

            println(GeneralSettings["lakes"][l])

            for s in 1:length(GeneralSettings["species"])
                j=j+1 #counter
                println(GeneralSettings["species"][s])

                #Get settings
                settings = getsettings(GeneralSettings["lakes"][l], GeneralSettings["species"][s])
                push!(settings, "years" => parse.(Int64,GeneralSettings["years"])[1]) #add "years" from GeneralSettings
                push!(settings, "yearsoutput" => parse.(Int64,GeneralSettings["yearsoutput"])[1]) #add "years" from GeneralSettings
                push!(settings, "modelrun" => GeneralSettings["modelrun"][1]) #add "modelrun" from GeneralSettings

                # Get macrophytes in multiple depths
                result = simulate1Depth(depths,settings) #Biomass, Number, indWeight, Height,
                # [depths][1=superInd][day*year,parameter]]

                # Virtual Ecologist
                # (select total (seed+tuber) biomass [or all values] of fieldday of last year of simulation for all depths)
                junefirst=nyears[1]*365-(365-152) #N of output day
                augustlast=nyears[1]*365-(365-243) #N of output day

                # Export summer mean of total Biomass for each depth
                #for i = 1:4 #depths
                Macroph[j,1] = mean(result[1][junefirst:augustlast,1]) #result[i][1][day,1:4]
                #end

                Macroph[j,2]=s #species Number
                Macroph[j,3]=l #lake Number

            end
        end
    return (Macroph) #Table For all lakes (&species) together
end


#