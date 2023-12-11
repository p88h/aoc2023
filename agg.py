
import glob
import math

order={"python3": 0, "pypy3": 1, "mojo": 2, "mojo_parallel": 3}
mat = {}

for f in glob.glob("all_*.txt"):
    col = f.split("_")[1]
    lines = open(f).read().split("\n")
    cur = None
    for line in lines:
        line = line.replace(":","").replace(" parallel","_parallel")
        suf = ""
        if line.startswith("day"):
            cur = line.split(".")[0]
        if line.startswith("par"):
            (sub, time, unit) = line.split()[0:3]
            if sub.endswith("parallel"):
                sub = sub[:-9]
                suf = "_parallel"
            row = cur+"_"+sub
            if row not in mat:
                mat[row] = [math.nan] * 8
                mat[row][7]="   "
            mat[row][order[col+suf]*2]=float(time)
            mat[row][order[col+suf]*2+1]=unit

sums = [0] * 3
for row in sorted(mat):
    label = row.replace("day","Day").replace("_", " ")
    raw = []
    for i in range(4):
        if mat[row][2*i] == math.nan:
            continue
        if mat[row][2*i+1] == "μs":
            raw.append(mat[row][2*i])
        else:
            raw.append(mat[row][2*i]*1000)
        if i < 3:
            sums[i] += raw[i]
    if len(raw) > 3 and raw[3] < raw[2]:
        raw[2] = raw[3]
    r1 = int(raw[1] / raw[2])
    r2 = int(raw[0] / raw[2])
    print("{0:<16s}{1:01.2f} {2}     {3:01.2f} {4}     {5:01.2f} {6}     {7:01.2f} {8}     * {9} - {10}".format(label,*mat[row],r1,r2))
    #print(label, mat[row])

tr1 = int(sums[1] / sums[2])
tr2 = int(sums[0] / sums[2])
totf = []
for i in range(3):
    totf.append(sums[i] / 1000)
    totf.append("ms")
totf.append(math.nan)
totf.append("   ")

print()
print("{0:<15s}{1:>2.2f} {2}     {3:>2.2f} {4}     {5:>2.2f} {6}     {7:01.2f} {8}     * {9} - {10}".format("Total",*totf,tr1,tr2))
    