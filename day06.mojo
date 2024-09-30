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
    delta = t * t - 4 * d
    if delta <= 0:
        return 0
    ds = ssqrt(delta)
    var x0 = (t - ds) / 2
    var x1 = (t + ds) / 2
    if x0 * (t - x0) <= d:
        x0 += 1
    if x1 * (t - x1) <= d:
        x1 -= 1
    return int((x1 - x0) + 1)


fn main() raises:
    f = open("day06.txt", "r")
    lines = make_parser['\n'](f.read())

    @parameter
    fn part1() -> Int64:
        times = make_parser[' '](lines.get(0))
        dist = make_parser[' '](lines.get(1))
        var s: Int64 = 1
        for i in range(1,times.length()):
            t = atoi(times.get(i))
            d = atoi(dist.get(i))
            q = quadratic(t, d)
            s *= q
        return s

    @parameter
    fn part2() -> Int64:
        t = atoi(lines.get(0)[10:])
        d = atoi(lines.get(1)[10:])
        return quadratic(t, d)

    minibench[part1]("part1")
    minibench[part2]("part2")
    print(lines.length(), "rows")
