module TupleSort

function Base.sort(t::Tuple; dims::Integer = 1, alg::Base.Algorithm=Base.DEFAULT_UNSTABLE, lt=isless, by=identity, rev::Bool=false, order::Base.Ordering=Base.Forward)
    #@assert dims == 1
    return tuplesort(t, lt, by, rev)
end

swaps = [
    [],
    [],
    [(1, 2)],
    [(2, 3), (1, 3), (1, 2)],
    [(1, 2), (3, 4), (1, 3), (2, 4), (2, 3)],
    [(1, 2), (4, 5), (3, 5), (3, 4), (1, 4), (1, 3), (2, 5), (2, 4), (2, 3)],
    [(2, 3), (1, 3), (1, 2), (5, 6), (4, 6), (4, 5), (1, 4), (2, 5), (3, 6), (3, 5), (2, 4), (3, 4)],
    [(2, 3), (1, 3), (1, 2), (4, 5), (6, 7), (4, 6), (5, 7), (5, 6), (1, 5), (1, 4), (2, 6), (3, 7), (3, 6), (2, 4), (3, 5), (3, 4)],
    [(1, 2), (3, 4), (1, 3), (2, 4), (2, 3), (5, 6), (7, 8), (5, 7), (6, 8), (6, 7), (1, 5), (2, 6), (2, 5), (3, 7), (4, 8), (4, 7), (3, 5), (4, 6), (4, 5)],
]

@generated function tuplesort(t::NTuple{N}, lt, by, rev) where {N}
    if N < length(swaps)
        return tuplesortthunk(swaps[N + 1], N)
    else
        return quote
            s = sort!(Base.copymutable(t); lt=lt, by=by, rev=rev)
            return ($([:(s[$n]) for n = 1:N]...),)
        end
    end
end

function tuplesortthunk(swaps, N)
    vars = [Symbol(:t,n) for n = 1:N]
    norev_thunk = Expr(:block)
    for (i, j) in swaps
        a = vars[i]
        b = vars[j]
        append!(norev_thunk.args, (quote
            c = lt(by($a), by($b))
            ($a, $b) = (ifelse(c, $a, $b), ifelse(c, $b, $a))
        end).args)
    end
    rev_thunk = Expr(:block)
    for (i, j) in swaps
        a = vars[i]
        b = vars[j]
        append!(rev_thunk.args, (quote
            c = lt(by($a), by($b))
            ($a, $b) = (ifelse(c, $b, $a), ifelse(c, $a, $b))
        end).args)
    end
    return quote
        ($(vars...),) = t
        if rev
            $rev_thunk
        else
            $norev_thunk
        end
        return ($(vars...),)
    end
end

end # module