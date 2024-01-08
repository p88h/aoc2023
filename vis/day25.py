from common import View, Controller
import pygame
from collections import defaultdict


def parse(lines):
    graph = defaultdict(set)
    for line in lines:
        src = line[:3]
        for dst in line[5:].split(" "):
            graph[src].add(dst)
            graph[dst].add(src)
    return graph


def bfs(graph, src):
    prev = {src: None}
    hist = []
    stak = [src]
    while stak:
        next = []
        for cur in stak:
            for dst in graph[cur]:
                if dst not in prev:
                    prev[dst] = cur
                    next.append(dst)
        # next.sort()
        hist.append(stak)
        stak = next

    return (hist, prev)


def edmond_karp(graph, cnt=4):
    mconn = -1
    for node in graph:
        if len(graph[node]) > mconn:
            src = node
    frames = []
    pos = {}
    tgt = None
    for i in range(cnt):
        (history, prev) = bfs(graph, src)
        # print(history)
        if not tgt:
            tgt = history[-1][10]
        for lvl, nodes in enumerate(history):
            cx = 0
            for node in nodes:
                if node not in pos:
                    pos[node] = (cx, lvl + 1)
                    cx += 1
                frames.append((node, i + 1, prev[node]))
        pre = tgt
        while pre in prev and prev[pre]:
            frames.append((pre, -1, prev[pre]))
            cur = prev[pre]
            graph[cur].remove(pre)
            pre = cur
    return pos, frames


class Display:
    fidx = 0
    speed = 2
    reachable = 0

    def __init__(self, graph) -> None:
        self.pos, self.frames = edmond_karp(graph)
        self.total = len(graph)

    def update(self, view, controller):
        if not controller.animate:
            return
        dy = 80
        for _ in range(self.speed):
            cf, cv, cp = self.frames[self.fidx]
            cx, cy = self.pos[cf]            
            if cv > 0:
                cc = (80 + cv * 42, 80 + cv * 42, 80 + cv * 42)
                pygame.draw.rect(view.win, (0, 0, 0), (cx * 7 + 1, cy * dy + 1, 5, 46))
                view.font.render_to(view.win, (cx * 7, cy * dy + 14), cf[0], cc)
                view.font.render_to(view.win, (cx * 7, cy * dy + 28), cf[1], cc)
                view.font.render_to(view.win, (cx * 7, cy * dy + 42), cf[2], cc)
                self.reachable += 1
            else:
                pygame.draw.rect(view.win, (255, 255, 255), (cx * 7, cy * dy, 7, 44), 1)
                self.reachable = 0
            if cv == 1 and cp:
                px, py = self.pos[cp]
                pygame.draw.line(view.win, cc, (cx * 7 + 3, cy * dy), (px * 7 + 3, py * dy + 44))
            if cv == -1 and cp:
                px, py = self.pos[cp]
                pygame.draw.line(view.win, (0,0,0,0), (cx * 7 + 3, cy * dy), (px * 7 + 3, py * dy + 44),2)
            self.fidx += 1
            if self.fidx >= len(self.frames):
                controller.animate = False
                break
        pygame.draw.rect(view.win, (0, 0, 0), (0, 0, 200, 30))
        view.font.render_to(view.win, (10, 20), "Reachable: " + str(self.reachable), (255, 255, 255))


view = View(1920, 1200, 60, 12)
view.setup("Day 25")
controller = Controller()
lines = open("day25.txt").read().splitlines()
controller.add(Display(parse(lines)))
controller.run(view)
