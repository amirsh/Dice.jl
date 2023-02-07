
using Dice 
using BenchmarkTools

function fun() 
    c = @dice begin
        a = uniform(DistInt{20},-500, 501)
        b = uniform(DistInt{20},-500, 501)
        c = uniform(DistInt{20},-500, 501)



        zero = DistInt{20}(0)


        type = 
            ifelse((a <= zero) | (b <= zero) | (c <= zero), 
                DistUInt{2}(3),
            ifelse(
                (a+b<=c) | (a+c<=b) | (b+c <= a), 
                DistUInt{2}(3),
            ifelse(
                prob_equals(a, b) & prob_equals(a, c) & prob_equals(b, c),
                DistUInt{2}(2), 
            ifelse(
                prob_equals(a, b) | prob_equals(a, c) | prob_equals(b, c), 
                DistUInt{2}(1), 
                DistUInt{2}(0)
            ))))

        type 

    end

    pr(c)
end 

x = @benchmark fun()

println((median(x).time)/10^9)
