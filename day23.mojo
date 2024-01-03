from parser import *
from algorithm import parallelize
from wrappers import minibench
from array import Array
from math import max

alias dirs = VariadicList[Tuple[Int, Int, Int]]((-1, 0, ord("<")), (1, 0, ord(">")), (0, -1, ord("^")), (0, 1, ord("v")))
alias cDot = ord(".")
alias cHash = ord("#")
alias gsize = 8


fn dfs1(x: Int, y: Int, inout path: Array[DType.int32], borrowed tiles: Parser, dimy: Int, dimx: Int, curl: Int) -> Int:
    var best: Int = 0
    if y == dimy - 1:  # final
        return curl
    path[y * dimx + x] = 1
    for i in range(4):
        let nx = x + dirs[i].get[0, Int]()
        let ny = y + dirs[i].get[1, Int]()
        let dc = dirs[i].get[2, Int]()
        if (tiles[ny][nx] == cDot or tiles[ny][nx] == dc) and path[ny * dimx + nx] == 0:
            best = max(best, dfs1(nx, ny, path, tiles, dimy, dimx, curl + 1))
    path[y * dimx + x] = 0
    return best


fn link(a: Int, b: Int, c: Int, inout graph: Array[DType.int32]):
    if graph[a] < 2:
        graph[a] = graph[0]
        graph[0] += 1
    if graph[b] < 2:
        graph[b] = graph[0]
        graph[0] += 1
    let ai = graph[a + 1]
    graph[a + 2 + ai * 2] = b
    graph[a + 2 + ai * 2 + 1] = c
    graph[a + 1] = ai + 1
    let bi = graph[b + 1]
    graph[b + 2 + bi * 2] = a
    graph[b + 2 + bi * 2 + 1] = c
    graph[b + 1] = bi + 1


fn dfs2(
    x: Int,
    y: Int,
    inout graph: Array[DType.int32],
    borrowed tiles: Parser,
    px: Int,
    py: Int,
    last: Int,
    dimx: Int,
    dimy: Int,
    steps: Int,
):
    var nsteps = steps
    var lnk = last
    let cur = (y * dimx + x) * gsize
    graph[cur] |= 1  # visited
    var cnt = 0
    for i in range(4):
        let nx = x + dirs[i].get[0, Int]()
        let ny = y + dirs[i].get[1, Int]()
        if tiles[ny][nx] != cHash and not (nx == px and ny == py):
            cnt += 1
    if cnt > 1:
        link(cur, last, steps, graph)  # if a link exist, it's a branch point
        lnk = cur
        nsteps = 0
    for i in range(4):
        let nx = x + dirs[i].get[0, Int]()
        let ny = y + dirs[i].get[1, Int]()
        let nc = (ny * dimx + nx) * gsize
        if (graph[nc] > 1) and not (nx == px and ny == py):
            link(nc, last, steps + 1, graph)
        elif tiles[ny][nx] != cHash and graph[nc] == 0:
            dfs2(nx, ny, graph, tiles, x, y, lnk, dimx, dimy, nsteps + 1)


fn dfs4(start: Int, borrowed graph: Array[DType.int32], inout paths: Array[DType.int32]) -> Int:
    let n0 = graph[start + 2].to_int()
    let d0 = graph[start + 2 + 1].to_int()
    var p = 0
    for i in range(graph[n0 + 1]):
        let n1 = graph[n0 + 2 + 2 * i].to_int()
        let d1 = graph[n0 + 2 + 2 * i + 1].to_int()
        if n1 == start:
            continue
        for j in range(graph[n1 + 1]):
            let n2 = graph[n1 + 2 + 2 * j].to_int()
            let d2 = graph[n1 + 2 + 2 * j + 1].to_int()
            if n2 == n0:
                continue
            for k in range(graph[n2 + 1]):
                let n3 = graph[n2 + 2 + 2 * k].to_int()
                let d3 = graph[n2 + 2 + 2 * k + 1].to_int()
                if n3 == n1:
                    continue
                paths[p * 4] = n3
                paths[p * 4 + 1] = d0 + d1 + d2 + d3
                paths[p * 4 + 2] = (1 << graph[n0]) | (1 << graph[n1]) | (1 << graph[n2])
                p += 1
    return p


fn bfstrim(start: Int, inout graph: Array[DType.int32], inout stak: Array[DType.int32]):
    stak[0] = start
    var si: Int = 0
    var ss: Int = 1
    while si < ss:
        let cur = stak[si]
        si += 1
        for i in range(graph[cur + 1]):
            let dst = graph[cur + 2 + 2 * i]
            if graph[dst + 1] == 3:
                for j in range(graph[dst + 1]):
                    if graph[dst + 2 + 2 * j] == cur:
                        graph[dst + 2 + 2 * j] = graph[dst + 6]
                        graph[dst + 2 + 2 * j + 1] = graph[dst + 7]
                        graph[dst + 1] -= 1
                stak[ss] = dst
                ss += 1


fn dfs3(cur: Int, end: Int, borrowed graph: Array[DType.int32], inout visited: Int64, steps: Int) -> Int:
    if cur == end:
        return steps
    visited |= 1 << graph[cur].to_int()
    var best = 0
    for i in range(graph[cur + 1]):
        let dst = graph[cur + 2 + 2 * i].to_int()
        let add = graph[cur + 2 + 2 * i + 1].to_int()
        if visited & (1 << graph[dst].to_int()) == 0:
            best = max(best, dfs3(dst, end, graph, visited, steps + add))
    visited ^= 1 << graph[cur].to_int()
    return best


fn main() raises:
    let f = open("day23.txt", "r")
    let tiles = make_parser["\n"](f.read())
    let dimx = tiles.length()
    let dimy = tiles[0].size
    let sx = tiles[0].find(cDot)
    let fx = tiles[dimy - 1].find(cDot)
    let work = Array[DType.int32](dimx * dimy * gsize)
    let tmp = Array[DType.int32](64)
    var dst = Atomic[DType.int32](0)

    @parameter
    fn part1() -> Int64:
        work.clear()
        work[sx] = 1
        return dfs1(sx, 1, work, tiles, dimy, dimx, 1)

    @parameter
    fn part2() -> Int64:
        work.clear()
        let start = sx * gsize
        let end = ((dimy - 1) * dimx + fx) * gsize
        work[start] = 2
        work[end] = 3
        work[0] = 4
        dfs2(sx, 1, work, tiles, sx, 0, start, dimx, dimy, 1)
        var visit: Int64 = 0
        bfstrim(start, work, tmp)
        return dfs3(start, end, work, visit, 0)

    @parameter
    fn part2_sub(p: Int):
        let end = ((dimy - 1) * dimx + fx) * gsize
        var vis: Int64 = tmp[p * 4 + 2].to_int()
        dst.max(dfs3(tmp[p * 4].to_int(), end, work, vis, tmp[p * 4 + 1].to_int()))

    @parameter
    fn part2_parallel() -> Int64:
        work.clear()
        let start = sx * gsize
        let end = ((dimy - 1) * dimx + fx) * gsize
        work[start] = 2
        work[end] = 3
        work[0] = 4
        dfs2(sx, 1, work, tiles, sx, 0, start, dimx, dimy, 1)
        bfstrim(start, work, tmp)
        let pcnt = dfs4(start, work, tmp)
        parallelize[part2_sub](pcnt, 10)
        return dst.value.to_int()

    minibench[part1]("part1")
    minibench[part2]("part2")
    minibench[part2_parallel]("part2_parallel")

    print(tiles.length(), "tokens", dimx, dimy)
    print(work.bytecount() + tmp.bytecount(), "work buffers")
