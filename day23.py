from benchy import minibench
import sys

sys.setrecursionlimit(10000)
tiles = open("day23.txt").read().split("\n")
dimx = len(tiles[0])
dimy = len(tiles)
(sx, sy) = (tiles[0].find("."), 0)
(fx, fy) = (tiles[dimy - 1].find("."), dimy - 1)

dirs = ((-1, 0, "<"), (1, 0, ">"), (0, -1, "^"), (0, 1, "v"))

def dfs1(x, y, path, plen):
    dirs = ((-1, 0, "<"), (1, 0, ">"), (0, -1, "^"), (0, 1, "v"))
    if (x, y) == (fx, fy):
        return plen
    path[y * dimx + x] = 1
    best = 0
    for dx, dy, dc in dirs:
        (nx, ny) = (x + dx, y + dy)
        if (tiles[ny][nx] == "." or tiles[ny][nx] == dc) and not path[ny * dimx + nx]:
            best = max(best, dfs1(nx, ny, path, plen + 1))
    path[y * dimx + x] = 0
    return best

def part1():
    p = [0] * (dimx * dimy)
    p[sx] = 1
    return dfs1(sx, sy + 1, p, 1)

def dfs2(x, y, visited, prev, last, steps, branches, graph):
    visited.add((x, y))
    cnt = 0
    for dx, dy, _ in dirs:
        (nx, ny) = (x + dx, y + dy)
        if tiles[ny][nx] != "#" and (nx, ny) != prev:
            cnt += 1
    if cnt > 1:
        cur = branches[(x, y)] = len(branches)
        graph.append([])
        graph[cur].append((last, steps))
        graph[last].append((cur, steps))
        last = cur
        steps = 0
    for dx, dy, _ in dirs:
        (nx, ny) = (x + dx, y + dy)
        if (nx, ny) != prev and (nx, ny) in branches:
            cur = branches[(nx, ny)]
            graph[cur].append((last, steps + 1))
            graph[last].append((cur, steps + 1))
        elif tiles[ny][nx] != "#" and (nx, ny) not in visited:
            dfs2(nx, ny, visited, (x, y), last, steps + 1, branches, graph)

def dfs3(cur, path, steps, graph):
    if cur == 1:
        return steps
    path |= 1 << cur
    best = 0
    for dst, add in graph[cur]:
        if not path & (1 << dst):
            best = max(best, dfs3(dst, path, steps + add, graph))
    path ^= 1 << cur
    return best

def bfstrim(start, graph):
    stak = [ start ]
    while stak:
        next = []
        for cur in stak:            
            for dst,_ in graph[cur]:
                if len(graph[dst]) == 3:
                    for (t,d) in graph[dst]:
                        if t == cur:
                            tod = (t,d)
                    graph[dst].remove(tod)
                    next.append(dst)
        stak = next

def part2():
    branches = {(sx, sy): 0, (fx, fy): 1}
    graph = [[], []]
    dfs2(sx, sy + 1, set(), (sx, sy), 0, 1, branches, graph)
    bfstrim(0, graph)
    return dfs3(0, 0, 0, graph)

print(part1())
print(part2())

minibench({"part1": part1, "part2": part2})