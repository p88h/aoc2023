from collections import defaultdict
from benchy import minibench

lines = open("day14.txt").read().split("\n")
(n, m) = (len(lines), len(lines[0]))
pebbles = []
order = []

# input is either fully sorted - first by Y (first coord) then X (second)
# or just by X. In fist case this will create groups, each with new different
# and those groups will still be internally sorted by Y, or it will be sorted
# by new Y, which still allows them to be trivially grouped by X.
def rot90(ppos):
    return [(x, n - y - 1) for (y, x) in ppos]

# group points by X. as long as the points were somewhat / partially sorted by Y,
# (see above) groups will be sorted by Y
def groupbyx(ppos):
    work = []
    for x in range(m):
        work.append([])
    for y, x in ppos:
        work[x].append(y)
    return work

def parse():
    tmp = []
    pebbles.clear()
    order.clear()
    # parse the map and store objects
    for y in range(n):
        l = [0] * m
        for x in range(m):
            if lines[y][x] == "O":
                pebbles.append((y, x))
            if lines[y][x] == "#":
                tmp.append((y, x))
    # keep rocks pre-grouped by x; and pre-rotated in 4 directions
    for i in range(4):
        grp = groupbyx(tmp)
        order.append(grp)
        tmp = []
        for x in range(m):
            tmp.extend([(y, x) for y in grp[x]])
        tmp = rot90(tmp)
    return len(pebbles)


def tilt(ppos, rgrp):
    # Distribute pebbles along the x axis.
    work = groupbyx(ppos)
    next = []
    # take each column
    for x in range(m):
        ofs = 0
        wp = rp = 0
        # if there are any rocks AND pebbles remaining:
        while wp < len(work[x]) and rp < len(rgrp[x]):
            # next rock and pebble y
            rocky = rgrp[x][rp]
            pebby = work[x][wp]
            # rock is lower than the pebble. consume the rock.
            # set ofs (next viable pebble position) to rocky + 1
            if rocky < pebby:
                ofs = rocky + 1
                rp += 1
            # consume the pebble, shift it to ofs and update ofs
            else:  # pebby < rocky:
                next.append((ofs, x))
                ofs += 1
                wp += 1
        # consume remaining pebbles:
        while wp < len(work[x]):
            next.append((ofs, x))
            ofs += 1
            wp += 1
    return next

def display(ppos, amap):
    print(ppos)
    for y in range(n):
        for x in range(m):
            if y in amap[x]:
                print("#", end="")
            elif (y, x) in ppos:
                print("O", end="")
            else:
                print(".", end="")
        print()

def load(ppos):
    return sum([n - y for (y, _) in ppos])

def part1():
    return load(tilt(pebbles, order[0]))

# Use a string-based signature that simply concatenates all positions represented
# as bytes. Trust python to do this reasonably fast.
def sign(ppos):
    ret = ""
    for x, y in ppos:
        ret += chr(x + 20)
        ret += chr(y + 20)
    return ret

def part2():
    cache = {}
    vals = []
    ppos = pebbles
    sgn = sign(ppos)
    while sgn not in cache:
        cache[sgn] = len(cache)
        vals.append(load(ppos))
        for amap in order:
            ppos = rot90(tilt(ppos, amap))
        sgn = sign(ppos)
    cycle_length = len(cache) - cache[sgn]
    remaining = (1000000000 - len(cache)) % cycle_length
    return vals[cache[sgn] + remaining]


print(parse())
print(part1())
print(part2())

minibench({"parse": parse, "part1": part1, "part2": part2})
