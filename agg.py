
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
        if math.isnan(mat[row][2*i]):
            continue
        # convert everything to microseconds
        unit = mat[row][2*i+1]
        if unit == "μs":
            raw.append(mat[row][2*i])
        elif unit == "ms":
            raw.append(mat[row][2*i]*1000)
        elif unit == "s":
            raw.append(mat[row][2*i]*1000000)
        elif unit == "ns":
            raw.append(mat[row][2*i]/1000)
        else:
            print("BORK BORK BORK:", label, row, unit, mat[row][2*i])
            exit(0)
        if i < 3:
            sums[i] += raw[i]
    if len(raw) > 3 and raw[3] < raw[2]:
        raw[2] = raw[3]
    r1 = int(raw[1] / raw[2])
    r2 = int(raw[0] / raw[2])
    print("{0:<16s}{1:01.2f} {2:<2s}     {3:01.2f} {4:<2s}     {5:01.2f} {6:<2s}     {7:01.2f} {8:<2s}     * {9} - {10}".format(label,*mat[row],r1,r2))
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
print("{0:<13s}{1:>7.2f} {2}   {3:>6.2f} {4}    {5:>5.2f} {6}   {7:5.2f} {8}     * {9} - {10}".format("Total",*totf,tr1,tr2))
    