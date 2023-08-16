using Dice
using BenchmarkTools

function fun() 
    n = 101
    c = @dice begin 
        curValue = uniform(DistInt{14}, 1, n)
        tgtValue = uniform(DistInt{14}, 1, n)



        delta = tgtValue - curValue


    
        d = ifelse((delta < DistInt{14}(5)) & (delta > DistInt{14}(-5)), 
            DistInt{14}(0), 
            ifelse(delta < DistInt{14}(0),
                
                ifelse(delta > DistInt{14}(-25),
                delta + uniform(DistInt{14}, -10, 11), 
                delta + uniform(DistInt{14}, -50, 51)), 
                
                ifelse(delta < DistInt{14}(25),
                delta + uniform(DistInt{14}, -10, 11), 
                delta + uniform(DistInt{14}, -50, 51))
            )
        )

        

        curValue = curValue + d 

        curValue = ifelse(curValue > DistInt{14}(50), 
                        DistInt{14}(50), 
                    ifelse(curValue < DistInt{14}(1), 
                        DistInt{14}(1), 
                        curValue))
        
        delta = tgtValue - curValue
        return (delta < DistInt{14}(5)) && (delta > DistInt{14}(-5))
        # return d
        # return delta
        # return curValue
    end 
    pr(c)
end

# println(sort(fun()))

x = @benchmark fun()

println((median(x).time)/10^9)