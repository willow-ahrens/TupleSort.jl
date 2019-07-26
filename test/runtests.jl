using Test
using Random
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

for n = 0:8
    s = ((1:n)...,)
    for t in permutations(s)
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
for n = 9:32
    for _ in 1:100
        s = ((1:n)...,)
        t = (randperm(n)...,)
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