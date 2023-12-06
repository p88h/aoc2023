from benchy import minibench


def maxballs(line):
    (_, rest) = line.split(": ")
    games = rest.split("; ")
    mdict = {}
    mdict["red"] = mdict["green"] = mdict["blue"] = 0
    for game in games:
        game = game.replace(",", "")
        toks = game.split(" ")
        for i in range(len(toks) // 2):
            cnt = int(toks[i * 2])
            col = toks[i * 2 + 1]
            mdict[col] = max(mdict[col], cnt)
    return mdict


lines = open("day02.txt").read().split("\n")


def part1():
    id = 1
    sum = 0
    for line in lines:
        mdict = maxballs(line)
        if mdict["red"] <= 12 and mdict["green"] <= 13 and mdict["blue"] <= 14:
            sum += id
        id += 1
    return sum


def part2():
    sum = 0
    for line in lines:
        mdict = maxballs(line)
        sum += mdict["red"] * mdict["green"] * mdict["blue"]
    return sum


print(part1())
print(part2())

minibench({"part1": part1, "part2": part2})
