from common import View, Controller
from random import randint
import pygame

class Solver:
    def __init__(self, syms, rules) -> None:
        self.syms = syms
        self.rules = rules
        self.cache = {}

    
    def count(self, sp, rp):
        # skip empty
        while sp < len(self.syms) and self.syms[sp] == ".":
            sp += 1
        if (sp,rp) in self.cache:
            return self.cache[(sp,rp)]
        if rp == len(self.rules):
            if all([c == "." or c == "?" for c in self.syms[sp:]]):
                z = 1
            else:
                z = 0
            self.cache[(sp, rp)] = z
            return z
        if sp >= len(self.syms):
            return 0
        l = self.rules[rp]
        s = p = sp
        # scan the current rule
        f = False
        while l > 0 and p < len(self.syms) and (self.syms[p] == "?" or self.syms[p] == "#"):
            f = f or self.syms[p] == "#"
            p += 1
            l -= 1
        # not able to fit
        if l > 0 and (f or p >= len(self.syms)):
            return 0
        if l > 0 and p < len(self.syms):
            return self.count(p + 1, rp)
        cnt = 0
        # Following symbol has to be '.' or '?' or EOL
        if p == len(self.syms) or self.syms[p] != "#":
            cnt += self.count(p + 1, rp + 1)
        # turn '?' at the start into '.'
        while p < len(self.syms) and self.syms[s] == "?" and (self.syms[p] == "#" or self.syms[p] == "?"):
            f = f or self.syms[p] == "#"
            s += 1
            p += 1
            if p == len(self.syms) or self.syms[p] != "#":
                cnt += self.count(p + 1, rp + 1)
        if not f and p < len(self.syms):
            cnt += self.count(p + 1, rp)
        self.cache[(sp, rp)] = cnt
        return cnt    

class Display:
    def __init__(self, lines) -> None:
        self.lines = lines
        self.lidx = -1
        self.ridx = -1
        self.fidx = -1
        self.speed = 8
        self.sidx = 0
        self.fill = False
        self.mapping = {"?": 0, "#": 1, ".": 2}
        self.boxes = [pygame.image.load("vis/box{}l.png".format(i)) for i in range(1, 4)]

    def draw_boxes(self, view, syms, dx, dy):
        for i, c in enumerate(syms):
            img = self.boxes[self.mapping[c]]
            view.win.blit(img, (i * 80 + dx, dy))

    def update(self, view, controller):
        if not controller.animate:
            return
        if self.sidx < self.speed:
            self.sidx += 1
            return
        self.sidx = 0

        view.win.fill((0x61, 0x75, 0xF8, 0xFF))

        # finished last row, go to previous
        if self.fidx < 0:
            self.ridx -= 1
            if self.ridx >= 0:
                self.fidx = len(self.syms) - self.nums[self.ridx]
        # finished all rows, go to next line
        if self.ridx < 0:
            self.lidx += 1
            line = self.lines[self.lidx]
            self.syms, b = line.split()
            self.nums = list(map(int, b.split(",")))
            self.ridx = len(self.nums) - 1
            self.fidx = len(self.syms) - self.nums[self.ridx]
            self.tab = []
            for i in range(len(self.nums)):
                self.tab.append([-1]*len(self.syms))
            self.solver = Solver(self.syms, self.nums)
            if self.speed > 0:
                self.speed -= 1
            # force break
            if (self.lidx == 100):
                controller.animate = False

        dy = 60
        dx = 80
        # history
        for i in range(self.lidx - 3, self.lidx):
            if i >= 0 and i < len(self.lines):
                self.draw_boxes(view, self.lines[i].split()[0], dx, dy)
            dy += 80
        dy += 40
        # current
        self.draw_boxes(view, self.syms, dx, dy)

        good = all([c == '#' or c =='?' for c in self.syms[self.fidx:self.fidx+self.nums[self.ridx]]])        
        if good:
            color = (0x73, 0xF2, 0x18, 0xFF)
        else:
            color = (0xb7, 0x25, 0x04, 0xFF)

        self.tab[self.ridx][self.fidx] = self.solver.count(self.fidx, self.ridx)

        # box
        pygame.draw.rect(view.win, color, (dx + self.fidx * 80 - 8, dy - 8, self.nums[self.ridx] * 80, 80), 4, 8)

        # table
        for i, r in enumerate(self.nums):
            color = (0x0, 0x0, 0x0, 255)
            if i == self.ridx:
                color = (0xC0, 0xF0, 0x80, 255)                
            view.font.render_to(view.win, (40, dy + 120 + i * 32), str(r), color)
            for j in range(len(self.syms)):
                if self.tab[i][j] >= 0:
                    view.font.render_to(view.win, (30 + 80*(j+1), dy + 120 + i * 32), str(self.tab[i][j]), color)


        # future
        dy += 320
        for i in range(self.lidx + 1, self.lidx + 6):
            if i < len(self.lines):
                self.draw_boxes(view, self.lines[i].split()[0], dx, dy)
            dy += 80
        # step
        self.fidx -= 1


view = View(1920, 1080, 60, 24)
view.setup("Day 12")
controller = Controller()
lines = open(controller.workdir() + "/day12.txt").read().split("\n")
controller.add(Display(lines))
controller.run(view)
