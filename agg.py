lines = open("BENCHMARKS.md").read().split("\n")[19:-4]
sums = [ 0 ] * 3
maxs = [ 0 ] * 3
for l in lines:
    l = l.replace("[","").split()[2:8]
    for i in range(3):
        v = float(l[2*i])
        if l[2*i+1].startswith("m"):
            v *= 1000
        sums[i] += v 
        maxs[i] = max(maxs[i],v)
print([s/1000 for s in sums])
print([s/1000 for s in maxs])
        
        