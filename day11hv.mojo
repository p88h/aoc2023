from parser import *
from wrappers import minibench
from array import Array

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
