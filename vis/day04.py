from common import View, Controller
import pygame


def parse(lines):
    games = []
    for id, line in enumerate(lines):
        line = line.replace("  ", " ")
        (_, t) = line.split(": ")
        (a, b) = t.split(" | ")
        n1 = set(map(int, a.split(" ")))
        n2 = set(map(int, b.split(" ")))
        games.append((n1, n2))
    return games


class Card:
    def __init__(self, game) -> None:
        (n1, n2) = game
        (fw, fh) = (16, 32)
        self.width = 40 + fw * 20
        self.height = 40 + fh * 10
        self.win = pygame.Surface((self.width, self.height), pygame.SRCALPHA)
        self.win.fill((0, 0, 0, 0))
        self.hand = pygame.Surface((self.width, self.height), pygame.SRCALPHA)
        self.hand.fill((0, 0, 0, 0))
        pygame.draw.rect(self.hand, (180, 180, 180, 120), (10, 10, self.width - 20, self.height - 20), 1)
        pygame.draw.rect(self.win, (220, 220, 220, 180), (10, 10, self.width - 20, self.height - 20))
        for i in range(1, 100):
            tx = 20 + (i % 10) * fw * 2
            ty = 20 + (i // 10) * fh
            if i in n1:
                pygame.draw.rect(self.win, (0, 0, 0, 0), (tx - 2, ty, fw * 2 - 2 , fh - 2))
            if i in n2:
                view.font.render_to(self.hand, (tx, ty + fh - 8), str(i), (200, 200, 200))

    def update_text(self, cnt, score=0):
        self.txt = pygame.Surface((self.width, 24), pygame.SRCALPHA)
        label = "  x " + str(cnt)
        if score > 0:
            label += "    MATCH: " + str(score)
        view.font.render_to(self.txt, (0, 24), label, (200, 200, 200))

    def blit(self, view, posx, ofs, text):
        view.win.blit(self.win, (posx, 30 + ofs))
        view.win.blit(self.hand, (posx, 60 + self.height))
        view.win.blit(self.txt, (posx, 60 + self.height * 2))


class Game:
    def __init__(self, games) -> None:
        self.games = games
        self.cards = [Card(game) for game in games]
        for card in self.cards:
            card.update_text(1)
        self.pan = 0
        self.shift = 0
        self.mode = 0
        self.sidx = 0
        self.msgs = [ "", "(c) 1730-2023 BINGO AND SCRATCHCARD CORPORATION OF NORTH POLE", 
                      "", "YOU WILL NEED A BAG TO HOLD THEESE SCRATCHCARDS. GO SEE https://adventofcode.com/2020/day/7",
                      "", "DO NOT TRUST THE SQUIDS. https://adventofcode.com/2021/day/4 ",                       
                      "", "PUNCHCARD SERVICES PROVIDED BY INTERNATIONAL PUNCHCARD MACHINES (R)",
                      "", "VISIT https://tinyurl.com/3tjhjfnw TO WIN EVEN MORE SCRATCHCARDS", 
                      "", "",
                      "", "THE CAKE IS A LIE",
                      "", "THE PRINCESS IS IN ANOTHER CASTLE",
                      "", "NOTHING TO SEE HERE. REALLY.",
                      "", "BYE!","BYE!!","BYE!!!"]
        self.muls = [ 2, 3, 4, 5, 6, 8, 10 , 15, 30 ]
        self.speed = self.muls[0]
        self.counts = [1] * len(games)
        self.score = 0

    def resolve_card(self, idx):
        (win, hand) = self.games[idx]
        x = 0
        for num in hand:
            if num in win:
                x += 1
        for i in range(idx + 1, min(len(self.games), idx + x + 1)):
            self.counts[i] += self.counts[idx]
        self.score += self.counts[idx]
        return x

    def update(self, view, controller):
        if not controller.animate:
            return
        view.win.fill((0, 0, 0))
        scard = self.cards[self.sidx]
        scard.blit(view, 0 - self.shift, self.pan, "  x " + str(self.counts[self.sidx]))
        for i in range(1, 7):
            if (self.sidx + i) >= len(self.cards):
                break
            card = self.cards[self.sidx + i]
            card.blit(view, i * card.width - self.shift, 0, "  x " + str(self.counts[self.sidx + i]))
        view.font.render_to(view.win, (20, 120 + scard.height * 2), "SCORE: " + str(self.score), (200, 200, 200))
        view.font.render_to(view.win, (20, 200 + scard.height * 2), self.msgs[self.sidx//10], (200, 200, 200))

        if self.mode == 0:
            if self.pan < scard.height + 30:
                self.pan += self.speed
            else:
                self.mode = 1
                x = self.resolve_card(self.sidx)
                scard.update_text(self.counts[self.sidx], x)
                for i in range(self.sidx + 1, min(self.sidx + 10, len(self.cards))):
                    self.cards[i].update_text(self.counts[i])

        if self.mode == 1:
            if self.shift < scard.width:
                self.shift += self.speed
            else:
                self.pan = self.shift = 0
                self.sidx += 1
                self.mode = 0
                if self.sidx < len(self.muls):
                    self.speed = self.muls[self.sidx]
                if self.sidx >= len(self.games):
                    controller.animate = False
                
        

view = View(1920, 1080, 60, 24)
view.setup("Day 03")
controller = Controller()
lines = open(controller.workdir() + "/day04.txt").read().split("\n")
controller.add(Game(parse(lines)))
controller.run(view)
