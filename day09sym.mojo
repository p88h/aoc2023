from parser import *
from wrappers import minibench
from array import Array


struct SymSolver:
    # A vector of up to 32 symbolic vectors, representing up to 32 variables.
    # We need the number to be a power of two to make the SIMD code simpler.
    var syms: Array[DType.int32]
    var size: Int

    # initialize and set the values to an 'identity matrix' of sorts.
    fn __init__(inout self, count: Int):
        self.syms = Array[DType.int32](256 * 32)
        self.size = count
        for i in range(count):
            var s = SIMD[DType.int32, 32](0)
            s[i] = 1
            self.syms.store[width=32](i * 32, s)

    # Computes the grid and returns the flat multiplier array (and it's mirror image)
    fn compute(inout self) -> Tuple[SIMD[DType.int32, 32], SIMD[DType.int32, 32]]:
        var f = SIMD[DType.int32, 32](0)
        # This is exactly the same as the specified problem, but working on 'symbolic' numbers
        # The math is the same, though, just instead of adding individual values, we do 32 at a time
        for k in range(self.size):
            # previous item
            var p = self.syms.load[width=32](0)
            for i in range(self.size - k - 1):
                # next item
                n = self.syms.load[width=32](i * 32 + 32)
                # compute diff and store back
                self.syms.store[width=32](i * 32, n - p)
                p = n
            # add the last element to our formula
            f += p
        # Compute the flipped version of the formula for the part 2
        # (you could flip the data matrix, but that's way more expensive)
        var r = SIMD[DType.int32, 32](0)
        for i in range(self.size):
            r[i] = f[self.size - i - 1]
        return (f, r)


struct VecMatrix:
    """
    Represents the input matrix, with each line stored in a single SIMD vector.
    Can handle up to 32 elements per line.
    """

    var nums: Array[DType.int32]
    var cols: Int
    var rows: Int

    # initializer. No need to clear, fma will ignore unused cells.
    fn __init__(inout self, rows: Int, cols: Int):
        self.cols = cols
        self.rows = 0
        # ensure everything is padded to 32.
        self.nums = Array[DType.int32](256 * 32)

    fn clear(inout self):
        self.rows = 0

    # parse and store an input line as a column in the matrix
    fn add_row(inout self, s: StringSlice):
        p = make_parser[" "](s)
        # When storing data, we just pad everything to 32, no SIMD here
        for i in range(p.length()):
            self.nums[self.rows * 32 + i] = int(atoi(p.get(i)))
        self.rows += 1

    # multiply each vector by the mult parameter and retun sum of results
    fn fma(self, mult: SIMD[DType.int32, 32]) -> Int:
        var acc = SIMD[DType.int32, 32](0)
        for i in range(self.rows):
            # multiply the whole row by the whole formula in one go
            # (well, not really one op, unless you have 1024-bit SIMD operations.
            # Mojo doesn't even do AVX512, so this breaks down to 4x8-wide ops with AVX2.
            # Or equivalent. Manually doing 3x8 is a tiny bit faster but too
            # complicated)
            acc = self.nums.load[width=32](i * 32).fma(mult, acc)
        return int(acc.reduce_add())


fn main() raises:
    f = open("day09.txt", "r")
    lines = make_parser["\n"](f.read())
    first = make_parser[" "](lines.get(0))
    var mat = VecMatrix(lines.length(), first.length())
    var flat = SIMD[DType.int32, 32](0)
    var talf = SIMD[DType.int32, 32](0)

    @parameter
    fn parse() -> Int64:
        var solver = SymSolver(first.length())
        (flat, talf) = solver.compute()
        mat.clear()
        for i in range(lines.length()):
            mat.add_row(lines.get(i))
        return lines.length()

    @parameter
    fn part1() -> Int64:
        return mat.fma(flat)

    @parameter
    fn part2() -> Int64:
        return mat.fma(talf)

    minibench[parse]("parse")
    minibench[part1]("part1")
    minibench[part2]("part2")

    print(lines.length(), "lines")
    print(first.length(), "items each")
    print(mat.cols, "vectors")
    print(flat)
