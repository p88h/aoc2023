import time

def minibench(fns, loops = 100):
    for key in fns:
        start = time.time()
        t = 0
        for _ in range(loops):
            t += fns[key]()
        end = time.time()
        print(key,":", ((end - start)*1000) / loops ,"ms")
