from parser import *
from wrappers import minibench
from array import Array
from math.bit import ctpop

# Popcnt based on https://en.wikipedia.org/wiki/Hamming_weight
fn popcnt(v: SIMD[DType.int32, 1]) -> Int:
    alias m1 = 0x5555555555555555
    alias m2 = 0x3333333333333333
    alias m4 = 0x0F0F0F0F0F0F0F0F
    alias h01 = 0x0101010101010101
    var x: UInt64 = v.to_int()
    x -= (x >> 1) & m1
    x = (x & m2) + ((x >> 2) & m2)
    x = (x + (x >> 4)) & m4
    return ((x * h01) >> 56).to_int()


fn main() raises:
    let f = open("day13.txt", "r")
    let lines = make_parser["\n"](f.read(), False)
    let mats = Array[DType.int32](200 * 20)
    var matcnt: Int = 0

    @parameter    
    # A matrix is represented as a list of integers, with cells represented as single bits.
    # This finds for matching pairs of rows and then extends the match until running into
    # the border. If that happens, that's a match. Vertical matches use rotated arrays
    # represented the same way.
    fn find_match(ofs: Int, size: Int) -> Int64:
        for i in range(1, size):
            var b = 0
            while i > b and i + b < size and mats[ofs + i - b - 1] == mats[ofs + i + b]:
                b += 1
            if i == b or i + b == size:
                return i
        return 0

    @parameter
    # Same as the trivial match, but uses a 'bit budget' and a bit-difference comparison 
    # based on popcnt. We set the budget to 1 initially and allow a mismatch up to a budget.
    # Then the algorithm works just like the regular one, except we require that the budget
    # is actually used up at the end.
    fn find_match_dirty(ofs: Int, size: Int) -> Int64:
        for i in range(1, size):
            var b = 0
            var tbb : Int32 = 1
            while i > b and i + b < size:
                let pc = ctpop(mats[ofs + i - b - 1] ^ mats[ofs + i + b]) 
                if pc > tbb:
                    break
                # apparently compiler is smart enough to not compute this
                tbb -= pc
                b += 1
            if tbb == 0 and (i == b or i + b == size):
                return i
        return 0

    @parameter
    fn parse() -> Int64:
        var ofs = 400
        var prev = 0
        mats.clear()
        matcnt = 0
        for l in range(lines.length()):
            # Empty lines trigger parsing the preceding array
            if lines[l].size == 0:
                let dimY = l - prev
                let r = mats.data.offset(ofs)
                let dimX = lines[l - 1].size
                let c = mats.data.offset(ofs + dimY)
                # Store each cell into bits of r and c
                # array r is represented row-wise, c is column-wise (transposed r)
                # all data is stored flat in the mats array. 
                for i in range(dimY):
                    for j in range(dimX):
                        let v = lines[prev + i][j].to_int() & 1
                        r[i] = r[i] * 2 + v
                        c[j] = c[j] * 2 + v
                prev = l + 1
                # save positions at the start of mats array
                mats[matcnt * 4] = ofs
                mats[matcnt * 4 + 1] = dimY
                mats[matcnt * 4 + 2] = ofs + dimY
                mats[matcnt * 4 + 3] = dimX
                ofs += dimY + dimX
                matcnt += 1
        return matcnt

    @parameter
    fn run[match_fn: fn (Int, Int, /) capturing -> Int64]() -> Int64:
        var sum: Int64 = 0
        for i in range(matcnt):
            sum += 100 * match_fn(mats[i * 4].to_int(), mats[i * 4 + 1].to_int())
            sum += match_fn(mats[i * 4 + 2].to_int(), mats[i * 4 + 3].to_int())
        return sum

    @parameter
    fn part1() -> Int64:
        return run[find_match]()

    @parameter
    fn part2() -> Int64:
        return run[find_match_dirty]()

    minibench[parse]("parse")
    minibench[part1]("part1")
    minibench[part2]("part2")

    print(lines.length(), "lines")
    print(mats.size, "bytes used")
    print(matcnt, "arrays")
