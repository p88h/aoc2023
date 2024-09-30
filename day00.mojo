from parser import *

struct Solution:
    var parse: Parser

    fn __init__(inout self, s: String):
        self.parse = make_parser[10](s)

    fn part1(self) raises -> String:
        l = self.parse.get(0)
        var x: Int = int(atoi(l))
        x *= 2
        return str(x)

    fn part2(self) raises -> String:
        var s: Int = 0
        for i in range(self.parse.length()):
            l = self.parse.get(i)
            y = int(atoi(l))
            s += y
        return str(s)

fn main():
    try:
        f = open("day00.txt", "r")
        s = Solution(f.read())
        print(s.part1())
        print(s.part2())
    except e:
        print(e)
