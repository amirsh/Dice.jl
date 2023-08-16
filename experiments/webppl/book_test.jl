using BenchmarkTools

# n = 10
n = 100
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

sub_cmp_pr_small(a :: Vector{Float64}, b :: Vector{Float64}) = begin
	M = length(b)
	N = length(a) + length(b) - 1
	D1 = 21
	res = [0.0 for _ in 1:(N + D1 - 1)]
	for i in 1:length(a)
		for j in 1:length(b)
			v_delta = i - j + M
			p_delta = a[i] * b[j]
			if(v_delta < 5 + M && v_delta > -5 + M)
				res[20] += p_delta
			else
				for di in 1:D1
					res[v_delta+di-1] += p_delta * 1 / D1
				end
			end
		end
	end
	return res
end

sub_cmp_pr_medium(a :: Vector{Float64}, b :: Vector{Float64}) = begin
	M = length(b)
	N = length(a) + length(b) - 1
	D1 = 21
	D2 = 101
	res = [0.0 for _ in 1:(N + D2 - 1)]
	for i in 1:length(a)
		for j in 1:length(b)
			v_delta = i - j + M
			p_delta = a[i] * b[j]
			if(v_delta < 5 + M && v_delta > -5 + M)
				res[150] += p_delta
			elseif(v_delta < 25 + M && v_delta > -25 + M)
				for di in 1:D1
					res[v_delta+40+di-1] += p_delta * 1 / D1
				end
			else
				for di in 1:D2
					res[v_delta+di-1] += p_delta * 1 / D2
				end
			end
		end
	end
	return res
end

sub_cmp_add_pr_small(a :: Vector{Float64}, b :: Vector{Float64}) = begin
	M = length(b)
	N = length(a) + length(b) - 1
	res_d = [0.0 for _ in 1:(M), _ in 1:(N + 21 - 1)]
	for i in 1:length(a)
		for j in 1:length(b)
			v_delta = i - j + M
			p_delta = a[i] * b[j]
			if(v_delta < 5 + M && v_delta > -5 + M)
				res_d[j, 20] += p_delta
			else
				for di in 1:21
					res_d[j, v_delta+di-1] += p_delta * 1 / 21
				end
			end
		end
	end
	res_c = [0.0 for _ in 1:(N + 21 - 1 + M - 1)]
	for j in 1:length(b)
		for di in 1:(N + 21 - 1)
			v_c = j + di - 1
			p_d = res_d[j, di]
			# res_c[v_c] += p_d
			if(v_c > 5 + 19)
				res_c[5 + 19] += p_d
			elseif(v_c < 1 + 19)
				res_c[1 + 19] += p_d
			else
				res_c[v_c] += p_d
			end
		end
	end
	return res_c
end

sub_cmp_add_pr_medium(a :: Vector{Float64}, b :: Vector{Float64}) = begin
	M = length(b)
	N = length(a) + length(b) - 1
	D1 = 21
	D2 = 101
	ZERO = 150
	res_d = [0.0 for _ in 1:(M), _ in 1:(N + D2 - 1)]
	for i in 1:length(a)
		for j in 1:length(b)
			v_delta = i - j + M
			p_delta = a[i] * b[j]
			if(v_delta < 5 + M && v_delta > -5 + M)
				res_d[j, ZERO] += p_delta
			elseif(v_delta < 25 + M && v_delta > -25 + M)
				for di in 1:D1
					res_d[j, v_delta+40+di-1] += p_delta * 1 / D1
				end
			else
				for di in 1:D2
					res_d[j, v_delta+di-1] += p_delta * 1 / D2
				end
			end
		end
	end
	res_c = [0.0 for _ in 1:(N + D2 - 1 + M - 1)]
	for j in 1:length(b)
		for di in 1:(N + D2 - 1)
			v_c = j + di - 1
			p_d = res_d[j, di]
			if(v_c > 50 + ZERO - 1)
				res_c[50 + ZERO - 1] += p_d
			elseif(v_c < 1 + ZERO - 1)
				res_c[1 + ZERO - 1] += p_d
			else
				res_c[v_c] += p_d
			end
		end
	end
	return res_c
end

sub_cmp_add_sub_pr_small(a :: Vector{Float64}, b :: Vector{Float64}) = begin
	A = length(a)
	M = length(b)
	N = length(a) + length(b) - 1
	res_d = [0.0 for _ in 1:A, _ in 1:(M), _ in 1:(N + 21 - 1)]
	for i in 1:length(a)
		for j in 1:length(b)
			v_delta = i - j + M
			p_delta = a[i] * b[j]
			if(v_delta < 5 + M && v_delta > -5 + M)
				res_d[i, j, 20] += p_delta
			else
				for di in 1:21
					res_d[i, j, v_delta+di-1] += p_delta * 1 / 21
				end
			end
		end
	end
	C = N + 21 - 1 + M - 1
	res_c = [0.0 for _ in 1:A, _ in 1:C]
	C_OFF = 19
	for i in 1:length(a)
		for j in 1:length(b)
			for di in 1:(N + 21 - 1)
				v_c = j + di - 1
				p_d = res_d[i, j, di]
				# res_c[v_c] += p_d
				if(v_c > 5 + C_OFF)
					res_c[i, 5 + C_OFF] += p_d
				elseif(v_c < 1 + C_OFF)
					res_c[i, 1 + C_OFF] += p_d
				else
					res_c[i, v_c] += p_d
				end
			end
		end
	end
	D = C + A - 1
	res_d2 = [0.0 for _ in 1:D]
	D_OFF = 29
	for i in 1:length(a)
		for j in 1:C
			v = i - j + C
			res_d2[v] += res_c[i, j]
		end
	end
	res = [0.0, 0.0]
	for i in 1:D
		v = (i < 5 + D_OFF && i > -5 + D_OFF) ? 2 : 1
		res[v] += res_d2[i]
	end
	return res
