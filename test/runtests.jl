using Test
using TupleSort

function allperms(things)
    if length(things) <= 1
        return [things]
    end
    perms = []
    for i in 1:length(things)
        for rest in allperms((things[1:i - 1]..., things[i + 1:end]...))
            push!(perms, (things[i], rest...))
        end
    end
    return perms
end

for n = 0:3
    s = ((1:n)...,)
    for t in allperms(s)
        println(t)
        @test sort(t) == s
        @test sort(t, by = -) == reverse(s)
        @test sort(t, lt = >) == reverse(s)
        @test sort(t, by = -, lt = >) == s
    end
end