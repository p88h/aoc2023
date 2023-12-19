from benchy import minibench

lines = open("day19.txt").read().split("\n")


def replace(t, i, v):
    r = t.copy()
    r[i] = v
    return r


funs = {}
insn = []


def parse():
    funs.clear()
    insn.clear()
    mapp = {"x": 0, "m": 1, "a": 2, "s": 3}
    funs["A"] = lambda ho, hoho: (hoho[0] - ho[0] + 1) * (hoho[1] - ho[1] + 1) * (hoho[2] - ho[2] + 1) * (hoho[3] - ho[3] + 1)
    funs["R"] = lambda ho, hoho: 0
    for line in lines:
        pos = line.find("{")
        if pos > 0:
            tok = line[:pos]
            ntok = tok + "_"
            rules = line[pos + 1 : -1].split(",")
            for r in rules:
                if ":" in r:
                    a, b = r.split(":")
                    v, o, n = a[0], a[1], int(a[2:])
                    i = mapp[v]
                    if o == "<":
                        funs[tok] = lambda ho, hoho, i=i, n=n, ntok=ntok, b=b: (
                            funs[b](ho, hoho) if hoho[i] < n else funs[ntok](ho, hoho)
                        )
                        tok = ntok
                        ntok = tok + "_"
                        funs[tok] = lambda ho, hoho, i=i, n=n, ntok=ntok, b=b: (
                            funs[b](ho, replace(hoho, i, n - 1)) + funs[ntok](replace(ho, i, n), hoho)
                            if ho[i] < n
                            else funs[ntok](ho, hoho)
                        )
                        tok = ntok
                        ntok = tok + "_"
                    else:
                        funs[tok] = lambda ho, hoho, i=i, n=n, ntok=ntok, b=b: (
                            funs[b](ho, hoho) if ho[i] > n else funs[ntok](ho, hoho)
                        )
                        tok = ntok
                        ntok = tok + "_"
                        funs[tok] = lambda ho, hoho, i=i, n=n, ntok=ntok, b=b: (
                            funs[b](replace(ho, i, n + 1), hoho) + funs[ntok](ho, replace(hoho, i, n))
                            if hoho[i] > n
                            else funs[ntok](ho, hoho)
                        )
                        tok = ntok
                        ntok = tok + "_"
                else:
                    funs[tok] = lambda ho, hoho, r=r: funs[r](ho, hoho)
        elif pos == 0:
            hohoho = []
            for t in line[1:-1].split(","):
                _, n = t.split("=")
                hohoho.append(int(n))
            insn.append(hohoho)
    return len(insn)+len(funs)

def part1():
    ret = 0
    for hohoho in insn:
        ret += sum(hohoho) * funs["in"](hohoho, hohoho)
    return ret

def part2():
    return funs["in"]([1,1,1,1],[4000,4000,4000,4000])

parse()
print(part1())
print(part2())

minibench({"parse": parse, "part1": part1, "part2": part2})
