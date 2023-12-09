
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
Task             Python      PyPy3       Mojo        Mojo parallel
Day1 Part1      0.70 ms     0.14 ms    [6.23 μs]    0.02 ms (x24)
Day1 Part2      2.86 ms     0.32 ms    [0.05 ms]    0.02 ms (x24)
Day2 Part1      0.30 ms     0.10 ms    [0.03 ms]    9.59 μs (x24)
Day2 Part2      0.30 ms     0.10 ms    [0.03 ms]    9.71 μs (x24)
Day3 Parser     0.62 ms     0.04 ms    [0.03 ms]    n/a
Day3 Part1      0.37 ms     0.04 ms    [5.35 μs]    n/a
Day3 Part2      0.81 ms     0.05 ms    [0.01 ms]    n/a
Day4 Parser     0.40 ms     0.22 ms    [0.04 ms]    n/a
Day4 Part1      0.08 ms     0.04 ms    [0.23 μs]    n/a
Day4 Part2      0.12 ms     0.05 ms    [0.43 μs]    n/a
Day5 Parser     0.06 ms     0.05 ms    [9.73 μs]    n/a
Day5 Part1      0.04 ms     3.81 μs    [1.76 μs]    n/a
Day5 Part2      0.22 ms     0.10 ms    [5.53 μs]    n/a
Day6 Part1      1.40 μs     0.21 μs    [0.10 μs]    n/a
Day6 Part2      0.57 μs     0.20 μs    [0.04 μs]    n/a
Day7 Part1      1.06 ms     0.48 ms    [0.05 ms]    n/a
Day7 Part2      1.10 ms     0.50 ms    [0.05 ms]    n/a
Day8 Parse      0.15 ms     0.06 ms    [2.75 μs]    n/a
Day8 Part1      0.46 ms     0.05 ms    [0.02 ms]    n/a
Day8 Part2      4.38 ms     1.29 ms    [0.17 ms]    0.04 ms (x6)
Task             Python      PyPy3       Mojo        Mojo parallel  * vs PyPy3 / Python
Day9 Parser     0.19 ms     0.07 ms    [0.03 ms]    n/a             * 2 - 6
Day9 Part1      1.28 ms     0.14 ms    [2.05 μs]    n/a             * 68 - 620
Day9 Part2      1.30 ms     0.14 ms    [2.05 μs]    n/a             * 68 - 630
```