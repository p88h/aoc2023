from common import View, Controller
from random import randint
import pygame


class Module:
    def __init__(self, name, id, targets) -> None:
        self.name = name
        self.id = id
        self.targets = targets
        self.state = 0
        self.freq = 0

    def setpos(self, x, y):
        self.x = x
        self.y = y
        self.v = randint(20, 40)

    def pulse(self, level, source="ignored"):
        return [(self.id, level, dst) for dst in self.targets]

    def add(self, id):
        pass

    def reset(self):
        pass

    def update(self, view, controller):
        bcol = (40, 40, 40)
        tcol = (240, 240, 240, 240)
        if self.state == 1:
            bcol,tcol=tcol,bcol
        pygame.draw.rect(view.win, bcol, (self.x, self.y, 40, 40))
        pygame.draw.rect(view.win, tcol, (self.x, self.y, 40, 40), 2)
        view.font.render_to(view.win, (self.x + 7, self.y + 28), self.name, )


class Dummy(Module):
    def __init__(self, name, id, targets) -> None:
        super().__init__(name, id, targets)
        self.count = [0, 0]

    def pulse(self, level, _):
        self.count[level] += 1
        return []

    def reset(self):
        self.count.clear()
        self.count.extend([0, 0])


class FlipFlop(Module):
    def __init__(self, name, id, targets) -> None:
        super().__init__(name, id, targets)
        self.level = 0

    def pulse(self, level, source):
        if level == 0:
            self.level = 1 - self.level
            self.state = self.level
            return super().pulse(self.level, source)
        return []

    def reset(self):
        self.level = 0


class Conjunction(Module):
    def __init__(self, name, id, targets) -> None:
        super().__init__(name, id, targets)
        self.states = self.counts = self.conn = 0
        self.linked = []
        self.state = 1

    def add(self, id):
        self.linked.append(id)
        self.conn += 1

    def pulse(self, level, source):
        self.counts |= level << source
        self.states &= ~(1 << source)
        self.states |= level << source
        if self.states.bit_count() == self.conn:
            self.state = 0
            return super().pulse(0, source)
        else:
            self.state = 1
            return super().pulse(1, source)

    def reset(self):
        self.states = self.counts = 0


def parse(lines):
    modules = [None]
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
                m = Conjunction(n, ids[n], dst)
            else:
                m = FlipFlop(n, ids[n], dst)
            modules.append(m)
        else:
            o = "*"
            n = "br"
            m = Module("br", 0, dst)
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
    modules.append(Dummy("rx", len(modules), []))
    return (modules, monitor)


class Background:
    def __init__(self, modules, monitor) -> None:
        self.modules = modules
        self.monitor = monitor
        self.pp = 0
        self.pulses = []
        self.active = set()
        self.seen = 0
        self.cnt = 0
        self.speed = 4
    
    def pushit(self, num):
        self.active.clear()
        if (self.pp == len(self.pulses)):
            self.pulses = self.modules[0].pulse(0)
            self.pp = 0
            self.cnt += 1
        while self.pp < len(self.pulses) and num > 0:
            (src, level, dst) = self.pulses[self.pp]
            self.active.add((src,dst))
            self.pulses.extend(modules[dst].pulse(level, src))
            self.pp += 1
            num -= 1
        if self.modules[self.monitor].counts != self.seen:
            nseen = self.modules[self.monitor].counts & ~self.seen
            for i in self.modules[self.monitor].linked:
                if nseen & (1 << i):
                    self.modules[i].freq = self.cnt
                    print(i, "activated at", self.cnt)

            self.seen = self.modules[self.monitor].counts            
            if self.seen.bit_count() == modules[monitor].conn:
                return True
        return False


    def update(self, view, controller):
        if view.frame > 4500:
            controller.animate = False
        if not controller.animate:
            return
        if self.cnt % self.speed == self.speed - 1 and self.speed < 512:
            self.speed *= 2
        self.pushit(self.speed)
        view.win.fill((0, 0, 0, 0))
        view.font.render_to(view.win, (31, 186), "BUTTON PUSHES: " + str(self.cnt), (255, 255, 255))
        for mod in self.modules:
            mod.update(view, controller)
            for i in mod.targets:
                dst = modules[i]
                w = 1
                col = (200,200,200)
                if (mod.id,i) in self.active:
                    w = 2 
                    col = (250,250,250)
                if mod.y < dst.y:
                    if dst.y - mod.y > 100:
                        points = [
                            (mod.x + 40, mod.y + 20),
                            (mod.x + 50, mod.y + 20),
                            (mod.x + 50, dst.y - 20),
                            (dst.x + 20, dst.y - 20),
                            (dst.x + 20, dst.y),
                        ]
                        pygame.draw.lines(view.win, col, False, points, w)
                        if mod.freq > 0:
                            view.font.render_to(view.win, (mod.x - 80, (mod.y+2*dst.y)//3), "FREQ: " + str(mod.freq), (240, 240, 240))
                        else:
                            view.font.render_to(view.win, (mod.x - 50, (mod.y+2*dst.y)//3), "FREQ: ?", (160, 160, 160))
                    else:
                        pygame.draw.line(view.win, col, (mod.x + 20, mod.y + 40), (dst.x + 20, dst.y), w)
                elif mod.y > dst.y:
                    pygame.draw.line(view.win, col, (mod.x + 20, mod.y), (dst.x + 20, dst.y + 40), w)
                elif mod.x < dst.x:
                    pygame.draw.line(view.win, col, (mod.x + 40, mod.y + 20), (dst.x, dst.y + 20), w)
                else:
                    pygame.draw.line(view.win, col, (mod.x, mod.y + 20), (dst.x + 40, dst.y + 20), w)


lines = open("day20.txt").read().split("\n")
modules, monitor = parse(lines)
view = View(1920, 1080, 60, 24)
view.setup("Day 20")
controller = Controller()
modules[0].setpos(900, 300)
for g in range(4):
    ofsx = g * 480 + 20
    modules[g * 13 + 1].setpos(ofsx, 400)
    modules[g * 13 + 2].setpos(ofsx + 60, 400)
    for mod in modules[g * 13 + 3 : g * 13 + 14]:
        mod.setpos(ofsx, 500)
        ofsx += 40
ofsx = 420
for mod in modules[-6:-2]:
    mod.setpos(ofsx, 400)
    ofsx += 480
modules[-2].setpos(900, 700)
modules[-1].setpos(900, 800)
controller.add(Background(modules, monitor))
controller.run(view)
