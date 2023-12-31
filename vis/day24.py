from common import View, Controller
import pygame
from pygame import gfxdraw
import math
import numpy as np


def parse(lines):
    stones = []
    for line in lines:
        line = line.replace(" @ ", ", ")
        nums = list(map(int, line.split(", ")))
        stones.append(nums)
    return stones

def project2d(x, y, z, phi = 0):
    x1 = x * math.cos(phi) + y * math.sin(phi)
    y1 = -x * math.sin(phi) + y * math.cos(phi)
    xp = (x1 + y1) / math.sqrt(2)
    yp = (x1 - 2 * z - y1) / math.sqrt(6)
    return (int(xp), int(yp))


def collider(stones):
    px = [ stones[0][0], stones[1][0], stones[2][0] ]
    py = [ stones[0][1], stones[1][1], stones[2][1] ]
    pz = [ stones[0][2], stones[1][2], stones[2][2] ]
    vx = [ stones[0][3], stones[1][3], stones[2][3] ]
    vy = [ stones[0][4], stones[1][4], stones[2][4] ]
    vz = [ stones[0][5], stones[1][5], stones[2][5] ]
    A = np.array(
        [
            [vy[1] - vy[0], vx[0] - vx[1], 0, py[0] - py[1], px[1] - px[0], 0],
            [vy[2] - vy[0], vx[0] - vx[2], 0, py[0] - py[2], px[2] - px[0], 0],
            [vz[1] - vz[0], 0, vx[0] - vx[1], pz[0] - pz[1], 0, px[1] - px[0]],
            [vz[2] - vz[0], 0, vx[0] - vx[2], pz[0] - pz[2], 0, px[2] - px[0]],
            [0, vz[1] - vz[0], vy[0] - vy[1], 0, pz[0] - pz[1], py[1] - py[0]],
            [0, vz[2] - vz[0], vy[0] - vy[2], 0, pz[0] - pz[2], py[2] - py[0]],
        ]
    )

    x = [
        (py[0] * vx[0] - py[1] * vx[1]) - (px[0] * vy[0] - px[1] * vy[1]),
        (py[0] * vx[0] - py[2] * vx[2]) - (px[0] * vy[0] - px[2] * vy[2]),
        (pz[0] * vx[0] - pz[1] * vx[1]) - (px[0] * vz[0] - px[1] * vz[1]),
        (pz[0] * vx[0] - pz[2] * vx[2]) - (px[0] * vz[0] - px[2] * vz[2]),
        (pz[0] * vy[0] - pz[1] * vy[1]) - (py[0] * vz[0] - py[1] * vz[1]),
        (pz[0] * vy[0] - pz[2] * vy[2]) - (py[0] * vz[0] - py[2] * vz[2]),
    ]
    return np.linalg.solve(A, x)    

class Background:
    tidx = 0
    fidx = 0
    minx = None
    miny = None 

    def __init__(self, stones) -> None:
        self.stones = stones
        self.speed = 1000000000
        self.coll = collider(stones)        
    
    def shift(self, p):
        (x, y) = p
        return (x - self.minx + 500, y - self.miny + 200)

    def update(self, view, controller):
        if not controller.animate:
            return
        phi = math.pi * self.fidx / 750
        view.win.fill((0, 0, 0, 0))
        pixels = []
        for stone in self.stones:
            sx, sy, sz = [(stone[i] + (stone[i+3] * self.tidx))/434197082915 - 500 for i in range(3)]
            pixels.append(project2d(sx, sy, sz, phi))
        if not self.minx:
            self.minx = min([x for (x,_) in pixels])
            self.miny = min([y for (_,y) in pixels])
        for p in pixels:
            (x,y) = self.shift(p)
            gfxdraw.pixel(view.win, x, y, (255,255,255))
        cx, cy, cz = [(self.coll[i])/434197082915 - 500 for i in range(3)]
        start = self.shift(project2d(cx,cy,cz, phi))
        cx, cy, cz = [(self.coll[i] + (self.coll[i+3] * self.tidx))/434197082915 - 500 for i in range(3)]
        end = self.shift(project2d(cx,cy,cz, phi))
        pygame.draw.line(view.win, (0xff,0xcd,0x3c), start, end)
        (ex, ey) = end
        pygame.draw.circle(view.win, (0xff,0xcd,0x3c), (ex+1,ey+1), 2)
        self.tidx += self.speed        
        self.fidx += 1
        if self.fidx == 1800:
            controller.animate = False
        view.font.render_to(view.win, (20, 20), "T: " + str(self.tidx), (255, 255, 255))        

view = View(1920, 1200, 60, 24)
view.setup("Day 24")
controller = Controller()
lines = open("day24.txt").read().splitlines()
controller.add(Background(parse(lines)))
controller.run(view)
