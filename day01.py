import sys
import time
lines = open("day01.txt").readlines()

def look(line):
    for i in range(len(line)):
        if line[i] >= '0' and line[i] <= '9':
            return  int(line[i])
    return 0

def look2(line, patterns):
    for i in range(len(line)):
        if line[i] >= '0' and line[i] <= '9':
            return int(line[i])
        p = line[i:]
        for d in range(len(patterns)):
            if p.startswith(patterns[d]):
                return d    
    return 0

def part1():
    s = 0
    for line in lines:
        s += look(line)*10 + look(line[::-1])
    return s

def part2():
    s = 0
    digits = ["zero","one","two","three","four","five","six","seven","eight","nine"]    
    stigid = [s[::-1] for s in digits]
    for line in lines:
        s += look2(line, digits)*10 + look2(line[::-1], stigid)
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

