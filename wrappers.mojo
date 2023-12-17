from algorithm import parallelize
import time
import benchmark

fn minibench[fun: fn () capturing -> Int64](label: StringLiteral, loops: Int = 100):
    let units = VariadicList[StringLiteral]("ns", "μs", "ms", "s")
    var start = time.now()
    var end = start
    var sloop = loops // 10
    var t : Int64 = 0
    while sloop <= 100000000 and end - start < 1000000000:
        sloop *= 10
        start = time.now()
        t = 0
        for _ in range(sloop):
            t += fun()
        end = time.now()
    
    let avg = (end - start) / sloop
    var div = 1
    var pos = 0

    while avg / div >= 10:
        div *= 1000
        pos += 1
    
    let unit = units[pos]
    print(fun())
    print(label, ":", avg / div, unit, "(", sloop, "loops ) avg", t // sloop,"mod",t % sloop)

fn run_multiline_task[f1: fn (Int, /) capturing -> None, f2: fn (Int, /) capturing -> None]
    (len: Int, disp: fn () capturing -> None, workers: Int = 12):
    @parameter
    fn part1() -> Int64:
        for l in range(len):
            f1(l)
        return 1

    @parameter
    fn part1_parallel() -> Int64:
        parallelize[f1](len, workers)
        return workers

    @parameter
    fn part2() -> Int64:
        for l in range(len):
            f2(l)
        return 1

    @parameter
    fn part2_parallel() -> Int64:
        parallelize[f2](len, workers)
        return workers

    _ = part1()
    _ = part2()
    disp()
    print("using",workers,"parallel threads")
    minibench[part1]("part1")
    minibench[part1_parallel]("part1 parallel")
    minibench[part2]("part2")
    minibench[part2_parallel]("part2 parallel")
    
# test the benchmark accuracy (or, well, sleep acuracy, since you can't sleep for <~100 usec reliably)
fn main():
    fn sleep20usec() -> Int64:
        time.sleep(0.00002)
        return 1

    fn sleep100usec() -> Int64:
        time.sleep(0.0001)
        return 1

    fn sleep500usec() -> Int64:
        time.sleep(0.0005)
        return 1

    fn sleep10ms() -> Int64:
        time.sleep(0.01)
        return 1

    fn sleep50ms() -> Int64:
        time.sleep(0.05)
        return 1

    minibench[sleep20usec]("sleep20usec")
    minibench[sleep100usec]("sleep100usec")
    minibench[sleep500usec]("sleep500usec")
    minibench[sleep10ms]("sleep10ms")
    minibench[sleep50ms]("sleep50ms")
