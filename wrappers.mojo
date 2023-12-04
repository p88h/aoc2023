from algorithm import parallelize
import benchmark


fn run_multiline_task[f1: fn (Int, /) capturing -> None, f2: fn (Int, /) capturing -> None]
    (len: Int, disp: fn () capturing -> None, workers: Int = 12):
    @parameter
    fn part1():
        for l in range(len):
            f1(l)

    @parameter
    fn part1_parallel():
        parallelize[f1](len, workers)

    @parameter
    fn part2():
        for l in range(len):
            f2(l)

    @parameter
    fn part2_parallel():
        parallelize[f2](len, workers)

    part1()
    part2()
    disp()

    print("part1 :", benchmark.run[part1]().mean["ms"](), "ms")
    print("part1_parallel:", benchmark.run[part1_parallel]().mean["ms"](), "ms")
    print("part1 :", benchmark.run[part2]().mean["ms"](), "ms")
    print("part2_parallel:", benchmark.run[part2_parallel]().mean["ms"](), "ms")
