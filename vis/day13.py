from collections import defaultdict
from common import View, Controller
from random import randint
import pygame


class Display:
    def __init__(self, lines) -> None:
        self.lines = lines
        self.midx = 0
        self.fidx = 0
        self.ridx = 0
        self.stop = 0
        self.speed = 1
        self.mats = []
        self.maps = []
        dima = self.dima = 30
        dimb = self.dimb = 36
        self.header = pygame.Surface((1280,120), pygame.SRCALPHA)
        self.halpha = 0
        cur = []
        for l in lines:
            if not l:
                self.mats.append(cur)
                if len(self.mats) == 1:
                    print(cur, len(cur[0]))
                dimc = (dimb - dima) // 2
                bmp = pygame.Surface((len(cur[0]) * dimb, len(cur) * dimb), pygame.SRCALPHA)
                bmph = pygame.Surface((len(cur[0]) * dimb, len(cur) * dimb), pygame.SRCALPHA)
                bmpv = pygame.Surface((len(cur[0]) * dimb, len(cur) * dimb), pygame.SRCALPHA)
                mv = len(cur) - 1
                mh = len(cur[0]) - 1
                for i in range(len(cur)):
                    for j in range(len(cur[i])):
                        if cur[i][j] == "#":
                            pygame.draw.rect(bmp, (255, 120, 0, 128), (j * dimb + dimc, i * dimb + dimc, dima, dima))
                            pygame.draw.rect(bmpv, (0, 120, 255, 128), (j * dimb + dimc, (mv - i) * dimb + dimc, dima, dima))
                            pygame.draw.rect(bmph, (0, 120, 255, 128), ((mh - j) * dimb + dimc, i * dimb + dimc, dima, dima))

                self.maps.append(bmp)
                self.maps.append(bmph)
                self.maps.append(bmpv)
                cur = []
            else:
                cur.append(l)

    def analyze(self, view, surface, w, h, ofsx, ofsy):
        dist = defaultdict(int)
        for y in range(4, h, self.dimb):
            for x in range(4, w, self.dimb):
                (r, g, b, _) = view.win.get_at((ofsx + x, ofsy + y))
                dist[(r, g, b)] += 1
        pos = 0
        mm = 1000
        mc = 0
        for col in dist:
            if col == (255, 255, 255):
                continue
            mc += 1
            pygame.draw.rect(surface, col, (ofsx, 8 + pos, self.dima, self.dima))
            view.font.render_to(surface, (ofsx + self.dimb, 12 + self.dimb // 2 + pos), "x " + str(dist[col]), (0, 0, 0, 255))
            mm = min(dist[col], mm)
            pos += self.dimb        
        if mc == 2 and mm == 1:
            pygame.draw.rect(surface, (0xf0,0xf0,0x80,0xff), (ofsx - 4, 4, 200, self.dimb * 2 + 4), 3, 2)
            view.font.render_to(surface, (ofsx + 200, 28), "Fold: " + str(self.fidx // self.dimb), (0, 0, 0, 255))
            self.stop = 36 // self.speed
            self.ridx = 10

    def update(self, view, controller):
        if not controller.animate:
            return
        if self.stop > 0:
            self.stop -= 1
            if not self.stop:
                self.fidx = 0
                self.midx += 1
                self.header.fill((0xFF, 0xFF, 0xFF, 0xFF))
                if self.speed < 4:
                    self.speed += 1
            return
        if (self.midx * 3 >= len(self.maps)):
            controller.animate = False
            return
        (w, h) = self.maps[self.midx * 3].get_size()
        if self.fidx % self.dimb == self.speed and self.ridx < (12 // self.speed):
            self.ridx += 1
            if self.ridx == 1:
                self.header.fill((0xFF, 0xFF, 0xFF, 0xFF))
                self.analyze(view, self.header, min(self.fidx, w-self.fidx), h, 16, 120)
                self.analyze(view, self.header, w, min(self.fidx, h-self.fidx), 648, 120)
                view.win.blit(self.header,(0,0))
                self.halpha = 0xff                
            return
        self.ridx = 0
        view.win.fill((0xFF, 0xFF, 0xFF, 0xFF))
        self.header.set_alpha(self.halpha)
        view.win.blit(self.header,(0,0))
        view.win.blit(self.maps[self.midx * 3], (16, 120), (self.fidx, 0, w - self.fidx, h))
        view.win.blit(self.maps[self.midx * 3 + 1], (16, 120), (max(w - self.fidx, 0), 0, self.fidx, h))
        view.win.blit(self.maps[self.midx * 3], (648, 120), (0, self.fidx, w, h - self.fidx))
        view.win.blit(self.maps[self.midx * 3 + 2], (648, 120), (0, max(h - self.fidx, 0), w, self.fidx))
        w1 = min(self.fidx, w-self.fidx)
        if w1 > 5:
            pygame.draw.rect(view.win, (0x40,0x40,0x40,0xff), (16, 120, w1, h), 3, 2)        
        h1 = min(self.fidx, h-self.fidx)
        if h1 > 5:
            pygame.draw.rect(view.win, (0x40,0x40,0x40,0xff), (648, 120, w, h1), 3, 2)
        self.fidx += self.speed


view = View(1280, 800, 60, 24)
view.setup("Day 13")
controller = Controller()
lines = open(controller.workdir() + "/day13.txt").read().split("\n")
controller.add(Display(lines))
controller.run(view)
