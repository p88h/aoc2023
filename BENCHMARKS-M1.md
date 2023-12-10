
All benchmarks running on 10 core Apple M1 Pro

OS: OS X Sonoma 14.1.1

Compilers:
```
$ python --version
Python 3.11.6
$ pypy3 --version
Python 3.10.13 (f1607341da97ff5a1e93430b6e8c4af0ad1aa019, Oct 09 2023, 18:49:30)
[PyPy 7.3.13 with GCC Apple LLVM 15.0.0 (clang-1500.0.40.1)]
$ mojo --version
mojo 0.6.0 (d55c0025)
```

```
Task             Python      PyPy3       Mojo       parallel  * speedup
Day1 Part1      1.15 ms     0.23 ms    [7.53 μs]    0.06 ms   * 30 - 150 '
Day1 Part2      4.99 ms     0.52 ms    [0.07 ms]    0.11 ms   * 7 - 70 ''
Day2 Part1      0.40 ms     0.16 ms    [0.09 ms]    0.03 ms   * 5 - 13 '
Day2 Part2      0.41 ms     0.16 ms    [0.09 ms]    0.03 ms   * 5 - 13 '
Day3 Parser     0.97 ms     0.08 ms    [0.03 ms]    n/a       * 3 - 32
Day3 Part1      0.49 ms     0.06 ms    [7.96 μs]    n/a       * 8 - 60
Day3 Part2      1.22 ms     0.09 ms    [0.02 ms]    n/a       * 2 - 60s
Day4 Parser     0.64 ms     0.34 ms    [0.03 ms]    n/a       * 10 - 20
Day4 Part1      0.11 ms     0.06 ms    [0.35 μs]    n/a       * 142 - 314
Day4 Part2      0.16 ms     0.07 ms    [0.68 μs]    n/a       * 100 - 200
Day5 Parser     0.10 ms     0.06 ms    [0.02 ms]    n/a       * 3 - 5
Day5 Part1      0.07 ms     5.90 μs    [3.74 μs]    n/a       * 1.5 - 18
Day5 Part2      0.35 ms     0.14 ms    [8.04 μs]    n/a       * 17 - 43
Day6 Part1      1.91 μs     0.36 μs    [0.22 μs]    n/a       * 1.5 - 10
Day6 Part2      0.81 μs     0.29 μs    [0.08 μs]    n/a       * 3 - 10
Day7 Part1      1.75 ms     0.74 ms    [0.13 ms]    n/a       * 5 - 13
Day7 Part2      1.79 ms     0.77 ms    [0.13 ms]    n/a       * 5 - 13
Day8 Parse      0.26 ms     0.11 ms    [2.97 μs]    n/a       * 36 - 86
Day8 Part1      0.77 ms     0.10 ms    [0.03 ms]    n/a       * 3 - 23
Day8 Part2      7.09 ms     1.93 ms    [0.25 ms]    0.09 ms   * 21 - 78 ' 
Day9 Parser     0.30 ms     0.12 ms    [0.07 ms]    n/a       * 2-4               
Day9 Part1      1.93 ms     0.21 ms    [3.37 μs]    n/a       * 62 - 570
Day9 Part2      2.06 ms     0.20 ms    [3.17 μs]    n/a       * 63 - 650
Day9sym Prep    0.53 ms     0.14 ms    [0.07 ms]    n/a       * 2 - 7
Day9sym Part1   0.17 ms     6.85 μs    [0.18 μs]    n/a       * 38 - 944
Day9sym Part2   0.23 ms     7.50 μs    [0.18 μs]    n/a       * 41 - 1277

' - uses parallel version (faster) as comparison
'' - uses non-parallel version (faster) as comparison
```
