from collections import defaultdict
from benchy import minibench

tiles = open("day21.txt").read().split("\n")
dimx = len(tiles[0])
dimy = len(tiles)
for y, line in enumerate(tiles):
    if "S" in line:
        (sx, sy) = (line.find("S"), y)
        break

def sign(x):
    if x < 0:
        return -1
    elif x > 0:
        return 1
    else:
        return 0

def trisum(rem, odds):
    fullsum = (rem) * (1 + rem) // 2
    evensum = (rem // 2) * (1 + rem // 2)
    if odds:
        return fullsum - evensum
    else:
        return evensum

def oddcnt(rem, odds):
    if rem % 2 == 0:
        return rem // 2
    return rem // 2 + odds

def bfs(start, steps, expand):
    dirs = [(-1, 0), (1, 0), (0, -1), (0, 1)]
    distance = 0
    current = [start]
    visited = set(current)
    history = defaultdict(list)
    total = 0
    minlen = 0
    (ox, oy) = start
    while current and distance < steps and minlen < 6:
        minlen = 9 * expand
        next = []
        for pos in current:
            (x, y) = pos
            if expand:
                r = (x // dimx - ox // dimx, y // dimy - oy // dimy)
                history[(x % dimx, y % dimy)].append((r, distance))
                minlen = min(minlen, len(history[(x % dimx, y % dimy)]))
            elif distance % 2 == steps % 2:
                total += 1
            for ndir in range(4):
                (dx, dy) = dirs[ndir]
                if expand:
                    (nx, ny) = ((x + dx) % dimx, (y + dy) % dimy)
                else:
                    if x + dx < 0 or x + dx >= dimx or y + dy < 0 or y + dy >= dimy:
                        continue
                    (nx, ny) = (x + dx, y + dy)
                if tiles[ny][nx] == "#" or (x + dx, y + dy) in visited:
                    continue
                visited.add((x + dx, y + dy))
                next.append((x + dx, y + dy))
        distance += 1
        current = next
    if not expand:
        total += len(current)
        return total
    for pos in history:
        pfx = 6
        d9 = [[0, 0, 0], [0, 0, 0], [0, 0, 0]]
        c9 = [0] * 9
        ch = history[pos]
        ((xx, yy), _) = ch[pfx - 1]
        if abs(xx) == 2 or abs(yy) == 2:
            pfx -= 1
        # map first few visited nodes into 3x3 grid and compute their counts
        for j in range(pfx):
            ((x1, y1), d1) = ch[j]
            d9[y1 + 1][x1 + 1] = d1
            rem = (steps - d1) // dimx
            if x1 == 0 or y1 == 0:
                c9[(y1 + 1) * 3 + x1 + 1] = oddcnt(rem + 1, d1 % 2)
            else:
                c9[(y1 + 1) * 3 + x1 + 1] = trisum(rem + 1, d1 % 2)
        # create the rest of the 3x3 grid and compute remaining quadrants
        for cx, cy in [(0, 0), (0, 2), (2, 2), (2, 0)]:
            if d9[cy][cx] == 0:
                d9[cy][cx] = dimx + min(d9[cy][1], d9[1][cx])
                rem = (steps - d9[cy][cx]) // dimx
                c9[cy * 3 + cx] = trisum(rem + 1, d9[cy][cx] % 2)
        c9[4] = d9[1][1] % 2
        total += sum(c9)
    return total

def part1():
    return bfs((sx, sy), 64, 0)

def part2():
    return bfs((sx + dimx * 1000, sy + dimy * 1000), 26501365, 1)

print(part1())
print(part2())

minibench({"part1": part1, "part2": part2})
