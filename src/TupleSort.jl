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
]

@generated function tuplesort(t::NTuple{N}, lt, by, rev) where {N}
    if N < length(swaps)
        return tuplesortthunk(swaps[N + 1], N)
    else
        return quote
            a = copymutable(t)
            #sort!(a; lt=lt, by=by, rev=rev)
            return a
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
            ($a, $b) = (ifelse(c, $a, $b), ifelse(c, $b, $a))
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