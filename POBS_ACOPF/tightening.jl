# tightening of 1.5 ord

# first bus
id1 = sparse([1],[1],[1],2n_bus-1,1)
@constraint(model,vmin[1]<=y[id1]<=vmax[1])
@constraint(model, 
    y[2id1]-vmax[1]^2<=( (vmax[1]^2-vmin[1]^2)/(vmax[1]-vmin[1]) )*(y[id1]-vmax[1]) 
)


# voltage bounds
vb = zeros(2n_bus-1,2)
vb[1,:] = [vmin[1] vmax[1]]
for i = 2:n_bus
    vb[i,:] = [-vmax[i] vmax[i]]
    vb[i+n_bus-1,:] = [-vmax[i] vmax[i]]
end


bb = 1:n_bus
if SD == 1
    bb = []
end 

# (upper_bound-var)[nb[i,j]]>=0
@constraint(model, 
    [ ng in bb, v = 1:length(nb[ng]) ],
    [
        (
        vb[nb[ng][v],2]*y[ (
                    if i == 0 sparse([1],[1],[0],2n_bus-1,1)
                    else sparse([i],[1],[1],2n_bus-1,1) end +
                    if j == 0 sparse([1],[1],[0],2n_bus-1,1)
                    else sparse([j],[1],[1],2n_bus-1,1) end
                  )] 
        -y[ (
            if i == 0 sparse([1],[1],[0],2n_bus-1,1)
            else sparse([i],[1],[1],2n_bus-1,1) end +
            if j == 0 sparse([1],[1],[0],2n_bus-1,1)
            else sparse([j],[1],[1],2n_bus-1,1) end
           + sparse([nb[ng][v]],[1],[1],2n_bus-1,1) 
           )]
        )
        for i in [nb[ng]; 0], j in [nb[ng]; 0]
    ]
    in PSDCone()
)

# (var-lower_bound)[nb[i,j]]>=0
@constraint(model, 
    [ ng in bb, v = 1:length(nb[ng]) ],
    [
        (
        y[ (
            if i == 0 sparse([1],[1],[0],2n_bus-1,1)
            else sparse([i],[1],[1],2n_bus-1,1) end +
            if j == 0 sparse([1],[1],[0],2n_bus-1,1)
            else sparse([j],[1],[1],2n_bus-1,1) end
            + sparse([nb[ng][v]],[1],[1],2n_bus-1,1) 
            )]
        -vb[nb[ng][v],1]*y[ (
                    if i == 0 sparse([1],[1],[0],2n_bus-1,1)
                    else sparse([i],[1],[1],2n_bus-1,1) end +
                    if j == 0 sparse([1],[1],[0],2n_bus-1,1)
                    else sparse([j],[1],[1],2n_bus-1,1) end
                  )] 
        )
        for i in [nb[ng]; 0], j in [nb[ng]; 0]
    ]
    in PSDCone()
)

#  (upper_bound-var)g(b_i)>=0
#  (var-lower_bound)g(b_i)>=0
for b in bb

    if gen[b]
        @constraint(model,
            [ g=1:6, v=1:length(nb[b]) ],
            (vb[nb[b][v],2]*sum( busTable[b][g,h]*y[list2[h]] for h = 1:length(list2) )
               -sum( busTable[b][g,h]*y[list2[h]+sparse([nb[b][v]],[1],[1],2n_bus-1,1)] 
                  for h = 1:length(list2) if busTable[b][g,h]!=0 )
            )
            >= 0
        )
        @constraint(model,
            [ g=1:6, v=1:length(nb[b]) ],
            (
            sum( busTable[b][g,h]*y[list2[h]+sparse([nb[b][v]],[1],[1],2n_bus-1,1)] 
                  for h = 1:length(list2) if busTable[b][g,h]!=0 )
            -vb[nb[b][v],1]*sum( busTable[b][g,h]*y[list2[h]] for h = 1:length(list2) )  
            )
            >= 0
        )
        
    else 
        @constraint(model,
            [ g=1:2, v=1:length(nb[b]) ],
            (vb[nb[b][v],2]*sum( busTable[b][g,h]*y[list2[h]] for h = 1:length(list2) )
               -sum( busTable[b][g,h]*y[list2[h]+sparse([nb[b][v]],[1],[1],2n_bus-1,1)] 
                  for h = 1:length(list2) if busTable[b][g,h]!=0 )
            )
            >= 0
        )
        @constraint(model,
            [ g=1:2, v=1:length(nb[b]) ],
            (
            sum( busTable[b][g,h]*y[list2[h]+sparse([nb[b][v]],[1],[1],2n_bus-1,1)] 
                  for h = 1:length(list2) if busTable[b][g,h]!=0 )
            -vb[nb[b][v],1]*sum( busTable[b][g,h]*y[list2[h]] for h = 1:length(list2) )  
            )
            >= 0
        )
        @constraint(model,
            [ g=3:4, v=1:length(nb[b]) ],
            (
            sum( busTable[b][g,h]*y[list2[h]+sparse([nb[b][v]],[1],[1],2n_bus-1,1)] 
                  for h = 1:length(list2) if busTable[b][g,h]!=0 )
            )
            == 0
        )

    end
end 