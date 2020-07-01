function filterMultipoles(M::Vector{poles_t})
    # sort M
    sort!(M, by=x->length(x.mem), rev=true)

    flag = falses(length(M))
	numpole = length(M)

    for x=numpole:-1:2
        for i=x-1:-1:1
            if issubset(M[x].mem, M[i].mem)
                flag[x] = true
                break
            end
        end
		# (numpole - x) % 10000 == 0 && (println("\t\tCompleted ", numpole - x, " / $numpole"))
    end

    deleteat!(M, findall(flag))

    return nothing
end
