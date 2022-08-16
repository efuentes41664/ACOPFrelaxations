function addShunt(bus,pg,qg)
    # add shunt

    if bus==1
        kd = sparse([1],[1],[1],2n_bus-1,1)

        pg[ idx2pos[2kd] ] += gs[bus]
        qg[ idx2pos[2kd] ] += -bs[bus]
    else

        kd = sparse([bus],[1],[1],2n_bus-1,1)
        kq = sparse([bus+n_bus-1],[1],[1],2n_bus-1,1)

        pg[ idx2pos[2kd] ] += gs[bus]
        pg[ idx2pos[2kq] ] += gs[bus]
        qg[ idx2pos[2kd] ] += -bs[bus]
        qg[ idx2pos[2kq] ] += -bs[bus]
    end

    return pg,qg
end
