
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
Task             Python      PyPy3       Mojo       parallel    * speedup
Day1 Part1      0.70 ms     0.14 ms    [6.23 μs]    0.02 ms     * 23 - 116
Day1 Part2      2.86 ms     0.32 ms    [0.05 ms]    0.02 ms     * 6 - 57
Day2 Part1      0.30 ms     0.10 ms    [0.03 ms]    9.59 μs     * 10 - 30
Day2 Part2      0.30 ms     0.10 ms    [0.03 ms]    9.71 μs     * 10 - 30
Day3 Parser     0.62 ms     0.04 ms    [0.03 ms]    n/a         * 1 - 20
Day3 Part1      0.37 ms     0.04 ms    [5.35 μs]    n/a         * 8 - 74
Day3 Part2      0.81 ms     0.05 ms    [0.01 ms]    n/a         * 5 - 81
Day4 Parser     0.40 ms     0.22 ms    [0.04 ms]    n/a         * 5 - 10
Day4 Part1      0.08 ms     0.04 ms    [0.23 μs]    n/a         * 173 - 347
Day4 Part2      0.12 ms     0.05 ms    [0.43 μs]    n/a         * 116 - 279
Day5 Parser     0.06 ms     0.05 ms    [9.73 μs]    n/a         * 5 - 6
Day5 Part1      0.04 ms     3.81 μs    [1.76 μs]    n/a         * 2 - 20
Day5 Part2      0.22 ms     0.10 ms    [5.53 μs]    n/a         * 20 - 40
Day6 Part1      1.40 μs     0.21 μs    [0.10 μs]    n/a         * 2 - 14
Day6 Part2      0.57 μs     0.20 μs    [0.04 μs]    n/a         * 5 - 14
Day7 Part1      1.06 ms     0.48 ms    [0.05 ms]    n/a         * 9 - 21
Day7 Part2      1.10 ms     0.50 ms    [0.05 ms]    n/a         * 10 - 22
Day8 Parse      0.15 ms     0.06 ms    [2.75 μs]    n/a         * 20 - 60
Day8 Part1      0.46 ms     0.05 ms    [0.02 ms]    n/a         * 2 - 23
Day8 Part2      4.38 ms     1.29 ms    [0.17 ms]    0.04 ms     * 32 - 109
Day9sym Prep    0.34 ms     0.08 ms    [0.03 ms]    n/a         * 2 - 6
Day9sym Part1   0.11 ms     3.61 μs    [0.16 μs]    n/a         * 22 - 687
Day9sym Part2   0.14 ms     4.95 μs    [0.16 μs]    n/a         * 30 - 875
Day10 Part1     1.76 ms     0.58 ms    [0.08 ms]    n/a         * 7 - 22
Day10 Part2     1.23 ms     0.47 ms    [0.04 ms]    0.015 ms    * 31 - 82
Day11 Part1     1.19 ms     0.19 ms    [0.02 ms]    n/a         * 5 - 80
Day11 Part2     1.24 ms     0.19 ms    [0.02 ms]    n/a         * 5 - 80

TOTAL          15.68 ms     4.16 ms    [0.62 ms]    n/a         * 6 - 25
```