using Dice
using BenchmarkTools

function fun()
    c = @dice begin 
        char_freqs = [0.082, 0.018, 0.024, 0.04, 0.123, 0.022, 0.022, 0.066, 0.069, 0.001, 0.008, 0.045, 0.024, 0.069, 0.073, 0.018, 0.002, 0.055, 0.067, 0.092, 0.028, 0.009, 0.023, 0.001, 0.018, 0.001]
        key = uniform(DistUInt{7}, 0, 26)
        
        function sendChar(key::DistUInt{7}, c::DistUInt{7})
            gen = discrete(DistUInt{7}, char_freqs)
            enc = key + gen 
            enc = ifelse(enc > DistUInt{7}(25), enc-DistUInt{7}(26), enc)
            observe(prob_equals(enc, c))
        end 

        text = [9, 11, 8, 21, 20, 21, 2, 5, 2, 12, 13, 2, 22, 9, 11, 8, 0, 11, 20, 6, 6, 2, 7, 0, 5, 20, 7, 0, 14, 20, 0, 24, 12, 9, 9, 5, 12, 20, 11, 24, 20, 7, 24, 17, 9, 11, 24, 12, 12, 2, 15, 24, 6, 24, 20, 7, 12, 8, 25, 11, 24, 9, 11, 24, 12, 24, 7, 13, 2, 7, 0, 20, 7, 23, 11, 24, 20, 12, 8, 7, 2, 7, 0, 20, 21, 8, 14, 13, 9, 11, 8, 21, 20, 21, 2, 5, 2, 12, 13, 2, 22, 6, 8, 23, 24, 5, 12, 13, 1, 24, 22, 8, 6, 9, 14, 13, 20, 13, 2, 8, 7, 20, 5, 22, 1, 20, 5, 5, 24, 7, 0, 24, 8, 25, 9, 11, 8, 21, 20, 21, 2, 5, 2, 12, 13, 2, 22, 2, 7, 25, 24, 11, 24, 7, 22, 24, 11, 24, 6, 20, 2, 7, 12, 13, 1, 24, 9, 11, 2, 6, 20, 11, 18, 11, 8, 20, 23, 21, 5, 8, 22, 4, 25, 8, 11, 20, 9, 9, 5, 18, 2, 7, 0, 9, 9, 5, 12, 2, 7, 9, 11, 20, 22, 13, 2, 22, 24, 2, 7, 25, 24, 11, 24, 7, 22, 24, 2, 12, 25, 14, 7, 23, 20, 6, 24, 7, 13, 20, 5, 5, 18, 1, 20, 11, 23, 12, 8, 13, 1, 24, 11, 24, 2, 12, 7, 8, 8, 7, 24, 12]
        for char in text
            sendChar(key, DistUInt{7}(char))
        end 
        key 
    end  


    debug_info_ref = Ref{CuddDebugInfo}()
    pr(c, ignore_errors=true, algo=Cudd(debug_info_ref=debug_info_ref))
    println("NUM_NODES_START")
    println(debug_info_ref[].num_nodes)
    println("NUM_NODES_END") 
end 

fun()

