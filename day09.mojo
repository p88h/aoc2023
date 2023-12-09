from parser import *
from wrappers import minibench
from algorithm import parallelize
from memory import memset


@value
struct Matrix2D:
    var nums: DTypePointer[DType.int32]
    var rows: Int
    var cols: Int

    fn __init__(inout self, w: Int, h: Int):
        # ensure everything is 8-padded.
        self.rows = w
        self.cols = (h + 7) & ~7
        self.nums = DTypePointer[DType.int32].aligned_alloc(64, self.rows * self.cols)
        memset(self.nums, 0, self.rows * self.cols)

    fn __copyinit__(inout self, other: Self):
        self.rows = other.rows
        self.cols = other.cols
        self.nums = DTypePointer[DType.int32].aligned_alloc(64, self.rows * self.cols)
        memcpy(self.nums, other.nums, self.rows * self.cols)

    fn __del__(owned self):
        self.nums.free()

    fn store_column(inout self, x: Int, s: StringSlice):
        let p = make_parser[32](s)
        for i in range(p.length()):
            self.nums[self.cols * i + x] = atoi(p.get(i)).to_int()

    fn reduce_down(inout self, rows: Int):
        for ofs in range(self.cols//8):
            var prev = self.nums.aligned_simd_load[8, 64](ofs * 8)
            for i in range(1, rows):
                let next = self.nums.aligned_simd_load[8, 64](i * self.cols + ofs * 8)
                prev = next - prev
                self.nums.aligned_simd_store[8, 64](((i - 1) * self.cols + ofs * 8), prev)
                prev = next

    fn reduce_up(inout self, skip: Int):
        for ofs in range(self.cols//8):
            var prev = self.nums.aligned_simd_load[8, 64](skip * self.cols + ofs * 8)
            for i in range(skip + 1, self.rows):
                let next = self.nums.aligned_simd_load[8, 64](i * self.cols + ofs * 8)
                prev = next - prev
                self.nums.aligned_simd_store[8, 64]((i * self.cols + ofs * 8), prev)
                prev = next

    fn sum(inout self) -> Int64:
        var tot = SIMD[DType.int32, 8](0)
        for ofs in range(self.cols // 8):
            var tmp = SIMD[DType.int32, 8](0)
            for i in range(self.rows):
                tmp += self.nums.aligned_simd_load[8, 64](i * self.cols + ofs * 8)
            tot += tmp
        return tot.reduce_add().to_int()

    fn dsum(inout self) -> Int64:
        var tot = SIMD[DType.int32, 8](0)
        for ofs in range(self.cols // 8):
            var prev = self.nums.aligned_simd_load[8, 64]((self.rows - 1) * self.cols + ofs * 8)
            for i in range(self.rows - 2, -1, -1):
                 let next = self.nums.aligned_simd_load[8, 64](i * self.cols + ofs * 8)
                 prev = next - prev
            tot += prev
        return tot.reduce_add().to_int()


    fn print(self, y: Int):
        for i in range(self.rows):
            print_no_newline(self.nums[i * self.cols + y],"")
        print()


fn main() raises:
    let f = open("day09.txt", "r")
    let lines = make_parser[10](f.read())
    let first = make_parser[32](lines.get(0))
    var mat = Matrix2D(first.length(), lines.length())
 
    @parameter
    fn parse() -> Int64:
        for i in range(lines.length()):
            mat.store_column(i, lines.get(i))
        return lines.length()

    @parameter
    fn part1() -> Int64:
        var work = mat
        for l in range(first.length(),0,-1):
            work.reduce_down(l)
        return work.sum()

    @parameter
    fn part2() -> Int64:
        var work = mat
        for l in range(first.length()-1):
            work.reduce_up(l)
        return work.dsum()

    minibench[parse]("parse")
    minibench[part1]("part1")
    minibench[part2]("part1")

    print(lines.length(), "lines")
    print(first.length(), "items each")
    print(mat.rows * mat.cols, "cells")

