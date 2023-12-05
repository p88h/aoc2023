from algorithm import parallelize
import time
import benchmark

fn minibench[fun: fn () capturing -> None](label: StringLiteral, loops: Int = 100, unit: StringLiteral = "ns"):
    let start = time.now()
    for _ in range(loops):
        fun()
    let end = time.now()
    let avg = (end - start) / loops
    var div = 1
    if (unit == "μs"):
        div = 1000
    if (unit == "ms"):
        div = 1000000
    print(label, ":", avg / div, unit)

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
    print("using",workers,"parallel threads")
    minibench[part1]("part1", 1000, "ms")
    minibench[part1_parallel]("part1 parallel", 1000, "ms")
    minibench[part2]("part2", 1000, "ms")
    minibench[part2_parallel]("part2 parallel", 1000, "ms")
    
