struct dualpoles_t{F<:AbstractFloat, I<:Signed}
	dept1::F
	dept2::F
	gain1::F
	gain2::F
	mem::Vector{I}
end

struct poles_t{F<:AbstractFloat,I<:Signed}
    dept::F # dependence
    gain::F	# gain
    mem::Vector{I} # indices of member timeseries
end
