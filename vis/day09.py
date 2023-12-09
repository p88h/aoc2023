from common import View, Controller
from random import randint
import pygame


class Game:
    def __init__(self, lines) -> None:
        self.seqs = []
        for l in lines:
            self.seqs.append(list(map(int, l.split(" "))))
        self.fidx = 0
        self.pidx = 0
        self.cidx = 0
        self.colors = []
        for i in range(24):
            r = 10 + i * 10
            b = 250 - i * 10
            g = 230
            self.colors.append((r,g,b))
    
    def update_text(self, view):
        txt = "F" + "'"*self.cidx + " = "
        for v in self.seqs[self.fidx]:
            txt += str(v) + " "
        view.font.render_to(view.win, (20,20+self.cidx*20), txt, self.colors[self.cidx])
        if self.cidx == 0:
            txt2 = str(self.fidx + 1) + " / " + str(len(self.seqs))
            view.font.render_to(view.win, (1800,20), txt2, self.colors[self.cidx])


    def update(self, view, controller):
        if not controller.animate:
            return
        if self.fidx == 0 and self.pidx == 0 and self.cidx == 0:
            view.win.fill((0, 0, 0))
            self.update_text(view)
        # take the current sequence
        t = self.seqs[self.fidx]
        # plot up to the current point
        oy = min(t)
        sy = ((max(t)-min(t)) // 1000) + 1
        sx = 1800 // len(t)
        px = pv = -1
        for i in range(1, self.pidx):
            x = 60 + i * sx
            v = 1040 - (t[i] - oy) // sy
            if px > 0:
                pygame.draw.line(view.win, self.colors[self.cidx], (px, pv), (x, v), 2)
            (px, pv) = (x, v)
        self.pidx += 1
        if self.pidx == len(t):                        
            self.pidx = 0
            orr = 0
            for i in range(len(t)-1):
                t[i] = t[i+1] - t[i]
                orr |= t[i]
            t.pop()
            if not(t) or orr == 0:
                self.fidx += 1
                if self.fidx < len(self.seqs):
                    view.win.fill((0, 0, 0))
                    self.cidx = 0
                else:
                    controller.animate = False
            else:                
                self.cidx += 1
            if controller.animate:
                self.update_text(view)
            
        
view = View(1920, 1080, 60, 24)
view.setup("Day 09")
controller = Controller()
lines = open(controller.workdir() + "/day09.txt").read().split("\n")
controller.add(Game(lines))
controller.run(view)
