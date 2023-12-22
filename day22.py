from benchy import minibench

def drop(bricks):
    mapp = [ 0 ] * 100
    height = [ 0 ] * 100
    suppby = [ 0 ] * len(bricks)
    suppon = []
    unsafe = [ 0 ] * len(bricks)
    for i,(z1,x1,y1,z2,x2,y2) in enumerate(bricks):
        suppon.append([])
        while z1 > 1:
            if x1 != x2:
                assert(x1<x2)
                mh = max([height[x + y1*10] for x in range(x1,x2+1)])
            else:
                assert(y1<=y2)
                mh = max([height[x1 + y*10] for y in range(y1,y2+1)])
            if mh < z1 - 1:
                z1 -= 1
                z2 -= 1
            else:
                break
        sup = []
        prev = -1
        if x1 != x2:
            r = [ (x,y1) for x in range(x1,x2+1)]
        else:
            r = [ (x1,y) for y in range(y1,y2+1)]
        for (x,y) in r:
            if z1 > 1 and height[x + y*10] == z1 - 1:
                base = mapp[x+y*10]
                if base != prev:
                    sup.append(base)
                prev = base
            height[x + y*10] = z2
            mapp[x + y*10] = i
        suppby[i] = len(sup)
        for j in sup:
            suppon[j].append(i)
        if len(sup) == 1:
            unsafe[sup[0]] = 1
    return (unsafe, suppby, suppon)

def explode(suppby, suppon, start):
    supp = suppby.copy()
    work = [ start ]
    pos = 0
    while pos < len(work):
        cur = work[pos]
        pos += 1
        for dst in suppon[cur]:
            supp[dst] -= 1
            if not supp[dst]:
                work.append(dst)
    return len(work) - 1


lines = open("day22.txt").read().split("\n")
bricks = []

def parse():
    bricks.clear()
    for line in lines:
        line = line.replace("~",",")
        (x1,y1,z1,x2,y2,z2) = map(int,line.split(","))
        # swap so that z1 is lower
        if (z2 < z1):
            (x1,y1,z1,x2,y2,z2)=(x2,y2,z2,x1,y1,z1)
        elif (x2 < x1): # z1,y1 is same as z2,y2
            x1,x2 = x2,x1
        elif (y2 < y1): # z1,x1 is same as z2,y2
            y1,y2 = y2,y1
        bricks.append((z1,x1,y1,z2,x2,y2))
    bricks.sort()
    return len(bricks)

def part1():
    global suppby, suppon, unsafe
    unsafe, suppby, suppon = drop(bricks)
    return len(bricks) - sum(unsafe)

def part2():
    cache = [ -1 ] * len(bricks)
    esum = 0
    for start in range(len(bricks)):
        if not unsafe[start]:
            continue
        if cache[start] >= 0:
            ecnt = cache[start]
        else:
            ecnt = explode(suppby, suppon, start)
        if len(suppon[start]) == 1:
            cache[suppon[start][0]] = ecnt -1
        esum += ecnt
    return esum
                           
parse()
print(part1())
print(part2())

minibench({"parse": parse, "part1": part1, "part2": part2})
