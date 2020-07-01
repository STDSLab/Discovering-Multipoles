using Combinatorics
include("datatype.jl")
function getMultipoles(corMat::Array{F, 2}, cans::Vector{Vector{I}}, delta::F, sigma::F) where {F<:AbstractFloat,I<:Signed}
    # initialize a nested array to store multipoles
    M = Vector{poles_t}()
    for myset in cans
        dependence, gain = getLinearCoefs(corMat, myset)

        if dependence >= sigma  # check the candidate
            if gain >= delta
                push!(M, poles_t(dependence, gain, myset))
            else # check subsets
                upperbound = Int(floor(1 + 1/delta))
                sublen = minimum([length(myset) - 1, upperbound])
                while sublen >= 3 #&& sublen <= upperbound
                    for x in combinations(myset, sublen)
                        dependence, gain = getLinearCoefs(corMat, x)
                        dependence >= sigma && gain >= delta && (push!(M, poles_t(dependence, gain, x)))
                    end
                    sublen -= 1
                end
            end
        end
    end
    return M
end
