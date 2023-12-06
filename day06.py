from benchy import minibench
import math

lines = open("day06.txt").read().split("\n")


def quadratic(t, d):
    delta = t * t - 4 * d
    if delta <= 0:
        return 0
    ds = math.sqrt(delta)
    x0 = math.ceil((t - ds) / 2)
    x1 = math.floor((t + ds) / 2)
    if x0 * (t - x0) == d:
        x0 += 1
    if x1 * (t - x1) == d:
        x1 -= 1
    return (x1 - x0) + 1


def part1():
    times = list(map(int, lines[0].split()[1:]))
    dist = list(map(int, lines[1].split()[1:]))
    s = 1
    for i in range(len(times)):
        s *= quadratic(times[i], dist[i])
    return s


def part2():
    t = int(lines[0][10:].replace(" ", ""))
    d = int(lines[1][10:].replace(" ", ""))
    return quadratic(t, d)


print(part1())
print(part2())

minibench({"part1": part1, "part2": part2}, 1000)
