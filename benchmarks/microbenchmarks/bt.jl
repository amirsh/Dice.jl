using BenchmarkTools
localARGS = ARGS
num_bits = parse(Int64, localARGS[1])
nbpow = 2^num_bits

a = [1/nbpow for _ in 1:nbpow]
b = [1/nbpow for _ in 1:nbpow]

less_pr(a :: Vector{Float64}, b :: Vector{Float64}) = begin
	res = [0.0, 0.0]
	for i in 1:nbpow
		ai = a[i]
		for j in 1:nbpow
			v = (i < j) ? 2 : 1
			res[v] += ai * b[j]
		end
	end
	return res
end

less_pr_d2(a :: Vector{Float64}, b :: Vector{Float64}) = begin
	res = [0.0, 0.0]
	rng = 2^(num_bits-1)
	for i in 1:rng
		i0 = i*2-1
		i1 = i*2
		ai0 = a[i0]
		ai1 = a[i1]
		for j in 1:rng
			j0 = j*2-1
			j1 = j*2
			# highbitsless = (i < j)
			# highbitsleq = (i <= j)
			# v0 = (highbitsless) ? 2 : 1
			# v1 = (highbitsleq) ? 2 : 1
			# v3 = (highbitsless) ? 2 : 1
			v0 = (i0 < j0) ? 2 : 1
			v1 = (i0 < j1) ? 2 : 1
			# v3 = (i1 < j0) ? 2 : 1 # not needed, the same as v0
			# v2 = (i1 < j1) ? 2 : 1 # not needed, the same as v0
			# res[v0] += ai0 * b[j0]
			# res[v2] += ai1 * b[j1]
			# res[v0] += ai1 * b[j1]
			res[v1] += ai0 * b[j1]
			# res[v0] += ai0 * (b[j0] + b[j1]) + ai1 * b[j1] # wrong
			# res[v3] += ai1 * b[j0]
			res[v0] += ai0 * b[j0] + ai1 * (b[j0] + b[j1])
		end
	end
	return res
end

less_pr_d4(a :: Vector{Float64}, b :: Vector{Float64}) = begin
	res = [0.0, 0.0]
	rng = 2^(num_bits-2)
	for i in 1:rng
		i0 = i*4-3
		i1 = i*4-2
		i2 = i*4-1
		i3 = i*4
		ai0 = a[i0]
		ai1 = a[i1]
		ai2 = a[i2]
		ai3 = a[i3]
		for j in 1:rng
			j0 = j*4-3
			j1 = j*4-2
			j2 = j*4-1
			j3 = j*4
			bj0 = b[j0]
			bj1 = b[j1]
			bj2 = b[j2]
			bj3 = b[j3]
			v0 = i0 < j0 ? 2 : 1
			v1 = i0 < j1 ? 2 : 1
			v2 = i0 < j2 ? 2 : 1
			v3 = i0 < j3 ? 2 : 1
			# res[v0] += ai0 * bj0
			# res[v1] += ai0 * bj1
			# res[v2] += ai0 * bj2
			# res[v3] += ai0 * bj3
			# res[v0] += ai1 * bj0
			# res[v0] += ai1 * bj1
			# res[v1] += ai1 * bj2
			# res[v2] += ai1 * bj3
			# res[v0] += ai2 * bj0
			# res[v0] += ai2 * bj1
			# res[v0] += ai2 * bj2
			# res[v1] += ai2 * bj3
			# res[v0] += ai3 * bj0
			# res[v0] += ai3 * bj1
			# res[v0] += ai3 * bj2
			# res[v0] += ai3 * bj3
			res[v0] += ai0 * bj0 + ai1 * (bj0 + bj1) + ai2 * (bj0 + bj1 + bj2) +
			  ai3 * (bj0 + bj1 + bj2 + bj3)
			res[v1] += ai0 * bj1 + ai1 * bj2 + ai2 * bj3
			res[v2] += ai0 * bj2 + ai1 * bj3 
			res[v3] += ai0 * bj3
		end
	end
	return res
end

less_pr_opt(a :: Vector{Float64}, b :: Vector{Float64}) = begin
	res = [0.0, 0.0]
	for i in 1:nbpow
		ai = a[i]
		tmp1 = 0.0
		for j in 1:i
			tmp1 += b[j]
		end
		tmp2 = 0.0
		for j in (i+1):nbpow
			tmp2 += b[j]
		end
		res[1] += ai * tmp1
		res[2] += ai * tmp2
	end
	return res
end

less_pr_opt2(a :: Vector{Float64}, b :: Vector{Float64}) = begin
	res = [0.0, 0.0]
	bsum = 0.0
	tmp1 = 0.0
	tmp2 = 0.0
	for j = 1:nbpow
		bsum += b[j]
	end
	tmp2 = bsum
	for i in 1:nbpow
		ai = a[i]
		tmp1 += b[i]
		tmp2 -= b[i]
		res[1] += ai * tmp1
		res[2] += ai * tmp2
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

# #~begin less
# println(less_pr(a, b))
# #~end

# #~begin less
# println(less_pr_d4(a, b))
# #~end

# #~begin less
# println(less_pr_opt2(a, b))
# #~end

# #~begin equals
# println(eq_pr(a, b))
# #~end

# #~begin sum
# println(add_exp(a, b))
# #~end

x = @benchmark less_pr(a, b)
println((median(x).time)/10^9)
x = @benchmark less_pr_d2(a, b)
println((median(x).time)/10^9)
x = @benchmark less_pr_d4(a, b)
println((median(x).time)/10^9)
x = @benchmark less_pr_opt(a, b)
println((median(x).time)/10^9)
x = @benchmark less_pr_opt2(a, b)
println((median(x).time)/10^9)