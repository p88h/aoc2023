from benchy import minibench

lines = open("day19.txt").read().split("\n")

def replace(t, i, v):
    r = t.copy()
    r[i] = v
    return r

class BaseRule():
    def __init__(self, name, lbl = None) -> None:
        self.name = name
        self.lbl = lbl
        self.rule = None
        self.next = None
    
    def apply(self, ho, hoho) -> None:
        # print("{} => {}".format(self.name, self.lbl))
        return self.rule.apply(ho, hoho)

class BasicRule(BaseRule):
    def __init__(self, name, lbl, i, n, v) -> None:
        BaseRule.__init__(self, name, lbl)
        self.v = v
        self.n = n
        self.i = i

class LessRule(BasicRule):
    def apply(self, ho, hoho):
        # print("{} {}({}-{}) < {} : {} / {}".format(self.name, self.v, ho[self.i], hoho[self.i], self.n, self.lbl, self.next.name))
        if hoho[self.i] < self.n:
            return self.rule.apply(ho, hoho)
        if ho[self.i] < self.n:
            return self.rule.apply(ho, replace(hoho, self.i, self.n - 1)) + self.next.apply(replace(ho, self.i, self.n), hoho)
        return self.next.apply(ho, hoho)

class MoreRule(BasicRule):
    def apply(self, ho, hoho):
        # print("{} {}({}-{}) > {} : {} / {}".format(self.name, self.v, ho[self.i], hoho[self.i], self.n, self.lbl, self.next.lbl))
        if ho[self.i] > self.n:
            return self.rule.apply(ho, hoho)
        if hoho[self.i] > self.n:
            return self.rule.apply(replace(ho, self.i, self.n + 1), hoho) + self.next.apply(ho, replace(hoho, self.i, self.n))
        return self.next.apply(ho, hoho)

class Accept(BaseRule):
    def apply(self, ho, hoho) -> None:
        return (hoho[0] - ho[0] + 1) * (hoho[1] - ho[1] + 1) * (hoho[2] - ho[2] + 1) * (hoho[3] - ho[3] + 1)

class Reject(BaseRule):
    def apply(self, ho, hoho) -> None:
        return 0

rules = {}
insn = []

def parse():
    rules.clear()
    insn.clear()
    mapp = {"x": 0, "m": 1, "a": 2, "s": 3}
    rules["A"] = Accept("A")
    rules["R"] = Reject("R")
    all_rules = []
    for line in lines:
        pos = line.find("{")
        if pos > 0:
            tok = line[:pos]
            rrr = line[pos + 1 : -1].split(",")
            prev = None
            for r in rrr:
                if ":" in r:
                    a, b = r.split(":")
                    v, o, n = a[0], a[1], int(a[2:])
                    i = mapp[v]
                    if o == "<":
                        rule = LessRule(tok, b, i, n, v)
                    else:
                        rule = MoreRule(tok, b, i, n, v)
                else:
                    rule = BaseRule(tok, r)
                all_rules.append(rule)
                if prev:
                    prev.next = rule
                else:
                    rules[tok] = rule
                prev = rule
        elif pos == 0:
            hohoho = []
            for t in line[1:-1].split(","):
                _, n = t.split("=")
                hohoho.append(int(n))
            insn.append(hohoho)
    for rule in all_rules:
        rule.rule = rules[rule.lbl]
    return len(insn)+len(rules)

def part1():
    ret = 0
    for hohoho in insn:
        ret += sum(hohoho) * rules["in"].apply(hohoho, hohoho)
    return ret

def part2():
    return rules["in"].apply([1,1,1,1],[4000,4000,4000,4000])

parse()
print(part1())
print(part2())

minibench({"parse": parse, "part1": part1, "part2": part2})
