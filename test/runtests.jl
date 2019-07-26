using Test
using TupleSort

function permutations(things)
    if length(things) <= 1
        return [things]
    end
    perms = []
    for i in 1:length(things)
        for rest in permutations((things[1:i - 1]..., things[i + 1:end]...))
            push!(perms, (things[i], rest...))
        end
    end
    return perms
end

for n = 0:9
    s = ((1:n)...,)
    for t in permutations(s)
        println(t)
        @test sort(t) == s
        @test sort(t, by = -) == reverse(s)
        @test sort(t, lt = >) == reverse(s)
        @test sort(t, by = -, lt = >) == s
        @test sort(t, rev=true) == reverse(s)
        @test sort(t, by = -, rev=true) == s
        @test sort(t, lt = >, rev=true) == s
        @test sort(t, by = -, lt = >, rev=true) == reverse(s)
    end
end