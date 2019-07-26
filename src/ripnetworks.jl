raw_html(n) = readlines(open(`curl http://jgamble.ripco.net/cgi-bin/nw.cgi?inputs=$n&algorithm=best&output=macro`))
println(raw_html(10))
println(raw_html(10))
for line in raw_html(10)
	for m in match(r"SWAP(\(\d+\), \(\d+\))", line)
	    println(m)
	end
end
