using LinearAlgebra
using AMD

# generate sparsity matrix
sparsity = spzeros(Int32,2*n_bus-1,2*n_bus-1)
for k = 1:n_bus
    sparsity[ nb[k] , nb[k] ] .= 1
end


function findMaxCliques(sparsity)
    # chordal extension by cholesky factorization
    n = size(sparsity,1)
    m = eigvals(Matrix(sparsity))[1]
    if m<1e-4
        sparsity = sparsity + Matrix(1.0I,n,n)*(-m+1e-3)
    end
    per = amd(sparse(sparsity))
    c = cholesky(Matrix(sparsity[per,per]),check=true)
    G = spzeros(Int32,n,n)
    r = findnz(sparse(Matrix(c.L)))
    for i = 1:length(r[1])
        i1 = per[r[1][i]]; i2 = per[r[2][i]]
        G[i1,i2]=G[i2,i1]=1
    end
    for i = 1:n G[i,i]=0 end
    G = dropzeros(G)

    # compute maximal cliques
    n = size(G,1)
    Gnum = []; Gelim=1:n
    l = 0; labels = spzeros(Int64,n,1)
    K = Dict(); k_cnt = 0

    for i = n:-1:1
        xi = findnz(labels.==maximum(labels))[1][1]
        if i!=n && labels[xi]<=l
            clique = [Gnum[end]]
            for c in findnz(sparse(G[Gnum[end],:]))[1]
                if sum(Gnum.==c)==1
                    clique = [clique; c]
                end
            end
            k_cnt+=1
            K[k_cnt] = clique
        end
        l = labels[xi]

        for c in findnz(sparse(G[xi,:]))[1]
            if sum(Gelim.==c)==1
                labels[c] += 1
            end
        end
        #elim and num
        labels[xi]=-50000
        Gelim = Gelim[Gelim.!=xi]
        Gnum = [Gnum; xi]
    end
    clique = [Gnum[end]]
    for c in findnz(sparse(G[Gnum[end],:]))[1]
        clique = [clique; c]
    end
    k_cnt+=1
    K[k_cnt] = clique
    return K
end

K = findMaxCliques(sparsity)