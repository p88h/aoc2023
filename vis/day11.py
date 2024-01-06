from common import View, Controller
from random import randint
from pygame import gfxdraw
import pygame


class Display:
    def __init__(self, lines) -> None:
        self.lines = lines
        self.stars = {}
        self.fidx = 0
        self.speed = 1
        self.scale = 8
        self.emptyv = [ True ] * len(self.lines)
        self.emptyh = [ True ] * len(self.lines)
        for y in range(len(lines)):
            for x in range(len(lines[y])):
                if lines[y][x] == '#':
                    self.emptyv[x] = False
                    self.emptyh[y] = False
        self.cntv = self.emptyv.count(True)
        self.cnth = self.emptyh.count(True)
        
    def update(self, view, controller):
        if not controller.animate:
            return
        dimx = len(self.lines[0]) + self.cntv * self.fidx
        dimy = len(self.lines) + self.cnth * self.fidx
        self.scale = 1200 / dimy
        print(self.scale)
        view.win.fill((10, 10, 10, 0))
        bw = int(dimx * self.scale)
        bh = int(dimy * self.scale)
        oy = by = (1200 - bh) // 2
        ox = bx = (1920 - bw) // 2
        sr = self.scale / 2
        for x in range(len(self.lines[0])):
            if self.emptyv[x]:
                pygame.draw.rect(view.win, (0,0,0), (int(ox), int(oy), int((1 + self.fidx) * self.scale), bh))
                ox += self.fidx * self.scale
            ox += self.scale
        for y in range(len(self.lines)):
            ox = bx
            if self.emptyh[y]:
                pygame.draw.rect(view.win, (0,0,0), (int(ox), int(oy), bw, int((1 + self.fidx) * self.scale)))
                oy += self.fidx * self.scale
            else:           
                for x in range(len(self.lines[y])):
                    if self.lines[y][x] == '#':
                        if sr < 1:
                            gfxdraw.pixel(view.win, int(ox), int(oy), (0xff,0xcd,0x3c))
                        else:
                            pygame.draw.circle(view.win, (0xff,0xcd,0x3c), (int(ox + sr), int(oy + sr)), sr)
                    if self.emptyv[x]:
                        ox += self.fidx * self.scale
                    ox += self.scale
            oy += self.scale
        self.fidx += 1
        if (self.fidx == 300):
            controller.animate = False
        view.font.render_to(view.win, (bx-160,by+16), "Current step: " + str(self.fidx), (255,255,255,255))


view = View(1920, 1200, 10, 16)
view.setup("Day 11")
controller = Controller()
lines = open(controller.workdir() + "/day11.txt").read().split("\n")
controller.add(Display(lines))
controller.run(view)
