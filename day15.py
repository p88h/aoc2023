from benchy import minibench

tokens = open("day15.txt").read().split(",")

def hash(s):
    v = 0
    for c in s:
        v += ord(c)
        v *= 17
        v &= 255
    return v

def part1():
    return sum(map(hash,tokens))

def part2():
    strength = {}
    boxes = []
    for i in range(256):
        # sets are slower here, anyway. max number of items in the list is ~6
        boxes.append([])
    for tok in tokens:
        if tok[-1] == "-":
            l = tok[:-1]
            hc = hash(l) 
            if l in boxes[hc]:
                boxes[hc].remove(l)
        else:
            l = tok[:-2]
            hc = hash(l)
            st = int(tok[-1])
            # checking via strength map is slower. 
            if l not in boxes[hc]:
                boxes[hc].append(l)
            strength[l] = st
    sum = 0
    for i in range(256):
        for j,l in enumerate(boxes[i]):
            sum += (i+1)*(j+1)*strength[l]
    return sum

print(part1())
print(part2())

minibench({"part1": part1, "part2": part2})
