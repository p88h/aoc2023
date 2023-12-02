from parser import Parser
from os.atomic import Atomic
from algorithm import parallelize
from utils.vector import DynamicVector
import benchmark

struct PseudoDict:
    var vals: DynamicVector[Int]
    
    fn __init__(inout self, ival: Int = 0):
        self.vals = DynamicVector[Int](10)
        for i in range(26):
            self.vals.push_back(ival)
    
    fn __moveinit__(inout self, owned existing: Self):
        self.vals = existing.vals^
    
    fn put_max(inout self, s: String, v: Int):
        let id = (s._buffer[0] - ord('a')).to_int()
        if (self.vals[id] < v):
            self.vals[id] = v

    fn get(self, s: String) -> Int:
        let id = (s._buffer[0] - ord('a')).to_int()
        return self.vals[id]

fn maxdict(s: String) -> PseudoDict:
    let start = s.find(": ") + 2
    let draws = Parser(s[start:], "; ")
    var mballs = PseudoDict()
    for d in range(draws.length()):
        let colors = Parser(draws.get(d), ", ")
        for b in range(colors.length()):
            let tok = colors.get(b)
            let p = tok.find(" ")
            try:
                let v = atol(tok[:p])
                let col = tok[p+1:]
                mballs.put_max(col,v)
            except e:
                pass
    return mballs^

fn main() raises:
    let f = open("day02.txt", "r")
    let lines = Parser(f.read())
    var sum1 = Atomic[DType.int32](0)
    var sum2 = Atomic[DType.int32](0)

    @parameter
    fn step1(l: Int):
        let mballs = maxdict(lines.get(l))
        if (mballs.get("r") <= 12 and mballs.get("g") <= 13 and mballs.get("b") <= 14):
            sum1 += l + 1

    @parameter
    fn part1():
        for l in range(lines.length()): step1(l)

    @parameter
    fn part1_parallel():
        parallelize[step1](lines.length(), 2)

    @parameter
    fn step2(l: Int):
        let mballs = maxdict(lines.get(l))
        sum2 += mballs.get("r") * mballs.get("g") * mballs.get("b")

    @parameter
    fn part2():
        for l in range(lines.length()): step2(l)

    @parameter
    fn part2_parallel():
        parallelize[step2](lines.length(), 2)

    part1_parallel()
    print(sum1.value.to_int())
    part2_parallel()
    print(sum2.value.to_int())

    print("part1 :", benchmark.run[part1]().mean["ms"](), "ms")
    print("part1_parallel:", benchmark.run[part1_parallel]().mean["ms"](), "ms")
    print("part1 :", benchmark.run[part2]().mean["ms"](), "ms")
    print("part2_parallel:", benchmark.run[part2_parallel]().mean["ms"](), "ms")

    print(lines.length(), "rows")
