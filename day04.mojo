from parser import Parser
from os.atomic import Atomic
from utils.vector import DynamicVector
from wrappers import run_multiline_task
from math import min, max
from memory import memset
from algorithm import parallelize
import benchmark

alias intptr = DTypePointer[DType.int32]
# | and 0 characters
alias space = 32
alias zero = 48


fn main() raises:
    let f = open("day04.txt", "r")
    let lines = Parser(f.read())

    let count = lines.length()
    # Each game is represented as two 128bit numbers, stored as 16-byte SIMD vectors
    var games = DynamicVector[Tuple[SIMD[DType.uint8, 16], SIMD[DType.uint8, 16]]](count)
    # Counts number of instances of each ticket
    var draws = intptr.alloc(count)
    # Result counters (not parallelizing this though)
    var sum1 = Atomic[DType.int32](0)
    var sum2 = Atomic[DType.int32](0)
    
    # Count the bits in a SIMD vector. Mojo doesn't expose the intrinsics that do this
    # natively, shame. But we can reduce at least, so we just need 3 shifting steps. 
    @always_inline
    fn bitcnt(m: SIMD[DType.uint8, 16]) -> Int:
        # odd / even bits
        let s55 = SIMD[DType.uint8, 16](0x55)
        # two-bit mask
        let s33 = SIMD[DType.uint8, 16](0x33)
        # four-bit mask
        let s0F = SIMD[DType.uint8, 16](0x0F)
        # ref: Hacker's Delight or https://en.wikipedia.org/wiki/Hamming_weight
        var mm = m - ((m >> 1) & s55)
        mm = (mm & s33) + ((mm >> 2) & s33)
        mm = (mm + (mm >> 4)) & s0F
        return mm.reduce_add[1]().to_int()

    # Set a single bit in a 8-bit based bitfield
    @always_inline
    fn setbit(inout m: SIMD[DType.uint8, 16], v: Int):
        let f = v // 8
        let b = v % 8
        m[f] = m[f] | (1 << b)

    # Build a bitfield from a string containing integers
    fn bitfield(s: String) -> SIMD[DType.uint8, 16]:
        var ret = SIMD[DType.uint8, 16](0)
        var pos = 0
        let l = len(s)
        var r = 0
        while pos < l:
            if s._buffer[pos] != space:
                r = r * 10 + s._buffer[pos].to_int() - zero
            elif r > 0:
                setbit(ret, r)
                r = 0
            pos += 1
        return ret

    # Scan each game, split it into winning numbers and store as bit vectors
    @parameter
    fn parse():
        games.clear()
        for y in range(lines.length()):
            var s: String = lines.get(y)
            # achievement unlocked: https://github.com/modularml/mojo/issues/1367
            # the below doesn't work. We'll need to live with multiple spaces.
            # s = s.replace("  ", " ") + " "
            s = s + " "
            let start = s.find(": ") + 2
            let sep = s.find("| ")
            let s1 = s[start:sep]
            let s2 = s[sep + 2 : len(s)]
            games.push_back((bitfield(s1), bitfield(s2)))

    # Count number of matches in a game
    @always_inline
    fn matches(t: Tuple[SIMD[DType.uint8, 16], SIMD[DType.uint8, 16]]) -> Int:
        let win: SIMD[DType.uint8, 16]
        let hand: SIMD[DType.uint8, 16]
        (win, hand) = t
        return bitcnt(win & hand)

    # Take numbers of matches, exponentiate, sum up
    @parameter
    fn part1():
        sum1 = 0
        for i in range(games.size):
            let w = 1 << matches(games[i])
            sum1 += w >> 1

    # Computes the ticket counts in draws table on the go
    @parameter
    fn part2():
        # Achievement #2 - memset with anything else than 0 doesn't work
        # https://github.com/modularml/mojo/issues/1368
        # We set ticket counts to zero then.
        memset(draws, 0, count)
        sum2 = 0
        for i in range(count):
            let cd = draws.load(i) + 1
            let x = matches(games[i])
            # Update next x draws
            for j in range(i + 1, min(count, i + x + 1)):
                draws.store(j, draws.load(j) + cd)            
            sum2 += cd

    @parameter
    fn results():
        print(sum1.value.to_int())
        print(sum2.value.to_int())

    # This part doesn't seem to benefit much from parallelization, so just run benchmarks.
    print("parse:", benchmark.run[parse]().mean["ms"](), "ms")
    # Achievement #3 (positive) - had to go to microseconds here. 
    print("part1:", benchmark.run[part1]().mean["ns"]()/1000, "μs")
    print(sum1)
    print("part2:", benchmark.run[part2]().mean["ns"]()/1000, "μs")
    print(sum2)

    # Ensure `lines` and `games` are still in use
    print(lines.length(), "rows")
    print(games.size, "games")
