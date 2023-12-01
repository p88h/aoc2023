import sys
import time
lines = open("day01.txt").readlines();

def part1():
    s = 0
    for line in lines:
        dd = []
        for i in range(len(line)):
            if line[i] >= '0' and line[i] <= '9':
                dd.append(int(line[i]))
        s += dd[0]*10 + dd[-1]
    return s

def part2():
    s = 0
    digits = ["zero","one","two","three","four","five","six","seven","eight","nine"]
    for line in lines:
        dd = []
        for i in range(len(line)):
            if line[i] >= '0' and line[i] <= '9':
                dd.append(int(line[i]))
            p = line[i:]
            for d in range(10):
                if p.startswith(digits[d]):
                    dd.append(d)
        s += dd[0]*10 + dd[-1]
    return s

print(part1())
print(part2())
start = time.time()
t = 0
for _ in range(100):
    t += part1()
end = time.time()
print("part1: ", (end - start)*10,"ms")
start = time.time()
for _ in range(100):
    t += part2()
end = time.time()
print("part2: ", (end - start)*10,"ms")

