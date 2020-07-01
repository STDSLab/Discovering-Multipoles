include("findCandidates.jl")
include("datatype.jl")
include("filterMultipoles.jl")
include("getMultipoles.jl")
include("getLinearCoefs.jl")


function COMETserial(corMat::Array{F,2}, delta::F, sigma::F) where {F<:AbstractFloat}

    candidates = findCandidates(corMat, F(0))
    M = getMultipoles(corMat, candidates, delta, sigma)
    filterMultipoles(M)

    return M
end
