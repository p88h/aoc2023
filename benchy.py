import time


def minibench(fns, loops=100):
    units = ["s", "ms", "μs", "ns"]
    for key in fns:
        sloop = loops // 10
        start = end = 0
        while end - start < 3:
            sloop *= 10
            start = time.time()
            t = 0
            for _ in range(sloop):
                t += fns[key]()
            end = time.time()
        ofs = 0
        div = 1
        while (end - start) * div / sloop < 0.01:
            ofs += 1
            div *= 1000
        print("{}\t {} {} ({} loops)".format(key, ((end - start) * div) / sloop, units[ofs], sloop))

#def foo():
#    time.sleep(0.01)
#    return 1
#minibench({"sleep": foo})