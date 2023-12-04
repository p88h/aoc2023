import pygame
from common import View, Controller


class Background:
    def __init__(self, lines, font) -> None:
        (fw, fh) = (8, 20)
        self.width = fw * len(lines[0]) + 40
        self.height = fh * len(lines) + 40
        print(self.width, self.height)
        self.tmp = pygame.Surface((self.width, self.height), pygame.SRCALPHA)
        self.tmp.fill((0, 0, 0, 0))
        for i in range(len(lines)):
            view.font.render_to(self.tmp, (20, 20 + fh * i), lines[i], (200, 200, 200))
        self.pan = 0

    def update(self, view, controller):
        if not controller.animate:
            return
        view.win.fill((0, 0, 0))
        view.win.blit(self.tmp, (60, 30 - self.pan))
        if self.pan < 100:
            self.pan += 1
        elif self.pan < 2200:
            self.pan += 2


class Numbers:
    def __init__(self, nums, bg) -> None:
        self.tiles = []
        self.fidx = 0
        self.nums = nums
        self.bg = bg
        self.tmp = pygame.Surface((bg.width, bg.height), pygame.SRCALPHA)
        self.tmp.fill((0, 0, 0, 0))

    def update(self, view, controller):
        if not controller.animate:
            return
        (fw, fh) = (8, 20)
        if self.fidx < len(self.nums):
            (x, y, w, r, bx, by, bw, bh, s) = self.nums[self.fidx]
            pygame.draw.rect(self.tmp, (200, 200, 160, 180), (20 + x * fw, 4 + y * fh, fw * w, fh), 1)
        if self.fidx >= 50 and self.fidx - 50 < len(self.nums):
            (x, y, w, r, bx, by, bw, bh, s) = self.nums[self.fidx - 50]
            pygame.draw.rect(self.tmp, (180, 220, 220, 200), (20 + bx * fw, 4 + by * fh, bw * fw, bh * fh), 1)
        if self.fidx >= 100 and self.fidx - 100 < len(self.nums):
            (x, y, w, r, bx, by, bw, bh, s) = self.nums[self.fidx - 100]
            if not s:
                pygame.draw.rect(self.tmp, (0, 0, 0, 255), (20 + bx * fw, 4 + by * fh, bw * fw, bh * fh), 1)
        view.win.blit(self.tmp, (60, 30 - bg.pan))
        self.fidx += 1


def bbox(y, x, l, r, dimx, dimy, lines):
    sx = max(x - 1, 0)
    lx = min(x + l, dimx - 1) + 1
    sy = max(y - 1, 0)
    ly = min(y + 1, dimy - 1) + 1
    star = None
    for gy in range(sy, ly):
        for gx in range(sx, lx):
            if lines[gy][gx] == "*":
                star = (gy, gx)
    return (x, y, l, r, sx, sy, lx - sx, ly - sy, star)


def find_nums(lines):
    dimx = len(lines[0])
    dimy = len(lines)
    nums = []
    for y in range(dimy):
        r = 0
        q = 0
        for x in range(dimx):
            c = ord(lines[y][x])
            if c >= 48 and c <= 57:
                d = c - 48
                r = r * 10 + d
                q += 1
            else:
                if q > 0:
                    nums.append(bbox(y, x - q, q, r, dimx, dimy, lines))
                    r = q = 0
        if q > 0:
            nums.append(bbox(y, dimx - q, q, r, dimx, dimy, lines))
    return nums


view = View(1280, 720, 60)
view.setup("Day 03")
controller = Controller()
lines = open(controller.workdir() + "/day03.txt").read().split("\n")
print(view.font)
bg = Background(lines, view.font)
controller.add(bg)
controller.add(Numbers(find_nums(lines), bg))
controller.run(view)
