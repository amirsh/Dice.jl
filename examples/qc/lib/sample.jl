using DirectedAcyclicGraphs: foldup
using Dice: frombits, tobits

function sample(tup)
    x, evid = tup
    while true
        vcache = Dict()
        fl(n::Dice.Flip) = begin
            if !haskey(vcache, n)
                prob = if haskey(Dice._flip_to_group, n)
                    Dice.sigmoid(Dice._group_to_psp[Dice._flip_to_group[n]])
                else
                    n.prob
                end
                vcache[n] = rand() < prob
            end
            vcache[n]
        end

        fi(n::Dice.DistAnd, call) = begin
            if !haskey(vcache, n)
                vcache[n] = call(n.x) && call(n.y)
            end
            vcache[n]
        end

        fi(n::Dice.DistOr, call) = begin
            if !haskey(vcache, n)
                vcache[n] = call(n.x) || call(n.y)
            end
            vcache[n]
        end

        fi(n::Dice.DistNot, call) = begin
            if !haskey(vcache, n)
                vcache[n] = !call(n.x)
            end
            vcache[n]
        end

        vcache = Dict()
        evid_computed = if evid isa Bool
            evid
        else
            foldup(evid, fl, fi, Bool)
        end
        evid_computed || continue
        for bit in tobits(x)
            bit isa Bool && continue
            foldup(bit, fl, fi, Bool)
        end
        return frombits(x, vcache)
    end
end