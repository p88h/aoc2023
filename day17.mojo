from parser import *
from wrappers import minibench
from array import Array
from math import sqrt
from utils.loop import unroll

fn main() raises:
    f = open("day17.txt", "r")
    tiles = make_parser["\n"](f.read())
    dimx = tiles.length()
    dimy = tiles[0].size
    alias maxq = 600
    alias maxd = 1200
    work = Array[DType.int32](maxd * maxq)  # dijkstra tables

    # packs into 24-bit representation
    @parameter
    fn pack(x: Int, y: Int, dir: Int, r: Int) -> Int32:
        return ((y * dimx + x) << 6) + dir * 10 + r

    @parameter
    fn bfs(minrun: Int, maxrun: Int) -> Int64:
        alias IntPair = SIMD[DType.int32, 2]
        alias dirs = List[IntPair](IntPair(-1, 0), IntPair(1, 0), IntPair(0, -1), IntPair(0, 1))
        var count = Array[DType.int8](dimx * dimy)  # heuristic counters
        var best = Array[DType.int16](dimx * dimy * 64)  # 1MB best-distance array        
        work[0] = 2
        work[1] = pack(0, 0, 1, 0)
        work[2] = pack(0, 0, 3, 0)
        var found = False
        var distance = 0
        var maxp = 0
        # reset the work queues
        for w in range(1, maxd):
            work[w * maxq] = 0
        while not found:
            # process the boundary at distance
            q = int(work[distance * maxq])
            for cp in range(q):
                current = int(work[distance * maxq + cp + 1])
                # unpack the current record
                x = (current >> 6) % dimx
                y = (current >> 6) // dimx
                dir = (current & 0x3F) // 10
                r = (current & 0x3F) % 10
                dx = int(dirs[dir][0])
                dy = int(dirs[dir][1])
                # final destination
                if x == dimx - 1 and y == dimy - 1:
                    found = True
                    break
                # skip if already processed same
                if best[current] < distance :
                    continue
                # + heuristic to trim the number of reviewed states. Probably could refine this.
                count[y * dimx + x] += 1
                if count[y * dimx + x] > maxrun + 1:
                    continue
                # + another heuristic - limit to +-20 in distance from the frontier
                if x + y + 22 < maxp:
                    continue
                # finally, completely cut out the middle circle.
                cx = abs(x - dimx // 2)
                cy = abs(y - dimx // 2)
                cd = sqrt(cx * cx + cy * cy)
                if cd < dimx // 2 - 7:
                    continue    
                if x + y > maxp:
                    maxp = x + y

                # this inner function thing is much faster than iterating with a loop.
                @parameter
                fn maybe_add[ndir: Int]():
                    nx = int(dirs[ndir][0])
                    ny = int(dirs[ndir][1])
                    var nr = 0
                    # don't turn back
                    if nx == -dx and ny == -dy:
                        return
                    # extend run length
                    if nx == dx and ny == dy:
                        nr = r + 1
                        if nr > maxrun:
                            return
                    elif r < minrun:
                        return
                    # boundaries check
                    if x + nx < 0 or x + nx >= dimx or y + ny < 0 or y + ny >= dimy:
                        return
                    # compute the next state
                    alias zero = ord("0")
                    cost = int(tiles[y + ny][x + nx] - zero)
                    p = pack(x + nx, y + ny, ndir, nr)
                    # skip if already processed
                    if best[p] > 0 and best[p] <= distance + cost:
                        return
                    # store into the work buffers
                    best[int(p)] = distance + cost
                    work[(distance + cost) * maxq] += 1
                    work[(distance + cost) * maxq + work[(distance + cost) * maxq]] = p

                unroll[maybe_add, range(4)]()

            distance += 1
        return distance - 1

    @parameter
    fn part1() -> Int64:
        return bfs(0, 2)

    @parameter
    fn part2() -> Int64:
        return bfs(3, 9)

    minibench[part1]("part1")
    minibench[part2]("part2")

    print(tiles.length(), "tokens", dimx, dimy)
    print(work.bytecount(), "work buffers")
    print(dimx, dimy)
