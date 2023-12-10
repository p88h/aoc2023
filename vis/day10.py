from common import View, Controller
from random import randint
import pygame
from pygame import gfxdraw


# simplified one-way search
def part1(lines):
    for y in range(len(lines)):
        if "S" in lines[y]:
            x = lines[y].find("S")
            break
    start = (y, x)
    if lines[y][x + 1] in ("J", "-", "7"):
        current = (y, x + 1)
    if lines[y][x - 1] in ("L", "-", "F"):
        current = (y, x - 1)
    if lines[y - 1][x] in ("|", "F", "7"):
        current = (y - 1, x)
    if lines[y + 1][x] in ("|", "L", "J"):
        current = (y + 1, x)
    next = {start: current}
    mapping = {
        "-": [(0, 1), (0, -1)],
        "|": [(1, 0), (-1, 0)],
        "L": [(0, 1), (-1, 0)],
        "F": [(0, 1), (1, 0)],
        "7": [(0, -1), (1, 0)],
        "J": [(0, -1), (-1, 0)],
    }
    prev = start
    print(prev, "S", current)
    while current != start:
        (y, x) = current
        char = lines[y][x]
        for dy, dx in mapping[char]:
            if (y + dy, x + dx) != prev:
                prev = current
                current = (y + dy, x + dx)
                print(prev, char, current)
                next[prev] = current
                break
    return (start, next)


# same as normal but returns the list of inside tiles
def part2(lines, next):
    marked = []
    skip = " "
    for y in range(len(lines)):
        out = True
        for x in range(len(lines[y])):
            if (y, x) in next:
                if lines[y][x] == "F":
                    skip = "7"
                elif lines[y][x] == "L":
                    skip = "J"
                elif lines[y][x] == "-":
                    continue
                else:
                    if lines[y][x] != skip:
                        out = not out
                    skip = " "
            elif not out:
                marked.append((y, x))
    return marked


class Display:
    def __init__(self, lines) -> None:
        self.lines = lines
        (self.start, self.next) = part1(lines)
        self.marked = part2(lines, self.next)
        print(self.marked)
        self.pixmaps = {
            "S": [0b01100110, 0b11100111, 0b11100111, 0, 0, 0b11100111, 0b11100111, 0b01100110],
            "F": [0, 0b01111111, 0b01111111, 0b01100000, 0b01100000, 0b01100111, 0b01100111, 0b01100110],
            "7": [0, 0b11111110, 0b11111110, 0b00000110, 0b00000110, 0b11100110, 0b11100110, 0b01100110],
            "L": [0b01100110, 0b01100111, 0b01100111, 0b01100000, 0b01100000, 0b01111111, 0b01111111, 0],
            "J": [0b01100110, 0b11100110, 0b11100110, 0b00000110, 0b00000110, 0b11111110, 0b11111110, 0],
            "|": [0b01100110] * 8,
            "-": [0, 0b11111111, 0b11111111, 0, 0, 0b111111111, 0b11111111, 0],
            ".": [0,0,0b00101010,0,0b01010100,0, 0, 0],
        }
        self.pixels = {}
        for c in self.pixmaps:
            self.pixels[c] = pygame.Surface((12, 8), pygame.SRCALPHA)
            for y, row in enumerate(self.pixmaps[c]):
                for bit in range(8):
                    if row & (1 << (7 - bit)):
                        gfxdraw.pixel(self.pixels[c], bit + 2, y, (255, 255, 255, 255))
                if row & (1 << 7):
                    gfxdraw.pixel(self.pixels[c], 0, y, (255, 255, 255, 255))
                    gfxdraw.pixel(self.pixels[c], 1, y, (255, 255, 255, 255))
                if row & 1:
                    gfxdraw.pixel(self.pixels[c], 10, y, (255, 255, 255, 255))
                    gfxdraw.pixel(self.pixels[c], 11, y, (255, 255, 255, 255))

        self.charmap = {"|LJF7-S."[i]: "║╚╝╔╗═╬░"[i] for i in range(8)}
        self.current = self.start
        self.visited = set([self.start])
        self.fidx = 0
        self.speed = 1
        self.fill = False

    def update(self, view, controller):
        if not controller.animate:
            return
        view.win.fill((0, 0, 0, 0))
        dimx = 12
        dimy = 8
        if self.fill:
            if self.fidx == len(self.marked):
                controller.animate = False
            else:
                self.visited.add(self.marked[self.fidx])
                self.fidx += 1
        for y in range(len(self.lines)):
            if (y * dimy) >= 1200:
                break
            for x in range(len(self.lines[y])):
                if (x * dimx) >= 1920:
                    break
                # view.font.render_to(view.win, (20 + x * dimx, 40 + y * dimy), self.charmap[self.lines[y][x]], (80, 80, 80, 40))
                pix = self.pixels[self.lines[y][x]]
                if (y, x) in self.visited:
                    if (y, x) in self.marked:
                        pix = self.pixels['.']
                    pix.set_alpha(255)
                else:
                    pix.set_alpha(100)
                view.win.blit(pix, (120 + x * dimx, 40 + y * dimy))
        for i in range(self.speed):
            self.current = self.next[self.current]
            if self.current in self.visited and not self.fill:
                self.fill = True
                self.fidx = 0
            else:
                self.visited.add(self.current)
        if self.fidx % 60 == 0 and self.speed < 10:
            self.speed += 1
        cyc = len(self.visited)
        if self.fill:
            cyc = len(self.next)
            txt2 = "Max distance: " + str(cyc//2) + "               Inner surface area: " + str(self.fidx)
            view.font.render_to(view.win, (900,1184), txt2, (255,255,255,255))
        txt = "Cycle length: " + str(cyc)
        view.font.render_to(view.win, (600,1184), txt, (255,255,255,255))




view = View(1920, 1200, 60, 16)
view.setup("Day 10")
controller = Controller()
lines = open(controller.workdir() + "/day10.txt").read().split("\n")
controller.add(Display(lines))
controller.run(view)
