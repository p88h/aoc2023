from benchy import minibench
import numpy as np

lines = open("day24.txt").read().split("\n")

px, py, pz = ([], [], [])
vx, vy, vz = ([], [], [])

def parse():
    for a in [px, py, pz, vx, vy, vz]:
        a.clear()
    for line in lines:
        line = line.replace(" @ ", ", ")
        nums = list(map(int, line.split(", ")))
        p = 0
        for a in [px, py, pz, vx, vy, vz]:
            a.append(nums[p])
            p += 1
    return len(lines)

def part1():
    num = len(lines)
    r1 = 200000000000000
    r2 = 400000000000000
    count = 0
    for i in range(num):
        a1 = vy[i] / vx[i]
        b1 = py[i] - a1 * px[i]
        for j in range(i + 1, num):
            a2 = vy[j] / vx[j]
            b2 = py[j] - a2 * px[j]
            if a1 == a2:
                continue
            x = (b2 - b1) / (a1 - a2)
            y = a1 * x + b1
            t1 = (x - px[i]) / vx[i]
            t2 = (x - px[j]) / vx[j]
            if t1 > 0 and t2 > 0 and x >= r1 and x <= r2 and y >= r1 and y <= r2:
                count += 1
    return count

def part2():
    A = np.array(
        [
            [vy[1] - vy[0], vx[0] - vx[1], 0, py[0] - py[1], px[1] - px[0], 0],
            [vy[2] - vy[0], vx[0] - vx[2], 0, py[0] - py[2], px[2] - px[0], 0],
            [vz[1] - vz[0], 0, vx[0] - vx[1], pz[0] - pz[1], 0, px[1] - px[0]],
            [vz[2] - vz[0], 0, vx[0] - vx[2], pz[0] - pz[2], 0, px[2] - px[0]],
            [0, vz[1] - vz[0], vy[0] - vy[1], 0, pz[0] - pz[1], py[1] - py[0]],
            [0, vz[2] - vz[0], vy[0] - vy[2], 0, pz[0] - pz[2], py[2] - py[0]],
        ]
    )

    x = [
        (py[0] * vx[0] - py[1] * vx[1]) - (px[0] * vy[0] - px[1] * vy[1]),
        (py[0] * vx[0] - py[2] * vx[2]) - (px[0] * vy[0] - px[2] * vy[2]),
        (pz[0] * vx[0] - pz[1] * vx[1]) - (px[0] * vz[0] - px[1] * vz[1]),
        (pz[0] * vx[0] - pz[2] * vx[2]) - (px[0] * vz[0] - px[2] * vz[2]),
        (pz[0] * vy[0] - pz[1] * vy[1]) - (py[0] * vz[0] - py[1] * vz[1]),
        (pz[0] * vy[0] - pz[2] * vy[2]) - (py[0] * vz[0] - py[2] * vz[2]),
    ]
    np.set_printoptions(linewidth=100000)
    sol = np.linalg.solve(A, x)
    return round(sol[0] + sol[1] + sol[2])


parse()
print(part1())
print(part2())
minibench({"parse": parse, "part1": part1, "part2": part2})
