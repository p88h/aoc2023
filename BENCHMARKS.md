
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
mojo 0.6.0 (d55c0025)
```

```
Task                    Python      PyPy3       Mojo        Mojo parallel
Day1 Part1 old/naive    0.81 ms    [0.18 ms]    0.35 ms     0.05 ms (x12)
Day1 Part2 old/naive    8.92 ms    [0.89 ms]    1.21 ms     0.17 ms (x12)
Day1 Part1 optimized    0.70 ms     0.14 ms    [0.10 ms]    0.03 ms (x24)
Day1 Part2 optimized    2.86 ms     0.32 ms    [0.16 ms]    0.04 ms (x24)
Day2 Part1              0.30 ms    [0.10 ms]    0.13 ms     0.04 ms (x24)
Day2 Part2              0.30 ms    [0.10 ms]    0.13 ms     0.04 ms (x24)
Day3 Parser             0.62 ms     0.04 ms    [0.03 ms]    n/a
Day3 Part1              0.37 ms     0.04 ms    [6.85 μs]    n/a
Day3 Part2              0.81 ms     0.05 ms    [0.01 ms]    n/a
Day4 Parser             0.40 ms     0.22 ms    [0.07 ms]    n/a
Day4 Part1              0.08 ms     0.04 ms    [0.95 μs]    n/a
Day4 Part2              0.12 ms     0.05 ms    [1.05 μs]    n/a
Day5 Parser             0.06 ms     0.05 ms    [0.03 ms]    n/a
Day5 Part1              0.04 ms     3.81 μs    [1.88 μs]    n/a
Day5 Part2              0.22 ms     0.10 ms    [6.47 μs]    n/a
Day6 Part1              1.40 μs    [0.21 μs]    0.50 μs     n/a
Day6 Part2              0.57 μs     0.20 μs    [0.10 μs]    n/a
```