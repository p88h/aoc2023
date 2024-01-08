from parser import *
from math import min, max
from wrappers import minibench
from math.bit import ctpop
from array import Array

alias space = ord(' ')
alias zero = ord('0')

# Count number of matches in a game
@always_inline
fn matches(win: SIMD[DType.uint8, 16], hand: SIMD[DType.uint8, 16]) -> Int:
    return ctpop(win & hand).reduce_add().to_int()

@always_inline
fn main() raises:
    let f = open("day04.txt", "r")
    let lines = make_parser['\n'](f.read())

    let count = lines.length()
    # Each game is represented as two 128bit numbers, stored as 2x16-byte SIMD vectors
    let games = Array[DType.uint8](count * 32)
    # Counts number of instances of each ticket    
    let draws = Array[DType.int32](count)

    # Set a single bit in a 8-bit based bitfield
    @always_inline
    fn setbit(inout m: SIMD[DType.uint8, 16], v: Int):
        let f = v // 8
        let b = v % 8
        m[f] = m[f] | (1 << b)

    # Build a bitfield from a string containing integers
    fn bitfield(s: StringSlice) -> SIMD[DType.uint8, 16]:
        var ret = SIMD[DType.uint8, 16](0)
        var pos = 0
        let l = s.size
        var r = 0
        while pos < l:
            if s[pos] != space:
                r = r * 10 + s[pos].to_int() - zero
            elif r > 0:
                setbit(ret, r)
                r = 0
            pos += 1
        if r > 0:
            setbit(ret, r)
            r = 0
        return ret

    # Scan each game, split it into winning numbers and store as bit vectors
    @parameter
    fn parse() -> Int64:
        games.clear()
        for y in range(count):
            let s: StringSlice = lines[y]
            alias cOlon = ord(':')
            let start = s.find(cOlon)
            alias cPipe = ord('|')
            let sep = s.find(cPipe)
            let s1 = s[start + 2:sep]
            let s2 = s[sep + 2:]
            games.aligned_simd_store[16](y * 32, bitfield(s1))
            games.aligned_simd_store[16](y * 32 + 16, bitfield(s2))
        return count

    # Take numbers of matches, exponentiate, sum up
    @parameter
    fn part1() -> Int64:
        var sum1 = 0
        for i in range(count):
            let w = 1 << matches(games.aligned_simd_load[16](i*32), games.aligned_simd_load[16](i*32+16))
            sum1 += w >> 1
        return sum1

    # Computes the ticket counts in draws table on the go
    @parameter
    fn part2() -> Int64:
        draws.clear(1)
        var sum2 : Int64 = 0
        for i in range(count):
            let cd = draws[i]
            let x = matches(games.aligned_simd_load[16](i*32), games.aligned_simd_load[16](i*32+16))
            # Update next x draws
            for j in range(i + 1, min(count, i + x + 1)):
                draws[j] += cd
            sum2 += cd.to_int()
        return sum2

    # This part doesn't seem to benefit much from parallelization, so just run benchmarks.
    minibench[parse]("parse")
    minibench[part1]("part1")
    minibench[part2]("part2")

    # Ensure `lines` and `games` are still in use
    print(lines.length(), "rows")
    print(games.bytecount() + draws.bytecount(), "bytes")
