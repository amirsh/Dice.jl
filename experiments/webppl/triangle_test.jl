
# localARGS = ARGS
# n = parse(Int64, localARGS[1])
n = 101
nover2 = 52

a = [1/n for _ in 1:n]
b = [1/n for _ in 1:n]
c = [1/n for _ in 1:n]

half = [(i == nover2) ? 1.0 : 0.0 for i in 1:n]

less_pr(a :: Vector{Float64}, b :: Vector{Float64}) = begin
	res = [0.0, 0.0]
	for i in 1:length(a)
		for j in 1:length(b)
			v = (i < j) ? 2 : 1
			res[v] += a[i] * b[j]
		end
	end
	return res
end

less_add_pr(a1 :: Vector{Float64}, b1 :: Vector{Float64}, a2 :: Vector{Float64}, b2 :: Vector{Float64}) = begin
	res = [0.0, 0.0]
	for i1 in 1:length(a1)
		for j1 in 1:length(b1)
			k1 = i1 + j1 - 1
			for i2 in 1:length(a2)
				for j2 in 1:length(b2)
					k2 = i2 + j2 - 1
					v = (k1 < k2) ? 2 : 1
					res[v] += a1[i1] * b1[j1] * a2[i2] * b2[j2]
				end
			end
		end
	end
	return res
end

less_add_or2_pr(a :: Vector{Float64}, b :: Vector{Float64}, c :: Vector{Float64}, d :: Vector{Float64}) = begin
	res = [0.0, 0.0]
	for i in 1:length(a)
		for j in 1:length(b)
			for ic in 1:length(c)
				for jd in 1:length(d)
					iab = i + j - 1
					icd = ic + jd - 1
					iac = i + ic - 1
					ibd = j + jd - 1
					v = (iab < icd || iac < ibd) ? 2 : 1
					res[v] += a[i] * b[j] * c[ic] * d[jd]
				end
			end
		end
	end
	return res
end

less_add_or2_pr(a :: Vector{Float64}, b :: Vector{Float64}, c :: Vector{Float64}, d :: Vector{Float64}) = begin
	res = [0.0, 0.0]
	for i in 1:length(a)
		for j in 1:length(b)
			for ic in 1:length(c)
				for jd in 1:length(d)
					iab = i + j - 1
					icd = ic + jd - 1
					iac = i + ic - 1
					ibd = j + jd - 1
					v = (iab < icd || iac < ibd) ? 2 : 1
					res[v] += a[i] * b[j] * c[ic] * d[jd]
				end
			end
		end
	end
	return res
end

less_add_or3_pr(a :: Vector{Float64}, b :: Vector{Float64}, c :: Vector{Float64}, d :: Vector{Float64}) = begin
	res = [0.0, 0.0]
	for i in 1:length(a)
		for j in 1:length(b)
			for ic in 1:length(c)
				for jd in 1:length(d)
					iab = i + j - 1
					icd = ic + jd - 1
					iac = i + ic - 1
					ibd = j + jd - 1
					iad = i + jd - 1
					ibc = j + ic - 1
					v = (iab < icd || iac < ibd || ibc < iad) ? 2 : 1
					res[v] += a[i] * b[j] * c[ic] * d[jd]
				end
			end
		end
	end
	return res
end

add_pr(a :: Vector{Float64}, b :: Vector{Float64}) = begin
	N = length(a) + length(b) - 1
	res = [0.0 for _ in 1:N]
	for i in 1:length(a)
		ip = i - 1
		for j in 1:length(b)
			jp = j - 1
			v = ip + jp + 1
			res[v] += a[i] * b[j]
		end
	end
	return res
end

or_pr(a :: Vector{Float64}, b :: Vector{Float64}) = begin
	res = [0.0, 0.0]
	res[1] += a[1] * b[1]
	res[2] += a[1] * b[2]
	res[2] += a[2] * b[1]
	res[2] += a[2] * b[2]
	return res
end

t1 = less_pr(a, half)
t2 = less_pr(b, half)
t3 = less_pr(c, half)
t4 = or_pr(t1, t2)
t5 = or_pr(t4, t3)
println(t5)
ab = add_pr(a, b)
ac = add_pr(a, c)
bc = add_pr(b, c)
ah = add_pr(a, half)
bh = add_pr(b, half)
ch = add_pr(c, half)
t11 = less_pr(ab, ch)
t12 = less_pr(ac, bh)
t13 = less_pr(bc, ah)
t14 = or_pr(t11, t12)
t15 = or_pr(t14, t13)
t20 = or_pr(t5, t15)
println(t11) # check3_1
println(less_add_pr(a, b, c, half)) # check3_1
println(t14) # check3_2 # wrong
println(less_add_or2_pr(a, b, c, half)) # check3_2 # correct
println(t15) # check3 # wrong
println(less_add_or3_pr(a, b, c, half)) # check3 # correct
println(t20)
