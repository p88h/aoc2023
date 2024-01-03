from parser import *
from wrappers import minibench
from array import Array
from math import max

alias maxc = 16
alias maxn = 1600

@always_inline
fn encode(s: StringSlice, inout mapp: Array[DType.int16]) -> Int:
    alias orda = ord("a")
    var ret = 0
    for i in range(s.size):
        ret = ret * 26 + (s[i].to_int()) - orda
    if mapp[ret] == 0:
        mapp[0] += 1
        mapp[ret] = mapp[0]
    return mapp[ret].to_int()

@always_inline
fn link(a: Int, b: Int, inout graph: Array[DType.int16]):
    let ai = graph[a * maxc].to_int()
    graph[a * maxc + 1 + ai] = b
    graph[a * maxc] = ai + 1
    let bi = graph[b * maxc].to_int()
    graph[b * maxc + 1 + bi] = a
    graph[b * maxc] = bi + 1

fn main() raises:
    let f = open("day25.txt", "r")
    let lines = make_parser["\n"](f.read())
    let enc = Array[DType.int16](26 * 26 * 26)
    let graph = Array[DType.int16](maxn * maxc)
    let marks = Array[DType.int32](maxn * maxn)
    let prev = Array[DType.int16](maxn)
    let work = Array[DType.int16](maxn)
    var mark = 1

    @parameter
    fn parse() -> Int64:
        graph.clear()
        for l in range(lines.length()):
            let line = lines[l]
            let src = encode(line[0:3], enc)
            for k in range(5, line.size, 4):
                let dst = encode(line[k : k + 3], enc)
                # print(line[0:3],src,line[k:k+3],dst)
                link(src, dst, graph)
        return enc[0].to_int()

    # compute a bfs path from src to tgt
    # if tgt not specified, a path to somewhere farthest from src.
    @parameter
    fn bfs(src: Int, tgt: Int = -1) -> Int:
        prev.clear(-1)
        work[0] = src
        prev[src] = 0
        var ss = 1
        var si = 0
        while si < ss:
            let cur = work[si].to_int()
            si += 1
            if cur == tgt:
                break
            for di in range(graph[cur * maxc]):
                let dst = graph[cur * maxc + 1 + di].to_int()
                if marks[cur * maxn + dst] != mark and prev[dst] < 0:
                    prev[dst] = cur
                    work[ss] = dst
                    ss += 1
        var dst = tgt
        if dst < 0:
            dst = work[ss - 1].to_int()
        if prev[dst] > 0:
            ss = 0
            while dst > 0:
                work[ss] = dst
                ss += 1
                dst = prev[dst].to_int()
        return ss

    # push cnt flow between src and tgt
    # then identify the cut and compute the subgraphs
    @parameter
    fn edmond_karpik(cnt: Int, src: Int) -> Int:
        mark += 1
        var tgt = -1
        for i in range(cnt):
            let plen = bfs(src, tgt)
            var pre = work[0].to_int()
            tgt = pre
            for i in range(1, plen):
                let cur = work[i].to_int()
                marks[cur * maxn + pre] = mark
                pre = cur

        # Compute the reachable nodes in residual graph
        return bfs(src, tgt)

    @parameter
    fn part1() -> Int64:
        let start = encode(lines[0][0:3], enc)
        let reachable = edmond_karpik(3, start)
        return reachable * (enc[0].to_int() - reachable)

    minibench[parse]("parse")
    minibench[part1]("part1")

    print(lines.length(), "lines")
    print(graph.bytecount(), "graph size")
    print(marks.bytecount(), "marks size")
    print(prev.bytecount() + work.bytecount() + enc.bytecount(), "work buffers size")
