
"""
    getsettings()

Combines all configuration options to produce a single settings dict.
Order of precedence: config file - default values
Source: GeMM Model by Leidinger&Vedder

"""

function getsettings(configfileLake::String = "",configfileSpecies::String = "",configfileGeneral::String = "",)
    defaultsGlobal = defaultSettingsGlobal()
    defaultsLake = defaultSettingsLake()
    defaultsSpecies = defaultSettingsSpecies()
    #defaultsGeneral = defaultSettingsGeneral()
    if !isempty(configfileLake) && isfile(configfileLake)
        configsLake = parseconfigLake(configfileLake)
    else
        configsLake = Dict{String,Any}()
    end
    if !isempty(configfileSpecies) && isfile(configfileSpecies)
        configsSpecies = parseconfigSpecies(configfileSpecies)
    else
        configsSpecies = Dict{String,Any}()
    end

    #if !isempty(configfileGeneral) && isfile(configfileGeneral)
    #    configsGeneral = parseconfigGeneral(configfileGeneral)
    #else
    #    configsGeneral = Dict{String,Any}()
    #end

    settings = merge(defaultsGlobal, defaultsLake, configsLake, defaultsSpecies, configsSpecies)
    return settings
end


"""
    basicparser(filename)

Do elementary parsing on a config or map file.

Reads in the file, strips whole-line and inline comments
and separates lines by whitespace.
Returns a 2d array representing the tokens in each line.
Source: GeMM Model by Leidinger&Vedder

"""
function basicparser(filename::String)
    # Read in the file
    lines = String[]
    open(filename) do file
        lines = readlines(file)
    end
    # Remove comments and tokenize
    lines = map(x -> strip(x), lines)
    filter!(x -> !isempty(x), lines)
    filter!(x -> (x[1] != '#'), lines)
    lines = map(s -> strip(split(s, '#')[1]), lines)
    lines = map(split, lines)
    map(l -> map(s -> convert(String, s), l), lines)
end


"""
    advancedparser(filename)

Do elementary parsing on a config or map file.



"""
function advancedparser(filename::String)
    # Read in the file
    lines = String[]
    open(filename) do file
        lines = readlines(file)
    end
    # Remove comments and tokenize
    lines = map(x -> strip(x), lines)
    filter!(x -> !isempty(x), lines)
    filter!(x -> (x[1] != '#'), lines)
    lines = map(s -> strip(split(s, '#')[1]), lines)
    lines = map(split, lines)
    map(l -> map(s -> convert(String, s), l), lines)
end



"""
    parseconfigLake(filename)

Parse a configuration file and return a settings dict.

The config syntax is very simple: each line consists of a parameter
name and a value (unquoted), e.g. `nniches 2`. `#` is the comment character.
Source: GeMM Model Source: GeMM Model by Leidinger&Vedder

"""

function parseconfigLake(configfilename::String)
    config = basicparser(configfilename)
    settings = Dict{String, Any}()
    defaults = defaultSettingsLake()
    for c in config
        if length(c) != 2
            #simlog("Bad config file syntax: $c", settings, 'w', "")
        elseif c[1] in keys(defaults)
            value = c[2]
            if !(typeof(defaults[c[1]]) <: AbstractString)
                try
                    value = parse(typeof(defaults[c[1]]), c[2]) # or Meta.parse with the old functionality
                catch
                    #simlog("$(c[1]) not of type $(typeof(defaults[c[1]])).",
                    #       settings, 'w', "")
                end
            end
            settings[c[1]] = value
        else
            # XXX maybe parse anyway
            #simlog(c[1]*" is not a recognized parameter!", settings, 'w', "")
        end
    end
    settings
end



"""
    parseconfigSpecies(filename)

Parse a configuration file and return a settings dict.

The config syntax is very simple: each line consists of a parameter
name and a value (unquoted), e.g. `nniches 2`. `#` is the comment character.
Source: GeMM Model Source: GeMM Model by Leidinger&Vedder

"""

function parseconfigSpecies(configfilename::String)
    config = basicparser(configfilename)
    settings = Dict{String, Any}()
    defaults = defaultSettingsSpecies()
    for c in config
        if length(c) != 2
            #simlog("Bad config file syntax: $c", settings, 'w', "")
        elseif c[1] in keys(defaults)
            value = c[2]
            if !(typeof(defaults[c[1]]) <: AbstractString)
                try
                    value = parse(typeof(defaults[c[1]]), c[2]) # or Meta.parse with the old functionality
                catch
                    #simlog("$(c[1]) not of type $(typeof(defaults[c[1]])).",
                    #       settings, 'w', "")
                end
            end
            settings[c[1]] = value
        else
            # XXX maybe parse anyway
            #simlog(c[1]*" is not a recognized parameter!", settings, 'w', "")
        end
    end
    settings
end


"""
    parseconfigGeneral(filename)

Parse a configuration file and return a settings dict.

The config syntax is very simple: each line consists of a parameter
name and a value (unquoted), e.g. `nniches 2`. `#` is the comment character.
Source: GeMM Model Source: GeMM Model by Leidinger&Vedder

"""


function parseconfigGeneral(configfilename::String)
    config = advancedparser(configfilename)
    settings = Dict{String, Any}()
    defaults = defaultSettingsGeneral()
    for c in config
        if c[1] in keys(defaults)
            value=String[]
            for i in 2:length(c)
                push!(value,c[i])
            end
            settings[c[1]] = value
        end
    end
    settings
end
