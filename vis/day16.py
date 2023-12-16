from common import View, Controller
import pygame

class Display:
    def __init__(self, tiles) -> None:
        self.tiles = tiles
        self.hidx = 0
        self.dimx = len(tiles[0])
        self.dimy = len(tiles)
        # first BFS
        self.history = self.bfs((-1,0,1,0))
        self.order = []
        for y in range(0,self.dimy): 
            self.order.append((-1,y,1,0))
        for x in range(0,self.dimx): 
            self.order.append((x,self.dimy,0,-1))
        for y in range(self.dimy,-1,-1): 
            self.order.append((self.dimx,y,-1,0))
        for x in range(self.dimx,-1,-1):
            self.order.append((x,-1,0,1))
        self.oidx = 0

    def bfs(self, start):
        history = []
        current = [ start ]
        visited = set()
        warm = set()
        while current:
            history.append(current)
            next = [] 
            for (x,y,dx,dy) in current:
                # move out of the previous tile
                x += dx
                y += dy
                # out of bounds
                if x < 0 or y < 0 or x >= self.dimx or y >= self.dimy:
                    continue
                # if we already _entered_ this tile this way, skip
                if (x,y,dx,dy) in visited:
                    continue
                visited.add((x,y,dx,dy))
                warm.add((x,y))
                t = self.tiles[y][x] 
                # empty or ignored splitter
                if t == '.' or (t == '|' and dx == 0) or (t =='-' and dy == 0):
                    next.append((x,y,dx,dy))
                # split vertically
                elif t == '|' and dx != 0:
                    next.append((x,y,0,1))
                    next.append((x,y,0,-1))
                elif t == '-' and dy != 0:
                    next.append((x,y,1,0))
                    next.append((x,y,-1,0))
                # mirror 1
                elif t == '/':
                    next.append((x,y,-dy,-dx))
                # mirror 2
                elif t == '\\':
                    next.append((x,y,dy,dx))
            current = next
        return history
    
    def center(self,x,y):
        return (self.sx + x * self.size + self.size // 2,
                self.sy + y * self.size + self.size // 2)

    def update(self, view: View, controller: Controller):
        if not controller.animate:
            return
        self.size = 10
        self.sx = (view.width - self.dimx * self.size) // 2
        self.sy = (view.height - self.dimy * self.size) // 2
        hsize = self.size // 2
        tcol = (120,120,120,255)
        if self.hidx == 0:
            view.win.fill((0,0,0,0))
            pygame.draw.rect(view.win,tcol,(self.sx-4,self.sy-4,self.dimx*self.size+4,self.dimy*self.size+4),4)
            for y in range(self.dimy):
                for x in range(self.dimx):
                    cx,cy = self.center(x,y)
                    t = self.tiles[y][x]                    
                    if t == '|':
                        pygame.draw.line(view.win, tcol, (cx,cy-hsize), (cx,cy+hsize), 3)
                    if t == '-':
                        pygame.draw.line(view.win, tcol, (cx-hsize,cy), (cx+hsize,cy), 3)
                    elif t == '/':
                        pygame.draw.line(view.win, tcol, (cx-hsize,cy+hsize), (cx+hsize,cy-hsize), 4)
                    elif t == '\\':
                        pygame.draw.line(view.win, tcol, (cx-hsize,cy-hsize), (cx+hsize,cy+hsize), 4)
        lcol = (255,255,255,255)
        for _ in range(min(10,self.oidx + 1)):
            for (x,y,dx,dy) in self.history[self.hidx]:
                cx1, cy1 = self.center(x,y)
                cx2, cy2 = self.center(x+dx,y+dy)
                pygame.draw.line(view.win, lcol, (cx1, cy1), (cx2, cy2), 2)
            self.hidx += 1
            if self.hidx == len(self.history):
                if (self.oidx + 1 >= len(self.order)):
                    controller.animate = False
                else: 
                    self.oidx += 1
                    self.history = self.bfs(self.order[self.oidx])
                    self.hidx = 0
                return



view = View(1920, 1200, 60, 24)
view.setup("Day 16")
controller = Controller()
lines = open(controller.workdir() + "/day16.txt").read().splitlines()
controller.add(Display(lines))
controller.run(view)
