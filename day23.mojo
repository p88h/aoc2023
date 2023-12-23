from parser import *
from wrappers import minibench
from array import Array
from math import max

alias dirs = VariadicList[Tuple[Int,Int,Int]]((-1,0,ord('<')),(1,0,ord('>')),(0,-1,ord('^')),(0,1,ord('v')))
alias cDot = ord('.')
alias cHash = ord('#')
alias gsize = 8

fn dfs1(x: Int,y : Int, inout path: Array[DType.int32], borrowed tiles: Parser, dimy: Int, dimx: Int, curl: Int) -> Int:
    var best : Int = 0
    if y == dimy - 1: # final
        return curl
    path[y * dimx + x] = 1
    for i in range(4):
        let nx = x + dirs[i].get[0, Int]()
        let ny = y + dirs[i].get[1, Int]()
        let dc = dirs[i].get[2, Int]()
        if (tiles[ny][nx] == cDot or tiles[ny][nx] == dc) and path[ny * dimx + nx] == 0:
            best = max(best, dfs1(nx,ny, path, tiles, dimy, dimx, curl + 1))
    path[y * dimx + x] = 0
    return best

fn link(a: Int, b: Int, c: Int, inout graph: Array[DType.int32]):
    graph[a] |= 2 # branch
    graph[b] |= 2 
    let ai = graph[a + 1]
    graph[a + 2 + ai * 2] = b
    graph[a + 2 + ai * 2 + 1] = c
    graph[a + 1] = ai + 1
    let bi = graph[b + 1]
    graph[b + 2 + bi * 2] = a
    graph[b + 2 + bi * 2 + 1] = c
    graph[b + 1] = bi + 1
    # print("link",a//(141*8),(a//8)%141,ai,",",b//(141*8),(b//8)%141,bi,"=",c)

fn dfs2(x: Int, y: Int, inout graph: Array[DType.int32], borrowed tiles: Parser, 
        px: Int, py: Int, last: Int, dimx: Int, dimy: Int, steps: Int):
    var nsteps = steps
    var lnk = last
    let cur = (y * dimx + x) * gsize
    graph[cur] |= 1 # visited
    var cnt = 0
    for i in range(4):
        let nx = x + dirs[i].get[0,Int]()
        let ny = y + dirs[i].get[1,Int]()
        if tiles[ny][nx] != cHash and not (nx == px and ny == py):
            cnt += 1
    if cnt > 1:
        link(cur, last, steps, graph) # if a link exist, it's a branch point
        lnk = cur
        nsteps = 0
    for i in range(4):
        let nx = x + dirs[i].get[0,Int]()
        let ny = y + dirs[i].get[1,Int]()
        let nc = (ny * dimx + nx) * gsize
        if (graph[nc] & 2) != 0 and not (nx == px and ny == py):
            link(nc, last, steps+1, graph)
        elif tiles[ny][nx] != cHash and graph[nc] == 0:
            dfs2(nx, ny, graph, tiles, x, y, lnk, dimx, dimy, nsteps + 1)

fn dfs3(cur: Int,end: Int,inout graph: Array[DType.int32],steps: Int) -> Int:
    if cur == end:
        return steps
    graph[cur] |= 4
    var best = 0
    for i in range(graph[cur+1]):
        let dst = graph[cur + 2 + 2 * i].to_int()
        let add = graph[cur + 2 + 2 * i + 1].to_int()
        if (graph[dst] & 4) == 0:
            best = max(best, dfs3(dst, end, graph, steps + add))
    graph[cur] ^= 4
    return best

fn main() raises:
    let f = open("day23.txt", "r")
    let tiles = make_parser["\n"](f.read())
    let dimx = tiles.length()
    let dimy = tiles[0].size
    let sx = tiles[0].find(cDot)
    let fx = tiles[dimy-1].find(cDot)
    let work = Array[DType.int32](dimx * dimy * gsize)

    @parameter
    fn part1() -> Int64:
        work.clear()
        work[sx] = 1
        return dfs1(sx, 1, work, tiles, dimy, dimx, 1)

    @parameter
    fn part2() -> Int64:
        work.clear()
        let start = sx * gsize
        let end = ((dimy - 1)*dimx + fx) * gsize
        work[start] = work[end] = 2 # make start & end branch points
        dfs2(sx, 1, work, tiles, sx, 0, start, dimx, dimy, 1)
        return dfs3(start, end, work, 0)

    minibench[part1]("part1")
    minibench[part2]("part2")

    print(tiles.length(), "tokens", dimx, dimy)
    print(work.bytecount(), "work buffers")
