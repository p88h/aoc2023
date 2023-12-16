from common import View, Controller
import pygame


class Mirror:
    def __init__(self, x, y, s, f) -> None:
        self.x = x
        self.y = y
        self.size = s
        self.forward = f

    def draw(self, surface: pygame.Surface, ofsx, ofsy):
        hsize = self.size // 2
        cx = ofsx + self.x * self.size + hsize
        cy = ofsy + self.y * self.size + hsize
        if self.forward:
            p1, p2 = (cx - hsize, cy + hsize), (cx + hsize, cy - hsize)
        else:
            p1, p2 = (cx - hsize, cy - hsize), (cx + hsize, cy + hsize)
        pygame.draw.line(surface, (120, 120, 120, 255), p1, p2, hsize//2+2)

    def update(self, beam):
        (dx, dy) = beam
        if self.forward:
            return [(-dy, -dx)]
        else:
            return [(dy, dx)]

    def switch(self):
        self.forward = not self.forward


class Splitter:
    def __init__(self, x, y, s, v) -> None:
        self.x = x
        self.y = y
        self.size = s
        self.vertical = v

    def draw(self, surface: pygame.Surface, ofsx, ofsy):
        hsize = self.size // 2
        cx = ofsx + self.x * self.size + hsize
        cy = ofsy + self.y * self.size + hsize
        if self.vertical:
            p1, p2 = (cx, cy - hsize), (cx, cy + hsize)
        else:
            p1, p2 = (cx - hsize, cy), (cx + hsize, cy)
        pygame.draw.line(surface, (120, 120, 120, 255), p1, p2, hsize//2+1)

    def update(self, beam):
        (dx, dy) = beam
        if self.vertical and dy == 0:
            return [(0, 1), (0, -1)]
        elif not self.vertical and dx == 0:
            return [(1, 0), (-1, 0)]
        else:
            return [(dx, dy)]

    def switch(self):
        self.vertical = not self.vertical


class Display:
    def __init__(self, tiles, dimx, dimy, scale) -> None:
        self.tiles = tiles
        self.dimx = dimx
        self.dimy = dimy
        self.scale = scale
        self.grid = {(t.x, t.y): t for t in tiles}
        self.sx = (view.width - self.dimx * self.scale) // 2
        self.sy = (view.height - self.dimy * self.scale) // 2
        self.fx = self.sx + self.dimx * self.scale
        self.fy = self.sy + self.dimy * self.scale
        self.start = (-1, 0, 1, 0)
        self.compute()

    def click(self, pos, state):
        if state:
            return
        (x, y) = pos
        if x >= self.sx and x < self.fx and y >= self.sy and y < self.fy:
            (xi, yi) = ((x - self.sx) // self.scale, (y - self.sy) // self.scale)
            if (xi, yi) in self.grid:
                self.grid[(xi, yi)].switch()
                self.compute()

    def compute(self):
        self.history = []
        self.hidx = 0
        current = [self.start]
        visited = set()
        warm = set()
        while current:
            self.history.append(current)
            next = []
            for x, y, dx, dy in current:
                # move out of the previous tile
                x += dx
                y += dy
                # out of bounds
                if x < 0 or y < 0 or x >= self.dimx or y >= self.dimy:
                    continue
                # if we already _entered_ this tile this way, skip
                if (x, y, dx, dy) in visited:
                    continue
                visited.add((x, y, dx, dy))
                warm.add((x, y))
                dirs = [(dx, dy)]
                if (x, y) in self.grid:
                    dirs = self.grid[(x, y)].update((dx, dy))
                for dx, dy in dirs:
                    next.append((x, y, dx, dy))
            current = next

    def center(self, x, y):
        return (self.sx + x * self.scale + self.scale // 2, self.sy + y * self.scale + self.scale // 2)

    def update(self, view: View, controller: Controller):
        if not controller.animate:
            return
        tcol = (120, 120, 120, 255)
        if (self.hidx == 0):
            view.win.fill((0, 0, 0, 0))
            pygame.draw.rect(view.win, tcol, (self.sx - 4, self.sy - 4, self.dimx * self.scale + 4, self.dimy * self.scale + 4), 4)            
            for pos in self.grid:
                self.grid[pos].draw(view.win, self.sx, self.sy)
        lcol = (255, 255, 255, 255)
        for _ in range(10):
            if self.hidx < len(self.history):
                for x, y, dx, dy in self.history[self.hidx]:
                    cx1, cy1 = self.center(x, y)
                    cx2, cy2 = self.center(x + dx, y + dy)
                    pygame.draw.line(view.win, lcol, (cx1, cy1), (cx2, cy2), 2)
                self.hidx += 1


controller = Controller()
lines = open(controller.workdir() + "/day16.txt").read().splitlines()
dimy = len(lines)
dimx = len(lines[0])
size = 10
while size * dimy * 2 < 1000:
    size *= 2
view = View(1920, 1200, 60, 24)
view.setup("Day 16")


objs = []
for y in range(dimy):
    for x in range(dimx):
        t = lines[y][x]
        if t in ["|", "-"]:
            objs.append(Splitter(x, y, size, t == "|"))
        if t in ["/", "\\"]:
            objs.append(Mirror(x, y, size, t == "/"))

controller.add(Display(objs, dimx, dimy, size), True)
controller.run(view)
