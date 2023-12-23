import pygame
from common import View, Controller
import pygame
import sys

sys.setrecursionlimit(10000)
tiles = open("day23.txt").read().split("\n")
tiles.reverse()
dimx = len(tiles[0])
dimy = len(tiles)
(fx, fy) = (tiles[0].find("."), 0)
(sx, sy) = (tiles[dimy - 1].find("."), dimy - 1)

branches = set([(sx, sy), (fx, fy)])
dirs = ((-1, 0, "<"), (1, 0, ">"), (0, -1, "^"), (0, 1, "v"))
frames = [(1,(sx,sy))]

def dfs2(x, y, visited, prev, last, steps):
    visited.add((x, y))
    frames.append((1, (x, y)))
    cnt = 0
    for dx, dy, _ in dirs:
        (nx, ny) = (x + dx, y + dy)
        if tiles[ny][nx] != "#" and (nx, ny) != prev:
            cnt += 1
    if cnt > 1:        
        branches.add((x, y))
        frames.append((2, ((x, y), last)))
        last = (x, y)
        steps = 0
    for dx, dy, _ in dirs:
        (nx, ny) = (x + dx, y + dy)
        if (nx, ny) != prev and (nx, ny) in branches:
            frames.append((2, ((nx, ny), last)))
        elif tiles[ny][nx] != "#" and (nx, ny) not in visited:
            dfs2(nx, ny, visited, (x, y), last, steps + 1)

dfs2(sx, sy - 1, set([(sx,sy)]), (sx, sy), (sx, sy), 1)


class Tile:
    def __init__(self, x, y, h):
        self.id = (x,y)
        y = (dimy - 1) - y 
        self.pos = (8 + x * 7 + y * 7, 700 - x * 5 + y * 4)
        self.cost = h
        self.parent = self
        self.distance = 999999999
        self.done = None
        self.selected = False
        self.prev = None
        self.update_block()

    def render(self, surface, pos):
        (x, y0) = pos
        y1 = y0 + self.height

        col2 = (255, 255, 255)
        pygame.draw.polygon(surface, self.color, [(x, y0), (x + 6, y0 - 3), (x + 12, y0),
                                                  (x + 6, y0 + 3)])
        pygame.draw.polygon(surface, col2, [(x, y0), (x + 6, y0 - 3), (x + 12, y0),
                                            (x + 6, y0 + 3)], 1)
        col3 = (80, 80, 80)
        col4 = (40, 40, 40)
        pygame.draw.polygon(surface, col4, [(x, y0), (x + 6, y0 + 3), (x + 12, y0), (x + 12, y1),
                                            (x + 6, y1 + 3), (x, y1)])
        pygame.draw.line(surface, col3, (x, y0), (x, y1))
        pygame.draw.line(surface, col3, (x + 6, y0 + 4), (x + 6, y1 + 3))
        pygame.draw.line(surface, col3, (x + 12, y0), (x + 12, y1))

    def update_block(self):
        if self.done:
            # self.height = self.distance // 5
            self.color = (250, 120, 120) if self.id in branches else (120, 250, 120)
            if self.id in branches:
                self.height = self.cost + 4
        elif self.distance < 999999999:
            self.color = (220, 120, 80)
        else:
            self.color = (160, 160, 160)
            self.height = self.cost
        self.tmp = pygame.Surface((12, self.height + 6), pygame.SRCALPHA)
        self.tmp.fill((0, 0, 0, 0))
        self.render(self.tmp, (0, 3))

    def render_block(self, surface, ofs):
        (x, y) = self.pos
        if self.done:
            y -= ofs
        surface.blit(self.tmp, (x, y - self.height))


class Board:
    def __init__(self, tiles, frames):
        self.tiles = tiles
        self.frames = frames
        self.fidx = 0
        self.speed = 1
        self.lines = []

    def update(self, view, controller):
        if not controller.animate:
            return
        for i in range(self.speed):
            (t, d) = self.frames[self.fidx]
            if t == 1:
                (x, y) = d
                st = self.tiles[y][x]
                st.done = True
                st.update_block()
            else:                
                self.lines.append(d)
            self.fidx += 1
            if self.fidx >= len(self.frames):
                controller.animate = False
                break
        if view.frame % 300 == 299 and self.speed < 5:
            self.speed += 1
            print("speed up")
        view.win.fill((0, 0, 0, 0))
        for y in range(dimy-1,-1,-1):
            for x in range(dimx-1,-1,-1):
                self.tiles[y][x].render_block(view.win, 6)
        for ((x1,y1),(x2,y2)) in self.lines:
            tx1,ty1 = self.tiles[y1][x1].pos
            tx2,ty2 = self.tiles[y2][x2].pos
            pygame.draw.line(view.win, (220,255,255), (tx1+6,ty1-6),(tx2+6,ty2-6), 5)
            pygame.draw.line(view.win, (10,10,10), (tx1+6,ty1-6),(tx2+6,ty2-6), 3)


controller = Controller()
board = []
for y in range(dimy):
    w = dimy - 1
    line = []
    for x in range(dimx):
        if tiles[y][x] == '#':
            h = 8
        else:
            h = 0
        line.append(Tile(x, y, h))
    board.append(line)
controller.add(Board(board, frames))
view = View(1920, 1200, 30)
view.setup("Day 23")
controller.run(view)
