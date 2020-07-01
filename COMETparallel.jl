include("findCandidates.jl")
include("datatype.jl")

@everywhere include("getMultipoles.jl")
@everywhere include("getLinearCoefs.jl")
@everywhere include("filterMultipolesParallel.jl")

function COMETparallel(corMat::Array{F,2}, delta::F, sigma::F; toprint=false) where {F<:AbstractFloat}
	# initialize a nested list to store multipoles
    M = Vector{poles_t}()
    # find all candidates
    time0 = time()
    toprint && (println("Finding candidates"))
    start_time = time()
    candidates = findCandidates(corMat, F(0))
	time1 = time()
    toprint &&  (println("\tCompleted. Number of candidates: ", length(candidates), " - Runtime: ", time1-time0))
    # find multipoles

    toprint && (println("Finding multipoles"))


    numjobs = length(candidates)

	np = nworkers()  # determine the number of processes available
    can = 1
    # function to produce the next work item from the queue.
    # in this case it's just an index.
    nextidx() = (idx=can; can+=1; idx)
    # tic()

    @sync begin
        for p=1:np
            if p != myid() || np == 1
				@async begin
	                while true
						idx = nextidx()
						idx > numjobs && (break)

	                    append!(M, remotecall_fetch(getMultipoles, p, corMat, [candidates[idx]], delta, sigma))
	                end
				end
            end
        end
    end
	time2 = time()
	toprint &&
    (println("\tComplete - Elapsed time: ", time2 - time1);
    println("Removing duplicates\n\tStart"))
    start_time = time()
    # FIND ALL DUPLICATES AND NON-MAXIMA
    # sort the list in reserve by size of elements
    sort!(M, by = x -> length(x.mem), rev = true)

    toprint && (println("\tNumber of unfiltered multipoles: ", length(M)))
    # send all candidates to processes
    @everywhere @eval (M=$M)

    # initialize an array to store a flag for each candidate
    # value = false if it is unique and not to be removed
    canFlag = falses(length(M))
    can = 1
    numjobs = length(M)

    @sync begin
        for p=1:np
            if p != myid() || np == 1
                @async begin
                    while true
                        idx = nextidx()
                        if idx > numjobs
                            break
                        end
                        canFlag[numjobs + 1 - idx] = remotecall_fetch(filterMultipolesParallel, p, Int32(numjobs + 1 - idx))
                    end
                end
            end
        end
    end
    # remove duplicates and non-maximals
    deleteat!(M, findall(x->x==true, canFlag))
    toprint && (println("\tNumber of multipoles: ", length(M), " - Runtime: ", time() - time2);
    println("\tComplete - Elapsed time: ", time() - time0))
    return M
end
