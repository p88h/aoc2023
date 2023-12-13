from parser import *
from wrappers import minibench
from memory import memset

alias simd_width_u32 = simdwidthof[DType.int32]()


@value
struct Matrix2D:
    var nums: DTypePointer[DType.int32]
    var rows: Int
    var cols: Int

    # blank initializer
    fn __init__(inout self, w: Int, h: Int):
        # ensure everything is 8-padded.
        self.rows = w
        self.cols = (h + simd_width_u32 - 1) & ~(simd_width_u32 - 1)
        self.nums = DTypePointer[DType.int32].aligned_alloc(64, self.rows * self.cols)
        memset(self.nums, 0, self.rows * self.cols)

    # override copy constructor to also copy memory
    fn __copyinit__(inout self, other: Self):
        self.rows = other.rows
        self.cols = other.cols
        self.nums = DTypePointer[DType.int32].aligned_alloc(64, self.rows * self.cols)
        memcpy(self.nums, other.nums, self.rows * self.cols)

    fn __del__(owned self):
        self.nums.free()

    # parse and store an input line as a column in the matrix
    fn store_column(inout self, x: Int, s: StringSlice):
        let p = make_parser[' '](s)
        for i in range(p.length()):
            self.nums[self.cols * i + x] = atoi(p.get(i)).to_int()

    # computes the differential, from top to bottown, leaving last row intact (used in the final pass)
    fn reduce_down(inout self, rows: Int):
        for ofs in range(self.cols // simd_width_u32):
            var prev = self.nums.aligned_simd_load[simd_width_u32, 64](ofs * simd_width_u32)
            for i in range(1, rows):
                let next = self.nums.aligned_simd_load[simd_width_u32, 64](i * self.cols + ofs * simd_width_u32)
                prev = next - prev
                self.nums.aligned_simd_store[simd_width_u32, 64](((i - 1) * self.cols + ofs * simd_width_u32), prev)
                prev = next

    # computes the differential, leaving first row intact (used in the final pass)
    fn reduce_up(inout self, skip: Int):
        for ofs in range(self.cols // simd_width_u32):
            var prev = self.nums.aligned_simd_load[simd_width_u32, 64](skip * self.cols + ofs * simd_width_u32)
            for i in range(skip + 1, self.rows):
                let next = self.nums.aligned_simd_load[simd_width_u32, 64](i * self.cols + ofs * simd_width_u32)
                prev = next - prev
                self.nums.aligned_simd_store[simd_width_u32, 64]((i * self.cols + ofs * simd_width_u32), prev)
                prev = next

    # Returns the sum of all elements in the matrix
    fn sum(inout self) -> Int64:
        var tot = SIMD[DType.int32, simd_width_u32](0)
        for ofs in range(self.cols // simd_width_u32):
            var tmp = SIMD[DType.int32, simd_width_u32](0)
            for i in range(self.rows):
                tmp += self.nums.aligned_simd_load[simd_width_u32, 64](i * self.cols + ofs * simd_width_u32)
            tot += tmp
        return tot.reduce_add().to_int()

    # Returns the sum of sequential differences of all the columns in the matrix
    fn dsum(inout self) -> Int64:
        var tot = SIMD[DType.int32, simd_width_u32](0)
        for ofs in range(self.cols // simd_width_u32):
            var prev = self.nums.aligned_simd_load[simd_width_u32, 64]((self.rows - 1) * self.cols + ofs * simd_width_u32)
            for i in range(self.rows - 2, -1, -1):
                let next = self.nums.aligned_simd_load[simd_width_u32, 64](i * self.cols + ofs * simd_width_u32)
                prev = next - prev
            tot += prev
        return tot.reduce_add().to_int()

    # for debugging
    fn print(self, y: Int):
        for i in range(self.rows):
            print_no_newline(self.nums[i * self.cols + y], "")
        print()


fn main() raises:
    let f = open("day09.txt", "r")
    let lines = make_parser['\n'](f.read())
    let first = make_parser[' '](lines.get(0))
    var mat = Matrix2D(first.length(), lines.length())

    @parameter
    fn parse() -> Int64:
        for i in range(lines.length()):
            mat.store_column(i, lines.get(i))
        return lines.length()

    @parameter
    fn part1() -> Int64:
        var work = mat
        for l in range(first.length(), 0, -1):
            work.reduce_down(l)
        return work.sum()

    @parameter
    fn part2() -> Int64:
        var work = mat
        for l in range(first.length() - 1):
            work.reduce_up(l)
        return work.dsum()

    minibench[parse]("parse")
    minibench[part1]("part1")
    minibench[part2]("part2")

    print(lines.length(), "lines")
    print(first.length(), "items each")
    print(mat.rows * mat.cols, "cells")
