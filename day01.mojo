from parser import Parser
from os.atomic import Atomic
from algorithm import parallelize
from utils.vector import DynamicVector
import benchmark

struct MultiMatcher:
    var fcv: DynamicVector[Int8]
    var pfx: DynamicVector[Int32]
    var msk: DynamicVector[Int32]
    
    fn __init__(inout self):
        self.fcv = DynamicVector[Int8](10)
        self.pfx = DynamicVector[Int32](10)
        self.msk = DynamicVector[Int32](10)
    
    fn add(inout self, s: String):
        let l = len(s)
        self.fcv.push_back(s._buffer[l - 1])
        var r: Int32 = 0
        var m: Int32 = 0
        for i in range(l-1):
            r = (r << 8) + s._buffer[i].to_int()
            m = (m << 8) + 0xFF
        self.pfx.push_back(r)
        self.msk.push_back(m)
    
    fn check(self, cc: Int8, prev: Int32) -> Int:
        for i in range(10):
            if self.fcv[i] == cc and (prev & self.msk[i]) == self.pfx[i]:
                return i
        return -1


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
            for i in range(len(s)):
                let c = s._buffer[i]
                if c >= ord("0") and c <= ord("9"):
                    d1 = c - zero
                    break
            for i in range(len(s)-1,-1,-1):
                let c = s._buffer[i]
                if c >= ord("0") and c <= ord("9"):
                    d2 = c - zero
                    break
            a1 += d1.to_int() * 10 + d2.to_int()

        var m = MultiMatcher()
        var r = MultiMatcher()

        fn reverse(s: String) -> String:
            var r = String()
            for i in range(len(s)):
                r += s[len(s)-i-1]
            return r

        @parameter
        fn store(s: String):
            m.add(s)
            r.add(reverse(s))
        store("zero"); store("one"); store("two"); store("three"); store("four")
        store("five"); store("six"); store("seven"); store("eight"); store("nine")

        @parameter
        fn digitize2(l: Int):
            let s = p.get(l)            
            var d1 = 0
            var d2 = 0
            let zero = SIMD[DType.int8, 1](ord("0"))
            # last four characters code
            var l4 : Int32 = 0
            for i in range(len(s)):
                let c = s._buffer[i]
                var d = -1
                if c >= ord("0") and c <= ord("9"):
                    d = (c - zero).to_int()
                else:
                    d = m.check(c, l4)
                # update code
                l4 = (l4 << 8) + c.to_int()
                if d >= 0:
                    d1 = d
                    break
            l4 = 0
            for i in range(len(s)-1,-1,-1):
                let c = s._buffer[i]
                var d = -1
                if c >= ord("0") and c <= ord("9"):
                    d = (c - zero).to_int()
                else:
                    d = r.check(c, l4)
                # update code
                l4 = (l4 << 8) + c.to_int()
                if d >= 0:
                    d2 = d
                    break

            a2 += d1 * 10 + d2
        
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
