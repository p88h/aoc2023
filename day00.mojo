from parser import Parser

struct Solution:
    var parse: Parser
    fn __init__(inout self, s: String):
        self.parse = Parser(s)

    fn part1(self) raises -> String:
        let l = self.parse.get(0)
        var x: Int = atol(l)
        x *= 2
        return String(x)
    
    fn part2(self) raises -> String:
        var s: Int = 0
        for i in range(self.parse.length()):
            let l = self.parse.get(i)
            let y = atol(l)
            s += y
        return String(s)

fn main():
    try:
        let f = open("day00.txt", "r")
        let s = Solution(f.read())
        print(s.part1())
        print(s.part2())
    except e:
        print(e)
