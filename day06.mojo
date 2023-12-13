from parser import *
from math import sqrt
from wrappers import minibench


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
    let lines = make_parser['\n'](f.read())

    @parameter
    fn part1() -> Int64:
        let times = make_parser[' '](lines.get(0))
        let dist = make_parser[' '](lines.get(1))
        var s: Int64 = 1
        for i in range(1,times.length()):
            let t = atoi(times.get(i))
            let d = atoi(dist.get(i))
            let q = quadratic(t, d)
            s *= q
        return s

    @parameter
    fn part2() -> Int64:
        let t: Int64 = atoi(lines.get(0)[10:])
        let d: Int64 = atoi(lines.get(1)[10:])
        return quadratic(t, d)

    minibench[part1]("part1")
    minibench[part2]("part2")
    print(lines.length(), "rows")
