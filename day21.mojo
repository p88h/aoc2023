from parser import *
from wrappers import minibench
from array import Array
from utils.loop import unroll

@always_inline
fn trisum(rem: Int, odds: Int) -> Int:
    fullsum = (rem) * (1 + rem) // 2
    evensum = (rem // 2) * (1 + rem // 2)
    if odds:
        return fullsum - evensum
    else:
        return evensum

@always_inline
fn oddcnt(rem: Int, odds: Int) -> Int:
    if rem % 2 == 0:
        return rem // 2
    return rem // 2 + odds

fn main() raises:
    f = open("day21.txt", "r")
    tiles = make_parser["\n"](f.read())
    dimx = tiles.length()
    dimy = tiles[0].size
    alias maxq = 256*1024
    alias maxw = 144
    work = Array[DType.int16](maxq)
    visited = Array[DType.int16](maxw * maxw * 9)
    var start: Int64

    @parameter
    fn parse() -> Int64:
        alias cS = ord("S")
        for y in range(dimy):
            for x in range(dimx):
                if tiles[y][x] == cS:
                    return (y << 16) + x
        return -1

    @parameter
    fn bfs(start: Int32, steps: Int, limx: Int, limy: Int) -> Int64:
        alias cHash = ord("#")
        alias IntPair = SIMD[DType.int64, 2]
        alias dirs = List[IntPair](IntPair(-1, 0), IntPair(1, 0), IntPair(0, -1), IntPair(0, 1))
        sy = int(start) >> 16
        sx = int(start) & 0xFFFF
        var current = 0
        var limit = 2
        var total = 0
        work[0] = sy
        work[1] = sx
        visited.zero()
        while current < limit:  # aaand ?
            y = int(work[current])
            x = int(work[current + 1])
            p = y * limx + x
            distance = visited[p]
            # ... and break here
            if distance > steps or distance > dimx + dimx // 2 + 1:
                break
            current += 2
            if dimx == limx and distance % 2 == steps % 2:
                total += 1

            @parameter
            fn maybe_add[ndir: Int]():
                nx = x + int(dirs[ndir][0])
                ny = y + int(dirs[ndir][1])
                if nx < 0 or nx >= limx or ny < 0 or ny >= limy:
                    return
                np = ny * limx + nx
                if tiles[ny % dimy][nx % dimx] == cHash or visited[np] != 0:
                    return
                visited[np] = distance + 1
                work[limit] = ny
                work[limit + 1] = nx
                limit += 2
            
            unroll[maybe_add, range(4)]()


        if dimx == limx:
            return total - 1

        for y in range(dimy):
            for x in range(dimx):
                cp = (y + dimx) * limx + x + dimx
                if visited[cp] == 0 and not (x + dimx == sx and y + dimy == sy):
                    continue
                alias ofs1 = List[IntPair](IntPair(-1, 0), IntPair(1, 0), IntPair(0, -1), IntPair(0, 1))
                @parameter
                fn scan1[i: Int]():
                    np = cp + dimx * int(ofs1[i][0]) + dimx * limx * int(ofs1[i][1])
                    if visited[np] == 0:
                        visited[np] = visited[cp] + dimx
                    cd = int(visited[np])
                    rem = (steps - cd) // dimx
                    total += oddcnt(rem + 1, cd % 2)
                unroll[scan1, range(4)]()

                alias ofs2 = List[IntPair](IntPair(-1, -1), IntPair(-1, 1), IntPair(1, -1), IntPair(1, 1))
                @parameter
                fn scan2[i: Int]():
                    np = cp + dimx * int(ofs2[i][0]) + dimx * limx * int(ofs2[i][1])
                    if visited[np] == 0:
                        np1 = cp + dimx * int(ofs2[i][0])
                        np2 = cp + dimx * limx * int(ofs2[i][1])
                        visited[np] = min(visited[np1], visited[np2]) + dimx
                    cd = int(visited[np])
                    rem = (steps - cd) // dimx
                    total += trisum(rem + 1, cd % 2)
                unroll[scan2, range(4)]()

                total += int(visited[cp]) % 2
        return total

    @parameter
    fn part1() -> Int64:
        return bfs(int(start), 64, dimx, dimy)

    @parameter
    fn part2() -> Int64:
        ofs = (dimy << 16) + dimx
        return bfs(int(start) + ofs, 26501365, dimx * 3, dimy * 3)

    start = parse()
    minibench[part1]("part1")
    minibench[part2]("part2")

    print(tiles.length(), "tokens", dimx, dimy)
    print(work.bytecount() + visited.bytecount(), "work buffers")
