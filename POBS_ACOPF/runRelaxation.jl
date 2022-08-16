

case_file = "case"*case*".m"

include("getNetworkData.jl")
include("maxCliquesCS.jl")
include("genVar.jl")
include("makeTables.jl")
include("opf.jl")
include("classicSDP.jl")
include("tightening.jl")
optimize!(model)

