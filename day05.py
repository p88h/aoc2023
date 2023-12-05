from benchy import minibench

lines = open("day05.txt").read().split("\n")
lines.append(":")
numbers = []
ranges = []
steps = []


def parse():
    s = lines[0].split()
    numbers.clear()
    ranges.clear()
    steps.clear()
    numbers.extend(map(int, s[1:]))
    for i in range(len(numbers) // 2):
        ranges.append((numbers[2 * i], numbers[2 * i] + numbers[2 * i + 1] - 1))
    cur = []
    for line in lines[3:]:
        if not line:
            continue
        if line[-1] == ":":
            cur.sort()
            print(cur)
            steps.append(cur)
            cur = []
            continue
        (dst, src, l) = map(int, line.split())
        cur.append((src, dst, l))
    return 0


def part1():
    work = numbers.copy()
    for step in steps:
        next = []
        for n in work:
            for src, dst, l in step:
                if n >= src + l:
                    continue
                if n < src:
                    next.append(n)
                else:
                    next.append(n + dst - src)
                n = -1
                break
            if n >= 0:
                next.append(n)
        work = next
    return min(work)


def part2():
    work = ranges.copy()
    for step in steps:
        next = []
        for a, b in work:
            for src, dst, l in step:
                ofs = dst - src
                if a >= src + l:
                    continue
                if a < src:  # some is untranslated
                    next.append((a, src - 1))
                    a = src
                # a >= src.
                if b >= src + l:  # some range remains
                    next.append((a + ofs, (src + l - 1) + ofs))
                    a = src + l
                else:  # everything fits
                    next.append((a + ofs, b + ofs))
                    a = b + 1
                    break
            if a <= b:  # some was left untranslated
                next.append((a, b))
        work = []
        for a, b in sorted(next):
            if work and (a == work[-1][1] + 1):
                work[-1] = (work[-1][0], b)
            else:
                work.append((a, b))
    return work[0][0]


parse()
print(part1())
print(part2())

minibench({"parse": parse, "part1": part1, "part2": part2}, 1000)
