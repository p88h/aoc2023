from benchy import minibench

lines = open("day17.txt").read().split("\n")
tiles = [ list(map(int, line)) for line in lines ]
dimx = len(tiles[0])
dimy = len(tiles)

def pack(x, y, dir, r):
    return (y * dimx + x) * 40 + dir * 10 + r

def bfs(minrun,maxrun):
    dirs = [ (-1,0), (1,0), (0,-1), (0,1) ]
    dijkstra = [ [] for _ in range(2000) ]
    best = [ 9999 ] * dimx * dimy * 40
    count = [ 0 ] * dimx * dimy
    dijkstra[0] = [(0,0,1,0),(0,0,3,0)]
    for (x,y,dir,r) in dijkstra[0]:
        best[pack(x,y,dir,r)] = 0
    found = False
    distance = 0
    maxd = 0 
    while not found:
        maxd = max(maxd,len(dijkstra[distance]))
        for current in dijkstra[distance]:
            (x,y,dir,r) = current
            (dx,dy) = dirs[dir]
            if x == dimx -1 and y == dimy -1:
                found = True
                break
            key = pack(x,y,dir,r)
            if best[key] < distance:
                continue
            count[y * dimx + x] += 1
            if count[y * dimx + x] > maxrun + 1:
                continue
            for ndir in range(4):
                (nx,ny) = dirs[ndir]
                nr = 0
                if (nx,ny) == (-dx,-dy):
                    continue
                if (nx,ny) == (dx,dy):
                    nr = r + 1
                    if nr > maxrun:
                        continue
                elif r < minrun:
                    continue
                if x + nx < 0 or x + nx >= dimx or y + ny < 0 or y + ny >= dimy:
                    continue
                cost = tiles[y + ny][x + nx]
                next = (x + nx, y + ny, ndir, nr)
                nkey = pack(x + nx, y + ny,ndir,nr)
                if best[nkey] <= distance + cost:
                    continue
                best[nkey] = distance + cost
                dijkstra[distance + cost].append(next)                
        distance += 1
    return distance - 1

def part1():
    return bfs(0,2)

def part2():
    return bfs(3,9)

print(part1())
print(part2())

minibench({"part1": part1, "part2": part2})
