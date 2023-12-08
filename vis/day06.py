from common import View, Controller
from random import randint
import math
import pygame


class Game:
    def __init__(self, lines) -> None:
        self.times = list(map(int, lines[0].split()[1:]))
        self.dist = list(map(int, lines[1].split()[1:]))
        self.tidx = 0
        self.vidx = 0
        self.colors = [
            (250, 200, 200),
            (200, 250, 200),
            (200, 200, 250),
            (250, 250, 200),
            (250, 200, 250),
            (200, 250, 250),
            (250, 250, 250),
        ]

    def update(self, view, controller):
        if not controller.animate:
            return
        # view.win.fill((0, 0, 0))
        t = self.times[self.tidx]
        p = 0
        for x in range(1, self.vidx + 1):
            v = (x * (t - x)) / 2
            pygame.draw.line(view.win, self.colors[self.tidx], ((x - 1) * 10 + 50, 1040 - p), (x * 10 + 50, 1040 - v))
            p = v
        if self.vidx < t:
            self.vidx += 1
        else:
            self.vidx = 0
            self.tidx += 1
        if self.tidx == len(self.times):
            controller.animate = False


view = View(1920, 1080, 30, 24)
view.setup("Day 06")
controller = Controller()
lines = open(controller.workdir() + "/day06.txt").read().split("\n")
controller.add(Game(lines))
controller.run(view)
