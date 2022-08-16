

case_file = "case"*case*".m"

include("getNetworkData.jl")
include("maxCliquesCS.jl")
include("genVar.jl")
include("makeTables.jl")
include("opf.jl")
include("classicSDP.jl")
include("tightening.jl")
optimize!(model)

using LinearAlgebra
eigval2 = []
for k in keys(K)
    Mval = value.([
        y[ (if i == 0 sparse([1],[1],[0],2n_bus-1,1) 
            else sparse([i],[1],[1],2n_bus-1,1) end +
            if j == 0 sparse([1],[1],[0],2n_bus-1,1) 
            else sparse([j],[1],[1],2n_bus-1,1) end 
        )]
        for i in [K[k]; 0], j in [K[k]; 0]
    ])
    global eigval2 = [eigval2; eigvals(Mval)[end-1] ]
    #println(eigvals(Mval))
end 
println(case," ",baseMVA*objective_value(model)," ",solve_time(model)," ",maximum(eigval2))