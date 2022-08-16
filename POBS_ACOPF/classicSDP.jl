
# classic SDP relaxation

@constraint(model,
    [ k in 1:length(K) ],
    [
        y[ (if i == 0 sparse([1],[1],[0],2n_bus-1,1) 
            else sparse([i],[1],[1],2n_bus-1,1) end +
            if j == 0 sparse([1],[1],[0],2n_bus-1,1) 
            else sparse([j],[1],[1],2n_bus-1,1) end 
        )]
        for i in [K[k]; 0], j in [K[k]; 0]
    ]
    in PSDCone()
)

