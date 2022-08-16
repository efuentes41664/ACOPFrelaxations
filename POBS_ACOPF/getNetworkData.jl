using SparseArrays
import PowerModels.parse_file, PowerModels.silence
silence()
network_data = parse_file("./testcases/"*case_file)

baseMVA = network_data["baseMVA"]
n_bus = length(network_data["bus"])
n_gen = length(network_data["gen"])
n_branch = length(network_data["branch"])
n_shunt = length(network_data["shunt"])

pd = spzeros(n_bus); qd = spzeros(n_bus)
for key in keys(network_data["load"])
    pd[ network_data["load"][key]["load_bus"] ] = network_data["load"][key]["pd"]
    qd[ network_data["load"][key]["load_bus"] ] = network_data["load"][key]["qd"]
end
bs = spzeros(n_bus); gs = spzeros(n_bus)
shunt = spzeros(Bool,n_bus)
for key in keys(network_data["shunt"])
    gs[ network_data["shunt"][key]["shunt_bus"] ] = network_data["shunt"][key]["gs"]
    bs[ network_data["shunt"][key]["shunt_bus"] ] = network_data["shunt"][key]["bs"]
    shunt[ network_data["shunt"][key]["shunt_bus"] ] = 1
end

vmin = zeros(n_bus); vmax = zeros(n_bus)
for key in keys(network_data["bus"])
    k = network_data["bus"][key]["index"]
    vmin[k] = network_data["bus"][key]["vmin"]
    vmax[k] = network_data["bus"][key]["vmax"]
end

##
gl = spzeros(n_branch); bl = spzeros(n_branch); bls = spzeros(n_branch)
tap = zeros(n_branch)
transf = spzeros(Bool,n_branch)
from = Dict(); to = Dict()
flowLimits = spzeros(Bool,n_branch)
Sl = spzeros(n_branch)
for k = 1:n_bus
    from[k] = zeros(Int32,0); to[k] = zeros(Int32,0)
end
for key in keys(network_data["branch"])
    l = parse(Int32,key)
    r  = network_data["branch"][key]["br_r"]
    # r = max(network_data["branch"][key]["br_r"],1e-4)
    x = network_data["branch"][key]["br_x"]
    gl[l] = real(1.0/(r+x*im))
    bl[l] = imag(1.0/(r+x*im))
    bls[l] = network_data["branch"][key]["b_fr"]
    tap[l] = network_data["branch"][key]["tap"]
    transf[l] = network_data["branch"][key]["transformer"]
    k = network_data["branch"][key]["f_bus"]
    m = network_data["branch"][key]["t_bus"]
    append!(from[k], l)
    append!(to[m], l)
    if haskey(network_data["branch"][key],"rate_a")
        Sl[l] = network_data["branch"][key]["rate_a"]
        flowLimits[l] = 1
    end
end
n_tap = sum(transf)

gen = zeros(Bool,n_bus)
pmax = spzeros(n_bus); pmin = spzeros(n_bus)
qmax = spzeros(n_bus); qmin = spzeros(n_bus)
isQuad = zeros(Bool,n_bus)
isLin = zeros(Bool,n_bus)
cost = Dict()
for key in keys(network_data["gen"])
    k = network_data["gen"][key]["gen_bus"]
    pmax[ k ] = network_data["gen"][key]["pmax"]
    pmin[ k ] = network_data["gen"][key]["pmin"]
    qmax[ k ] = network_data["gen"][key]["qmax"]
    qmin[ k ] = network_data["gen"][key]["qmin"]
    if network_data["gen"][key]["ncost"]==3
        isQuad[k] = 1
    else
        isLin[k] = 1
    end
    cost[k]=network_data["gen"][key]["cost"]/baseMVA
    gen[ k ] = 1

end


# neighborhoods
nb = Dict(); for b = 2:n_bus nb[b]=[b;b+n_bus-1] end; nb[1] = [1]
for bus = 1:n_bus
    for l = 1:length(from[bus])
        m = network_data["branch"][string(from[bus][l])]["t_bus"]
        if m==1
            nb[bus] = [nb[bus]; m]
        else
            nb[bus] = [nb[bus]; m; m+n_bus-1]
        end
    end
    for l = 1:length(to[bus])
        m = network_data["branch"][string(to[bus][l])]["f_bus"]
        if m==1
            nb[bus] = [nb[bus]; m]
        else
            nb[bus] = [nb[bus]; m; m+n_bus-1]
        end
    end
end
