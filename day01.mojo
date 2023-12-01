from parser import Parser
from os.atomic import Atomic
from algorithm import parallelize
import benchmark

fn main():
    try:
        let f = open("day01.txt", "r")
        let p = Parser(f.read())
        var a1 = Atomic[DType.int32](0)
        var a2 = Atomic[DType.int32](0)

        @parameter
        fn digitize1(l: Int):
            let s = p.get(l)
            var d1 = SIMD[DType.int8, 1](0)
            var d2 = SIMD[DType.int8, 1](0)
            let zero = SIMD[DType.int8, 1](ord("0"))
            var first = True
            for i in range(len(s)):
                let c = s._buffer[i]
                if c >= ord("0") and c <= ord("9"):
                    d2 = c - zero
                    if first:
                        d1 = c - zero
                        first = False
            a1 += d1.to_int() * 10 + d2.to_int()

        fn encode(s: String) -> Int32:
            var ret: Int32 = 0
            for i in range(len(s)):
                ret = (ret << 8) + s._buffer[i].to_int()
            return ret

        let p1 = encode("on")
        let p2 = encode("tw")
        let p3 = encode("thre")
        let p4 = encode("fou")
        let p5 = encode("fiv")
        let p6 = encode("si")
        let p7 = encode("seve")
        let p8 = encode("eigh")
        let p9 = encode("nin")
        let p0 = encode("zer")

        @parameter
        fn digitize2(l: Int):
            let s = p.get(l)
            var d1 = SIMD[DType.int8, 1](0)
            var d2 = SIMD[DType.int8, 1](0)
            let zero = SIMD[DType.int8, 1](ord("0"))
            var first = True
            var l2 : Int32 = 0
            var l3 : Int32 = 0
            var l4 : Int32 = 0
            for i in range(len(s)):
                let c = s._buffer[i]
                var d = SIMD[DType.int8, 1](-1)            
                if c >= ord("0") and c <= ord("9"):
                    d = c - zero
                else:
                    if c == ord('e'):
                        if l2 == p1: d = 1
                        if l4 == p3: d = 3
                        if l3 == p5: d = 5
                        if l3 == p9: d = 9
                    if c == ord('o'):
                        if l2 == p2: d = 2
                        if l3 == p9: d = 0
                    if c == ord('r') and l3 == p4: d = 4
                    if c == ord('x') and l2 == p6: d = 6
                    if c == ord('n') and l4 == p7: d = 7
                    if c == ord('t') and l4 == p8: d = 8
                l2 = ((l2 << 8) + c.to_int()) & 0xFFFF
                l3 = ((l3 << 8) + c.to_int()) & 0xFFFFFF
                l4 = (l4 << 8) + c.to_int()
                if d >= 0:
                    if first:
                        d1 = d
                        first = False
                    d2 = d
            a2 += d1.to_int() * 10 + d2.to_int()
        
        @parameter
        fn part1():
            for l in range(p.length()): digitize1(l)

        @parameter
        fn part1_parallel():
            parallelize[digitize1](p.length(), 24)

        @parameter
        fn part2():
            for l in range(p.length()): digitize2(l)

        @parameter
        fn part2_parallel():
            parallelize[digitize2](p.length(), 24)

        part1()
        print(a1.value.to_int())
        part2()
        print(a2.value.to_int())

        let b1 = benchmark.run[part1]().mean["ms"]()
        let b1p = benchmark.run[part1_parallel]().mean["ms"]()
        print("Part 1: ", b1, "ms, parallelized:", b1p, "ms")
        let b2 = benchmark.run[part2]().mean["ms"]()
        let b2p = benchmark.run[part2_parallel]().mean["ms"]()
        print("Part 2: ", b2, "ms, parallelized:", b2p, "ms")

        print(p.length())


    except e:
        print(e)
