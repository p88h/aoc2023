import sys

sys.setrecursionlimit(10000)
tiles = open("day23.txt").read().split("\n")
dimx = len(tiles[0])
dimy = len(tiles)
(sx, sy) = (tiles[0].find("."), 0)
(fx, fy) = (tiles[dimy - 1].find("."), dimy - 1)

branches = { (sx,sy) : 0, (fx, fy): 1 }
graph = [ [], [] ]
dirs = ((-1,0,'<'),(1,0,'>'),(0,-1,'^'),(0,1,'v'))

best = 0
def dfs1(x,y,path):
    global best
    dirs = ((-1,0,'<'),(1,0,'>'),(0,-1,'^'),(0,1,'v'))
    if (x,y) == (fx,fy):
        if sum(path) > best:
            best = max(best, sum(path))
        return
    path[y * dimx + x] = 1
    for (dx,dy,dc) in dirs:
        (nx,ny) = (x+dx,y+dy)
        if (tiles[ny][nx] == '.' or tiles[ny][nx] == dc) and not path[ny * dimx + nx]:
            dfs1(nx,ny, path)
    path[y * dimx + x] = 0

def dfs2(x, y, visited, prev, last, steps):
    visited.add((x, y))
    cnt = 0
    for dx, dy, _ in dirs:
        (nx, ny) = (x + dx, y + dy)
        if tiles[ny][nx] != "#" and (nx, ny) != prev:
            cnt += 1
    if cnt > 1:
        cur = branches[(x,y)] = len(branches)
        graph.append([])
        graph[cur].append((last,steps))
        graph[last].append((cur,steps))
        last = cur
        steps = 0
    for dx, dy, _ in dirs:
        (nx, ny) = (x + dx, y + dy)
        if (nx, ny) != prev and (nx, ny) in branches:
            cur = branches[(nx, ny)]
            graph[cur].append((last,steps + 1))
            graph[last].append((cur,steps + 1))
        elif tiles[ny][nx] != "#" and (nx, ny) not in visited:
            dfs2(nx, ny, visited, (x, y), last, steps + 1)

def dfs3(cur,path,steps):
    global best
    if cur == 1:
        best = max(best, steps)
        return
    path[cur] = 1
    for (dst,add) in graph[cur]:        
        if not path[dst]:
            dfs3(dst, path, steps +add)
    path[cur] = 0

p = [ 0 ] * (dimx * dimy)
p[sx] = 1 
dfs1(sx, sy + 1, p)
print(best)
dfs2(sx, sy + 1, set(), (sx, sy), 0, 1)
dfs3(0, [0]*len(graph), 0)
print(best)