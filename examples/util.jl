function print_dict(d)
    d = sort(collect(d), by= xv -> -xv[2])  # by decreasing probability
    println("$(typeof(d)) with $(length(d)) entries")
    widest = if length(d) > 0 maximum(length(string(k)) for (k, _) in d) else 0 end
    for (k, v) in d
        println("   $(rpad(k, widest, ' ')) => $(v)")
    end
end

# Prints trees as returned from inference on DistTree
# tree := (val, [tree, tree, tree...])
function print_tree(t; indent_per_level=4)
    @assert indent_per_level >= 1
    print_tree_helper(t, [], 0, false, indent_per_level)
end

function print_tree_helper(t, pipes, level, last_child, indent_per_level)
    # Print padding
    padding_size = level * indent_per_level
    if level > 0
        padding = [' ' for _ in 1:padding_size]
        for pipe in pipes
            padding[pipe] = '│'
        end
        # Connect last pipe to value
        padding[last(pipes)] = if last_child '└' else '├' end
        for i in (last(pipes)+1):(padding_size-1)
            padding[i] = '─'
        end
        print(join(padding))
    end

    # Print value
    println(t[1])
    
    # Consume last pipe if we are last child, always create new pipe below us
    inherited_pipes = copy(pipes)
    if last_child
        pop!(inherited_pipes)
    end
    push!(inherited_pipes, padding_size + 1)

    for i in 1:length(t[2])
        print_tree_helper(
            t[2][i],
            inherited_pipes,
            level + 1,
            i == length(t[2]),
            indent_per_level
        )
    end
end