from benchy import minibench

lines = open("day10.txt").read().split("\n")
visited = set()

def part1():
    start = None
    for y in range(len(lines)):
        if "S" in lines[y]:
            x = lines[y].find("S")
            start = (y, x)    
            break
    visited.clear()
    visited.add((y,x))
    if lines[y][x + 1] in ("J", "-", "7"):
        current = (y, x + 1)
    if lines[y][x - 1] in ("L", "-", "F"):
        current = (y, x - 1)
    if lines[y - 1][x] in ("|", "F", "7"):
        current = (y - 1, x)
    if lines[y + 1][x] in ("|", "L", "J"):
        current = (y + 1, x)
    mapping = {
        "-": [(0, 1), (0, -1)],
        "|": [(1, 0), (-1, 0)],
        "L": [(0, 1), (-1, 0)],
        "F": [(0, 1), (1, 0)],
        "7": [(0, -1), (1, 0)],
        "J": [(0, -1), (-1, 0)],
    }
    prev = start
    while current != start:
        visited.add(current)
        (y, x) = current
        char = lines[y][x]        
        for dy, dx in mapping[char]:
            next = (y + dy, x + dx)
            if next != prev:
                prev = current
                current = next
                break
    return len(visited) // 2

def part2():
    cnt = 0
    skip = " "
    for y in range(len(lines)):
        out = True
        for x in range(len(lines[y])):
            if (y, x) in visited:
                # start of the fence, maybe
                if lines[y][x] == "F":
                    skip = "7"
                elif lines[y][x] == "L":
                    skip = "J"
                elif lines[y][x] == "-":
                    # walking along the fence, whatever.
                    continue
                else:
                    # equivalent to "|" now
                    if lines[y][x] != skip:
                        out = not out
                    # stop walking along the fence
                    skip = " "
            elif not out:
                cnt += 1
    return cnt

print(part1())
print(part2())

minibench({"part1": part1, "part2": part2})
