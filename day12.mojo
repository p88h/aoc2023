from parser import *
from wrappers import run_multiline_task
from array import Array
from memory import memcpy, memset
from os.atomic import Atomic

struct Solver:
    var cache : Array[DType.int64]
    var csize : Int
    var buf : Array[DType.uint8]
    var syms : StringSlice
    var rules : List[Int]

    fn __init__(inout self, line: StringSlice, mult: Int = 1):
        alias cAsk = ord('?')
        p = make_parser[' '](line)
        r = make_parser[','](p[1])
        l = p[0].size * mult + mult - 1
        self.csize = (l+2) * 32
        self.cache = Array[DType.int64](self.csize, -1)
        self.buf = Array[DType.uint8](l)
        self.syms = StringSlice(self.buf.data, l)
        self.rules = List[Int](capacity = r.length() * mult)
        for i in range(r.length()):
            self.rules.append(int(atoi(r[i])))
        memcpy(self.buf.data, line.ptr, p[0].size)
        # replicate
        for i in range (1, mult):
            ofs = (p[0].size + 1) * i
            self.buf.store(ofs - 1, cAsk)
            memcpy(self.buf.data.offset(ofs), line.ptr, p[0].size)
            for j in range(r.length()):
                self.rules.append(self.rules[j])

    fn count(inout self, sp: Int, rp: Int) -> Int64:
        var sp1 = sp
        # skip empty
        alias cDot = ord('.')
        alias cHash = ord('#')
        alias cAsk = ord('?')
        while sp1 < self.syms.size and self.syms[sp1] == cDot:
            sp1 += 1
        ck = sp1*32+rp
        if self.cache[ck] >= 0:
            return self.cache[ck]
        var ret : Int64 = 0
        if rp == self.rules.size:
            if self.syms.find(cHash, sp) < 0: 
                ret = 1
            self.cache[ck] = ret
            return ret
        elif sp >= self.syms.size:
            return 0
        var l = self.rules[rp]
        var s = sp1
        var p = sp1
        # scan the current rule
        var f = False
        while l > 0 and p < self.syms.size and (self.syms[p] == cAsk or self.syms[p] == cHash):
            f = f or self.syms[p] == cHash
            p += 1
            l -= 1
        # not able to fit
        if l > 0 and (f or p >= self.syms.size):
            return 0
        if l > 0:
            ret = self.count(p + 1, rp)
            self.cache[ck] = ret
            return ret
        # Following symbol has to be '.' or '?' or EOL
        if p == self.syms.size or self.syms[p] != cHash:
            ret += self.count(p + 1, rp + 1)
        # turn '?' at the start into '.'
        while p < self.syms.size and self.syms[s] == cAsk and (self.syms[p] == cHash or self.syms[p] == cAsk):
            f = f or self.syms[p] == cHash
            s += 1
            p += 1
            if p == self.syms.size or self.syms[p] != cHash:
                ret += self.count(p + 1, rp + 1)
        if not f and p < self.syms.size:
            ret += self.count(p + 1, rp)
        self.cache[ck] = ret
        return ret
            

fn main() raises:
    f = open("day12.txt", "r")
    lines = make_parser['\n'](f.read())
    var sum1 = Atomic[DType.int64](0)
    var sum2 = Atomic[DType.int64](0)

    alias chunk_size = 20

    @parameter
    fn chunk_step(i: Int, mult: Int = 1) -> Int64:
        var lsum : Int64 = 0
        for j in range(chunk_size):
            var solver = Solver(lines[i * chunk_size + j], mult)
            lsum += solver.count(0, 0)
        return lsum

    @parameter
    fn step1(i : Int):
        sum1 += chunk_step(i, 1)

    @parameter
    fn step2(i : Int):
        sum2 += chunk_step(i, 5)

    @parameter
    fn results():
        print(int(sum1.value))
        print(int(sum2.value))

    run_multiline_task[step1, step2, results](lines.length() // chunk_size)

    print(lines.length(), "lines", sum1.value, sum2.value)
