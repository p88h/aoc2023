from parser import *
from wrappers import minibench
from memory.buffer import Buffer
from math import min

@always_inline
fn trisum(rem: Int, odds: Int) -> Int:
    let fullsum = (rem) * (1 + rem) // 2
    let evensum = (rem // 2) * (1 + rem // 2)
    if odds:
        return fullsum - evensum
    else:
        return evensum

@always_inline
fn oddcnt(rem: Int, odds: Int) -> Int:
    if rem % 2 == 0:
        return rem // 2
    return rem // 2 + odds

fn main() raises:
    let f = open("day21.txt", "r")
    let tiles = make_parser["\n"](f.read())
    let dimx = tiles.length()
    let dimy = tiles[0].size
    alias maxq = 256*1024
    alias maxw = 144
    let work = Buffer[maxq, DType.int16].aligned_stack_allocation[32]()
    let visited = Buffer[maxw * maxw * 9, DType.int16].aligned_stack_allocation[32]()
    let start: Int64

    @parameter
    fn parse() -> Int64:
        alias cS = ord("S")
        for y in range(dimy):
            for x in range(dimx):
                if tiles[y][x] == cS:
                    return (y << 16) + x
        return -1

    @parameter
    fn bfs(start: Int32, steps: Int, limx: Int, limy: Int) -> Int64:
        alias cHash = ord("#")
        alias dirs = VariadicList[Tuple[Int, Int]]((-1, 0), (1, 0), (0, -1), (0, 1))
        let sy = start.to_int() >> 16
        let sx = start.to_int() & 0xFFFF
        var current = 0
        var limit = 2
        var total = 0
        work[0] = sy
        work[1] = sx
        visited.zero()
        while current < limit:  # aaand ?
            let y = work[current].to_int()
            let x = work[current + 1].to_int()
            let p = y * limx + x
            let distance = visited[p]
            # ... and break here
            if distance > steps or distance > 2 * dimx + 1:
                break
            current += 2
            if dimx == limx and distance % 2 == steps % 2:
                total += 1

            @parameter
            fn maybe_add[ndir: Int]():
                let nx = x + dirs[ndir].get[0, Int]()
                let ny = y + dirs[ndir].get[1, Int]()
                if nx < 0 or nx >= limx or ny < 0 or ny >= limy:
                    return
                let np = ny * limx + nx
                if tiles[ny % dimy][nx % dimx] == cHash or visited[np] != 0:
                    return
                visited[np] = distance + 1
                work[limit] = ny
                work[limit + 1] = nx
                limit += 2

            maybe_add[0]()
            maybe_add[1]()
            maybe_add[2]()
            maybe_add[3]()

        if dimx == limx:
            return total

        for y in range(dimy):
            for x in range(dimx):
                let cp = (y + dimx) * limx + x + dimx
                if visited[cp] == 0 and not (x + dimx == sx and y + dimy == sy):
                    continue
                let ofs1 = VariadicList[Tuple[Int, Int]]((-1, 0), (1, 0), (0, -1), (0, 1))
                for i in range(4):
                    let np = cp + dimx * ofs1[i].get[0, Int]() + dimx * limx * ofs1[i].get[1, Int]()
                    let cd = visited[np].to_int()
                    let rem = (steps - cd) // dimx
                    total += oddcnt(rem + 1, cd % 2)
                let ofs2 = VariadicList[Tuple[Int, Int]]((-1, -1), (-1, 1), (1, -1), (1, 1))
                for i in range(4):
                    let np = cp + dimx * ofs2[i].get[0, Int]() + dimx * limx * ofs2[i].get[1, Int]()
                    if visited[np] == 0:
                        let np1 = cp + dimx * ofs2[i].get[0, Int]()
                        let np2 = cp + dimx * limx * ofs2[i].get[1, Int]()
                        visited[np] = min(visited[np1], visited[np2]) + dimx
                    let cd = visited[np].to_int()
                    let rem = (steps - cd) // dimx
                    total += trisum(rem + 1, cd % 2)
                total += visited[cp].to_int() % 2
        return total

    @parameter
    fn part1() -> Int64:
        return bfs(start.to_int(), 64, dimx, dimy)

    @parameter
    fn part2() -> Int64:
        let ofs = (dimy << 16) + dimx
        return bfs(start.to_int() + ofs, 26501365, dimx * 3, dimy * 3)

    start = parse()
    minibench[part1]("part1")
    minibench[part2]("part2")

    print(tiles.length(), "tokens", dimx, dimy)
    print(work.bytecount() + visited.bytecount(), "work buffers")
