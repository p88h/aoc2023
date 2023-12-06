from parser import Parser
from math import sqrt
from wrappers import minibench


# Custom string-to-int which skips spaces
fn atoi(s: String) -> Int64:
    alias zero = 48
    alias space = 32
    var ret: Int = 0
    for i in range(len(s)):
        let c = s._buffer[i].to_int()
        if c != space:
            ret = ret * 10 + c - zero
    return ret


# this is actually faster than math.sqrt(Int), but works for 64-bit numbers
fn ssqrt(x: Int64) -> Int64:
    var d: Int64 = 1
    while d * d < x:
        d *= 2
    var a: Int64 = 0
    while d > 1:
        d = d / 2
        if x > (a + d) * (a + d):
            a += d
    return a


# Computes the integral distance between solutions of a quadratic function (x)(t-x)-d
# / number of values of x such for which the function is strictly larger than zero
fn quadratic(t: Int64, d: Int64) -> Int64:
    let delta: Int64 = t * t - 4 * d
    if delta <= 0:
        return 0
    let ds = ssqrt(delta)
    var x0 = (t - ds) / 2
    var x1 = (t + ds) / 2
    if x0 * (t - x0) <= d:
        x0 += 1
    if x1 * (t - x1) <= d:
        x1 -= 1
    return ((x1 - x0) + 1).to_int()


fn main() raises:
    let f = open("day06.txt", "r")
    let lines = Parser(f.read())
    var ret1 = Atomic[DType.int64](0)
    var ret2 = Atomic[DType.int64](0)

    @parameter
    fn part1():
        let times = Parser(lines.get(0), " ")
        let dist = Parser(lines.get(1), " ")
        var s: Int64 = 1
        for i in range(1,times.length()):
            let t = atoi(times.get(i))
            let d = atoi(dist.get(i))
            let q = quadratic(t, d)
            s *= q
        ret1 = s

    @parameter
    fn part2():
        let t: Int64 = atoi(String(lines.get(0))[10:])
        let d: Int64 = atoi(String(lines.get(1))[10:])
        ret2 = quadratic(t, d)

    minibench[part1]("part1")
    print(ret1)
    minibench[part2]("part2")
    print(ret2)
    print(lines.length(), "rows")
