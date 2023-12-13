from benchy import minibench

lines = open("day13.txt").read().split("\n")
mats = []

def find_match(a):
    for i in range(1,len(a)):
        b = 0
        while i>b and i+b<len(a) and a[i-b-1]==a[i+b]:
            b += 1
        if i==b or i+b == len(a):
            return i
    return 0

def find_match_dirty(a):
    for i in range(1,len(a)):
        b = 0
        tbb = 1
        while i>b and i+b<len(a) and (a[i-b-1]^a[i+b]).bit_count()<=tbb:
            tbb -= (a[i-b-1]^a[i+b]).bit_count()
            b += 1
        if tbb == 0 and (i==b or i+b == len(a)):
            return i
    return 0

def parse():
    w=0
    r=[]
    c=[]
    mats.clear()
    for l in lines:
        if not l:
            mats.append((r,c))
            r=[]
            c=[]
        else:
            w = 0
            if not r:
                r  = [ 0 ] * len(l)
            for i,ch in enumerate(l):
                b = ord(ch) & 1
                w = w*2 + b
                r[i] = r[i]*2 + b
            c.append(w)
    return len(mats)

def part1():
    return sum([100*find_match(c)+find_match(r) for (r,c) in mats])

def part2():
    return sum([100*find_match_dirty(c)+find_match_dirty(r) for (r,c) in mats])
        
print(parse(),"arrays")
print(part1())
print(part2())

minibench({"parse": parse, "part1": part1, "part2": part2})