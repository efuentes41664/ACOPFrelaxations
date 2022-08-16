# opf
@variable(model, pg[1:n_bus] )
@variable(model, qg[1:n_bus] )
@variable(model, pf[1:n_branch] )
@variable(model, qf[1:n_branch] )
@variable(model, pt[1:n_branch] )
@variable(model, qt[1:n_branch] )

for k = 1:n_bus

    p = @expression(model, 0.0); q = @expression(model, 0.0)
    for l = 1:length(from[k])
        p = @expression(model, p + pf[ from[k][l] ])
        q = @expression(model, q + qf[ from[k][l] ])
    end
    for l = 1:length(to[k])
        p = @expression(model, p + pt[ to[k][l] ])
        q = @expression(model, q + qt[ to[k][l] ])
    end

    V2 = @expression(model, 0.0 )
    if k==1
        r = sparse([1],[1],[2],2n_bus-1,1)
        V2 = @expression(model, y[r] )
    else
        r1 = sparse([k],[1],[2],2n_bus-1,1)
        r2 = sparse([k+n_bus-1],[1],[2],2n_bus-1,1)

        V2 = @expression(model, y[r1]+y[r2] )
    end

    if shunt[k]
        @constraint(model, pg[k]-pd[k]-gs[k]*V2 == p )
        @constraint(model, qg[k]-qd[k]+bs[k]*V2  == q )
    else
        @constraint(model, pg[k]-pd[k] == p )
        @constraint(model, qg[k]-qd[k] == q )
    end
    @constraint(model, pmin[k] <= pg[k] <= pmax[k] )
    @constraint(model, qmin[k] <= qg[k] <= qmax[k] )
    @constraint(model, vmin[k]^2 <= V2 <= vmax[k]^2 )

end

for l = 1:n_branch


    if flowLimits[l]
        @constraint(model,
            pf[l]^2+qf[l]^2<=Sl[l]^2
        )
        @constraint(model,
            pt[l]^2+qt[l]^2<=Sl[l]^2
        )
    end

    k = network_data["branch"][string(l)]["f_bus"]
    m = network_data["branch"][string(l)]["t_bus"]

    if k==1 || m==1
        if k==1
            r1 = sparse([k],[1],[2],2n_bus-1,1)
            r3 = sparse([m],[1],[2],2n_bus-1,1)
            r4 = sparse([m+n_bus-1],[1],[2],2n_bus-1,1)
            r5 = sparse([k,m],[1,1],[1,1],2n_bus-1,1)
            r7 = sparse([k,m+n_bus-1],[1,1],[1,1],2n_bus-1,1)

            @constraint(model, pf[l] ==
                  gl[l]*(y[r1])/( tap[l]^2  )
                 -gl[l]*(y[r5])/tap[l]
                 +bl[l]*(y[r7])/tap[l]
            )
            @constraint(model, pt[l] ==
                   gl[l]*(y[r3]+y[r4])
                  -gl[l]*(y[r5])/tap[l]
                  -bl[l]*(y[r7])/tap[l]
            )
            @constraint(model, qf[l] ==
                 -(bl[l]+bls[l])*(y[r1])/(tap[l]^2 )
                  +bl[l]*(y[r5])/tap[l]
                  +gl[l]*(y[r7])/tap[l]
            )
            @constraint(model, qt[l] ==
                 -(bl[l]+bls[l])*(y[r3]+y[r4])
                  +bl[l]*(y[r5])/tap[l]
                  +gl[l]*(-y[r7])/tap[l]
            )
        else
            r1 = sparse([k],[1],[2],2n_bus-1,1)
            r2 = sparse([k+n_bus-1],[1],[2],2n_bus-1,1)
            r3 = sparse([m],[1],[2],2n_bus-1,1)
            r5 = sparse([k,m],[1,1],[1,1],2n_bus-1,1)
            r8 = sparse([k+n_bus-1,m],[1,1],[1,1],2n_bus-1,1)

            @constraint(model, pf[l] ==
                  gl[l]*(y[r1]+y[r2])/( tap[l]^2  )
                 -gl[l]*(y[r5])/tap[l]
                 +bl[l]*(-y[r8])/tap[l]
            )
            @constraint(model, pt[l] ==
                   gl[l]*(y[r3])
                  -gl[l]*(y[r5])/tap[l]
                  -bl[l]*(-y[r8])/tap[l]
            )
            @constraint(model, qf[l] ==
                 -(bl[l]+bls[l])*(y[r1]+y[r2])/(tap[l]^2 )
                  +bl[l]*(y[r5])/tap[l]
                  +gl[l]*(-y[r8])/tap[l]
            )
            @constraint(model, qt[l] ==
                 -(bl[l]+bls[l])*(y[r3])
                  +bl[l]*(y[r5])/tap[l]
                  +gl[l]*(y[r8])/tap[l]
            )
        end
    else
        r1 = sparse([k],[1],[2],2n_bus-1,1)
        r2 = sparse([k+n_bus-1],[1],[2],2n_bus-1,1)
        r3 = sparse([m],[1],[2],2n_bus-1,1)
        r4 = sparse([m+n_bus-1],[1],[2],2n_bus-1,1)
        r5 = sparse([k,m],[1,1],[1,1],2n_bus-1,1)
        r6 = sparse([k+n_bus-1,m+n_bus-1],[1,1],[1,1],2n_bus-1,1)
        r7 = sparse([k,m+n_bus-1],[1,1],[1,1],2n_bus-1,1)
        r8 = sparse([k+n_bus-1,m],[1,1],[1,1],2n_bus-1,1)

        @constraint(model, pf[l] ==
              gl[l]*(y[r1]+y[r2])/( tap[l]^2  )
             -gl[l]*(y[r5]+y[r6])/tap[l]
             +bl[l]*(y[r7]-y[r8])/tap[l]
        )
        @constraint(model, pt[l] ==
               gl[l]*(y[r3]+y[r4])
              -gl[l]*(y[r5]+y[r6])/tap[l]
              -bl[l]*(y[r7]-y[r8])/tap[l]
        )
        @constraint(model, qf[l] ==
             -(bl[l]+bls[l])*(y[r1]+y[r2])/(tap[l]^2 )
              +bl[l]*(y[r5]+y[r6])/tap[l]
              +gl[l]*(y[r7]-y[r8])/tap[l]
        )
        @constraint(model, qt[l] ==
             -(bl[l]+bls[l])*(y[r3]+y[r4])
              +bl[l]*(y[r5]+y[r6])/tap[l]
              +gl[l]*(-y[r7]+y[r8])/tap[l]
        )
    end
end

obj = @expression(model, 0.0 )
for g in keys( network_data["gen"] )

    k = network_data["gen"][g]["gen_bus"]

    if network_data["gen"][g]["ncost"] == 3
        c2 = network_data["gen"][g]["cost"][1]
        c1 = network_data["gen"][g]["cost"][2]
        c0 = network_data["gen"][g]["cost"][3]
        global obj = @expression(model,obj+c0+c1*pg[k]+c2*pg[k]^2)
    elseif network_data["gen"][g]["ncost"] == 2
        c1 = network_data["gen"][g]["cost"][1]
        c0 = network_data["gen"][g]["cost"][2]
        global obj = @expression(model, obj + c1*pg[k] + c0 )
    end

end

@objective(model, Min, obj/baseMVA )
# @objective(model, Min, obj )
