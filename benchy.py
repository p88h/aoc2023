import time


def minibench(fns, loops=100):
    units = ["s","ms","μs","ns"]
    for key in fns:
        start = time.time()
        t = 0
        for _ in range(loops):
            t += fns[key]()
        end = time.time()
        ofs = 0
        div = 1
        while ((end - start) * div / loops < 0.01):
            ofs += 1
            div *= 1000
        print(key, ":", ((end - start) * div) / loops, units[ofs])
