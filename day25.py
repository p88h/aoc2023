from benchy import minibench
from collections import defaultdict
lines = open("day25.txt").read().split("\n")
graph = defaultdict(set)

def parse():
    graph.clear()
    for line in lines:
        src = line[:3]
        for dst in line[5:].split(' '):
            graph[src].add(dst)
            graph[dst].add(src)
    return len(graph)

# compute a bfs path from src to tgt
# if tgt not specified, a path to somewhere farthest from src.
def bfs(src, tgt = None):
    prev = { src : None }
    stak = [ src ]
    sp = 0
    while sp < len(stak):
        cur = stak[sp]
        sp += 1
        if cur == tgt:
            break
        for dst in graph[cur]:
            if dst not in prev:
                prev[dst] = cur
                stak.append(dst)
    if tgt == None:
        tgt = stak[-1]
    elif tgt not in prev:
        return stak
    path = []
    while (tgt != None):
        path.append(tgt)
        tgt = prev[tgt]
    return path

# push cnt flow between src and tgt
# then identify the cut and compute the subgraphs
def edmond_karp(cnt, src, tgt = None):
    removed = []
    for i in range(cnt):
        path = bfs(src, tgt)
        tgt = pre = path[0]
        for i in range(1, len(path)):
            cur = path[i]
            graph[cur].remove(pre)
            graph[pre].remove(cur)
            removed.append((cur,pre))
            pre = cur
    # Compute the reachable nodes in residual graph
    reachable = bfs(src, tgt)
    # Restore removed edges
    for (a,b) in removed:
            graph[a].add(b)
            graph[b].add(a)
    return len(reachable)

def part1():
    total = len(graph)
    first = lines[0][:3]
    reachable = edmond_karp(3, first)
    return(reachable * (total-reachable))

print(parse())
print(part1())

minibench({"parse": parse, "part1": part1})