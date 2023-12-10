from benchy import minibench

lines = open("day10.txt").read().split("\n")
distance = {}

def part1():
    start = None
    for y in range(len(lines)):
        if 'S' in lines[y]:
            x = lines[y].find('S')
            start = (y,x)
    (y,x) = start
    distance.clear()
    distance[(y,x)] = 0
    current = []
    if lines[y][x+1] in ('J','-','7'):
        current.append((y,x+1))
    if lines[y][x-1] in ('L','-','F'):
        current.append((y,x-1))
    if lines[y-1][x] in ('|','F','7'):
        current.append((y-1,x))
    if lines[y+1][x] in ('|','L','J'):
        current.append((y+1,x))
    for d in current:
        distance[d] = 1
    mapping = {'-':[(0,1),(0,-1)], '|':[(1,0),(-1,0)],
            'L':[(0,1),(-1,0)], 'F':[(0,1),(1,0)],
            '7':[(0,-1),(1,0)], 'J':[(0,-1),(-1,0)]}
    while current:
        next = []
        for (y,x) in current:
            dst = distance[(y,x)]
            char = lines[y][x]
            for (dy,dx) in mapping[char]:
                if (y+dy,x+dx) not in distance:
                    next.append((y+dy,x+dx))
                    distance[(y+dy,x+dx)] = dst + 1
        current = next

    return max(distance.values())

def part2():
    cnt = 0
    skip = ' '
    for y in range(len(lines)):
        out = True
        for x in range(len(lines[y])):
            if (y,x) in distance:
                # start of the fence, maybe
                if lines[y][x] == 'F':
                    skip = '7'
                elif lines[y][x] == 'L':
                    skip = 'J'
                elif lines[y][x] == '-':
                    # walking along the fence, whatever. 
                    continue
                else:
                    # equivalent to "|" now
                    if lines[y][x] != skip:
                        out = not out
                    # stop walking along the fence
                    skip = ' '
            elif not out:
                cnt += 1
    return cnt

print(part1())
print(part2())

minibench({"part1": part1, "part2": part2})

