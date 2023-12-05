from common import View, Controller
import pygame

def parse(lines):
    s = lines[0].split()
    ranges = []
    numbers = list(map(int, s[1:]))
    for i in range(len(numbers) // 2):
        ranges.append((numbers[2 * i], numbers[2 * i] + numbers[2 * i + 1] - 1))
    cur = []
    steps = []
    for line in lines[3:]:
        if not line:
            continue
        if line[-1] == ":":
            steps.append(sorted(cur))
            cur = []
            continue
        (dst, src, l) = map(int, line.split())
        cur.append((src, dst, l))
    steps.append(sorted(cur))
    return (numbers, ranges, steps)

def split(ranges,step):
    next = []
    tmp = []
    for a, b in ranges:
        for src, dst, l in step:
            ofs = dst - src
            if a >= src + l:
                continue
            if a < src: # some is untranslated
                tmp.append((a,b))
                next.append((a, src - 1))
                a = src
            # a >= src. 
            if b >= src + l: # some range remains
                tmp.append((a,b))
                next.append((a + ofs, (src + l - 1) + ofs))
                a = src + l
            else: # everything fits
                tmp.append((a,b))
                next.append((a + ofs, b + ofs))
                a = b + 1
                break
        if (a <= b): # some was left untranslated
            tmp.append((a,b))
            next.append((a,b))
    return (tmp, next)


class Game:
    def __init__(self, parse) -> None:
        (self.numbers, self.ranges, self.steps) = parse
        self.mode = 0
        self.sidx = 0
        self.fidx = 0

    def update(self, view, controller):
        if not controller.animate:
            return
        view.win.fill((0, 0, 0))
        for i in range(len(self.steps)):
            step = self.steps[i]
            for (src,dst,l) in step:
                y0 = 60 + 140 * i
                y1 = y0 + 100
                x0 = src // 2236962
                x1 = (src + l) // 2236962
                x2 = dst // 2236962
                x3 = (dst + l) // 2236962
                cr = src % 240
                cb = dst % 240
                pygame.draw.polygon(view.win,(cr,220,cb,160),[(x0,y0),(x1,y0),(x3,y1),(x2,y1)],1)
        if (self.fidx == 0):
            (self.ranges, self.next) = split(self.ranges, self.steps[self.sidx])
            print(self.ranges, self.next)

        for i in range(len(self.ranges)):
            (a, b) = self.ranges[i]
            (c, d) = self.next[i]
            x = (a * (140 - self.fidx) + c * self.fidx) // (140 * 2236962)
            w = (b - a) // 2236962
            y = 20 + 140 * self.sidx + self.fidx 
            pygame.draw.rect(view.win, (200, 240, 200, 120), (x, y, w, 40))
            pygame.draw.rect(view.win, (160, 140, 100, 220), (x, y, w, 40), 1)
        self.fidx += 1
        if self.fidx == 140:
            self.fidx = 0
            self.sidx += 1
            self.ranges = self.next
        if self.sidx == len(self.steps):
            controller.animate = False


view = View(1920, 1080, 30, 24)
view.setup("Day 05")
controller = Controller()
lines = open(controller.workdir() + "/day05.txt").read().split("\n")
controller.add(Game(parse(lines)))
controller.run(view)
