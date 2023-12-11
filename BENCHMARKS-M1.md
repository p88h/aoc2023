
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
Task             Python      PyPy3       Mojo       parallel    * speedup
Day01 part1     1.16 ms     0.23 ms     7.71 μs     0.07 ms     * 30 - 150
Day01 part2     4.97 ms     0.51 ms     0.07 ms     0.11 ms     * 7 - 72
Day02 part1     0.41 ms     0.16 ms     0.12 ms     0.04 ms     * 3 - 9
Day02 part2     0.41 ms     0.16 ms     0.12 ms     0.04 ms     * 3 - 9
Day03 parse     0.97 ms     0.16 ms     0.03 ms     nan         * 4 - 29
Day03 part1     0.50 ms     0.06 ms     7.85 μs     nan         * 7 - 63
Day03 part2     1.22 ms     0.09 ms     0.02 ms     nan         * 5 - 64
Day04 parse     0.64 ms     0.34 ms     0.02 ms     nan         * 13 - 25
Day04 part1     0.11 ms     0.07 ms     0.36 μs     nan         * 185 - 310
Day04 part2     0.16 ms     0.07 ms     0.68 μs     nan         * 100 - 234
Day05 parse     0.10 ms     0.06 ms     0.02 ms     nan         * 2 - 4
Day05 part1     0.08 ms     5.98 μs     4.94 μs     nan         * 1 - 15
Day05 part2     0.35 ms     0.13 ms     8.04 μs     nan         * 16 - 43
Day06 part1     1.89 μs     0.35 μs     0.28 μs     nan         * 1 - 6
Day06 part2     0.81 μs     0.29 μs     0.10 μs     nan         * 2 - 7
Day07 part1     1.75 ms     0.73 ms     0.19 ms     nan         * 3 - 9
Day07 part2     1.79 ms     0.76 ms     0.19 ms     nan         * 4 - 9
Day08 parse     0.26 ms     0.11 ms     2.87 μs     nan         * 37 - 89
Day08 part1     0.78 ms     0.10 ms     0.03 ms     nan         * 3 - 25
Day08 part2     7.15 ms     1.92 ms     0.26 ms     0.08 ms     * 23 - 89
Day09 parse     0.31 ms     0.11 ms     0.07 ms     nan         * 1 - 4
Day09 part1     1.93 ms     0.21 ms     4.76 μs     nan         * 43 - 406
Day09 part2     2.00 ms     0.20 ms     4.56 μs     nan         * 44 - 439
Day09sym parse  0.54 ms     0.14 ms     0.07 ms     nan         * 1 - 7
Day09sym part1  0.17 ms     6.77 μs     0.19 μs     nan         * 36 - 924
Day09sym part2  0.23 ms     7.45 μs     0.19 μs     nan         * 39 - 1214
Day10 part1     2.62 ms     1.09 ms     0.13 ms     nan         * 8 - 19
Day10 part2     1.77 ms     0.74 ms     0.04 ms     0.02 ms     * 36 - 87
Day11 part1     1.93 ms     0.32 ms     0.04 ms     nan         * 8 - 50
Day11 part2     1.97 ms     0.14 ms     0.04 ms     nan         * 3 - 51
Day11hv part1   0.55 ms     0.18 ms     0.01 ms     nan         * 13 - 42
Day11hv part2   0.55 ms     0.18 ms     0.01 ms     nan         * 13 - 42

Total          37.38 ms     8.99 ms     1.52 ms     nan         * 5 - 24
```
