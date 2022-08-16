include("addShunt.jl")
include("addFrom.jl")
include("addTo.jl")


nc = length(list2)
ineq = spzeros(0,nc)
eq = spzeros(0,nc)
n2 = 2n_bus-1
################################################################################
# voltage magnitude
################################################################################

for bus = 1:n_bus
    if bus == 1
    # bus1
    kd2 = sparse([1],[1],[2],2n_bus-1,1)
    coeff = spzeros(1,nc)
    coeff[1] = vmax[1]^2; coeff[idx2pos[kd2]]=-1
    global ineq = [ineq; coeff];
    coeff[1] = -vmin[1]^2; coeff[idx2pos[kd2]]=1
    global ineq = [ineq; coeff];
    else
    # other buses
    kd2 = sparse([bus],[1],[2],2n_bus-1,1)
    kq2 = sparse([bus+n_bus-1],[1],[2],2n_bus-1,1)
    coeff = spzeros(1,nc)
    coeff[1] = vmax[bus]^2; coeff[idx2pos[kd2]]=-1; coeff[idx2pos[kq2]]=-1
    global ineq = [ineq; coeff];
    coeff[1] = -vmin[bus]^2; coeff[idx2pos[kd2]]=1; coeff[idx2pos[kq2]]=1
    global ineq = [ineq; coeff];
    end
end
################################################################################


################################################################################
# pg qg
################################################################################
for bus =1:n_bus

    local pg = spzeros(1,nc); local qg = spzeros(1,nc)
    pg[1] = pd[bus]; qg[1] = qd[bus]

    pg, qg = addFrom( from[bus], pg, qg )
    pg, qg = addTo( to[bus], pg, qg )
    if shunt[bus]
        pg, qg = addShunt( bus, pg, qg )
    end

    if gen[bus]

        coeff = copy(-pg); coeff[1] += pmax[bus];
        global ineq = [ineq; coeff]
        coeff = copy(pg); coeff[1] += -pmin[bus];
        global ineq = [ineq; coeff]

        coeff = copy(-qg); coeff[1] += qmax[bus];
        global ineq = [ineq; coeff]
        coeff = copy(qg); coeff[1] += -qmin[bus];
        global ineq = [ineq; coeff]

    else
        global eq = [eq; pg; qg]
    end

end

######################################################################"
busTable = Dict()
ic = 0
ec = 0
for bus = 1:n_bus
    if gen[bus]
        busTable[bus] = zeros(6,nc)
        busTable[bus][1:2,:] = ineq[2bus-1:2bus,:]
        busTable[bus][3:6,:] = ineq[2n_bus+4ic+1: 2n_bus+4ic+4,:]
        global ic += 1
    else
        busTable[bus] = zeros(4,nc)
        busTable[bus][1:2,:] = ineq[2bus-1:2bus,:]
        busTable[bus][3:4,:] = eq[2ec+1:2ec+2,:]
        global ec += 1
    end
    #################################################################
end
