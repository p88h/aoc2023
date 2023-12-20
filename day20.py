from benchy import minibench

class Module:
    def __init__(self, id, targets) -> None:
        self.id = id
        self.targets = targets

    def pulse(self, level, source="ignored"):
        return [(self.id, level, dst) for dst in self.targets]

    def add(self, id):
        pass

    def reset(self):
        pass

class Dummy(Module):
    def __init__(self, id, targets) -> None:
        super().__init__(id, targets)
        self.count = [0, 0]

    def pulse(self, level, _):
        self.count[level] += 1
        return []

    def reset(self):
        self.count.clear()
        self.count.extend([0, 0])

class FlipFlop(Module):
    def __init__(self, id, targets) -> None:
        super().__init__(id, targets)
        self.level = 0

    def pulse(self, level, source):
        if level == 0:
            self.level = 1 - self.level
            return super().pulse(self.level, source)
        return []

    def reset(self):
        self.level = 0

class Conjunction(Module):
    def __init__(self, id, targets) -> None:
        super().__init__(id, targets)
        self.states = self.counts = self.conn = 0
        self.linked = []

    def add(self, id):
        self.linked.append(id)
        self.conn += 1

    def pulse(self, level, source):
        self.counts |= level << source
        self.states &= ~(1 << source)
        self.states |= (level << source)
        if self.states.bit_count() == self.conn:
            return super().pulse(0, source)
        else:
            return super().pulse(1, source)

    def reset(self):
        self.states = self.counts = 0

lines = open("day20.txt").read().split("\n")
modules = [None]
monitor = -1

def parse():
    # parse
    global monitor
    modules.clear()
    modules.append(None)
    ids = {"br": 0}
    for line in lines:
        if ">" not in line:
            continue
        l, r = line.split(" -> ")
        dst = r.split(", ")
        if l != "broadcaster":
            o = l[0]
            n = l[1:]
            ids[n] = len(modules)
            if o == "&":
                m = Conjunction(ids[n], dst)
            else:
                m = FlipFlop(ids[n], dst)
            modules.append(m)
        else:
            o = "*"
            n = "br"
            m = Module(0, dst)
            modules[0] = m

    # link up
    for mod in modules:
        for dst in mod.targets:
            if dst not in ids:
                ids[dst] = len(modules)
                monitor = mod.id
            else:
                modules[ids[dst]].add(mod.id)
        mod.targets = [ids[dst] for dst in mod.targets]
    modules.append(Dummy(len(modules), []))
    return len(modules)

def pushit():
    pcnt = [1,0]
    pulses = []
    pp = 0
    pulses.extend(modules[0].pulse(0))
    while pp < len(pulses):
        (src, level, dst) = pulses[pp]
        # print(src,level,dst)
        pcnt[level] += 1
        pulses.extend(modules[dst].pulse(level, src))
        pp += 1
    return pcnt

def reset():
    for mod in modules:
        mod.reset()

def part1():
    reset()
    los = his = 0
    for _ in range(1000):
        (lo, hi) = pushit()
        los += lo
        his += hi
    return los * his

def part2():
    reset()
    cnt = 0
    prod = 1
    seen = 0
    while modules[-1].count[0] == 0:
        pushit()
        cnt += 1
        if modules[monitor].counts != seen:
            seen = modules[monitor].counts
            prod *= cnt
            if seen.bit_count() == modules[monitor].conn:
                return prod
    return cnt

parse()
print(part1())
print(part2())

minibench({"parse": parse, "part1": part1, "part2": part2})
