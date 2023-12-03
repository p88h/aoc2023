from parser import Parser
from os.atomic import Atomic
from utils.vector import DynamicVector
from wrappers import run_multiline_task
from math import min, max
from memory import memset
from algorithm import parallelize
import benchmark

alias intptr = DTypePointer[DType.int32]

fn main() raises:
    let f = open("day03.txt", "r")
    let lines = Parser(f.read())
    let dimx = len(lines.get(0))
    let dimy = lines.length()
    # Here we'll keep all the found numbers - the format is POS_Y,POS_X,LENGTH,VALUE
    var nums = DynamicVector[Tuple[Int, Int, Int, Int]](1000)
    # And here we'll keep all the information about gears. We just keep a huge table
    # with enough space to have gears in all position of the board. No hashing - the
    # gear position _is_ the index into this array. 
    var gears = intptr.alloc(dimy*dimx)
    # Atomic results (although in the end we don't really use parallelization here)
    var sum1 = Atomic[DType.int32](0)
    var sum2 = Atomic[DType.int32](0)
    
    # This is the common 'parse' task: scan the board and find anythin that looks like
    # a number. Store all found numbers into the 'nums' vector. This could be nicer
    # with return values and all, but we weant to benchmark it and benchmark doesn't like
    # functions with parameters. 
    @parameter
    fn find_nums():
        nums.clear()
        for y in range(lines.length()):
            var r : Int = 0
            var q : Int = 0
            for x in range(dimx):
                let c = ord(lines.get(y)[x])
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

    # Step 1 will search around the specified number and look for special characters.
    # If any are found, will increment the sum.
    @parameter
    fn step1(i: Int):
        # Unpacking tuples in Mojo is comical. 
        let y: Int
        let x: Int
        let l: Int
        let v: Int
        (y,x,l,v) = nums[i]
        # Bounding box around the number
        let sx = max(x-1,0)
        let lx = min(x+l,dimx-1)
        let sy = max(y-1,0)
        let ly = min(y+1,dimy-1)
        # Scan the box. This is rather fast in Mojo.
        for gy in range(sy,ly+1):
            let gl = lines.get(gy)
            for gx in range(sx,lx+1):
                let c = ord(gl[gx])
                # Not a number and not a dot
                if (c < 48 or c > 57) and (c != 46):
                    sum1 += v
                    return
    
    @parameter
    fn part1():
        sum1 = 0
        for i in range(nums.size): step1(i)

    # Part 2 is actually really similar to Part1, but we're only looking for stars.
    @parameter
    fn step2(i: Int):
        let y: Int
        let x: Int
        let l: Int
        let v: Int
        (y,x,l,v) = nums[i]
        let sx = max(x-1,0)
        let lx = min(x+l,dimx-1)
        let sy = max(y-1,0)
        let ly = min(y+1,dimy-1)
        for gy in range(sy,ly+1):
            let gl = lines.get(gy)
            for gx in range(sx,lx+1):
                if ord(gl[gx]) == 42:
                    # If a star is found, look up its state (previously found neighbor value) in `gears`
                    let gk = (gy * dimy + gx)                    
                    # Apparently, there is never a gear with more than tow neighbors so this is sufficient
                    if gears.load(gk) > 0:
                        sum2 += v * gears.load(gk)
                    # Just store the current value.
                    gears.store(gk, v)

    @parameter
    fn part2():
        # So, Pointers don't support the [] operator (like in C) to get nth element, you have to call load() or store().
        # But sure, there is memset. Which the documentation hints is probably slowish, but let's not reimplement it yet. 
        memset(gears, 0, dimy*dimx)
        sum2 = 0
        for i in range(nums.size): step2(i)
                    
    @parameter
    fn results():
        print(sum1.value.to_int())
        print(sum2.value.to_int())

    # This part doesn't seem to benefit much from parallelization, so just run benchmarks. 
    print("parse:", benchmark.run[find_nums]().mean["ms"](), "ms")
    print("part1:", benchmark.run[part1]().mean["ms"](), "ms")
    print(sum1)
    print("part2:", benchmark.run[part2]().mean["ms"](), "ms")
    print(sum2)

    # Ensure `lines` and `nums` are still in use
    print(lines.length(), "rows")
    print(nums.size, "numbers")
