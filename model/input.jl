"""
    getsettings()

Combines all configuration options to produce a single settings dict.
Order of precedence: config file - default values
"""

function getsettings(configfile::String = "")
    defaults = defaultSettings()
    if !isempty(configfile) && isfile(configfile)
        configs = parseconfig(configfile)
    else
        configs = Dict{String, Any}()
    end
    settings = merge(defaults, configs)
    settings
end
