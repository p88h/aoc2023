from benchy import minibench

lines = open("day03.txt").read().split("\n")
dimx = len(lines[0])
dimy = len(lines)
nums = []


def find_nums():
    nums.clear()
    for y in range(dimy):
        r = 0
        q = 0
        for x in range(dimx):
            c = ord(lines[y][x])
            if c >= 48 and c <= 57:
                d = c - 48
                r = r * 10 + d
                q += 1
            else:
                if q > 0:
                    nums.append((y, x - q, q, r))
                    r = q = 0
        if q > 0:
            nums.append((y, dimx - q, q, r))
    return 0


def part1():
    s = 0
    for y, x, l, v in nums:
        n = ""
        sx = max(x - 1, 0)
        if y > 0:
            n = n + lines[y - 1][sx : x + l + 1]
        if x > 0:
            n += lines[y][x - 1]
        if x + l < dimx:
            n += lines[y][x + l]
        if y + 1 < dimy:
            n += lines[y + 1][sx : x + l + 1]
        for c in n:
            if c != "." and not c.isdigit():
                s += v
                break
    return s


def part2():
    gc = [0] * (dimx * dimy)
    s2 = 0
    for y, x, l, v in nums:
        sx = max(x - 1, 0)
        lx = min(x + l, dimx - 1)
        sy = max(y - 1, 0)
        ly = min(y + 1, dimy - 1)
        for gy in range(sy, ly + 1):
            for gx in range(sx, lx + 1):
                if lines[gy][gx] == "*":
                    gk = gy * dimx + gx
                    if gc[gk] != 0:
                        s2 += gc[gk] * v
                    gc[gk] = v
    return s2


find_nums()
print(part1())
print(part2())

minibench({"parse": find_nums, "part1": part1, "part2": part2})
