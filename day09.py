from benchy import minibench

def differential(s):
    d = []
    orr = 0
    for i in range(1,len(s)):
        t = s[i] - s[i-1]
        orr |= t
        d.append(t)
    s.clear()
    s.extend(d)
    return orr

def diff1(s):
    r = [s[-1]]
    while differential(s):
        r.append(s[-1])
    return sum(r)

def diff2(s):
    l = [s[0]]
    while differential(s):
        l.append(s[0])
    for i in range(len(l)-2,-1,-1):
        l[i] -= l[i+1]
    return l[0]

lines = open("day09.txt").read().split("\n")
seqs = []

def parse():
    seqs.clear()
    for l in lines:
        seqs.append(list(map(int, l.split(" "))))
    return len(seqs)

def part1():
    return sum([diff1(s.copy()) for s in seqs])

def part2():
    return sum([diff2(s.copy()) for s in seqs])

parse()
print(part1())
print(part2())

minibench({"parse": parse, "part1": part1, "part2": part2})
