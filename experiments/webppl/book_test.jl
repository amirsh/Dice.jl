using BenchmarkTools

n = 10
curValue = [1/n for _ in 1:n]
tgtValue = [1/n for _ in 1:n]

sub_pr(a :: Vector{Float64}, b :: Vector{Float64}) = begin
	M = length(b)
	N = length(a) + length(b) - 1
	res = [0.0 for _ in 1:N]
	for i in 1:length(a)
		for j in 1:length(b)
			v = i - j + M
			res[v] += a[i] * b[j]
		end
	end
	return res
end

sub_cmp_pr(a :: Vector{Float64}, b :: Vector{Float64}) = begin
	M = length(b)
	N = length(a) + length(b) - 1
	res = [0.0 for _ in 1:(N + 21 - 1)]
	for i in 1:length(a)
		for j in 1:length(b)
			v_delta = i - j + M
			p_delta = a[i] * b[j]
			if(v_delta < 5 + M && v_delta > -5 + M)
				# for d in 1:(N + 21)
				# 	res[d] += p_delta
				# end
				# res[v_delta+11] += p_delta
				res[20] += p_delta
			else
				for di in 1:21
					res[v_delta+di-1] += p_delta * 1 / 21
				end
			end
			# res[v_delta] += a[i] * b[j]
		end
	end
	return res
end

delta = sub_pr(curValue, tgtValue)
d = sub_cmp_pr(curValue, tgtValue)

# println(delta)
println(d)