from parser import *
from wrappers import minibench
from memory import memset


@value
struct Array[AType: DType]:
    var data: DTypePointer[AType]
    var size: Int
    alias simd_width = simdwidthof[AType]()

    fn __init__(inout self, size: Int, value: SIMD[AType, 1] = 0):
        let pad = size + (Self.simd_width - 1) & ~(Self.simd_width - 1)
        # print("pad", size, "to", pad, "align", Self.simd_width)
        self.data = DTypePointer[AType].aligned_alloc(Self.simd_width, pad)
        self.size = size
        self.clear(value)

    fn __getitem__(self, idx: Int) -> SIMD[AType, 1]:
        return self.data[idx]

    fn __setitem__(inout self, idx: Int, val: SIMD[AType, 1]):
        self.data[idx] = val

    fn __del__(owned self):
        self.data.free()

    fn clear(inout self, value: SIMD[AType, 1] = 0):
        let initializer = SIMD[AType, Self.simd_width](value)
        @unroll(4)
        for i in range((self.size + Self.simd_width - 1) // Self.simd_width):
            self.data.aligned_simd_store[Self.simd_width, Self.simd_width](i * Self.simd_width, initializer)


fn main() raises:
    let f = open("day11.txt", "r")
    let lines = make_parser[10](f.read())

    fn compute1(owned exp: Array[DType.int64], owned cnt: Array[DType.int64]) -> Int64:
        var pos: Int64 = 0
        var tot: Int64 = 0
        var dst: Int64 = 0
        var sum: Int64 = 0
        for i in range(cnt.size):
            tot += cnt[i]
            dst += cnt[i] * pos
            sum += cnt[i] * (tot * pos - dst)
            pos += exp[i]
        return sum

    @parameter
    fn compute(cosmic_constant: Int64) -> Int64:
        # initializers for blank space detection
        let dimy = lines.length()
        let dimx = lines.get(0).size
        var vexp = Array[DType.int64](dimy, cosmic_constant)
        var hexp = Array[DType.int64](dimx, cosmic_constant)
        var vcnt = Array[DType.int64](dimy, 0)
        var hcnt = Array[DType.int64](dimx, 0)
        # find empty lines
        alias cHash = ord('#')
        for i in range(dimy):
            for j in range(dimx):
                if lines[i][j] == cHash:
                    vexp[i] = hexp[j] = 1
                    vcnt[i] += 1
                    hcnt[j] += 1
        return compute1(hexp ^, hcnt ^) + compute1(vexp ^, vcnt ^)

    @parameter
    fn part1() -> Int64:
        return compute(2)

    @parameter
    fn part2() -> Int64:
        return compute(1000000)

    minibench[part1]("part1")
    minibench[part2]("part2")

    print(lines.length(), "lines")
