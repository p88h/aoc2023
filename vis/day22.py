from common import View, Controller
import pygame
import math


def parse(lines):
    bricks = []
    for line in lines:
        line = line.replace("~", ",")
        (x1, y1, z1, x2, y2, z2) = map(int, line.split(","))
        # swap so that z1 is lower
        if z2 < z1:
            (x1, y1, z1, x2, y2, z2) = (x2, y2, z2, x1, y1, z1)
        elif x2 < x1:  # z1,y1 is same as z2,y2
            x1, x2 = x2, x1
        elif y2 < y1:  # z1,x1 is same as z2,y2
            y1, y2 = y2, y1
        bricks.append((z1, x1, y1, z2, x2, y2))
    bricks.sort()
    return bricks


def project2d(v):
    x, y, z = v
    x, y, z = 40 * x, 40 * y, 40 * z
    xp = (x + y) / math.sqrt(2) + 800
    yp = (x - 2 * z - y) / math.sqrt(6) + 1000
    return (int(xp), int(yp))


class Background:
    def __init__(self, bricks) -> None:
        self.bricks = bricks
        self.mapp = [ 0 ] * 100
        self.height = [ 0 ] * 100
        self.unsafe = [ 0 ] * len(bricks)
        self.bidx = 0
        self.maxz2 = 0        

    def drop(self, i):
        (z1, x1, y1, z2, x2, y2) = self.bricks[i].dims
        if z1 > 1:
            if x1 != x2:
                mh = max([self.height[x + y1*10] for x in range(x1,x2+1)])
            else:
                mh = max([self.height[x1 + y*10] for y in range(y1,y2+1)])
            if z1 - 1 > mh:
                z2 -= 1
                z1 -= 1
                self.bricks[i].dims = (z1, x1, y1, z2, x2, y2)
                self.bricks[i].y += 33
                return False
        sup = []
        prev = -1
        if x1 != x2:
            r = [ (x,y1) for x in range(x1,x2+1)]
        else:
            r = [ (x1,y) for y in range(y1,y2+1)]
        for (x,y) in r:
            if z1 > 1 and self.height[x + y*10] == z1 - 1:
                base = self.mapp[x+y*10]
                if base != prev:
                    sup.append(base)
                prev = base
            self.height[x + y*10] = z2
            self.mapp[x + y*10] = i
        if len(sup) == 1:
            self.unsafe[sup[0]] = 1
        return True

    def update(self, view, controller):
        if not controller.animate:
            return
        view.win.fill((0, 0, 0, 0))
        for brick in self.bricks:
            brick.update(view)
        pos = (self.bidx * 1820) // len(self.bricks)
        pygame.draw.line(view.win, (255, 255, 255), (50, 1160), (1870, 1160), 2)
        pygame.draw.circle(view.win, (255, 255, 255), (51 + pos, 1161), 6)
        view.font.render_to(view.win, (31 + pos, 1186), "Z " + str(self.maxz2), (255, 255, 255))
        if self.drop(self.bidx):
            self.maxz2=max(self.maxz2, self.bricks[self.bidx].dims[3])
            self.bidx += 1        
        if self.bidx >= len(self.bricks):
            controller.animate = False
            return
        while self.bricks[self.bidx].dims[0] - self.maxz2 > 5:
            for j in range(self.bidx, len(self.bricks)):
                (z1, x1, y1, z2, x2, y2) = self.bricks[j].dims
                z1 -= 1
                z2 -= 1
                self.bricks[j].dims = (z1, x1, y1, z2, x2, y2)
                self.bricks[j].y += 33





class Box3D:
    def __init__(self, dims):
        self.dims = dims
        (z1, x1, y1, z2, x2, y2) = dims
        (x, y, z) = (x1, y1, z1)
        (w, h, d) = (x2 - x1 + 1, y2 - y1 + 1, z2 - z1 + 1)
        
        vertices3D = [
            [x, y, z],
            [x + w, y, z],
            [x + w, y + h, z],
            [x, y + h, z],
            [x, y, z + d],
            [x + w, y, z + d],
            [x + w, y + h, z + d],
            [x, y + h, z + d],
        ]
        faces = [
            [project2d(vertices3D[i]) for i in range(4)],
            [project2d(vertices3D[i]) for i in range(4, 8)],
            [project2d(vertices3D[i]) for i in [0, 1, 5, 4]],
            [project2d(vertices3D[i]) for i in [2, 3, 7, 6]],
            [project2d(vertices3D[i]) for i in [1, 2, 6, 5]],
            [project2d(vertices3D[i]) for i in [0, 3, 7, 4]],
        ]
        all_points = []
        all_points.extend(faces[1])
        all_points.extend(faces[2])
        all_points.extend(faces[4])
        self.x = self.y = 1000000
        self.w = self.h = -1000000
        for x, y in all_points:
            self.x = min(x, self.x)
            self.y = min(y, self.y)
            self.w = max(self.w, x)
            self.h = max(self.h, y)
        self.w -= self.x
        self.h -= self.y
        self.tmp = pygame.Surface((self.w, self.h), pygame.SRCALPHA)
        face1 = [(x - self.x, y - self.y) for (x, y) in faces[1]]
        face2 = [(x - self.x, y - self.y) for (x, y) in faces[2]]
        face4 = [(x - self.x, y - self.y) for (x, y) in faces[4]]
        pygame.draw.polygon(self.tmp, (200, 200, 200), face2)
        pygame.draw.polygon(self.tmp, (120, 120, 120), face1)
        pygame.draw.polygon(self.tmp, (160, 160, 160), face4)
        pygame.draw.polygon(self.tmp, (0, 0, 0), face2, 1)
        pygame.draw.polygon(self.tmp, (0, 0, 0), face1, 1)
        pygame.draw.polygon(self.tmp, (0, 0, 0), face4, 1)
        print(w,h,d,"=>",self.w,self.h)
        

    def update(self, view):
        dy = self.y + view.frame * 2 // 5
        if dy + self.h > 0 and dy < 1200:
            view.win.blit(self.tmp, (self.x, dy))


view = View(1920, 1200, 60, 24)
view.setup("Day 22")
controller = Controller()
lines = open("day22.txt").read().splitlines()
controller.add(Background([Box3D(box) for box in parse(lines)]))
controller.run(view)
