from parser import Parser
from utils.vector import DynamicVector
from math import min, max
from wrappers import minibench


# Yay. Mojo 0.6.0 arrived, with collection traits, so now we can do this
# and then stuff these structs in vectors.
struct TransformStep(CollectionElement):
    var map_src: DynamicVector[Int64]
    var map_dst: DynamicVector[Int64]
    var map_len: DynamicVector[Int64]

    fn __init__(inout self):
        self.map_src = DynamicVector[Int64](20)
        self.map_dst = DynamicVector[Int64](20)
        self.map_len = DynamicVector[Int64](20)

    # And we just need all of this boilerplate code.
    fn __moveinit__(inout self, owned other: Self):
        self.map_src = other.map_src ^
        self.map_dst = other.map_dst ^
        self.map_len = other.map_len ^

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
        self.map_src.push_back(0)
        self.map_dst.push_back(0)
        self.map_len.push_back(0)
        while pos > 0 and self.map_src[pos - 1] > src:
            self.map_src[pos] = self.map_src[pos - 1]
            self.map_dst[pos] = self.map_dst[pos - 1]
            self.map_len[pos] = self.map_len[pos - 1]
            pos -= 1
        self.map_src[pos] = src
        self.map_dst[pos] = dst
        self.map_len[pos] = rlen

    fn print(self):
        print_no_newline("(")
        for i in range(self.map_src.size):
            print_no_newline(self.map_src[i], self.map_dst[i], self.map_len[i], ", ")
        print(")")


fn atoi(s: StringRef) -> Int64:
    alias zero = 48
    var ret: Int64 = 0
    for i in range(s.length):
        ret = ret * 10 + ord(s[i]) - zero
    return ret


fn main() raises:
    let f = open("day05.txt", "r")
    let lines = Parser(f.read())
    var transform = DynamicVector[TransformStep](10)
    var numbers = DynamicVector[Int64](20)
    var ret1 = Atomic[DType.int64](0)
    var ret2 = Atomic[DType.int64](0)

    @parameter
    fn parse():
        let s = Parser(lines.get(0), " ")
        numbers.clear()
        for i in range(1, s.length()):
            numbers.push_back(atoi(s.get(i)))
        transform.clear()
        var cur = TransformStep()
        for l in range(3, lines.length()):
            let line = lines.get(l)
            if not line:
                continue
            if line[line.length - 1] == ":":
                transform.push_back(cur ^)
                cur = TransformStep()
            else:
                let lp = Parser(line, " ")
                let dst = atoi(lp.get(0))
                let src = atoi(lp.get(1))
                let rl = atoi(lp.get(2))
                cur.append(src, dst, rl)
        transform.push_back(cur ^)

    # Take numbers of matches, exponentiate, sum up
    @parameter
    fn part1():
        var work: DynamicVector[Int64] = numbers
        for si in range(transform.size):
            let step = transform[si]
            var next = DynamicVector[Int64]()
            for i in range(work.size):
                var n = work[i]
                for j in range(step.map_src.size):
                    let src = step.map_src[j]
                    let dst = step.map_dst[j]
                    let l = step.map_len[j]
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
            work = next ^
        ret1 = work[0]
        for i in range(work.size):
            ret1.min(work[i])

    # Computes the ticket counts in draws table on the go
    @parameter
    fn part2():
        var work = DynamicVector[Tuple[Int64, Int64]](numbers.size // 2)
        for i in range(numbers.size // 2):
            work.push_back((numbers[2 * i], numbers[2 * i] + numbers[2 * i + 1] - 1))
        for si in range(transform.size):
            let step = transform[si]
            var next = DynamicVector[Tuple[Int64, Int64]](work.size * 2)
            for i in range(work.size):
                var a: Int64
                let b: Int64
                (a, b) = work[i]
                for j in range(step.map_src.size):
                    let src = step.map_src[j]
                    let dst = step.map_dst[j]
                    let l = step.map_len[j]
                    let ofs = dst - src
                    if a >= src + l:
                        continue
                    if a < src:  # some is untranslated
                        next.push_back((a, src - 1))
                        a = src
                    # a >= src.
                    if b >= src + l:  # some range remains
                        next.push_back((a + ofs, (src + l - 1) + ofs))
                        a = src + l
                    else:  # everything fits
                        next.push_back((a + ofs, b + ofs))
                        a = b + 1
                        break
                if a <= b:  # some was left untranslated
                    next.push_back((a, b))
            work = next ^
        ret2 = work[0].get[0, Int64]()
        for i in range(work.size):
            ret2.min(work[i].get[0, Int64]())

    # This part doesn't seem to benefit much from parallelization, so just run benchmarks.
    minibench[parse]("parse", 1000, "ms")
    minibench[part1]("part1", 1000, "μs")
    print(ret1)
    minibench[part2]("part2", 1000, "μs")
    print(ret2)

    print(lines.length(), "rows")
    print(numbers.size, "numbers")
    print(transform.size, "transform steps")
