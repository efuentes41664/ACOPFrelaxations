using MosekTools, JuMP
model = Model(Mosek.Optimizer)

vars = Dict()

#################################
# gen all second order variables
#################################
# from the cliques
for k in keys(K)
    idx2 = [
        sparse([i],[1],[1],2n_bus-1,1)+sparse([j],[1],[1],2n_bus-1,1)
        for i in K[k] for j in K[k]
    ]
    for i in idx2 
        vars[ i ] = 0
    end 
end

list2 = Dict()
idx2pos = Dict()
list2[1] = sparse([1],[1],[0],2n_bus-1,1)
idx2pos[sparse([1],[1],[0],2n_bus-1,1)] = 1
cnt = 2
for i in keys(vars)
    list2[cnt] = i
    idx2pos[ i ] = cnt
    global cnt += 1
end

vars[sparse([1],[1],[0],2n_bus-1,1)] = 0

# third order
for k in keys(nb)
    idx3 = [
        sparse([i],[1],[1],2n_bus-1,1)+
        sparse([j],[1],[1],2n_bus-1,1)+
        sparse([h],[1],[1],2n_bus-1,1)
        for i in nb[k] for j in nb[k] for h in nb[k]
    ]
    for i in idx3 
        vars[ i ] = 0
    end 
end


# #################################
# # gen all first order variables
# #################################
for k in 1:2n_bus-1
    vars[ sparse([k],[1],[1],2n_bus-1,1) ] = 0
end 

@variable(model, y[ keys(vars) ], container=Dict)
@constraint(model, y[sparse([1],[1],[0],2n_bus-1,1)]==1 )
