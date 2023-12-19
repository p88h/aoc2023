from common import View, Controller
import pygame
import math


def replace(t, i, v):
    r = t.copy()
    r[i] = v
    return r


class BaseRule:
    def __init__(self, name, lbl=None) -> None:
        self.name = name
        self.lbl = lbl
        self.rule = None
        self.next = None

    def apply(self, ho, hoho) -> None:
        return self.rule.apply(ho, hoho)


class BasicRule(BaseRule):
    def __init__(self, name, lbl, i, n, v) -> None:
        BaseRule.__init__(self, name, lbl)
        self.v = v
        self.n = n
        self.i = i


class LessRule(BasicRule):
    def apply(self, ho, hoho):
        if hoho[self.i] < self.n:
            return self.rule.apply(ho, hoho)
        if ho[self.i] < self.n:
            return self.rule.apply(ho, replace(hoho, self.i, self.n - 1)) + self.next.apply(replace(ho, self.i, self.n), hoho)
        return self.next.apply(ho, hoho)


class MoreRule(BasicRule):
    def apply(self, ho, hoho):
        if ho[self.i] > self.n:
            return self.rule.apply(ho, hoho)
        if hoho[self.i] > self.n:
            return self.rule.apply(replace(ho, self.i, self.n + 1), hoho) + self.next.apply(ho, replace(hoho, self.i, self.n))
        return self.next.apply(ho, hoho)


class Accept(BaseRule):
    def __init__(self, name) -> None:
        super().__init__(name)
        self.boxes = []

    def apply(self, ho, hoho) -> None:
        self.boxes.append((ho, hoho))
        return (hoho[0] - ho[0] + 1) * (hoho[1] - ho[1] + 1) * (hoho[2] - ho[2] + 1) * (hoho[3] - ho[3] + 1)


class Reject(BaseRule):
    def apply(self, ho, hoho) -> None:
        return 0


def parse(lines):
    rules = {}
    insn = []
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
    return rules


def project2d(v):
    x, y, z = v
    x, y, z = x // 4, y // 8, z // 5
    xp = (x - z) / math.sqrt(2) + 860
    yp = (x + 2 * y + z) / math.sqrt(6) + 40
    return (int(xp), int(yp))


class Background:
    def __init__(self) -> None:
        pass

    def update(self, view, controller):
        if view.frame > 4000:
            controller.animate = False
        if not controller.animate:
            return
        view.win.fill((0, 0, 0, 0))
        pygame.draw.line(view.win, (255,255,255), (50,1160),(1870,1160), 2)
        pygame.draw.circle(view.win, (255,255,255), (51+view.frame*5//11,1161), 6)
        view.font.render_to(view.win, (31+view.frame*5//11, 1186), "Z " + str(view.frame), (255, 255, 255))


class Box3D:
    def __init__(self, dims):
        ho, hoho = dims
        (x, y, z, t1) = ho
        (w, h, d, tt) = [hoho[i] - ho[i] for i in range(4)]
        self.t1 = t1
        self.t2 = t1 + tt
        vertices3D = [
            [x, y, z],
            [x + w, y, z],
            [x + w, y + h, z],
            [x, y + h, z],
            [x, y, z + d],
            [x + w, y, z + d],
            [x + w, y + h, z + d],
            [x, y + h, z + d],
        ]
        faces = [
            [project2d(vertices3D[i]) for i in range(4)],
            [project2d(vertices3D[i]) for i in range(4, 8)],
            [project2d(vertices3D[i]) for i in [0, 1, 5, 4]],
            [project2d(vertices3D[i]) for i in [2, 3, 7, 6]],
            [project2d(vertices3D[i]) for i in [1, 2, 6, 5]],
            [project2d(vertices3D[i]) for i in [0, 3, 7, 4]],
        ]
        all_points = []
        all_points.extend(faces[1])
        all_points.extend(faces[2])
        all_points.extend(faces[4])
        self.x = self.y = 2000
        self.w = self.h = 0
        for x, y in all_points:
            self.x = min(x, self.x)
            self.y = min(y, self.y)
            self.w = max(self.w, x)
            self.h = max(self.h, y)
        self.w -= self.x
        self.h -= self.y
        self.tmp = pygame.Surface((self.w, self.h), pygame.SRCALPHA)
        face1 = [(x - self.x, y - self.y) for (x, y) in faces[1]]
        face2 = [(x - self.x, y - self.y) for (x, y) in faces[2]]
        face4 = [(x - self.x, y - self.y) for (x, y) in faces[4]]
        pygame.draw.polygon(self.tmp, (200, 200, 200), face2)
        pygame.draw.polygon(self.tmp, (120, 120, 120), face1)
        pygame.draw.polygon(self.tmp, (160, 160, 160), face4)
        pygame.draw.polygon(self.tmp, (0, 0, 0), face2, 1)
        pygame.draw.polygon(self.tmp, (0, 0, 0), face1, 1)
        pygame.draw.polygon(self.tmp, (0, 0, 0), face4, 1)

    def update(self, view, controller):
        if view.frame < self.t1 or view.frame > self.t2:
            return
        dur = self.t2 - self.t1
        pos = min(view.frame - self.t1, self.t2 - view.frame)
        alpha = 255
        if pos < dur / 4:
            alpha = pos * 1024 // dur
        self.tmp.set_alpha(alpha)
        view.win.blit(self.tmp, (self.x, self.y))


view = View(1920, 1200, 60, 24)
view.setup("Day 16")
controller = Controller()
lines = open("day19.txt").read().split("\n")
rules = parse(lines)
rules["in"].apply([1, 1, 1, 1], [4000, 4000, 4000, 4000])
boxes = rules["A"].boxes
controller.add(Background())
for box in boxes:
    controller.add(Box3D(box))
controller.run(view)
