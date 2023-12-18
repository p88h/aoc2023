import pygame
import heapq
import itertools
from collections import defaultdict
from common import View, Controller


class Tile:
    def __init__(self, x, y, h):
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
            self.height = self.distance // 5
            self.color = (120, 120, 250) if self.selected else (120, 250, 120)
        elif self.distance < 999999999:
            self.color = (220, 120, 80)
        else:
            self.color = (160, 160, 160)
            self.height = self.cost * 2
        self.tmp = pygame.Surface((12, self.height + 6), pygame.SRCALPHA)
        self.tmp.fill((0, 0, 0, 0))
        self.render(self.tmp, (0, 3))

    def render_block(self, surface, ofs):
        (x, y) = self.pos
        if self.done:
            y += ofs
        surface.blit(self.tmp, (x, y - self.height))


class Board:
    def __init__(self, tiles):
        self.tiles = tiles
        self.tiles[0][0].distance = 0
        self.maxd = (0,0)
        self.maxs = 0
        self.maxh = 0
        self.path = []
        self.dijkstra = defaultdict(list)
        self.dijkstra[0] = [(0,0,1,0,0),(0,0,0,1,0)]
        self.best = {}
        self.prevs = {}
        for s in self.dijkstra[0]:
            self.best[s] = 0
            self.prevs[s] = None
        self.found = False
        self.distance = 0
        self.minrun = 3
        self.maxrun = 9
        self.dimx = len(tiles)
        self.dimy = len(tiles[0])

    def bfsstep(self):
        #print(distance,':',dijkstra[distance])
        for current in self.dijkstra[self.distance]:
            (x,y,dx,dy,r) = current
            st = self.tiles[y][x]
            if not st.done:
                st.done = current
                st.distance = self.distance
                st.update_block()
                if st.height > self.maxh:
                    self.maxh = st.height
                if x + y > self.maxs:
                    self.maxs = x + y
                    self.maxd = (x,y)
            if x == self.dimx -1 and y == self.dimy -1:
                self.found = True
                break
            if self.best[current] < self.distance:
                continue
            #if x + y < self.maxs - 30:
            #    continue 
            for (nx,ny) in [ (-1,0), (1,0), (0,1), (0,-1) ]:
                nr = 0
                if (nx,ny) == (-dx,-dy):
                    continue
                if (nx,ny) == (dx,dy):
                    nr = r + 1
                    if nr > self.maxrun:
                        continue
                elif r < self.minrun:
                    continue
                if x + nx < 0 or x + nx >= self.dimx or y + ny < 0 or y + ny >= self.dimy:
                    continue
                cost = self.tiles[y + ny][x + nx].cost
                next = (x + nx, y + ny, nx, ny, nr)
                if next in self.best and self.best[next] <= self.distance + cost:
                    continue
                self.prevs[next] = current
                self.best[next] = self.distance + cost
                self.dijkstra[self.distance + cost].append(next)
        if not self.found:
            self.distance += 1

    def update(self, view, controller):
        if self.found:
            controller.animate = False
        else:
            self.bfsstep()
        if not controller.animate:
            return        
        for t in self.path:
            t.selected = False
        npath = []
        (x,y) = self.maxd
        #for i in range(self.dimx-1,-1,-1):
        st = self.tiles[y][x]
        state = st.done
        while state:
            (x,y,dx,dy,r) = state
            st = self.tiles[y][x]
            npath.append(st)
            st.selected = True
            st.update_block()
            state = self.prevs[state]
        for t in self.path:
            if not t.selected:
                t.update_block()
        self.path = npath

        view.win.fill((0, 0, 0, 0))
        for y in range(self.dimy-1,-1,-1):
            for x in range(self.dimx-1,-1,-1):
                self.tiles[y][x].render_block(view.win, self.maxh)


def init(controller):
    board = []
    with open(controller.workdir() + "/day17.txt") as f:
        y = 0
        for l in f.read().splitlines():
            w = len(l) - 1
            line = [Tile(x, w - y, int(l[x])) for x in range(len(l))]
            board.append(line)
            y += 1
    controller.add(Board(board))
    return controller


view = View(1920, 1200, 30)
view.setup("Day 15")
init(Controller()).run(view)
