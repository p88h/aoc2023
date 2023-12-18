from common import View, Controller
from random import randint
import pygame
from pygame import gfxdraw

class Display:
    def __init__(self, lines) -> None:
        self.segments = []
        for line in lines:
            (d, n, c) = line.split()
            self.segments.append((d, int(n) * 3, (int(c[2:4], 16), int(c[4:6], 16), int(c[6:8], 16), 255)))
        self.lidx = 0
        self.pidx = 0
        self.speed = 1
        self.cx = 660
        self.cy = 740
        self.cc = 3
        self.ca = 0
        self.border = []
        self.lines = pygame.Surface((1920, 1080), pygame.SRCALPHA)
        self.fills = pygame.Surface((1920, 1080))
        self.fills.fill((128, 128, 200))
        self.phase2 = False

    def blit(self, view: View):
        view.win.blit(self.fills, (0, 0))
        view.win.blit(self.lines, (0, 0))
        view.font.render_to(view.win, (40, 40), "Border diameter: " + str(self.cc//3), (0,0,0,255))
        view.font.render_to(view.win, (40, 70), "Integral area (absolute): " + str(abs(self.ca//9)), (0,0,0,255))
        view.font.render_to(view.win, (40, 100), "Total area w/border: " + str(abs(self.ca//9) + self.cc//6 + 1) , (0,0,0,255))

    def update(self, view: View, controller: Controller):
        if not controller.animate:
            return
        if self.phase2:
            if not self.border:
                controller.animate = False
            next = []
            for (x,y) in self.border:
                if randint(1,10) < 2:
                    col = self.fills.get_at((x, y))
                    for (dx,dy) in [(-1,0),(1,0),(0,1),(0,-1)]:
                        (r,g,b,a) = self.fills.get_at((x+dx, y+dy))
                        if r == 191 and g == 191 and b == 200:
                            gfxdraw.pixel(self.fills,x+dx,y+dy,col)
                            next.append((x+dx,y+dy))
                else:
                    next.append((x,y))
            self.border = next
            self.blit(view)
            return
        view.win.fill((0, 0, 0, 255))
        (dir, num, col) = self.segments[self.lidx]
        m = min(self.speed, num - self.pidx)
        self.pidx += m
        self.cc += m
        if dir == "R":
            self.fills.fill((63,63,0),(self.cx,self.cy,m,1080-self.cy),special_flags=pygame.BLEND_ADD)
            pygame.draw.line(self.lines, col, (self.cx, self.cy), (self.cx + m, self.cy), 3)
            for i in range(m):
                self.border.append((self.cx+i,self.cy))
            self.cx += m
            self.ca += m * self.cy
        elif dir == "L":
            self.fills.fill((63,63,0),(self.cx-m,self.cy,m,1080-self.cy),special_flags=pygame.BLEND_SUB)
            pygame.draw.line(self.lines, col, (self.cx, self.cy), (self.cx - m, self.cy), 3)
            for i in range(m):
                self.border.append((self.cx-i,self.cy))
            self.cx -= m
            self.ca -= m * self.cy
        elif dir == "U":
            pygame.draw.line(self.lines, col, (self.cx, self.cy), (self.cx, self.cy - m), 3)
            for i in range(m):
                self.border.append((self.cx-1,self.cy))
            self.cy -= m
        elif dir == "D":
            self.cy += m
            pygame.draw.line(self.lines, col, (self.cx, self.cy), (self.cx, self.cy + m), 3)
            for i in range(m):
                self.border.append((self.cx-1,self.cy))
        if self.pidx == num:
            self.lidx += 1
            self.pidx = 0
            if self.speed < 10:
                self.speed += 1
        if self.lidx == len(self.segments):
            self.phase2 = True
            for (x,y) in self.border:
                pix = self.lines.get_at((x,y))
                gfxdraw.pixel(self.fills,x,y,pix)
            # controller.animate = False
        self.blit(view)

        


view = View(1920, 1080, 60, 24)
view.setup("Day 18")
controller = Controller()
lines = open(controller.workdir() + "/day18.txt").read().splitlines()
controller.add(Display(lines))
controller.run(view)
