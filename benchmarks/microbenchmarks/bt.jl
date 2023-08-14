
localARGS = ARGS
num_bits = parse(Int64, localARGS[1])
nbpow = 2^num_bits

a = [1/nbpow for _ in 1:nbpow]
b = [1/nbpow for _ in 1:nbpow]

less_pr(a :: Vector{Float64}, b :: Vector{Float64}) = begin
	res = [0.0, 0.0]
	for i in 1:nbpow
		for j in 1:nbpow
			v = (i < j) ? 2 : 1
			res[v] += a[i] * b[j]
		end
	end
	return res
end

eq_pr(a :: Vector{Float64}, b :: Vector{Float64}) = begin
	res = [0.0, 0.0]
	for i in 1:nbpow
		for j in 1:nbpow
			v = (i == j) ? 2 : 1
			res[v] += a[i] * b[j]
		end
	end
	return res
end

add_exp(a :: Vector{Float64}, b :: Vector{Float64}) = begin
	res = 0.0
	for i in 1:nbpow
		ip = i - 1
		for j in 1:nbpow
			jp = j - 1
			v = ip + jp
			res += a[i] * b[j] * v
		end
	end
	return res
end

#~begin less
println(less_pr(a, b))
#~end

#~begin equals
println(eq_pr(a, b))
#~end

#~begin sum
println(add_exp(a, b))
#~end