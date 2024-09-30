from parser import *
from collections import List
from wrappers import minibench
from array import Array


fn main() raises:
    f = open("day03.txt", "r")
    lines = make_parser["\n"](f.read())
    dimx = lines.get(0).size
    dimy = lines.length()
    # Here we'll keep all the found numbers - the format is POS_Y,POS_X,LENGTH,VALUE
    nums = Array[DType.int32](2000 * 8)
    var cnt = 0
    # And here we'll keep all the information about gears. We just keep a huge table
    # with enough space to have gears in all position of the board. No hashing - the
    # gear position _is_ the index into this array.
    gears = Array[DType.int32](160 * 160)

    @parameter
    fn push_num(y: Int, x: Int, l: Int, v: Int):
        # Bounding box around the number
        sx = max(x - 1, 0)
        lx = min(x + l, dimx - 1)
        sy = max(y - 1, 0)
        ly = min(y + 1, dimy - 1)
        nums.store[width=8](cnt * 8, SIMD[DType.int32, 8](sx, lx, sy, ly, v))
        cnt += 1

    # This is the common 'parse' task: scan the board and find anythin that looks like
    # a number. Store all found numbers into the 'nums' vector. This could be nicer
    # with return values and all, but we weant to benchmark it and benchmark doesn't like
    # functions with parameters.
    @parameter
    fn find_nums() -> Int64:
        cnt = 0
        for y in range(lines.length()):
            var r: Int = 0
            var q: Int = 0
            line = lines[y]
            for x in range(dimx):
                c = int(line[x])
                # char is in 0..9 range
                if c >= 48 and c <= 57:
                    r = r * 10 + c - 48
                    q += 1
                # or not, but we have some leftover number
                elif q > 0:
                    push_num(y, x - q, q, r)
                    r = q = 0
            # handle numbers at the right edge
            if q > 0:
                push_num(y, dimx - q, q, r)
        return cnt

    # Step 1 will search around the specified number and look for special characters.
    # If any are found, will increment the sum.
    @parameter
    fn step1(i: Int) -> Int64:
        rec = nums.load[width=8](i * 8)
        # unpack
        sx = rec[0]
        lx = rec[1]
        sy = rec[2]
        ly = rec[3]
        v = int(rec[4])
        # Scan the box. This is rather fast in Mojo.
        for gy in range(sy, ly + 1):
            line = lines[gy]
            for gx in range(sx, lx + 1):
                c = line[gx]
                # Not a number and not a dot
                if (c < 48 or c > 57) and (c != 46):
                    return v
        return 0

    @parameter
    fn part1() -> Int64:
        var sum1: Int64 = 0
        for i in range(cnt):
            sum1 += step1(i)
        return sum1

    # Part 2 is actually really similar to Part1, but we're only looking for stars.
    @parameter
    fn step2(i: Int) -> Int64:
        rec = nums.load[width=8](i * 8)
        # unpack
        sx = rec[0]
        lx = rec[1]
        sy = rec[2]
        ly = rec[3]
        v = int(rec[4])
        var sum2: Int64 = 0
        for gy in range(sy, ly + 1):
            line = lines[gy]
            for gx in range(sx, lx + 1):
                if line[gx] == 42:
                    # If a star is found, look up its state (previously found neighbor value) in `gears`
                    gk = gy * dimy + gx
                    # Apparently, there is never a gear with more than tow neighbors so this is sufficient
                    if gears[gk] > 0:
                        sum2 += v * int(gears[gk])
                    # Just store the current value.
                    gears[gk] = v
        return sum2

    @parameter
    fn part2() -> Int64:
        gears.zero()
        var sum2: Int64 = 0
        for i in range(cnt):
            sum2 += step2(i)
        return sum2

    # This part doesn't seem to benefit much from parallelization, so just run benchmarks.
    minibench[find_nums]("parse")
    minibench[part1]("part1")
    minibench[part2]("part2")

    # Ensure `lines` and `nums` are still in use
    print(lines.length(), "rows")
    print(cnt, "numbers")
    print(nums.bytecount() + gears.bytecount(), "bytes")
