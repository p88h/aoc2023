from common import View, Controller
from random import randint
import pygame

pats = {
'2': ["   "," * ","   "," * ","   "],
'3': [" * ","   "," * ","   "," * "],
'4': ["* *","   ","   ","   ","* *"],
'5': ["* *","   "," * ","   ","* *"],
'6': ["* *","   ","* *","   ","* *"],
'7': [" * ","* *"," * ","* *"," * "],
'8': ["* *"," * ","* *"," * ","* *"],
'9': ["  *"," **","***","** ","*  "],
'T': [" * ","***","* *","***"," * "]}

class Game:
    def __init__(self, hands) -> None:
        self.hands = hands
        self.mode = 0
        self.sidx = 0
        self.fidx = 0
        self.bigfont = pygame.freetype.Font("vis/Inconsolata-SemiBold.ttf", 48)

    def update(self, view, controller):
        if not controller.animate:
            return
        view.win.fill((0, 0, 0))
        p = 0
        for hand, score, col in self.hands:
            x = p * 100 + 40
            if x > 1920:
                break
            y = 960
            pygame.draw.line(view.win, (220, 220, 220, 240), (x, y), (x + 80, y), 1) 
            cols = "♠♥♦♣"
            for c in hand:
                points = [(x, y), (x, y - 160), (x + 80, y - 160), (x + 80, y)]
                pygame.draw.lines(view.win, (220, 220, 220, 240), False, points, 1)
                view.font.render_to(view.win, (x + 60, y - 130), c, (200, 200, 200))
                if c in pats:
                    pat = pats[c]
                    j = 0
                    for row in pat:
                        j += 1
                        if j == 5 and y != 960:
                            break
                        k = 0
                        for el in row:
                          k += 1
                          if (el == '*'):
                            view.font.render_to(view.win, (x + 20*k-5, y - 130 + 20*j), cols[col], (200, 200, 200))                            
                        
                y -= 120
            p += 1


view = View(1920, 1080, 30, 24)
view.setup("Day 07")
controller = Controller()
lines = open(controller.workdir() + "/day07.txt").read().split()
parsed = [(lines[i * 2], int(lines[i * 2 + 1]), randint(0,3)) for i in range(len(lines) // 2)]
controller.add(Game(parsed))
controller.run(view)
