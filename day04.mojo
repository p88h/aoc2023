from parser import *
from array import Array
from wrappers import minibench
from bit import pop_count

alias space = ord(" ")
alias zero = ord("0")


# Count number of matches in a game
@always_inline
fn matches(win: SIMD[DType.uint8, 16], hand: SIMD[DType.uint8, 16]) -> Int:
    return int(pop_count(win & hand).reduce_add())


@always_inline
fn main() raises:
    f = open("day04.txt", "r")
    lines = make_parser["\n"](f.read())

    count = lines.length()
    # Each game is represented as two 128bit numbers, stored as 2x16-byte SIMD vectors
    games = Array[DType.uint8](256 * 32)
    # Counts number of instances of each ticket
    draws = Array[DType.int32](256)

    # Set a single bit in a 8-bit based bitfield
    @always_inline
    fn setbit(inout m: SIMD[DType.uint8, 16], v: Int):
        g = v // 8
        b = v % 8
        m[g] = m[g] | (1 << b)

    # Build a bitfield from a string containing integers
    fn bitfield(s: StringSlice) -> SIMD[DType.uint8, 16]:
        var ret = SIMD[DType.uint8, 16](0)
        var pos = 0
        l = s.size
        var r = 0
        while pos < l:
            if s[pos] != space:
                r = r * 10 + int(s[pos]) - zero
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
        games.zero()
        for y in range(count):
            s = lines[y]
            alias cOlon = ord(":")
            start = s.find(cOlon)
            alias cPipe = ord("|")
            sep = s.find(cPipe)
            s1 = s[start + 2 : sep]
            s2 = s[sep + 2 :]
            games.store[width=16](y * 32, bitfield(s1))
            games.store[width=16](y * 32 + 16, bitfield(s2))
        return count

    # Take numbers of matches, exponentiate, sum up
    @parameter
    fn part1() -> Int64:
        var sum1 = 0
        for i in range(count):
            w = 1 << matches(games.load[width=16](i * 32), games.load[width=16](i * 32 + 16))
            sum1 += w >> 1
        return sum1

    # Computes the ticket counts in draws table on the go
    @parameter
    fn part2() -> Int64:
        draws.fill(1)
        var sum2: Int64 = 0
        for i in range(count):
            cd = draws[i]
            x = matches(games.load[width=16](i * 32), games.load[width=16](i * 32 + 16))
            # Update next x draws
            for j in range(i + 1, min(count, i + x + 1)):
                draws[j] += cd
            sum2 += int(cd)
        return sum2

    # This part doesn't seem to benefit much from parallelization, so just run benchmarks.
    minibench[parse]("parse")
    minibench[part1]("part1")
    minibench[part2]("part2")

    # Ensure `lines` and `games` are still in use
    print(lines.length(), "rows", count)
    print(games.bytecount() + draws.bytecount(), "bytes")
