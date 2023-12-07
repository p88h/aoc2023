from parser import *
from os.atomic import Atomic
from utils.vector import DynamicVector
from wrappers import minibench
from math import min, max
from memory import memset

alias intptr = DTypePointer[DType.int32]


fn main() raises:
    let f = open("day03.txt", "r")
    let lines = make_parser[10](f.read())
    let dimx = lines.get(0).size
    let dimy = lines.length()
    # Here we'll keep all the found numbers - the format is POS_Y,POS_X,LENGTH,VALUE
    var nums = DynamicVector[Tuple[Int, Int, Int, Int]](1000)
    var flat = DynamicVector[Int](100000)
    # And here we'll keep all the information about gears. We just keep a huge table
    # with enough space to have gears in all position of the board. No hashing - the
    # gear position _is_ the index into this array.
    var gears = intptr.alloc(dimy * dimx)
    # Atomic results (although in the end we don't really use parallelization here)
    var sum1 = Atomic[DType.int32](0)
    var sum2 = Atomic[DType.int32](0)

    # This is the common 'parse' task: scan the board and find anythin that looks like
    # a number. Store all found numbers into the 'nums' vector. This could be nicer
    # with return values and all, but we weant to benchmark it and benchmark doesn't like
    # functions with parameters.
    @parameter
    fn find_nums() -> Int64:
        nums.clear()
        flat.clear()
        for y in range(lines.length()):
            var r: Int = 0
            var q: Int = 0
            let line: StringSlice = lines.get(y)
            for x in range(dimx):
                let c = line[x].to_int()
                flat.push_back(c)
                # char is in 0..9 range
                if c >= 48 and c <= 57:
                    r = r * 10 + c - 48
                    q += 1
                # or not, but we have some leftover number
                elif q > 0:
                    nums.push_back((y, x - q, q, r))
                    r = q = 0
            # handle numbers at the right edge
            if q > 0:
                nums.push_back((y, dimx - q, q, r))
        return nums.size

    # Step 1 will search around the specified number and look for special characters.
    # If any are found, will increment the sum.
    @parameter
    fn step1(i: Int) -> Int64:
        # Unpacking tuples in Mojo is comical.
        let y: Int
        let x: Int
        let l: Int
        let v: Int
        (y, x, l, v) = nums[i]
        # Bounding box around the number
        let sx = max(x - 1, 0)
        let lx = min(x + l, dimx - 1)
        let sy = max(y - 1, 0)
        let ly = min(y + 1, dimy - 1)
        # Scan the box. This is rather fast in Mojo.
        for gy in range(sy, ly + 1):
            for gx in range(sx, lx + 1):
                let c = flat[gy * dimx + gx]
                # Not a number and not a dot
                if (c < 48 or c > 57) and (c != 46):
                    return Int64(v)
        return 0

    @parameter
    fn part1() -> Int64:
        var sum1 : Int64 = 0
        for i in range(nums.size):
            sum1 += step1(i)
        return sum1

    # Part 2 is actually really similar to Part1, but we're only looking for stars.
    @parameter
    fn step2(i: Int) -> Int64:
        let y: Int
        let x: Int
        let l: Int
        let v: Int
        (y, x, l, v) = nums[i]
        let sx = max(x - 1, 0)
        let lx = min(x + l, dimx - 1)
        let sy = max(y - 1, 0)
        let ly = min(y + 1, dimy - 1)
        var sum2 : Int64 = 0
        for gy in range(sy, ly + 1):
            for gx in range(sx, lx + 1):
                if flat[gy * dimx + gx] == 42:
                    # If a star is found, look up its state (previously found neighbor value) in `gears`
                    let gk = (gy * dimy + gx)
                    # Apparently, there is never a gear with more than tow neighbors so this is sufficient
                    if gears[gk] > 0:
                        sum2 += (v * gears[gk]).to_int()
                    # Just store the current value.
                    gears[gk] = v
        return sum2

    @parameter
    fn part2() -> Int64:
        memset(gears, 0, dimy * dimx)
        var sum2 : Int64 = 0
        for i in range(nums.size):
            sum2 += step2(i)
        return sum2

    @parameter
    fn results():
        print(sum1.value.to_int())
        print(sum2.value.to_int())

    # This part doesn't seem to benefit much from parallelization, so just run benchmarks.
    minibench[find_nums]("parse")
    minibench[part1]("part1")
    minibench[part2]("part2")

    # Ensure `lines` and `nums` are still in use
    print(lines.length(), "rows")
    print(nums.size, "numbers")
    print(flat.size, "cells")
