from parser import *
from wrappers import minibench
from algorithm import parallelize
from memory import memset

# Encode a 3-letter identifier to 15-bit integer
@always_inline
fn encode(s: StringSlice) -> Int:
    return ((s[0].to_int() - 64) << 10) + 
           ((s[1].to_int() - 64) << 5) + 
           (s[2].to_int() - 64)

@always_inline
fn gcd(a1: Int64,b1: Int64) -> Int64:
    var a = a1
    var b = b1
    while b != 0:
        let c = a % b
        a = b
        b = c         
    return a

@always_inline
fn lcm(a: Int64,b: Int64) -> Int64:
    let g = gcd(a,b)
    return (a // g) * b

struct Game:
    var lr: DTypePointer[DType.int32]
    var sp: DynamicVector[Int]
    var cnt: Int

    fn __init__(inout self):
        self.lr = DTypePointer[DType.int32].alloc(32768)
        self.sp = DynamicVector[Int]()
        self.cnt = 0
    
    fn __del__(owned self):
        self.lr.free()
    
    fn clear(inout self):
        memset(self.lr,0, 32768)
        self.sp.clear()
        self.cnt = 0

    fn add(inout self, s: StringSlice):
        let n = encode(s[0:3])
        let l = encode(s[7:10])
        let r = encode(s[12:15])
        # start node goes into the vector
        if s[2] == 65:  # 'A'
            self.sp.push_back(n)
        self.lr[n] = (l << 15) + r
        # final node gets a bit
        if s[2] == 90:  # 'Z'
            self.lr[n] |= 1 << 30
        # print(s,n,l,r,self.lr[n])
        self.cnt += 1
    
    fn next(self, id: Int, c: Int8) -> Int:
        if c == 76: # 'L'
            return ((self.lr[id] >> 15) & 0x7FFF).to_int()
        else:
            return ((self.lr[id]) & 0x7FFF).to_int()

fn main() raises:
    let f = open("day08.txt", "r")
    let lines = make_parser[10](f.read())
    let ins = lines.get(0)
    var game = Game()
    var results = DynamicVector[Int](10)

    @parameter
    fn parse() -> Int64:
        game.clear()
        results.clear()
        for i in range(1,lines.length()):
            game.add(lines.get(i))
        for i in range(game.sp.size):
            results.push_back(0)
        return game.cnt

    @parameter
    fn part1() -> Int64:
        var s = 0        
        var id = (1 << 10) + (1 << 5) + 1 # 'AAA'
        let fin = (26 << 10) + (26 << 5) + 26 # 'ZZZ'
        while id != fin and id != 0:
            id = game.next(id, ins[s % ins.size])
            s += 1            
        return s
    
    @parameter
    fn step2(i: Int) -> None:
        var s = 0
        var id = game.sp[i]
        while game.lr[id] >> 30 == 0:
            id = game.next(id, ins[s % ins.size])
            s = s + 1
        results[i] = s

    @parameter
    fn part2() -> Int64:
        var z : Int64 = 1
        for l in range(game.sp.size):
            step2(l)
            # print(l, results[l])
            z = lcm(z, results[l])
        return z

    @parameter
    fn part2_parallel() -> Int64:
        parallelize[step2](game.sp.size, game.sp.size)
        var z : Int64 = 1
        for l in range(game.sp.size):
            z = lcm(z, results[l])
        return z

    minibench[parse]("parse")
    minibench[part1]("part1")
    minibench[part2]("part2")
    minibench[part2_parallel]("part2_parallel")

    print(lines.length(), "lines")
    print(game.cnt, "nodes")
    print(ins.size, "steps")
    print(results[0])
