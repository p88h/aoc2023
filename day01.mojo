from parser import Parser
from utils.vector import DynamicVector
from utils.vector import InlinedFixedVector
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

        @parameter
        fn digitize2(l: Int):
            let s = p.get(l)
            var d1 = SIMD[DType.int8, 1](0)
            var d2 = SIMD[DType.int8, 1](0)
            let zero = SIMD[DType.int8, 1](ord("0"))
            var first = True
            for i in range(len(s)):
                let c = s._buffer[i]
                var d = SIMD[DType.int8, 1](-1)
                if c >= ord("0") and c <= ord("9"):
                    d = c - zero
                # this is stupid.
                if s[i:i+3] == "one": d = 1
                if s[i:i+3] == "two": d = 2
                if s[i:i+5] == "three": d = 3
                if s[i:i+4] == "four": d = 4
                if s[i:i+4] == "five": d = 5
                if s[i:i+3] == "six": d = 6
                if s[i:i+5] == "seven": d = 7
                if s[i:i+5] == "eight": d = 8
                if s[i:i+4] == "nine": d = 9
                if s[i:i+4] == "zero": d = 0
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
            parallelize[digitize1](p.length(), 16)

        @parameter
        fn part2():
            for l in range(p.length()): digitize2(l)

        @parameter
        fn part2_parallel():
            parallelize[digitize2](p.length(), 16)

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
