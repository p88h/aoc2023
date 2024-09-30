from parser import *
from algorithm import parallelize
from wrappers import minibench
from array import Array
from utils.loop import unroll
from os.atomic import Atomic

alias T3 = Tuple[Int, Int, Int]
alias dirs = ((-1, 0, ord("<")), (1, 0, ord(">")), (0, -1, ord("^")), (0, 1, ord("v")))
alias cDot = ord(".")
alias cHash = ord("#")
alias gsize = 8


fn dfs1(x: Int, y: Int, inout path: Array[DType.int32], borrowed tiles: Parser, dimy: Int, dimx: Int, curl: Int) -> Int:
    var best: Int = 0
    if y == dimy - 1:  # final
        return curl
    path[y * dimx + x] = 1
    @parameter
    fn run1[i: Int]():
        nx = x + dirs.get[i, T3]().get[0, Int]()
        ny = y + dirs.get[i, T3]().get[1, Int]()
        dc = dirs.get[i, T3]().get[2, Int]()
        if (tiles[ny][nx] == cDot or tiles[ny][nx] == dc) and path[ny * dimx + nx] == 0:
            best = max(best, dfs1(nx, ny, path, tiles, dimy, dimx, curl + 1))
    unroll[run1, range(4)]()
    path[y * dimx + x] = 0
    return best


fn link(a: Int, b: Int, c: Int, inout graph: Array[DType.int32]):
    if graph[a] < 2:
        graph[a] = graph[0]
        graph[0] += 1
    if graph[b] < 2:
        graph[b] = graph[0]
        graph[0] += 1
    ai = graph[a + 1]
    graph[a + 2 + ai * 2] = b
    graph[a + 2 + ai * 2 + 1] = c
    graph[a + 1] = ai + 1
    bi = graph[b + 1]
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
    cur = (y * dimx + x) * gsize
    graph[cur] |= 1  # visited
    var cnt = 0
    @parameter
    fn run2[i: Int]():
        nx = x + dirs.get[i, T3]().get[0, Int]()
        ny = y + dirs.get[i, T3]().get[1, Int]()
        if tiles[ny][nx] != cHash and not (nx == px and ny == py):
            cnt += 1
    unroll[run2, range(4)]()
    if cnt > 1:
        link(cur, last, steps, graph)  # if a link exist, it's a branch point
        lnk = cur
        nsteps = 0
    @parameter
    fn run3[i: Int]():
        nx = x + dirs.get[i, T3]().get[0, Int]()
        ny = y + dirs.get[i, T3]().get[1, Int]()
        nc = (ny * dimx + nx) * gsize
        if (graph[nc] > 1) and not (nx == px and ny == py):
            link(nc, last, steps + 1, graph)
        elif tiles[ny][nx] != cHash and graph[nc] == 0:
            dfs2(nx, ny, graph, tiles, x, y, lnk, dimx, dimy, nsteps + 1)
    unroll[run3, range(4)]()


fn dfs4(cur: Int, tpath: Int, tdst: Int, lim: Int, borrowed graph: Array[DType.int32], inout paths: List[Int]):
    if lim == 0:
        paths.append(cur)
        paths.append(tdst)
        paths.append(tpath)
        return
    for i in range(graph[cur + 1]):
        next = int(graph[cur + 2 + 2 * i])
        dist = int(graph[cur + 2 + 2 * i + 1])
        if (tpath & (1 << int(graph[next]))) != 0:
            continue
        dfs4(next, tpath | (1 << int(graph[cur])), tdst + dist, lim - 1, graph, paths)

fn bfstrim(start: Int, inout graph: Array[DType.int32], inout stak: List[Int]):
    var si: Int = 0
    stak.append(start)
    while si < stak.size:
        cur = stak[si]
        si += 1
        for i in range(graph[cur + 1]):
            dst = graph[cur + 2 + 2 * i]
            if graph[dst + 1] == 3:
                for j in range(graph[dst + 1]):
                    if graph[dst + 2 + 2 * j] == cur:
                        graph[dst + 2 + 2 * j] = graph[dst + 6]
                        graph[dst + 2 + 2 * j + 1] = graph[dst + 7]
                        graph[dst + 1] -= 1
                stak.append(int(dst))


fn dfs3(cur: Int, end: Int, borrowed graph: Array[DType.int32], inout visited: Int64, steps: Int) -> Int:
    if cur == end:
        return steps
    visited |= 1 << int(graph[cur])
    var best = 0
    for i in range(graph[cur + 1]):
        dst = int(graph[cur + 2 + 2 * i])
        add = int(graph[cur + 2 + 2 * i + 1])
        if visited & (1 << int(graph[dst])) == 0:
            best = max(best, dfs3(dst, end, graph, visited, steps + add))
    visited ^= 1 << int(graph[cur])
    return best


fn main() raises:
    f = open("day23.txt", "r")
    tiles = make_parser["\n"](f.read())
    dimx = tiles.length()
    dimy = tiles[0].size
    sx = tiles[0].find(cDot)
    fx = tiles[dimy - 1].find(cDot)
    work = Array[DType.int32](dimx * dimy * gsize)
    tmp = List[Int](2048)
    var dst = Atomic[DType.int32](0)

    @parameter
    fn part1() -> Int64:
        work.zero()
        work[sx] = 1
        return dfs1(sx, 1, work, tiles, dimy, dimx, 1)

    @parameter
    fn part2() -> Int64:
        work.zero()
        start = sx * gsize
        end = ((dimy - 1) * dimx + fx) * gsize
        work[start] = 2
        work[end] = 3
        work[0] = 4
        dfs2(sx, 1, work, tiles, sx, 0, start, dimx, dimy, 1)
        var visit: Int64 = 0
        bfstrim(start, work, tmp)
        return dfs3(start, end, work, visit, 0)

    @parameter
    fn part2_sub(p: Int):
        end = ((dimy - 1) * dimx + fx) * gsize
        var vis: Int64 = tmp[p * 3 + 2]
        dst.max(dfs3(tmp[p * 3], end, work, vis, tmp[p * 3 + 1]))

    @parameter
    fn part2_parallel() -> Int64:
        work.zero()        
        start = sx * gsize
        end = ((dimy - 1) * dimx + fx) * gsize
        work[start] = 2
        work[end] = 3
        work[0] = 4
        dfs2(sx, 1, work, tiles, sx, 0, start, dimx, dimy, 1)
        tmp.clear()
        bfstrim(start, work, tmp)        
        tmp.clear()
        dfs4(start, 0, 0, 10, work, tmp)
        parallelize[part2_sub](tmp.size // 3, 24)
        return int(dst.value)

    minibench[part1]("part1")
    minibench[part2]("part2")
    minibench[part2_parallel]("part2_parallel")

    print(tiles.length(), "tokens", dimx, dimy, sx, fx)
    print(work.bytecount() + tmp.size, "work buffers")
