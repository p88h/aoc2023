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

class Display:
    def __init__(self, tokens) -> None:
        self.tokens = tokens
        self.boxes = []
        self.strength = defaultdict(int)
        self.textbox = []
        for _ in range(256):
            self.boxes.append([])
        self.tidx = 0
       
    def update(self, view, controller):
        if not controller.animate:
            return
        view.win.fill((0,0,0,0))
        cx = 960
        cy = 540
        for i in range(256):
            r1 = 500
            r2 = r1-4
            rad = (i * math.pi * 2) / 256
            x1, y1 = cx + r1 * math.cos(rad), cy + r1 * math.sin(rad)
            x2, y2 = cx + r2 * math.cos(rad), cy + r2 * math.sin(rad)
            pygame.draw.line(view.win, (240,240,240,240), (x1,y1), (x2,y2), 3)
            for l in self.boxes[i]:
                (x1,y1,r1) = (x2,y2,r2)
                r2 -= (self.strength[l]*8+5)
                x2, y2 = cx + r2 * math.cos(rad), cy + r2 * math.sin(rad)
                pygame.draw.line(view.win, color(l), (x1,y1), (x2,y2), 3)
        alpha = 10
        cx -= 40
        cy += 120
        for i in range(len(self.textbox)-20,len(self.textbox)):
            if i >= 0:
                o,l,v = self.textbox[i]
                view.font.render_to(view.win, (cx, cy), o + " " + l + " " + str(v), color(l, alpha))
            cy -= 16
            alpha += 12
        if self.tidx == len(self.tokens):
            controller.animate = False
            return
        tok = self.tokens[self.tidx]
        if tok[-1] == "-":
            l = tok[:-1]
            hc = hash(l) 
            if l in self.boxes[hc]:
                self.boxes[hc].remove(l)
            self.textbox.append(("-",l, self.strength[l]))
        else:
            l = tok[:-2]
            hc = hash(l)
            st = int(tok[-1])
            # checking via strength map is slower. 
            if l not in self.boxes[hc]:
                self.boxes[hc].append(l)
            self.strength[l] = st
            self.textbox.append(("=",l, st))
        self.tidx += 1



view = View(1920, 1080, 30, 24)
view.setup("Day 15")
controller = Controller()
lines = open(controller.workdir() + "/day15.txt").read().split(",")
controller.add(Display(lines))
controller.run(view)
