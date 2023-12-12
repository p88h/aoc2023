from benchy import minibench
lines = open("day12.txt").read().split("\n")

cache = {}
def count(syms, sp, rules, rp):
    # skip empty
    while sp < len(syms) and syms[sp] == ".":
        sp += 1
    if (sp, rp) in cache:
        return cache[(sp, rp)]
    if rp == len(rules):
        if all([c == "." or c == "?" for c in syms[sp:]]):
            z = 1
        else:
            z = 0
        cache[(sp, rp)] = z
        return z
    if sp >= len(syms):
        return 0
    l = rules[rp]
    s = p = sp
    # scan the current rule
    f = False
    while l > 0 and p < len(syms) and (syms[p] == "?" or syms[p] == "#"):
        f = f or syms[p] == "#"
        p += 1
        l -= 1
    # not able to fit
    if l > 0 and (f or p >= len(syms)):
        return 0
    if l > 0 and p < len(syms):
        return count(syms, p + 1, rules, rp)
    cnt = 0
    # Following symbol has to be '.' or '?' or EOL
    if p == len(syms) or syms[p] != "#":
        cnt += count(syms, p + 1, rules, rp + 1)
    # turn '?' at the start into '.'
    while p < len(syms) and syms[s] == "?" and (syms[p] == "#" or syms[p] == "?"):
        f = f or syms[p] == "#"
        s += 1
        p += 1
        if p == len(syms) or syms[p] != "#":
            cnt += count(syms, p + 1, rules, rp + 1)
    if not f and p < len(syms):
        cnt += count(syms, p + 1, rules, rp)
    cache[(sp, rp)] = cnt
    return cnt

def run(mult):
    tot = 0
    for l in lines:
        a, b = l.split()
        c = list(map(int, b.split(",")))
        cache.clear()
        aa = a
        if (mult > 1):
            aa = ((a + "?") * 5)[:-1]
        z = count(aa , 0, c * mult , 0)
        tot += z
    return tot

def part1():
    return run(1)

def part2():
    return run(5)

print(part1())
print(part2())

minibench({"part1": part1, "part2": part2})