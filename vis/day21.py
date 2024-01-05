from common import View, Controller
from random import randint
import pygame


class Display:
    def __init__(self, lines) -> None:
        self.lines = lines
        for y in range(len(lines)):
            x = lines[y].find('S')
            if x > 0:
                self.start = (x,y)
                break      
        self.current = [self.start]  
        self.rocks = {}
        self.visited = {self.start: 0}
        self.fidx = 0
        self.speed = 1
        self.scale = 8

    def step(self, expand = False):
        if not self.current:
            return
        dimx = len(self.lines[0])
        dimy = len(self.lines)
        dirs = [(-1, 0), (1, 0), (0, -1), (0, 1)]
        next = []
        for pos in self.current:
            distance = self.visited[pos]
            (x, y) = pos
            for ndir in range(4):
                (dx, dy) = dirs[ndir]
                if expand:
                    (nx, ny) = ((x + dx) % dimx, (y + dy) % dimy)
                else:
                    if x + dx < 0 or x + dx >= dimx or y + dy < 0 or y + dy >= dimy:
                        continue
                    (nx, ny) = (x + dx, y + dy)
                if (x + dx, y + dy) in self.visited:
                    continue
                if self.lines[ny][nx] == "#":
                    self.rocks[(x + dx, y + dy)] = distance + 1
                    continue
                self.visited[(x + dx, y + dy)] = distance + 1
                next.append((x + dx, y + dy))
        self.current = next
        
    def update(self, view, controller):
        if not controller.animate:
            return
        view.win.fill((0, 0, 0, 0))
        by = (1200 - len(self.lines) * self.scale)//2
        bx = (1920 - len(self.lines) * self.scale)//2
        sz = self.scale
        for y in range(len(self.lines)):
            for x in range(len(self.lines[y])):
                (ox,oy) = (bx + x * self.scale, by + y * self.scale)
                if self.lines[y][x] == '#':
                    pygame.draw.rect(view.win, (100,60,60), (ox + 1, oy + 1, sz - 2, sz - 2))
        for (x,y) in self.visited:
            d = self.visited[(x,y)]
            if d % 2:
                col = (80,100,80)
            else:
                col = (80,80,100)
            (ox,oy) = (bx + x * self.scale, by + y * self.scale)
            pygame.draw.rect(view.win, col, (ox, oy, sz, sz))            
        for (x,y) in self.rocks:
            (ox,oy) = (bx + x * self.scale, by + y * self.scale)
            pygame.draw.rect(view.win, (200,100,100), (ox+1, oy+1, sz-2, sz-2))
        if self.fidx < 196:
            self.step(True)
            self.fidx += 1
        else:
            controller.animate = False
        if (self.fidx * 2 * self.scale) > 1200 :
            self.scale -= 1
        view.font.render_to(view.win, (by,by), "Current step: " + str(self.fidx), (255,255,255,255))


view = View(1920, 1200, 10, 16)
view.setup("Day 21")
controller = Controller()
lines = open(controller.workdir() + "/day21.txt").read().split("\n")
controller.add(Display(lines))
controller.run(view)
