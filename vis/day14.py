import pygame
import random
from common import View, Controller


class Tile:
    def __init__(self, x, y, h):
        self.pos = (40 + x * 9 + y * 9, 540 - x * 5 + y * 5)
        self.height = h * 2
        self.covered = False
        self.color = (100, random.randint(100, 240), random.randint(100, 240), 160)
        self.done = False

    def render_block(self, surface):
        (x, y) = self.pos
        y0 = y - self.height

        if self.height == 2:
            y0 = y
        col1 = (160, 160, 160)
        col2 = (255, 255, 255)
        pygame.draw.polygon(surface, col1, [(x, y0), (x + 8, y0 - 4), (x + 16, y0), (x + 8, y0 + 4)])
        pygame.draw.polygon(surface, col2, [(x, y0), (x + 8, y0 - 4), (x + 16, y0), (x + 8, y0 + 4)], 1)
        col3 = (80, 80, 80)
        col4 = (40, 40, 40)
        pygame.draw.polygon(surface, col4, [(x, y0), (x + 8, y0 + 4), (x + 16, y0), (x + 16, y), (x + 8, y + 4), (x, y)])
        pygame.draw.line(surface, col3, (x, y0), (x, y))
        pygame.draw.line(surface, col3, (x + 8, y0 + 4), (x + 8, y + 4))
        pygame.draw.line(surface, col3, (x + 16, y0), (x + 16, y))
        if self.height == 2:
            col5 = (200, 200, 200)
            pygame.draw.circle(surface, (160, 160, 160), (x + 8, y0 - 4), 8)
            pygame.draw.circle(surface, (200, 200, 200), (x + 8 - 1, y0 - 4 - 1), 5)
            pygame.draw.circle(surface, (240, 240, 240), (x + 8 - 2, y0 - 4 - 2), 2)
            pygame.draw.circle(surface, col4, (x + 8, y0 - 4), 8, 1)

    def render_water(self, surface, level):
        (x, y) = self.pos
        if int(level) > self.height:
            (r, g, b, a) = self.find().color
            yw = y - int(level) + random.randint(-1, 1)
            pygame.draw.polygon(surface, (r, g, b, a), [(x, yw), (x + 8, yw - 4), (x + 16, yw), (x + 8, yw + 4)])
            pygame.draw.polygon(surface, (r, g, b, a + 40), [(x - 1, yw), (x + 8, yw - 5), (x + 17, yw), (x + 8, yw + 5)], 1)
            self.covered = True

def fnv1a(ppos):
        hash = 2166136261
        for (x,y) in ppos:
            hash = ((hash ^ x) * 16777619) & 0xFFFFFFFF
            hash = ((hash ^ y) * 16777619) & 0xFFFFFFFF
        return hash

class Background:
    def __init__(self, board, pic, pebbles):
        # self.surf = pygame.Surface((1920, 1080))
        # self.surf.fill((0, 0, 0, 0))
        self.board = board
        self.pic = pic
        self.pebbles = pebbles
        self.bepples = []
        self.dx = 0
        self.dy = -1
        self.hc = 0
        self.load = sum([len(pic) - y for (y, _) in pebbles])
        self.seen = {}
        self.ccnt = 0
        self.speed = 1

    def update(self, view, _):
        if not controller.animate:
            return
        view.win.fill((0, 0, 0, 0))
        for y in range(len(self.board)):
            for x in range(len(self.board[y]) - 1, -1, -1):
                self.board[y][x].render_block(view.win)
        dim = len(self.pic)
        if self.pebbles:
            moved = 0
            for _ in range(self.speed):                
                updated = []
                for x, y in self.pebbles:
                    (nx, ny) = (x + self.dx, y + self.dy)
                    if nx >= 0 and nx < dim and ny >= 0 and ny < dim and self.pic[ny][nx] == ".":
                        self.pic[y][x] = "."
                        self.board[y][x].height = 0
                        self.pic[ny][nx] = "O"
                        self.board[ny][nx].height = 2
                        updated.append((nx,ny))
                        moved += 1
                    else:
                        updated.append((x,y))
                if moved > 0:
                    self.pebbles = updated
                else:                    
                    self.pebbles = []
                    self.bepples = updated
                    break
        else:                        
            (self.dx, self.dy) = (self.dy, -self.dx)
            self.pebbles = self.bepples
            self.pebbles.sort()
            self.bepples = []
            if (self.dy == -1):
                if self.hc:
                    self.seen[self.hc] = self.ccnt
                self.ccnt += 1
                self.hc = fnv1a(self.pebbles)
                self.load = sum([dim - y for (y, _) in self.pebbles])
                if self.speed < 10:
                    self.speed += 1
        view.font.render_to(view.win, (20, 40), "Cycle " + str(self.ccnt) + " hash: " + str(self.hc), (255, 255, 255, 255))
        if self.hc in self.seen:
            view.font.render_to(view.win, (20, 60), "Previously seen at cycle: " + str(self.seen[self.hc]), (255, 255, 255, 255))
            controller.animate = False
        # view.win.blit(self.surf, (0, 0))


def init(controller):
    board = []
    pic = []
    pebbles = []
    th = {".": 0, "#": 6, "O": 1}
    with open(controller.workdir() + "/day14.txt") as f:
        y = 0
        for l in f.read().splitlines():
            pic.append(list(l))
            line = [Tile(x, y, th[l[x]]) for x in range(len(l))]
            for x, c in enumerate(l):
                if c == "O":
                    pebbles.append((x, y))
            board.append(line)
            y += 1
    controller.add(Background(board, pic, pebbles))
    # controller.add(Water(board))
    return controller


view = View(1920, 1080, 30, 24)
view.setup("Day 14")
controller = Controller()
init(controller).run(view)
