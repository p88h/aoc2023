from parser import *
from wrappers import run_multiline_task
from array import Array
from memory import memcpy

struct Solver:
    var cache : Array[DType.int64]
    var csize : Int
    var buf : DTypePointer[DType.int8]
    var syms : StringSlice
    var rules : DynamicVector[Int]

    fn __init__(inout self, line: StringSlice, mult: Int = 1):
        alias cAsk = ord('?')
        let p = make_parser[' '](line)
        let r = make_parser[','](p[1])
        let l = p[0].size * mult + mult - 1
        self.csize = (l+2) * 32
        self.cache = Array[DType.int64](self.csize, -1)
        self.buf = DTypePointer[DType.int8].alloc(l)
        self.syms = StringSlice(self.buf, l)
        self.rules = DynamicVector[Int](r.length() * mult)
        for i in range(r.length()):
            self.rules.push_back(atoi(r[i]).to_int())
        memcpy(self.buf, line.ptr, p[0].size)
        # replicate
        for i in range (1, mult):
            let ofs = (p[0].size + 1) * i
            self.buf.store(ofs - 1, cAsk)
            memcpy(self.buf.offset(ofs), line.ptr, p[0].size)
            for j in range(r.length()):
                self.rules.push_back(self.rules[j])
        
    fn count(inout self, sp: Int, rp: Int) -> Int64:
        var sp1 = sp
        # skip empty
        alias cDot = ord('.')
        alias cHash = ord('#')
        alias cAsk = ord('?')
        while sp1 < self.syms.size and self.syms[sp1] == cDot:
            sp1 += 1
        let ck = sp1*32+rp
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
    let f = open("day12.txt", "r")
    let lines = make_parser['\n'](f.read())
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
        print(sum1.value.to_int())
        print(sum2.value.to_int())

    run_multiline_task[step1, step2, results](lines.length() // chunk_size, 24)

    print(lines.length(), "lines")
