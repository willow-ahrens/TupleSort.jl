raw_html(n) = readlines(open(`curl http://jgamble.ripco.net/cgi-bin/nw.cgi?inputs=$n&algorithm=best&output=macro`))
swaps = []
for n = 2:64
	swap = []
	for line in raw_html(n)
		for m in eachmatch(r"SWAP\((\d+), (\d+)\)", line)
			push!(swap, (parse(Int, m[1]) + 1, parse(Int, m[2]) + 1))
		end
	end
	push!(swaps, swap)
end
for swap in swaps
	print("[")
	for s in swap
		print("$s, ")
	end
	println("],")
end
