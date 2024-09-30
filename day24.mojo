from parser import *
from wrappers import minibench
from array import Array
from algorithm import parallelize
from os.atomic import Atomic

fn gauss[n: Int](inout a: Array[DType.float64]) -> SIMD[DType.float64, 8]:
    var h = 0
    var k = 0
    while h < n and k < n + 1:
        var g = h
        # find maximum
        for i in range(h+1,n):
            if abs(a[i*8+k]) > abs(a[g*8+k]):
                g = i
        if abs(a[g*8+k]) == 0:
            k += 1
            continue
        t = a.load[width=8](g*8)
        # swap g,h rows
        if g != h:
            t2 = a.load[width=8](h*8)
            a.store[width=8](g*8,t2)
            a.store[width=8](h*8,t)
        # zero out below pivot
        for i in range(h+1,n):
            var r = a.load[width=8](i*8)
            f = r[k] / t[k]
            r -= t * f
            r[k] = 0
            a.store[width=8](i*8, r)
        h += 1 
        k += 1
    # resolve
    for i in range(n-1,-1,-1):
        var r = a.load[width=8](i*8)
        for j in range(i+1,n):
            q = a.load[width=8](j*8)
            r -= r[j]*q
        r[n] /= r[i]
        r[i] = 1
        a.store[width=8](i*8, r)
    var ret = SIMD[DType.float64, 8](0)
    for i in range(n):
        ret[i] = a[i*8+n]
    return ret

fn main() raises:
    f = open("day24.txt", "r")
    lines = make_parser["\n"](f.read())
    params = Array[DType.float64](4096)
    count = lines.length()
    rc = 0
    var asum = Atomic[DType.int32](0)

    @parameter
    fn parse() -> Int64:
        for l in range(lines.length()):
            p = atomi[8, DType.float64](lines[l])
            params.store[width=8](l*8, p)
        return lines.length()

    alias chunk_size = 6

    @parameter
    fn part1_sub(o: Int):
        alias r1 = 200000000000000
        alias r2 = 400000000000000
        var cnt = 0
        for i in range(o*chunk_size,o*chunk_size+chunk_size):
            p1 = params.load[width=8](i * 8)
            a1 = p1[4] / p1[3]
            b1 = p1[1] - a1 * p1[0]
            for j in range(i + 1, count):
                p2 = params.load[width=8](j * 8)
                a2 = p2[4] / p2[3]
                b2 = p2[1] - a2 * p2[0]
                if a1 == a2:
                    continue
                x = (b2 - b1) / (a1 - a2)
                y = a1 * x + b1
                t1 = (x - p1[0]) / p1[3]
                t2 = (x - p2[0]) / p2[3]
                if t1 > 0 and t2 > 0 and x >= r1 and x <= r2 and y >= r1 and y <= r2:
                    cnt += 1
        asum += cnt

    @parameter
    fn part1() -> Int64:
        asum = 0
        for i in range(count // chunk_size):
            part1_sub(i)
        return int(asum.value)

    @parameter
    fn part1_parallel() -> Int64:
        asum = 0
        parallelize[part1_sub](count // chunk_size, 24)
        return int(asum.value)

    @parameter
    fn part2() -> Int64:
        px = VariadicList[Float64](params[0], params[8], params[16])
        py = VariadicList[Float64](params[1], params[9], params[17])
        pz = VariadicList[Float64](params[2], params[10], params[18])
        vx = VariadicList[Float64](params[3], params[11], params[19])
        vy = VariadicList[Float64](params[4], params[12], params[20])
        vz = VariadicList[Float64](params[5], params[13], params[21])
        x = VariadicList[Float64](
            (py[0] * vx[0] - py[1] * vx[1]) - (px[0] * vy[0] - px[1] * vy[1]),
            (py[0] * vx[0] - py[2] * vx[2]) - (px[0] * vy[0] - px[2] * vy[2]),
            (pz[0] * vx[0] - pz[1] * vx[1]) - (px[0] * vz[0] - px[1] * vz[1]),
            (pz[0] * vx[0] - pz[2] * vx[2]) - (px[0] * vz[0] - px[2] * vz[2]),
            (pz[0] * vy[0] - pz[1] * vy[1]) - (py[0] * vz[0] - py[1] * vz[1]),
            (pz[0] * vy[0] - pz[2] * vy[2]) - (py[0] * vz[0] - py[2] * vz[2]),
        )
        var a = Array[DType.float64](64)
        a.store[width=8](0,SIMD[DType.float64,8](vy[1] - vy[0], vx[0] - vx[1], 0, py[0] - py[1], px[1] - px[0], 0, x[0],0))
        a.store[width=8](8,SIMD[DType.float64,8](vy[2] - vy[0], vx[0] - vx[2], 0, py[0] - py[2], px[2] - px[0], 0, x[1],0))
        a.store[width=8](16,SIMD[DType.float64,8](vz[1] - vz[0], 0, vx[0] - vx[1], pz[0] - pz[1], 0, px[1] - px[0], x[2],0))
        a.store[width=8](24,SIMD[DType.float64,8](vz[2] - vz[0], 0, vx[0] - vx[2], pz[0] - pz[2], 0, px[2] - px[0], x[3],0))
        a.store[width=8](32,SIMD[DType.float64,8](0, vz[1] - vz[0], vy[0] - vy[1], 0, pz[0] - pz[1], py[1] - py[0], x[4],0))
        a.store[width=8](40,SIMD[DType.float64,8](0, vz[2] - vz[0], vy[0] - vy[2], 0, pz[0] - pz[2], py[2] - py[0], x[5],0))
        ret = gauss[6](a)
        rc += int(ret[0]) + 1 # force compute
        return int(round(ret[0]+ret[1]+ret[2]))

    minibench[parse]("parse")
    minibench[part1]("part1")
    minibench[part1_parallel]("part1_parallel")
    minibench[part2]("part2")

    print(lines.length(), "lines", count)
    print(params.bytecount(), "params size", asum.value, rc)
