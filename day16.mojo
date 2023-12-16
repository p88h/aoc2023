from algorithm import parallelize
from parser import *
from wrappers import minibench
from array import Array
from math import max


fn main() raises:
    let f = open("day16.txt", "r")
    let tiles = make_parser['\n'](f.read())
    let dimx = tiles.length()
    let dimy = tiles[0].size
    var ignored = Array[DType.int8](1000)
    var order = Array[DType.int32](4000)
    var scnt : Int = 0
    var warm : Int64 = 0
    var mmax = Atomic[DType.int64](0)

    fn bidx(x: Int32, y: Int32) -> Int32:
        if (y+1) % 111 != 0:
            return ((x+1)%2)*110+y+1
        return 220+((y+1)%2)*110+x+1

    @parameter
    fn bfs(start: SIMD[DType.int32,4]) -> Int64:
        var current = Array[DType.int32](1000)
        var next = Array[DType.int32](1000)
        var visited = Array[DType.int8](110*110)
        var x: Int32
        var y: Int32
        var dx: Int32
        var dy: Int32
        (x,y,dx,dy) = (start[0], start[1], start[2], start[3])
        let b = bidx(x,y)
        if ignored[b.to_int()] != 0:
            return 0
        var curs = 4
        warm = 0
        current.data.aligned_simd_store[4,4](0, start)
        while curs > 0:
            var nexs = 0
            for i in range(0,curs,4):
                let tmp = current.data.aligned_simd_load[4,4](i)
                (x,y,dx,dy) = (tmp[0], tmp[1], tmp[2], tmp[3])
                # move out of the previous tile
                x += dx
                y += dy
                # out of bounds
                if x < 0 or y < 0 or x >= dimx or y >= dimy:
                    ignored[bidx(x,y).to_int()] = 1
                    continue
                # if we already _entered_ this tile this way, skip
                let op = (y*dimx + x).to_int()
                let bp = (1 << (dy+1)*3 + (dx+1)).to_int() # maps to bits 5,3,2,0 
                if visited[op] & bp != 0:
                    continue
                if visited[op] == 0:
                    warm += 1
                visited[op] |= bp
                let t = tiles[y.to_int()][x.to_int()] 
                alias cDot = ord('.')
                alias cPipe = ord('|')
                alias cDash = ord('-')
                alias cSlash = ord('/')
                alias cBack = ord('\\')
                # empty or ignored splitter
                if t == cDot or (t == cPipe and dx == 0) or (t == cDash and dy == 0):
                    next.data.aligned_simd_store[4,4](nexs,SIMD[DType.int32,4](x,y,dx,dy))
                    nexs += 4
                # split vertically
                elif t == cPipe and dx != 0:
                    next.data.aligned_simd_store[4,4](nexs,SIMD[DType.int32,4](x,y,0,1))
                    next.data.aligned_simd_store[4,4](nexs+4,SIMD[DType.int32,4](x,y,0,-1))
                    nexs += 8
                # or horizontally
                elif t == cDash and dy != 0:
                    next.data.aligned_simd_store[4,4](nexs,SIMD[DType.int32,4](x,y,1,0))
                    next.data.aligned_simd_store[4,4](nexs+4,SIMD[DType.int32,4](x,y,-1,0))
                    nexs += 8
                # mirror 1
                elif t == cSlash:
                    next.data.aligned_simd_store[4,4](nexs,SIMD[DType.int32,4](x,y,-dy,-dx))
                    nexs += 4
                # mirror 2
                elif t == cBack:
                    next.data.aligned_simd_store[4,4](nexs,SIMD[DType.int32,4](x,y,dy,dx))
                    nexs += 4
            curs = nexs
            current.swap(next)
        return warm
    
    @parameter
    fn prep() -> Int64:
        var o : Int = 0 
        for x in range(dimx):
            order.data.aligned_simd_store[4,4](o, SIMD[DType.int32,4](x,-1,0,1))
            order.data.aligned_simd_store[4,4](o+4, SIMD[DType.int32,4](x,dimy,0,-1))
            o += 8
        for y in range(dimy):
            order.data.aligned_simd_store[4,4](o, SIMD[DType.int32,4](-1,0,1,0))
            order.data.aligned_simd_store[4,4](o+4, SIMD[DType.int32,4](dimx,0,-1,0))
            o += 8
        return o

    @parameter
    fn part1() -> Int64:
        return bfs(SIMD[DType.int32,4](-1,0,1,0))

    @parameter
    fn step2(i: Int):
        mmax.max(bfs(order.data.aligned_simd_load[4,4](i*4)))

    @parameter
    fn part2() -> Int64:
        ignored.clear()
        for i in range(scnt):
            step2(i)            
        return mmax.value

    @parameter
    fn part2_parallel() -> Int64:
        ignored.clear()
        parallelize[step2](scnt, 8)
        return mmax.value

    scnt = prep().to_int() // 4
    minibench[part1]("part1")
    minibench[part2]("part2")
    minibench[part2_parallel]("part2_parallel")

    print(tiles.length(), "tokens", dimx, dimy, warm)
    print(ignored.size, "temp buffers size")
    print(order.size, "start point buffer")
