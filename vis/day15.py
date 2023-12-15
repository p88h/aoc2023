from collections import defaultdict
from common import View, Controller
import math
import pygame

def hash(s):
    v = 0
    for c in s:
        v += ord(c)
        v *= 17
        v &= 255
    return v

def  fnv1a(s):
        hash= 2166136261
        for c in s:
            hash = ((hash ^ ord(c)) * 16777619) % 0xFFFFFFFF
        return hash 

def color(l, alpha = 255):
    h = fnv1a(l)
    return (h & 0xFF, (h>>8)&0xFF, (h>>16)&0xFF, alpha)


gcx = 660
gcy = 540

class Segment:
    def __init__(self, ri, rmax, color, length):
        self.rad = (ri * math.pi * 2) / 256
        self.color = color
        self.lmax = length
        self.lc = 0
        self.rmax = rmax
        self.rc = 0

    def update(self, view, pmax):
        if self.lc < self.lmax:
            self.lc += 1
        if self.lc > self.lmax:
            self.lc //= 2
        if self.rc < self.rmax and self.rc < pmax:
            self.rc += 4
        elif self.rc > pmax:
            self.rc = pmax 
        r1 = self.rc
        r2 = r1 - self.lc
        x1, y1 = gcx + r1 * math.cos(self.rad), gcy + r1 * math.sin(self.rad)
        x2, y2 = gcx + r2 * math.cos(self.rad), gcy + r2 * math.sin(self.rad)
        pygame.draw.line(view.win, self.color, (x1,y1), (x2,y2), 3)
        return self.rc - self.lc

class Display:
    def __init__(self, tokens) -> None:
        self.tokens = tokens
        self.boxes = []
        self.segments = []
        self.segmap = {}
        self.strength = defaultdict(int)
        self.textbox = []
        for _ in range(256):
            self.boxes.append([])            
            self.segments.append([])
        self.fidx = 0
        self.tidx = 0
        self.speed = 10
        self.ridx = 300
       
    def update(self, view, controller):
        if not controller.animate:
            return
        view.win.fill((0,0,0,0))
        for i in range(256):
            r1 = 500
            r2 = r1-4
            rad = (i * math.pi * 2) / 256
            x1, y1 = gcx + r1 * math.cos(rad), gcy + r1 * math.sin(rad)
            x2, y2 = gcx + r2 * math.cos(rad), gcy + r2 * math.sin(rad)
            pygame.draw.line(view.win, (240,240,240,240), (x1,y1), (x2,y2), 3)
            mark = []
            for segment in self.segments[i]:
                r2 = segment.update(view, r2)
                # cleanup maybe ? 
                if segment.lmax == 0 and segment.lc == 0:
                    mark.append(segment)
            for marked in mark:
                self.segments[i].remove(marked)
        alpha = 10
        cx = gcx + 600
        cy = gcy + 120
        for i in range(len(self.textbox)-20,len(self.textbox)):
            if i >= 0:
                o,l,v = self.textbox[i]
                view.font.render_to(view.win, (cx, cy), o + " " + l + " " + str(v), color(l, alpha))
            cy -= 16
            alpha += 12
        cy -= 16
        view.font.render_to(view.win, (cx, cy), str(self.tidx) + " / " + str(len(self.tokens)), (255,255,255,255))
        if self.fidx < self.speed:
            self.fidx += 1
            return
        self.fidx = 0
        if self.tidx == len(self.tokens):
            if self.ridx == 0:
                controller.animate = False
            else:
                self.ridx -= 1
            return
        if self.tidx % 100 == 99 and self.speed > 1:
            self.speed -= 1
        tok = self.tokens[self.tidx]
        if tok[-1] == "-":
            l = tok[:-1]
            hc = hash(l) 
            if l in self.boxes[hc]:
                self.boxes[hc].remove(l)
                self.segmap[l].lmax = 0
            self.textbox.append(("-",l, self.strength[l]))
        else:
            l = tok[:-2]
            hc = hash(l)
            st = int(tok[-1])
            # checking via strength map is slower. 
            if l not in self.boxes[hc]:
                self.boxes[hc].append(l)
                seg = Segment(hc, 500, color(l), 8*st+4)
                self.segments[hc].append(seg)
                self.segmap[l] = seg
            else:
                self.segmap[l].lmax = 8*st+4
            self.strength[l] = st
            self.textbox.append(("=",l, st))
        self.tidx += 1



view = View(1920, 1080, 60, 24)
view.setup("Day 15")
controller = Controller()
lines = open(controller.workdir() + "/day15.txt").read().split(",")
controller.add(Display(lines))
controller.run(view)
