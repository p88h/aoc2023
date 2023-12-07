from benchy import minibench

lines = open("day07.txt").read().split()
alphabet = "AKQJT98765432"
mapp = {v: k for (k,v) in enumerate(alphabet)}

def rank(ss, joke):
    k=[ 0 ]*6
    j = ss.count('J') * joke
    for chr in alphabet:
        k[ss.count(chr)] += 1
    if (k[5] > 0):
        s = 0
    elif (k[4] > 0):
        s = 1
        if (j > 0):
            s = 0
    elif (k[3] > 0) and (k[2] > 0) :
        s = 2
        if (j > 0):
            s = 0
    elif (k[3] > 0):
        s = 3
        if (j > 0):
            s = 1
    elif (k[2] > 1):
        s = 4
        if (j == 1):
            s = 2
        elif (j == 2):
            s = 1
    elif (k[2] > 0):
        s = 5
        if (j > 0):
            s = 3
    elif (j > 0):
        s = 5
    else:
        s=6
    for chr in ss:
        if (joke and chr == "J"):
            s = s * 14 + 13
        else:
            s = s * 14 + mapp[chr]
    return s


def play(joke):
    ranked = []
    for l in range(len(lines)//2):
        (hand, s) = (lines[l*2], lines[l*2+1])
        ranked.append((rank(hand, joke), int(s), hand))
    p = len(ranked)
    s = 0
    for (r,v,h) in sorted(ranked):
        # print (r,h,v,"*",p)
        s += v * p
        p -= 1
    return(s)


def part1():
    return play(0)

def part2():
    return play(1)

print(part1())
print(part2())
minibench({"part1": part1, "part2": part2}, 1000)
