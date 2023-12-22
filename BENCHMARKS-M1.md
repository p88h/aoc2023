
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
Day12 part1     8.99 ms     2.06 ms     0.64 ms     0.17 ms     * 12 - 53
Day12 part2     0.20 s      0.05 s      3.58 ms     0.74 ms     * 66 - 268
Day13 parse     1.56 ms     0.09 ms     0.03 ms     nan         * 2 - 50
Day13 part1     0.23 ms     9.38 μs     1.58 μs     nan         * 5 - 143
Day13 part2     0.30 ms     0.02 ms     2.81 μs     nan         * 8 - 106
Day14 parse     1.59 ms     0.33 ms     0.03 ms     nan         * 10 - 50
Day14 part1     0.40 ms     0.07 ms     7.93 μs     nan         * 8 - 49
Day14 part2     0.28 s      0.05 s      8.02 ms     nan         * 6 - 34
Day15 part1     1.38 ms     0.16 ms     0.02 ms     nan         * 7 - 67
Day15 part2     1.74 ms     0.47 ms     0.05 ms     nan         * 9 - 33
Day16 part1     3.29 ms     2.05 ms     0.05 ms     nan         * 39 - 63
Day16 part2     0.66 s      0.42 s      0.01 s      1.85 ms     * 226 - 356
Day17 part1     0.11 s      0.02 s      2.10 ms     nan         * 9 - 53
Day17 part2     0.29 s      0.06 s      4.50 ms     nan         * 13 - 63
Day18 part1     0.13 ms     0.03 ms     3.35 μs     nan         * 9 - 40
Day18 part2     0.23 ms     0.07 ms     3.59 μs     nan         * 19 - 64
Day19 parse     1.10 ms     0.43 ms     0.04 ms     nan         * 9 - 25
Day19 part1     0.15 ms     0.06 ms     6.54 μs     nan         * 9 - 23
Day19 part2     0.40 ms     0.07 ms     7.36 μs     nan         * 9 - 54
Day20 parse     0.05 ms     0.02 ms     2.20 μs     nan         * 7 - 22
Day20 part1     0.02 s      2.12 ms     0.25 ms     nan         * 8 - 71
Day20 part2     0.07 s      8.27 ms     0.45 ms     nan         * 18 - 157
Day21 part1     5.67 ms     1.61 ms     0.10 ms     nan         * 16 - 56
Day21 part2     0.23 s      0.06 s      2.10 ms     nan         * 26 - 110
Day22 parse     0.81 ms     0.82 ms     0.17 ms     nan         * 4 - 4
Day22 part1     0.03 s      5.44 ms     0.19 ms     nan         * 28 - 139
Day22 part2     6.56 ms     0.74 ms     0.11 ms     nan         * 6 - 59

Total        1950.34 ms   688.92 ms    35.76 ms    22.31 ms     * 30 - 87
```
