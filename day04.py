from benchy import minibench

lines = open("day04.txt").read().split("\n")
games = []

def parse():
    games.clear()
    for (id,line) in enumerate(lines):
        line = line.replace("  "," ")
        (_,t) = line.split(": ");
        (a,b) = t.split(" | ")
        n1 = set(map(int, a.split(" ")))
        n2 = list(map(int, b.split(" ")))
        games.append((id,n1,n2))
    return 0

def part1():
    s = 0
    for (_, win,hand) in games:
        c = 1
        for num in hand:
            if num in win:
                c *= 2
        s += c//2
    return s

def part2():
    l = len(games)
    w = [ 1 ] * l
    s2 = 0
    for (id, win,hand) in games:
        x = 0
        for num in hand:
            if num in win:
                x+=1
        for i in range(id+1,min(l, id+x+1)):
            w[i] += w[id]
        s2 += w[id]
    return s2

parse()
print(part1())
print(part2())

minibench({"parse": parse, "part1": part1, "part2": part2}, 1000)
