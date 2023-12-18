from parser import *
from wrappers import minibench
from array import Array
from math import abs

alias ordR = ord('R')
alias ordD = ord('D')
alias ordL = ord('L')
alias ordU = ord('U')
alias zero = ord('0')

struct Solver:
    var cx: Int
    var cy: Int
    var cc: Int
    var ca: Int
    
    fn __init__(inout self):
        self.cx = self.cy = self.ca = 0
        self.cc = 1
    
    fn move(inout self,dir: Int8,count: Int):
        # print(chr(dir.to_int()), count)
        self.cc += count
        if dir == ordR:
            self.ca += self.cy * count
            self.cx += count
        elif dir == ordL:
            self.ca -= self.cy * count
            self.cx -= count
        elif dir == ordD:
            self.cy += count
        elif dir == ordU:
            self.cy -= count
    
    fn area(self) -> Int64:
        return abs(self.ca) + self.cc//2 + 1    

fn main() raises:
    let f = open("day18.txt", "r")
    let lines = make_parser["\n"](f.read())

    @parameter
    fn part1() -> Int64:
        alias sep = ord('(')
        var s = Solver()
        for i in range(lines.length()):
            let line = lines[i]
            let p = line.find(sep)
            s.move(line[0],atoi(line[2:p-1]).to_int())
        return s.area()

    @parameter
    fn part2() -> Int64:
        alias dirs = VariadicList[Int8]( ordR, ordD, ordL, ordU )
        var s = Solver()
        for i in range(lines.length()):
            let line = lines[i]
            let c = line[line.size-2] - zero
            let d = dirs[c.to_int()]
            let x = xtoi(line[line.size-7:line.size-2])
            s.move(d,x.to_int())
        return s.area()

    print(part1())
    print(part2())
    minibench[part1]("part1")
    minibench[part2]("part2")

    print(lines.length(), "lines")
