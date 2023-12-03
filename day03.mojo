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
    var nums = DynamicVector[Tuple[Int, Int, Int, Int]](1000)
    var gears = intptr.alloc(dimy*dimx)
    var sum1 = Atomic[DType.int32](0)
    var sum2 = Atomic[DType.int32](0)

    @parameter
    fn find_nums():
        nums.clear()
        for y in range(lines.length()):
            var r : Int = 0
            var q : Int = 0
            for x in range(dimx):
                let c = ord(lines.get(y)[x])
                if c >= 48 and c <= 57:
                    r = r * 10 + c - 48
                    q += 1
                else:
                    if q > 0:
                        nums.push_back((y, x - q, q, r))
                        r = q = 0
            if q > 0:
                nums.push_back((y, dimx - q, q, r))

    @parameter
    fn step1(i: Int):
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
                let c = ord(gl[gx])
                if (c < 48 or c > 57) and (c != 46):
                    sum1 += v
                    return
    
    @parameter
    fn part1():
        sum1 = 0
        for i in range(nums.size): step1(i)

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
                    let gk = (gy * dimy + gx)
                    if gears.load(gk) > 0:
                        sum2 += v * gears.load(gk)
                    gears.store(gk, v)

    @parameter
    fn part2():
        memset(gears, 0, dimy*dimx)
        sum2 = 0
        for i in range(nums.size): step2(i)
                    
    @parameter
    fn results():
        print(sum1.value.to_int())
        print(sum2.value.to_int())

    print("parse:", benchmark.run[find_nums]().mean["ms"](), "ms")
    print("part1:", benchmark.run[part1]().mean["ms"](), "ms")
    print(sum1)
    print("part2:", benchmark.run[part2]().mean["ms"](), "ms")
    print(sum2)
    print(lines.length(), "rows")
    print(nums.size, "numbers")
