from parser import *
from wrappers import minibench
from array import Array
from math import max,abs,sqrt

fn main() raises:
    let f = open("day17.txt", "r")
    let tiles = make_parser["\n"](f.read())
    let dimx = tiles.length()
    let dimy = tiles[0].size
    alias maxq = 600
    alias maxd = 1200
    let work = Array[DType.int32](maxd*maxq) # dijkstra tables    

    # packs into 24-bit representation
    fn pack(x: Int, y: Int, dir: Int, r: Int) -> Int32:
        return ((y * dimx + x) << 6) + dir * 10 + r

    @parameter
    fn bfs(minrun: Int, maxrun: Int) -> Int64:
        alias dirs = VariadicList[Tuple[Int,Int]]( (-1,0), (1,0), (0,-1), (0,1) )
        var count = Array[DType.int8](dimx*dimy) # heuristic counters
        var best = Array[DType.int16](dimx*dimy*64) # 1MB best-distance array
        work[0] = 2
        work[1] = pack(0,0,1,0)
        work[2] = pack(0,0,3,0)
        var found = False
        var distance = 0
        var maxp = 0
        # reset the work queues
        for w in range(1,maxd):
            work[w * maxq] = 0
        while not found:
            # process the boundary at distance
            let q = work[distance*maxq].to_int()
            for cp in range(q):
                let current = work[distance*maxq+cp+1].to_int()
                # unpack the current record
                let x = (current >> 6) % dimx
                let y = (current >> 6) // dimx
                let dir = (current & 0x3F) // 10
                let r = (current & 0x3F) % 10
                let dx = dirs[dir].get[0, Int]()
                let dy = dirs[dir].get[1, Int]()
                # final destination
                if x == dimx -1 and y == dimy -1:
                    found = True
                    break
                # skip if already processed same
                if best[current].to_int() < distance:
                    continue
                # + heuristic to trim the number of reviewed states. Probably could refine this.
                count[y*dimx+x] += 1
                if count[y*dimx+x] > maxrun + 1:
                    continue
                # + another heuristic - limit to +-20 in distance from the frontier
                if x + y + 22 < maxp:
                    continue
                # finally, completely cut out the middle circle.
                let cx = abs(x - dimx//2)
                let cy = abs(y - dimx//2)
                let cd = sqrt(cx*cx+cy*cy)
                if cd < dimx // 2 - 7:
                    continue
                if x + y > maxp:
                    maxp = x + y

                # this inner function thing is much faster than iterating with a loop.
                @parameter
                fn maybe_add[ndir: Int]():
                    let nx = dirs[ndir].get[0, Int]()
                    let ny = dirs[ndir].get[1, Int]()            
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
                    alias zero = ord('0')
                    let cost = (tiles[y + ny][x + nx] - zero).to_int()
                    let p = pack(x + nx, y + ny, ndir, nr)
                    # skip if already processed
                    if best[p] > 0 and best[p].to_int() <= distance + cost:                        
                        return
                    # store into the work buffers
                    best[p.to_int()] = distance + cost
                    work[(distance + cost)*maxq] += 1
                    work[(distance + cost)*maxq + work[(distance + cost)*maxq]] = p
                # do this in all directions
                maybe_add[0]()
                maybe_add[1]()
                maybe_add[2]()
                maybe_add[3]()
                
            distance += 1
        return distance - 1


    @parameter
    fn part1() -> Int64:
        return bfs(0,2)

    @parameter
    fn part2() -> Int64:
        return bfs(3,9)

    minibench[part1]("part1")
    minibench[part2]("part2")

    print(tiles.length(), "tokens", dimx, dimy)
    print(work.size, "work buffers")
