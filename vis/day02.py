from common import View, Controller
from random import randint
import math
import pygame


class Game:
    def __init__(self, lines) -> None:
        self.lines = lines
        self.fidx = 0
        self.colors = {"red": (250, 200, 200), "green": (200, 250, 200), "blue": (200, 200, 250)}
        self.maxs = []

    def update(self, view, controller):
        if not controller.animate:
            return
        view.win.fill((0, 0, 0))
        ox = 60
        for p in range(self.fidx):
            oy = 0
            for col in ["red", "green", "blue"]:
                cnt = self.maxs[p][col]
                for j in range(cnt):
                    pygame.draw.circle(view.win,self.colors[col],(ox,1060-oy), 8)
                    oy += 18
                oy += (19-j)*18
                oy += 9
            ox += 18
        ox += 9
        if self.fidx >= len(self.lines):
            return
        line = self.lines[self.fidx]
        (_, rest) = line.split(": ")
        draws = rest.split("; ")
        mdict = {"red": 0, "green": 0, "blue": 0}
        for draw in draws:
            draw = draw.replace(",", "")
            toks = draw.split(" ")
            for i in range(len(toks) // 2):
                cnt = int(toks[i * 2])
                col = toks[i * 2 + 1]
                mdict[col] = max(mdict[col],cnt)
                for j in range(cnt):
                    pygame.draw.circle(view.win,self.colors[col],(ox,1060-j*18), 8)
                ox += 18
            ox += 9
        self.maxs.append(mdict)
        self.fidx += 1
            




view = View(1920, 1080, 30, 24)
view.setup("Day 02")
controller = Controller()
lines = open(controller.workdir() + "/day02.txt").read().split("\n")
controller.add(Game(lines))
controller.run(view)
