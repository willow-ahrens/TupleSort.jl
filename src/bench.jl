using BenchmarkTools
using Plots
using Random
using TupleSort
using ProgressMeter
using BSON: @save, @load
pyplot()

const N = 64

newsort_times = zeros(N)
copysort_times = zeros(N)
arraysort_times = zeros(N)

@generated function copysort(stuff::NTuple{N}) where {N}
    return quote
        s = sort!(Base.copymutable(stuff))
        return ($([:(s[$n]) for n = 1:N]...),)
    end
end

if true
    p = Progress(N, 1, "Making Ur Plot...")
    for n = 1:N
        newsort_times[n] += time(@benchmark sort(perm) setup=(perm=(randperm($n)...,))) - time(@benchmark identity(perm) setup=(perm=(randperm($n)...,)))
        copysort_times[n] += time(@benchmark copysort(perm) setup=(perm=(randperm($n)...,))) - time(@benchmark identity(perm) setup=(perm=(randperm($n)...,)))
        arraysort_times[n] += time(@benchmark sort!(perm) setup=(perm=randperm($n))) - time(@benchmark identity(perm) setup=(perm=randperm($n)))
	next!(p)
    end
    @save "results.bson" newsort_times copysort_times arraysort_times # Same as above
end
@load "results.bson" newsort_times copysort_times arraysort_times # Same as above

plot(1:N, [newsort_times...], label="newsort(::Tuple{Vararg{Int}})", ylims=(0, max(maximum(newsort_times), maximum(copysort_times), maximum(arraysort_times))), xlabel="N", ylabel="time (ns)")
plot!(1:N, [copysort_times...], label="copysort(::Tuple{Vararg{Int}})")
plot!(1:N, [arraysort_times...], label="sort!(::Vector{Int})")

savefig("plot.png")