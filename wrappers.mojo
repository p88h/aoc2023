from algorithm import parallelize
import time
import benchmark

fn minibench[fun: fn () capturing -> None](label: StringLiteral, loops: Int = 100):
    let units = VariadicList[StringLiteral]("ns", "μs", "ms", "s")
    var start = time.now()
    var end = start
    var sloop = loops // 10
    while end - start < 1000000000:
        sloop *= 10
        start = time.now()
        for _ in range(sloop):
            fun()
        end = time.now()
    
    let avg = (end - start) / sloop    
    var div = 1
    var pos = 0

    while avg / div >= 10:
        div *= 1000
        pos += 1
    
    let unit = units[pos]

    print(label, ":", avg / div, unit, "(", sloop, "loops )")

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
    minibench[part1]("part1")
    minibench[part1_parallel]("part1 parallel")
    minibench[part2]("part2")
    minibench[part2_parallel]("part2 parallel")
    
