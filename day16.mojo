from algorithm import parallelize
from parser import *
from wrappers import minibench
from array import Array
from os.atomic import Atomic


fn main() raises:
    f = open("day16.txt", "r")
    tiles = make_parser["\n"](f.read())
    dimx = tiles.length()
    dimy = tiles[0].size
    scnt = dimx * 2 + dimy * 2
    ignored = Array[DType.int16](1000)
    var mmax = Atomic[DType.int64](0)

    @always_inline
    fn bidx(x: Int32, y: Int32) -> Int32:
        if (y + 1) % 111 != 0:
            return ((x + 1) % 2) * 110 + y + 1
        return 220 + ((y + 1) % 2) * 110 + x + 1

    @parameter
    fn bfs(start: SIMD[DType.int32, 4]) -> Int64:
        var current = Array[DType.int32](1000)
        var next = Array[DType.int32](1000)
        var visited = Array[DType.int8](110 * 110)
        (x, y, dx, dy) = (start[0], start[1], start[2], start[3])
        b = bidx(x, y)
        if ignored[int(b)] != 0:
            return 0
        var curs = 4
        var warm = 0
        current.store[width=4](0, start)
        while curs > 0:
            var nexs = 0
            for i in range(0, curs, 4):
                tmp = current.load[width=4](i)
                (x, y, dx, dy) = (tmp[0], tmp[1], tmp[2], tmp[3])
                # move out of the previous tile
                x += dx
                y += dy
                # out of bounds
                if x < 0 or y < 0 or x >= dimx or y >= dimy:
                    ignored[int(bidx(x, y))] = 1
                    continue
                # if we already _entered_ this tile this way, skip
                op = int(y * dimx + x)
                bp = int(1 << (dy + 1) * 3 + (dx + 1))  # maps to bits 5,3,2,0
                if visited[op] & bp != 0:
                    continue
                if visited[op] == 0:
                    warm += 1
                visited[op] |= bp
                t = tiles[int(y)][int(x)]
                alias cDot = ord(".")
                alias cPipe = ord("|")
                alias cDash = ord("-")
                alias cSlash = ord("/")
                alias cBack = ord("\\")
                # empty or ignored splitter
                if t == cDot or (t == cPipe and dx == 0) or (t == cDash and dy == 0):
                    next.store[width=4](nexs, SIMD[DType.int32, 4](x, y, dx, dy))
                    nexs += 4
                # split vertically
                elif t == cPipe and dx != 0:
                    next.store[width=4](nexs, SIMD[DType.int32, 4](x, y, 0, 1))
                    next.store[width=4](nexs + 4, SIMD[DType.int32, 4](x, y, 0, -1))
                    nexs += 8
                # or horizontally
                elif t == cDash and dy != 0:
                    next.store[width=4](nexs, SIMD[DType.int32, 4](x, y, 1, 0))
                    next.store[width=4](nexs + 4, SIMD[DType.int32, 4](x, y, -1, 0))
                    nexs += 8
                # mirror 1
                elif t == cSlash:
                    next.store[width=4](nexs, SIMD[DType.int32, 4](x, y, -dy, -dx))
                    nexs += 4
                # mirror 2
                elif t == cBack:
                    next.store[width=4](nexs, SIMD[DType.int32, 4](x, y, dy, dx))
                    nexs += 4
            curs = nexs
            swap(current.data, next.data)
        return warm

    @parameter
    fn start(i: Int) -> SIMD[DType.int32, 4]:
        if i < dimx:
            return SIMD[DType.int32, 4](i, -1, 0, 1)
        if i < 2 * dimx:
            return SIMD[DType.int32, 4](i - dimx, dimy, 0, 1)
        if i < 2 * dimx + dimy:
            return SIMD[DType.int32, 4](-1, i - 2 * dimx, 1, 0)
        return SIMD[DType.int32, 4](dimy, i - 2 * dimx - dimy, -1, 0)

    @parameter
    fn part1() -> Int64:
        ignored[int(bidx(-1, 0))] = 0
        return bfs(SIMD[DType.int32, 4](-1, 0, 1, 0))

    alias chunk_size = 10

    @parameter
    fn step2(i: Int):
        var lmax: Int64 = 0
        for j in range(chunk_size):
            lmax = max(lmax, bfs(start(i * chunk_size + j)))
        mmax.max(lmax)

    @parameter
    fn part2() -> Int64:
        ignored.zero()
        for i in range(scnt // chunk_size):
            step2(i)
        return mmax.value

    @parameter
    fn part2_parallel() -> Int64:
        ignored.zero()
        parallelize[step2](scnt // chunk_size)
        return mmax.value

    minibench[part1]("part1")
    minibench[part2]("part2")
    minibench[part2_parallel]("part2_parallel")

    print(tiles.length(), "tokens", dimx, dimy, scnt)
    print(ignored.bytecount(), "temp size", mmax.value)
