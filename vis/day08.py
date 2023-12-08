from common import View, Controller
from random import randint
import math
import pygame


class Game:
    def __init__(self, lines) -> None:
        self.I = lines[0]
        self.S = []
        self.F = set()
        self.L = {}
        self.R = {}
        for l in lines[2:]:
            n = l[0:3]
            if n[-1] == "A":
                self.S.append(n)
            if n[-1] == "Z":
                self.F.add(n)
            self.L[n] = l[7:10]
            self.R[n] = l[12:15]
        self.B = {}
        self.Z = []
        for s in self.S:
            vis = set([s])
            self.B[s] = [[s]]
            d = 0
            while self.B[s][d]:
                nex = []
                for t in self.B[s][d]:
                    l = self.L[t]
                    r = self.R[t]
                    if l not in vis:
                        vis.add(l)
                        nex.append(l)
                    if r not in vis:
                        vis.add(r)
                        nex.append(r)
                self.B[s].append(nex)
                d += 1
            self.Z.append((len(self.B[s]),s))
        self.Z.sort(reverse=True)
        print("subgraphs:", self.Z)
        self.speed = 1
        self.sidx = 0
        self.fidx = 0
        self.act = self.S
        self.prepare()

    def prepare(self):
        self.tmp = pygame.Surface((1920,1080), pygame.SRCALPHA)
        self.tmp.fill((0, 0, 0, 0))
        self.loc = {}
        self.dist = [ 0 ] * len(self.Z)
        siz = 24
        pad = siz + 8
        # Just ... precomputed
        w = [ 10, 7, 6, 5, 4, 3 ]
        x = 60 
        y = 80  
        for c in range(len(self.Z)):
            dx = 0
            dy = pad
            ox = -pad
            oy = 0
            (k, s) = self.Z[c]
            turns = [k//2-w[c],k//2,k-w[c]-1,k-1]
            for d in range (1,len(self.B[s])):
                foo = self.B[s][d]
                p1 = [x,y,siz,siz]
                p2 = [x+ox,y+oy,siz,siz]                
                pygame.draw.rect(self.tmp, (250,250,250,250), p1, 1)
                if (len(foo)>0):
                    pygame.draw.rect(self.tmp, (250,250,250,250), p2, 1)
                    self.loc[foo[0]]=p1
                    self.loc[foo[1]]=p2
                else:
                    self.loc[self.B[s][0][0]]=p1
                
                if d in turns:
                    (dx, dy) = (dy, -dx)
                    ox = oy = 0
                    if dx > 0:
                        oy = pad
                    elif dx  < 0:
                        oy = -pad
                    elif dy < 0:
                        ox = pad
                y += dy
                x += dx
                if d + 1 in turns:
                    if dy > 0:
                        oy = pad
                    elif dy  < 0:
                        oy = -pad
                    elif dx < 0:
                        ox = -pad
                    elif dx > 0:
                        ox = pad
            x += (w[c] + 4) * pad 
                
    def update(self, view, controller):
        if not controller.animate:
            return
        view.win.fill((0, 0, 0))
        view.win.blit(self.tmp, (0, 0))
        al = 240 // self.speed
        txt = "NEXT DIRECTIONS: "
        for o in range(self.sidx,self.sidx+10):
            txt += self.I[(self.sidx + o) % len(self.I)]
        view.font.render_to(view.win, (1460,860), txt, (200, 200, 200)) 
        for r in range(self.speed):
            c = self.I[self.sidx % len(self.I)]
            for i in range(len(self.act)):
                n = self.act[i]
                p = self.loc[n]
                if r == 0:
                    txt = "Camel " + str(i) + " at: " + str(n) + " (" + str(self.dist[i]) + " steps)"
                    view.font.render_to(view.win, (1460,884 + i * 24), txt, (200, 200, 200))
                if n in self.F:
                    pygame.draw.rect(view.win, (al*r,al*(r+1),al*r,240), p)
                    continue
                self.dist[i] += 1
                pygame.draw.rect(view.win, (al*r,al*(r+1),al*r,240), p)
                if c == "L":
                    n = self.L[n]
                else:
                    n = self.R[n]
                self.act[i] = n
            self.sidx += 1
        self.fidx += 1
        if self.fidx % 120 == 0 and self.speed < 5:
            self.speed += 1
            print(self.speed)

view = View(1920, 1080, 30, 24)
view.setup("Day 08")
controller = Controller()
lines = open(controller.workdir() + "/day08.txt").read().split("\n")
controller.add(Game(lines))
controller.run(view)
