from parser import *
from wrappers import minibench
from array import Array

alias maxc = 16
alias maxn = 1600

@always_inline
fn encode(s: StringSlice, inout mapp: Array[DType.int16]) -> Int:
    alias orda = ord("a")
    var ret = 0
    for i in range(s.size):
        ret = ret * 26 + (int(s[i])) - orda
    if mapp[ret] == 0:
        mapp[0] += 1
        mapp[ret] = mapp[0]
    return int(mapp[ret])

@always_inline
fn link(a: Int, b: Int, inout graph: Array[DType.int16]):
    ai = int(graph[a * maxc])
    graph[a * maxc + 1 + ai] = b
    graph[a * maxc] = ai + 1
    bi = int(graph[b * maxc])
    graph[b * maxc + 1 + bi] = a
    graph[b * maxc] = bi + 1

fn main() raises:
    f = open("day25.txt", "r")
    lines = make_parser["\n"](f.read())
    enc = Array[DType.int16](26 * 26 * 26)
    graph = Array[DType.int16](maxn * maxc)
    marks = Array[DType.int32](maxn * maxn)
    prev = Array[DType.int16](maxn)
    work = Array[DType.int16](maxn)
    var mark = 1

    @parameter
    fn parse() -> Int64:
        graph.zero()
        for l in range(lines.length()):
            line = lines[l]
            src = encode(line[0:3], enc)
            for k in range(5, line.size, 4):
                dst = encode(line[k : k + 3], enc)
                # print(line[0:3],src,line[k:k+3],dst)
                link(src, dst, graph)
        return int(enc[0])

    # compute a bfs path from src to tgt
    # if tgt not specified, a path to somewhere farthest from src.
    @parameter
    fn bfs(src: Int, tgt: Int = -1) -> Int:
        prev.fill(-1)
        work[0] = src
        prev[src] = 0
        var ss = 1
        var si = 0
        while si < ss:
            cur = int(work[si])
            si += 1
            if cur == tgt:
                break
            for di in range(graph[cur * maxc]):
                dst = int(graph[cur * maxc + 1 + di])
                if marks[cur * maxn + dst] != mark and prev[dst] < 0:
                    prev[dst] = cur
                    work[ss] = dst
                    ss += 1
        var dsl = tgt
        if dsl < 0:
            dsl = int(work[ss - 1])
        if prev[dsl] > 0:
            ss = 0
            while dsl > 0:
                work[ss] = dsl
                ss += 1
                dsl = int(prev[dsl])
        return ss

    # push cnt flow between src and tgt
    # then identify the cut and compute the subgraphs
    @parameter
    fn edmond_karpik(cnt: Int, src: Int) -> Int:
        mark += 1
        var tgt = -1
        for i in range(cnt):
            plen = bfs(src, tgt)
            var pre = int(work[0])
            tgt = pre
            for i in range(1, plen):
                cur = int(work[i])
                marks[cur * maxn + pre] = mark
                pre = cur

        # Compute the reachable nodes in residual graph
        return bfs(src, tgt)

    @parameter
    fn part1() -> Int64:
        start = encode(lines[0][0:3], enc)
        reachable = edmond_karpik(3, start)
        return reachable * (int(enc[0]) - reachable)

    minibench[parse]("parse")
    minibench[part1]("part1")

    print(lines.length(), "lines")
    print(graph.bytecount(), "graph size")
    print(marks.bytecount(), "marks size")
    print(prev.bytecount() + work.bytecount() + enc.bytecount(), "work buffers size")
