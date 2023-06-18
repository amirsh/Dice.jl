export step_params!, train_params!, BoolToMax, total_logprob

struct BoolToMax
    bool::AnyBool
    evid::AnyBool
    weight::Real
    BoolToMax(bool, evid, weight) = new(bool & evid, evid, weight)
end

function BoolToMax(bool; evidence=true, weight=1)
    BoolToMax(bool, evidence, weight)
end

# Find the log-probabilities and the log-probability gradient of a BDD
function add_scaled_dict!(
    x::AbstractDict{<:Any, <:Real},
    y::AbstractDict{<:Any, <:Real},
    s::Real
)
    for (k, v) in y
        x[k] += v * s
    end
end

# Step flip probs in direction of gradient to maximize likelihood of BDDS
function step_params!(
    c::BDDCompiler,
    bdds_to_max::Vector{<:Tuple{CuddNode, CuddNode, <:Real}},
    learning_rate::AbstractFloat
)
    global _parameter_to_value
    adnodes = Set([
        f.prob
        for f in values(c.level_to_flip)
        if f.prob isa ADNode
    ])
    vals = compute(adnodes)

    # Find grad of logprobability w.r.t. each flip's probability
    w = WMC(c)
    grad = DefaultDict{Flip, Float64}(0.)
    for (bdd, obs_bdd, weight) in bdds_to_max
        isconstant(bdd) && continue
        grad_here = grad_logprob(w, bdd, vals)
        add_scaled_dict!(grad_here, grad_logprob(w, obs_bdd, vals), -1)
        add_scaled_dict!(grad, grad_here, weight)
    end

    root_derivs = DefaultDict{ADNode, Real}(0.)
    for (f, d) in grad
        if f.prob isa ADNode
            root_derivs[f.prob] += d
        end
    end

    derivs = differentiate(root_derivs)
    for (adnode, d) in derivs
        if adnode isa Parameter
            _parameter_to_value[adnode] += d * learning_rate
            # println(adnode, ' ', d)
        end
    end
end

function train_params!(
    bools_to_max::Vector{<:AnyBool};
    args...
)
    train_params!(
        [BoolToMax(b, true, 1) for b in bools_to_max];
        args...
    )
end


# Train group_to_psp to such that generate() approximates dataset's distribution
function train_params!(
    bools_to_max::Vector{BoolToMax};
    epochs::Integer=2000,
    learning_rate::AbstractFloat=0.003,
)
    # Compile to BDDs
    c = BDDCompiler(Iterators.flatten(map(x -> [x.bool, x.evid], bools_to_max)))
    bdds_to_max = [
        (compile(c, x.bool), compile(c, x.evid), x.weight)
        for x in bools_to_max
    ]
    for _ in 1:epochs
        step_params!(c, bdds_to_max, learning_rate)
    end
    nothing
end

function total_logprob(bools_to_max::Vector{BoolToMax})
    w = WMC(
        BDDCompiler(Iterators.flatten(map(x -> [x.bool, x.evid], bools_to_max)))
    )
    sum(
        logprob(w, b.bool) - logprob(w, b.evid)
        for b in bools_to_max
    )
end
