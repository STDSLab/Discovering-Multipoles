using Combinatorics, LinearAlgebra
function getLinearCoefs(corMat::Array{F, 2}, myset::Vector{I}) where {F<:AbstractFloat, I<:Signed}
    size(myset, 1) <= 2 && (return F(0), F(0))

    # get set size
    set_len = length(myset)
    # get cor matrix of the clique
    set_cor::Array{F, 2} = reshape([corMat[x,y] for x in myset for y in myset], set_len, :)

    dependence::F = 1 - minimum(eigvals(set_cor))
    subdependence = Vector{F}()

    # temp_cor = zeros(F, set_len - 1, set_len - 1)
    for i in combinations(myset, set_len-1)
        temp_cor = reshape([corMat[x,y] for x in i for y in i], set_len-1, set_len-1)
        push!(subdependence, F(1 - minimum(eigvals(temp_cor))))
    end

    return dependence, dependence - maximum(subdependence)

end