end

sub_cmp_add_sub_pr_medium(a :: Vector{Float64}, b :: Vector{Float64}) = begin
	A = length(a)
	M = length(b)
	N = length(a) + length(b) - 1
	res_d = [0.0 for _ in 1:A, _ in 1:(M), _ in 1:(N + 21 - 1)]
	for i in 1:length(a)
		for j in 1:length(b)
			v_delta = i - j + M
			p_delta = a[i] * b[j]
			if(v_delta < 5 + M && v_delta > -5 + M)
				res_d[i, j, 20] += p_delta
			else
				for di in 1:21
					res_d[i, j, v_delta+di-1] += p_delta * 1 / 21
				end
			end
		end
	end
	C = N + 21 - 1 + M - 1
	res_c = [0.0 for _ in 1:A, _ in 1:C]
	C_OFF = 19
	for i in 1:length(a)
		for j in 1:length(b)
			for di in 1:(N + 21 - 1)
				v_c = j + di - 1
				p_d = res_d[i, j, di]
				# res_c[v_c] += p_d
				if(v_c > 5 + C_OFF)
					res_c[i, 5 + C_OFF] += p_d
				elseif(v_c < 1 + C_OFF)
					res_c[i, 1 + C_OFF] += p_d
				else
					res_c[i, v_c] += p_d
				end
			end
		end
	end
	A = length(a)
	M = length(b)
	N = length(a) + length(b) - 1
	D1 = 21
	D2 = 101
	ZERO = 150
	res_d = [0.0 for  _ in 1:A, _ in 1:(M), _ in 1:(N + D2 - 1)]
	for i in 1:length(a)
		for j in 1:length(b)
			v_delta = i - j + M
			p_delta = a[i] * b[j]
			if(v_delta < 5 + M && v_delta > -5 + M)
				res_d[i, j, ZERO] += p_delta
			elseif(v_delta < 25 + M && v_delta > -25 + M)
				for di in 1:D1
					res_d[i, j, v_delta+40+di-1] += p_delta * 1 / D1
				end
			else
				for di in 1:D2
					res_d[i, j, v_delta+di-1] += p_delta * 1 / D2
				end
			end
		end
	end
	C = N + D2 - 1 + M - 1
	res_c = [0.0 for _ in 1:A, _ in 1:C]
	for i in 1:length(a)
		for j in 1:length(b)
			for di in 1:(N + D2 - 1)
				v_c = j + di - 1
				p_d = res_d[i, j, di]
				if(v_c > 50 + ZERO - 1)
					res_c[i, 50 + ZERO - 1] += p_d
				elseif(v_c < 1 + ZERO - 1)
					res_c[i, 1 + ZERO - 1] += p_d
				else
					res_c[i, v_c] += p_d
				end
			end
		end
	end
	D = C + A - 1
	res_d2 = [0.0 for _ in 1:D]
	D_OFF = 249
	for i in 1:length(a)
		for j in 1:C
			v = i - j + C
			res_d2[v] += res_c[i, j]
		end
	end
	res = [0.0, 0.0]
	for i in 1:D
		v = (i < 5 + D_OFF && i > -5 + D_OFF) ? 2 : 1
		res[v] += res_d2[i]
	end
	return res
end

print_vec(v) = begin
	# println(sort(Dict(enumerate(v))))
	println(v)
	println("length: $(length(v))")
end

# delta = sub_pr(tgtValue, curValue)
# d = sub_cmp_pr_small(tgtValue, curValue)
# d = sub_cmp_pr_medium(tgtValue, curValue)
# cv = sub_cmp_add_pr_small(tgtValue, curValue)
# cv = sub_cmp_add_pr_medium(tgtValue, curValue)
# dv = sub_cmp_add_sub_pr_small(tgtValue, curValue)
# dv = sub_cmp_add_sub_pr_medium(tgtValue, curValue)

# print_vec(delta)
# print_vec(d)
# print_vec(cv)
# print_vec(dv)

function fun() 
	# n = 10
	n = 100
	# n = 500
	curValue = [1/n for _ in 1:n]
	tgtValue = [1/n for _ in 1:n]
	# return sub_cmp_add_sub_pr_small(tgtValue, curValue)
	return sub_cmp_add_sub_pr_medium(tgtValue, curValue)
end 

x = @benchmark fun()

println((median(x).time)/10^9)