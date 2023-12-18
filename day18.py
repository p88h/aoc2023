from benchy import minibench

lines = open("day18.txt").read().split("\n")

class Solver:
    def __init__(self) -> None:
        self.cx = self.cy = self.ca = 0
        self.cc = 1
    
    def move(self,dir,count):
        self.cc += count
        if dir == 'R':
            self.ca += self.cy * count
            self.cx += count
        elif dir == 'L':
            self.ca -= self.cy * count
            self.cx -= count
        elif dir == 'U':
            self.cy += count
        elif dir == 'D':
            self.cy -= count
    
    def area(self):
        return abs(self.ca) + self.cc//2 + 1

def part1():
    s = Solver()
    for line in lines:
        (d,n,_) = line.split()
        s.move(d,int(n))
    return s.area()

def part2():
    s = Solver()
    m = "RDLU"
    for line in lines:
        h = line.split()[2]
        d = m[int(h[7])]
        n = int(h[2:7],16)
        s.move(d,int(n))
    return s.area()

print(part1())
print(part2())

minibench({"part1": part1, "part2": part2})

#######  inner area = 6*2 = 12
# a21 #  circumf = 16 (15+1) 
#######  12 * 0.5 + 4 * 0.75 = 16 * 0.5 + 4 * 0.25 = 8 + 1