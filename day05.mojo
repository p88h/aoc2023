from parser import *
from collections import List
from wrappers import minibench


# Yay. Mojo 0.6.0 arrived, with collection traits, so now we can do this
# and then stuff these structs in vectors.
struct TransformStep(CollectionElement):
    var map_src: List[Int64]
    var map_dst: List[Int64]
    var map_len: List[Int64]

    fn __init__(inout self):
        self.map_src = List[Int64]()
        self.map_dst = List[Int64]()
        self.map_len = List[Int64]()

    # And we just need all of this boilerplate code.
    fn __moveinit__(inout self, owned other: Self):
        self.map_src = other.map_src^
        self.map_dst = other.map_dst^
        self.map_len = other.map_len^

    fn __copyinit__(inout self, other: Self):
        self.map_src = other.map_src
        self.map_dst = other.map_dst
        self.map_len = other.map_len

    fn __del__(owned self):
        pass

    fn clear(inout self):
        self.map_src.clear()
        self.map_dst.clear()
        self.map_len.clear()

    # poor man sort.
    fn append(inout self, src: Int64, dst: Int64, rlen: Int64):
        var pos = self.map_src.size
        self.map_src.append(0)
        self.map_dst.append(0)
        self.map_len.append(0)
        while pos > 0 and self.map_src[pos - 1] > src:
            self.map_src[pos] = self.map_src[pos - 1]
            self.map_dst[pos] = self.map_dst[pos - 1]
            self.map_len[pos] = self.map_len[pos - 1]
            pos -= 1
        self.map_src[pos] = src
        self.map_dst[pos] = dst
        self.map_len[pos] = rlen

    fn print(self):
        print("(", end="")
        for i in range(self.map_src.size):
            print(self.map_src[i], self.map_dst[i], self.map_len[i], ", ", end="")
        print(")")


fn main() raises:
    f = open("day05.txt", "r")
    lines = make_parser["\n"](f.read())
    var transform = List[TransformStep]()
    var numbers = List[Int64]()

    @parameter
    fn parse() -> Int64:
        s = make_parser[" "](lines.get(0))
        numbers.clear()
        for i in range(1, s.length()):
            numbers.append(atoi(s.get(i)))
        transform.clear()
        var cur = TransformStep()
        for l in range(3, lines.length()):
            line = lines.get(l)
            if not line.size:
                continue
            alias cOlon = ord(":")
            if line[line.size - 1] == cOlon:  # ":"
                transform.append(cur^)
                cur = TransformStep()
            else:
                lp = make_parser[" "](line)
                dst = atoi(lp.get(0))
                src = atoi(lp.get(1))
                rl = atoi(lp.get(2))
                cur.append(src, dst, rl)
        transform.append(cur^)
        return transform.size

    # Take numbers of matches, exponentiate, sum up
    @parameter
    fn part1() -> Int64:
        var work: List[Int64] = numbers
        for si in range(transform.size):
            step = transform[si]
            var next = List[Int64]()
            for i in range(work.size):
                var n = work[i]
                for j in range(step.map_src.size):
                    src = step.map_src[j]
                    dst = step.map_dst[j]
                    l = step.map_len[j]
                    if n >= src + l:
                        continue
                    if n < src:
                        next.append(n)
                    else:
                        next.append(n + dst - src)
                    n = -1
                    break
                if n >= 0:
                    next.append(n)
            work = next^
        var ret1 = work[0]
        for i in range(work.size):
            ret1 = min(ret1, work[i])
        return ret1

    # Computes the ticket counts in draws table on the go
    @parameter
    fn part2() -> Int64:
        alias IntPair = SIMD[DType.int64, 2]
        var work = List[IntPair](capacity = numbers.size // 2)
        for i in range(numbers.size // 2):
            work.append(IntPair(numbers[2 * i], numbers[2 * i] + numbers[2 * i + 1] - 1))
        for si in range(transform.size):
            step = transform[si]
            var next = List[IntPair](capacity = work.size * 2)
            for i in range(work.size):
                var a: Int64                
                (a, b) = work[i][0], work[i][1]
                for j in range(step.map_src.size):
                    src = step.map_src[j]
                    dst = step.map_dst[j]
                    l = step.map_len[j]
                    ofs = dst - src
                    if a >= src + l:
                        continue
                    if a < src:  # some is untranslated
                        next.append(IntPair(a, src - 1))
                        a = src
                    # a >= src.
                    if b >= src + l:  # some range remains
                        next.append(IntPair(a + ofs, (src + l - 1) + ofs))
                        a = src + l
                    else:  # everything fits
                        next.append(IntPair(a + ofs, b + ofs))
                        a = b + 1
                        break
                if a <= b:  # some was left untranslated
                    next.append(IntPair(a, b))
            work = next^
        var ret2 = work[0][0]
        for i in range(work.size):
            ret2 = min(ret2, work[i][0])
        return ret2

    # This part doesn't seem to benefit much from parallelization, so just run benchmarks.
    minibench[parse]("parse")
    minibench[part1]("part1")
    minibench[part2]("part2")

    print(lines.length(), "rows")
    print(numbers.size, "numbers")
    print(transform.size, "transform steps")
