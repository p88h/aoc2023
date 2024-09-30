# See https://github.com/modularml/mojo/issues/3579

from array import Array
from testing import assert_true

alias maxc = 16
alias maxn = 1600

fn main() raises:
    graph = Array[DType.int16](maxn * maxn)
    marks = Array[DType.int32](maxn * maxn)
    prev = Array[DType.int16](maxn)
    work = Array[DType.int16](maxn)
    var mark = 0
    graph.zero()
    marks.zero()

    # compute a bfs path from src to tgt
    # if tgt not specified, a path to somewhere farthest from src.
    @parameter
    fn bfs(src: Int, tgt: Int = -1) raises -> Int:
        work[0] = src
        var ss = 1
        var si = 0
        while si < ss:
            cur = int(work[si])
            si += 1
            assert_true(cur == 0)
            assert_true(graph[0] == 0)
            # uncommenting this assert makes the (sample) code run properly
            # assert_true(graph[cur] == 0)
            for di in range(graph[cur]):
                assert_true(cur * maxc == 0)
                # while the above is true, the code does not crash with the term removed below
                dst = int(graph[cur * maxc + 1 + di])
                assert_true(dst == 0)
                assert_true(cur * maxn + dst == 0)
                # this assert also helps survive the crash
                # assert_true(marks[cur * maxn + dst] == mark)
                if marks[cur * maxn + dst] != mark and prev[dst] < 0:
                    # and similarly, removing this assert makes the crash go away...
                    # assert_true(False)
                    assert_true(ss == 1)
                    work[ss] = dst
                    ss += 1
        return ss

    @parameter
    fn part1() raises -> Int64:
        return bfs(0, -1)

    print(part1())

    # without these, it likely crashes for different reasons. 
    print(graph.bytecount(), "graph size", mark)
    print(marks.bytecount() + prev.bytecount() + work.bytecount() , "work buffers size")
