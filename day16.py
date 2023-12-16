from benchy import minibench

tiles = open("day16.txt").read().split("\n")
dimx = len(tiles[0])
dimy = len(tiles)

def bfs(start):
    current = [ start ]
    visited = set()
    warm = set()
    while current:
        next = [] 
        for (x,y,dx,dy) in current:
            # move out of the previous tile
            x += dx
            y += dy
            # out of bounds
            if x < 0 or y < 0 or x >= dimx or y >= dimy:
                continue
            # if we already _entered_ this tile this way, skip
            if (x,y,dx,dy) in visited:
                continue
            visited.add((x,y,dx,dy))
            warm.add((x,y))
            t = tiles[y][x] 
            # empty or ignored splitter
            if t == '.' or (t == '|' and dx == 0) or (t =='-' and dy == 0):
                next.append((x,y,dx,dy))
            # split vertically
            elif t == '|' and dx != 0:
                next.append((x,y,0,1))
                next.append((x,y,0,-1))
            elif t == '-' and dy != 0:
                next.append((x,y,1,0))
                next.append((x,y,-1,0))
            # mirror 1
            elif t == '/':
                next.append((x,y,-dy,-dx))
            # mirror 2
            elif t == '\\':
                next.append((x,y,dy,dx))
        current = next
    return len(warm)

def part1():
    return bfs((-1,0,1,0))

def part2():
    m = 0
    for x in range(dimx):
        m = max(m, bfs((x,-1,0,1)))
        m = max(m, bfs((x,dimy,0,-1)))
    for y in range(dimy):
        m = max(m, bfs((-1,0,1,0)))
        m = max(m, bfs((dimx,0,-1,0)))
    return m

print(part1())
print(part2())

minibench({"part1": part1, "part2": part2})
