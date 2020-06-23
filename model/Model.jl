"""
Model for macrophyte growth, similar to CHARISMA (van Nes 2003)
"""

include("defaults.jl")
get(defaultSettings(), "lat", "NA")

include("Initialisation.jl")
include("Resp_PS.jl")
include("run_simulation.jl")




end
