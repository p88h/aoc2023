from parser import *
from wrappers import minibench
from array import Array
from memory.buffer import Buffer
from quicksort import qsort
from math import min, max


fn main() raises:
    let f = open("day22.txt", "r")
    let lines = make_parser["\n"](f.read())
    let lcnt = lines.length()
    # lots of arrays
    let bricks = Array[DType.int16](lcnt * 8)
    let deps = Array[DType.int16](lcnt * 8)
    let hmap = Array[DType.int16](100)
    let bmap = Array[DType.int16](100)
    let supp = Array[DType.int16](lcnt)
    let work = Array[DType.int16](lcnt)
    let safe = Array[DType.int16](lcnt, 1)

    @parameter
    fn parse() -> Int64:
        for i in range(lcnt):
            let line = lines[i]
            var vec = atomi[8, DType.int16, False, False](line).rotate_right[1]()
            let v1 = vec.slice[4](0).rotate_right[1]()
            let v2 = vec.slice[4](4).rotate_right[2]()
            if v2[0] < v1[0]:
                vec = v2.join(v1)
            else:
                vec = v1.join(v2)
            bricks.aligned_simd_store(i * 8, vec)
        qsort[8, DType.int16, 1](bricks)
        return lcnt
    
    @parameter
    fn reset():
        hmap.clear()
        bmap.clear()
        safe.fill(1)
        for k in range(lcnt):
            deps[k*8] = 0

    @parameter
    fn drop(idx: Int):
        var vec = bricks.aligned_simd_load[8](idx * 8)
        var rng = SIMD[DType.int16, 16](0)
        var rl = 0
        if vec[2] != vec[6]:
            for x in range(vec[2], vec[6] + 1):
                rng[rl] = x + vec[3] * 10
                rl += 1
        else:
            for y in range(vec[3], vec[7] + 1):
                rng[rl] = vec[2] + y * 10
                rl += 1
        # print(idx,vec, rl, rng)
        if vec[0] > 1:
            var mh: Int16 = 0
            for i in range(rl):
                mh = max(mh, hmap[rng[i].to_int()])
            if mh < vec[0] - 1:
                alias sub = SIMD[DType.int16, 8](1, 0, 0, 0, 1, 0, 0, 0)
                vec -= sub * (vec[0] - 1 - mh)
        var sup = SIMD[DType.int16, 8](0)
        var prev : Int16 = -1
        for i in range(rl):
            let ri = rng[i].to_int()
            if vec[0] > 1 and hmap[ri] == vec[0] - 1:
                let base = bmap[ri]
                if base != prev:
                    sup[0] += 1
                    sup[sup[0].to_int()] = base
                prev = base
            hmap[ri] = vec[4]
            bmap[ri] = idx
        supp[idx] = sup[0]
        for j in range(sup[0]):
            let k = sup[j+1].to_int()
            deps[k * 8] += 1
            deps[k * 8 + deps[k * 8].to_int()] = idx
        if sup[0] == 1:
            safe[sup[1].to_int()] = 0

    @parameter
    fn explode(start: Int) -> Int:
        var sup2 = Array[DType.int16](lcnt)
        memcpy(sup2.data, supp.data, lcnt)
        work[0] = start
        var pos = 0
        var lim = 1
        while pos < lim:
            let cur = work[pos].to_int()
            pos += 1
            for di in range(deps[cur * 8]):
                let dst = deps[cur * 8 + di + 1].to_int()
                sup2[dst] -= 1
                if sup2[dst] == 0:
                    work[lim] = dst
                    lim += 1
        return lim - 1

    @parameter
    fn part1() -> Int64:
        var sum = 0
        reset()
        for i in range(lcnt):
            drop(i)
        for i in range(lcnt):
            sum += safe[i].to_int()
        return sum
        
    @parameter
    fn part2() -> Int64:
        var cache = Array[DType.int32](lcnt, - 1)
        var esum = 0
        for start in range(lcnt):
            let ecnt : Int
            if safe[start] == 1:
                continue
            if cache[start] >= 0:
                ecnt = cache[start].to_int()
            else:
                ecnt = explode(start)
            if deps[start * 8] == 1:
                cache[deps[start * 8 + 1].to_int()] = ecnt -1
            esum += ecnt
        return esum

    minibench[parse]("parse")
    minibench[part1]("part1")
    minibench[part2]("part2")

    print(lines.length(), "bricks")
    print(bricks.bytecount(), "bricks mem")
    print(hmap.bytecount()+bmap.bytecount()+safe.bytecount(),"drop mem")
    print(deps.bytecount()+supp.bytecount()+work.bytecount(),"deps mem")
