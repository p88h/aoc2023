from parser import *
from wrappers import minibench
from memory import memset

alias simd_width_u32 = simdwidthof[DType.int32]()


struct SymSolver:
    """
    A vector of symbolic vectors, representing up to 32 variables with +/- operations.
    """

    var syms: DTypePointer[DType.int32]
    var size: Int

    # initialize and set the diagonal to value
    fn __init__(inout self, count: Int):
        self.syms = DTypePointer[DType.int32].aligned_alloc(32, count * 32)
        self.size = count
        for i in range(count):
            var s = SIMD[DType.int32, 32](0)
            s[i] = 1
            self.syms.aligned_simd_store[32, 32](i * 32, s)

    # Computes the grid and returns the flat multiplier array (and it's mirror image)
    fn compute(inout self) -> Tuple[SIMD[DType.int32, 32], SIMD[DType.int32, 32]]:
        var f = SIMD[DType.int32, 32](0)
        var r = SIMD[DType.int32, 32](0)
        for k in range(self.size):
            var p = self.syms.aligned_simd_load[32, 32](0)
            for i in range(self.size - k - 1):
                let n = self.syms.aligned_simd_load[32, 32](i * 32 + 32)
                self.syms.aligned_simd_store[32, 32](i * 32, n - p)
                p = n
            f += p
        for i in range(self.size):
            r[i] = f[self.size - i - 1]
        return (f, r)


struct VecMatrix:
    """
    Represents the input matrix, with each line stored in a single SIMD vector.
    Can handle up to 32 elements per line.
    """    
    var nums: DTypePointer[DType.int32]
    var cols: Int
    var rows: Int

    # initializer. No need to clear, fma will ignore unused cells. 
    fn __init__(inout self, rows: Int, cols: Int):        
        self.cols = cols
        self.rows = 0
        # ensure everything is padded to 32.
        self.nums = DTypePointer[DType.int32].aligned_alloc(32, 32 * rows)

    fn __del__(owned self):
        self.nums.free()

    fn clear(inout self):
        self.rows = 0

    # parse and store an input line as a column in the matrix
    fn add_row(inout self, s: StringSlice):
        let p = make_parser[32](s)
        for i in range(p.length()):
            self.nums[self.rows * 32 + i] = atoi(p.get(i)).to_int()
        self.rows += 1

    # multiply each vector by the mult parameter and retun sum of results
    fn fma(self, mult: SIMD[DType.int32, 32]) -> Int:
        var acc = SIMD[DType.int32, 32](0)
        for i in range(self.rows):
            acc += self.nums.aligned_simd_load[32, 32](i * 32) * mult
        return acc.reduce_add().to_int()


fn main() raises:
    let f = open("day09.txt", "r")
    let lines = make_parser[10](f.read())
    let first = make_parser[32](lines.get(0))
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
