using LightGraphs

function findCandidates(corMat::Array{F, 2}, miu::F) where {F<:AbstractFloat}
	# number of timeseries
	num_var = size(corMat, 1)

    # initialize the combined graph (double)
    G = Graph(num_var*2)

    # add neg corr edges

    for i=1:num_var-1
        for j=i+1:num_var
            if corMat[i,j] < miu # neg on each half
                add_edge!(G, i, j)
                add_edge!(G, i + num_var, j + num_var)
            end
        end
    end

    # add positive edges
    for i=1:num_var
        for j=1:num_var
            if corMat[i,j] >= -miu
                add_edge!(G, i, j + num_var)
				add_edge!(G, i + num_var, j)
            end
        end
    end


    # find all maximal cliques of length > 2
    cliques = [convert(Vector{Int32}, x) for x in maximal_cliques(G) if length(x) > 2]

	G = []

    numcliques = length(cliques)

    canFlag = falses(numcliques)

    for i=1:numcliques
        clique = cliques[i]
        minbefore = minimum(clique)
        clique[clique .> num_var] .-= num_var
        minafter = minimum(clique)
        minbefore == minafter ? canFlag[i] = true : canFlag[i] = false
    end

    deleteat!(cliques, findall(canFlag))

	canFlag = []

    return cliques
end
