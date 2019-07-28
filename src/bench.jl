using BenchmarkTools
using Plots
using Random
using TupleSort
using TupleTools
using ProgressMeter
using BSON: @save, @load
pyplot()



@generated function copysort(stuff::NTuple{N}) where {N}
    return quote
        s = sort!(Base.copymutable(stuff))
        return @inbounds ($([:(s[$n]) for n = 1:N]...),)
    end
end



const ns = 2 .^(1:7)
const seconds = 25

networksort_times = []
copysort_times = []
mergesort_times = []
arraysort_times = []

if true
    p = Progress(length(ns), 1, "Making Ur Plot...")
    for n = ns
        push!(networksort_times, time(@benchmark networksort(perm) setup=(perm=(randperm($n)...,)) seconds=seconds)
                               - time(@benchmark identity(perm) setup=(perm=(randperm($n)...,)) seconds=seconds))
        push!(copysort_times, time(@benchmark copysort(perm) setup=(perm=(randperm($n)...,)) seconds=seconds)
                            - time(@benchmark identity(perm) setup=(perm=(randperm($n)...,)) seconds=seconds))
        push!(mergesort_times, time(@benchmark TupleTools.sort(perm) setup=(perm=(randperm($n)...,)) seconds=seconds)
                             - time(@benchmark identity(perm) setup=(perm=(randperm($n)...,)) seconds=seconds))
        push!(arraysort_times, time(@benchmark sort!(perm) setup=(perm=randperm($n)) seconds=seconds)
                             - time(@benchmark identity(perm) setup=(perm=randperm($n)) seconds=seconds))
        next!(p)
    end
    @save "results.bson" networksort_times copysort_times mergesort_times arraysort_times # Same as above
end
@load "results.bson" networksort_times copysort_times mergesort_times arraysort_times # Same as above

plot(ns, networksort_times, label="networksort(::Tuple{Vararg{Int}})", ylims=(0.01, max(maximum(networksort_times), maximum(mergesort_times), maximum(copysort_times), maximum(arraysort_times))), xlabel="N", ylabel="time (ns)", xscale=:log2, yscale = :log10)
plot!(ns, copysort_times, label="copysort(::Tuple{Vararg{Int}})")
plot!(ns, mergesort_times, label="mergesort(::Tuple{Vararg{Int}})")
plot!(ns, arraysort_times, label="sort!(::Vector{Int})")

savefig("plot.png")
