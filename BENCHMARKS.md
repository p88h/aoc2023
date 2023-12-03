
All benchmarks running on 12-core / 24-thread Intel Core I7-13700K

OS: Win11 + WSL2 / Ubuntu 23.04 

Compilers:
```
$ python --version
Python 3.11.4
$ pypy3 --version
Python 3.9.16 (7.3.11+dfsg-2, Feb 06 2023, 23:22:49)
[PyPy 7.3.11 with GCC 12.2.0]
$ mojo --version
mojo 0.5.0 (6e50a738)
```

```
Task                    Python      PyPy3       Mojo        Mojo 
Day1 Part1 old/naive    0.81 ms    [0.18 ms]    0.35 ms     0.05 ms (x12)
Day1 Part2 old/naive    8.92 ms    [0.89 ms]    1.21 ms     0.17 ms (x12)
Day1 Part1 optimized    0.70 ms     0.26 ms    [0.12 ms]    0.04 ms (x12)
Day1 Part2 optimized    2.86 ms     0.41 ms    [0.12 ms]    0.03 ms (x12)
Day2 Part1              0.30 ms    [0.12 ms]    0.26 ms     0.14 ms (x4)
Day2 Part2              0.30 ms    [0.11 ms]    0.26 ms     0.15 ms (x4)
Day3 Parser             0.70 ms     0.09 ms    [0.02 ms]    n/a
Day3 Part1              0.42 ms     0.06 ms    [0.01 ms]    n/a
Day3 Part2              0.88 ms     0.10 ms    [0.01 ms]    n/a
```