from parser import *
from wrappers import minibench
from algorithm import parallelize
from memory import memset
from array import Array

# Encode a 3-letter identifier to 15-bit integer
@always_inline
fn encode(s: StringSlice) -> Int:
    return ((int(s[0]) - 64) << 10) + 
           ((int(s[1]) - 64) << 5) + 
           (int(s[2]) - 64)

@always_inline
fn gcd(a1: Int64,b1: Int64) -> Int64:
    var a = a1
    var b = b1
    while b != 0:
        c = a % b
        a = b
        b = c         
    return a

@always_inline
fn lcm(a: Int64,b: Int64) -> Int64:
    g = gcd(a,b)
    return (a // g) * b

struct Game:
    var lr: Array[DType.int32]
    var sp: List[Int]
    var cnt: Int

    fn __init__(inout self):
        self.lr = Array[DType.int32](32768)
        self.sp = List[Int]()
        self.cnt = 0
        
    fn clear(inout self):
        self.lr.zero()
        self.sp.clear()
        self.cnt = 0

    fn add(inout self, s: StringSlice):
        n = encode(s[0:3])
        l = encode(s[7:10])
        r = encode(s[12:15])
        # start node goes into the vector
        alias cA = ord('A')
        if s[2] == cA:  # 'A'
            self.sp.append(n)
        self.lr[n] = (l << 15) + r
        # final node gets a bit
        alias cZ = ord('Z')
        if s[2] == cZ:  # 'Z'
            self.lr[n] |= 1 << 30
        # print(s,n,l,r,self.lr[n])
        self.cnt += 1
    
    fn next(self, id: Int, c: UInt8) -> Int:
        if c == 76: # 'L'
            return int((self.lr[id] >> 15) & 0x7FFF)
        else:
            return int((self.lr[id]) & 0x7FFF)

fn main() raises:
    f = open("day08.txt", "r")
    lines = make_parser['\n'](f.read())
    ins = lines.get(0)
    var game = Game()
    var results = List[Int]()

    @parameter
    fn parse() -> Int64:
        game.clear()
        results.clear()
        for i in range(1,lines.length()):
            game.add(lines.get(i))
        for _ in range(game.sp.size):
            results.append(0)
        return game.cnt

    @parameter
    fn part1() -> Int64:
        var s = 0        
        var id = (1 << 10) + (1 << 5) + 1 # 'AAA'
        fin = (26 << 10) + (26 << 5) + 26 # 'ZZZ'
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
