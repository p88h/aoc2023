
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
Day01 part1     1.16 ms     0.23 ms     7.11 μs     0.09 ms     * 32 - 163
Day01 part2     5.01 ms     0.52 ms     0.07 ms     0.11 ms     * 7 - 73
Day02 part1     0.41 ms     0.16 ms     0.11 ms     0.03 ms     * 5 - 13
Day02 part2     0.41 ms     0.16 ms     0.11 ms     0.03 ms     * 5 - 13
Day03 parse     0.97 ms     0.08 ms     0.03 ms     nan         * 2 - 30
Day03 part1     0.49 ms     0.06 ms     8.11 μs     nan         * 6 - 60
Day03 part2     1.22 ms     0.09 ms     0.02 ms     nan         * 4 - 64
Day04 parse     0.64 ms     0.34 ms     0.02 ms     nan         * 13 - 25
Day04 part1     0.11 ms     0.07 ms     0.21 μs     nan         * 314 - 531
Day04 part2     0.16 ms     0.07 ms     0.70 μs     nan         * 95 - 229
Day05 parse     0.10 ms     0.06 ms     0.02 ms     nan         * 3 - 4
Day05 part1     0.08 ms     5.92 μs     5.10 μs     nan         * 1 - 14
Day05 part2     0.35 ms     0.14 ms     8.03 μs     nan         * 16 - 43
Day06 part1     1.91 μs     0.36 μs     0.27 μs     nan         * 1 - 7
Day06 part2     0.81 μs     0.29 μs     0.10 μs     nan         * 2 - 8
Day07 part1     1.73 ms     0.72 ms     0.06 ms     nan         * 11 - 28
Day07 part2     1.78 ms     0.75 ms     0.06 ms     nan         * 11 - 28
Day08 parse     0.26 ms     0.11 ms     2.95 μs     nan         * 36 - 88
Day08 part1     0.78 ms     0.10 ms     0.03 ms     nan         * 3 - 25
Day08 part2     7.06 ms     1.93 ms     0.26 ms     0.10 ms     * 18 - 69
Day09 parse     0.31 ms     0.11 ms     0.07 ms     nan         * 1 - 4
Day09 part1     1.93 ms     0.21 ms     4.71 μs     nan         * 43 - 410
Day09 part2     2.01 ms     0.20 ms     4.84 μs     nan         * 42 - 415
Day09sym parse  0.53 ms     0.14 ms     0.07 ms     nan         * 1 - 7
Day09sym part1  0.17 ms     6.78 μs     0.19 μs     nan         * 36 - 916
Day09sym part2  0.23 ms     7.51 μs     0.19 μs     nan         * 39 - 1208
Day10 part1     2.63 ms     1.05 ms     0.13 ms     nan         * 7 - 20
Day10 part2     1.79 ms     0.74 ms     0.02 ms     0.03 ms     * 30 - 74
Day11 part1     1.91 ms     0.32 ms     0.04 ms     nan         * 8 - 49
Day11 part2     1.96 ms     0.14 ms     0.04 ms     nan         * 3 - 51
Day11hv part1   0.55 ms     0.18 ms     0.01 ms     nan         * 13 - 42
Day11hv part2   0.55 ms     0.18 ms     0.01 ms     nan         * 13 - 41
Day12 part1     8.97 ms     2.02 ms     0.64 ms     0.16 ms     * 12 - 55
Day12 part2     0.20 s      0.05 s      3.61 ms     0.74 ms     * 65 - 271
Day13 parse     1.50 ms     0.14 ms     0.03 ms     nan         * 4 - 49
Day13 part1     0.22 ms     9.13 μs     1.55 μs     nan         * 5 - 141
Day13 part2     0.29 ms     0.02 ms     2.39 μs     nan         * 9 - 120
Day14 parse     1.59 ms     0.33 ms     0.02 ms     nan         * 13 - 64
Day14 part1     0.40 ms     0.07 ms     7.26 μs     nan         * 9 - 55
Day14 part2     0.27 s      0.05 s      6.66 ms     nan         * 8 - 40
Day15 part1     1.36 ms     0.16 ms     0.02 ms     nan         * 7 - 63
Day15 part2     1.70 ms     0.47 ms     0.04 ms     nan         * 10 - 38
Day16 part1     3.35 ms     2.06 ms     0.05 ms     nan         * 40 - 66
Day16 part2     0.66 s      0.41 s      0.01 s      1.83 ms     * 223 - 363
Day17 part1     0.08 s      0.01 s      1.59 ms     nan         * 8 - 49
Day17 part2     0.20 s      0.04 s      3.47 ms     nan         * 10 - 57
Day18 part1     0.14 ms     0.03 ms     3.31 μs     nan         * 9 - 41
Day18 part2     0.23 ms     0.07 ms     3.58 μs     nan         * 19 - 63
Day19 parse     1.10 ms     0.43 ms     0.04 ms     nan         * 9 - 25
Day19 part1     0.15 ms     0.06 ms     6.57 μs     nan         * 9 - 23
Day19 part2     0.40 ms     0.07 ms     7.37 μs     nan         * 9 - 54
Day20 parse     0.05 ms     0.02 ms     2.58 μs     nan         * 6 - 18
Day20 part1     0.02 s      2.11 ms     0.24 ms     nan         * 8 - 75
Day20 part2     0.07 s      8.31 ms     0.41 ms     nan         * 20 - 171
Day21 part1     5.63 ms     1.62 ms     0.10 ms     nan         * 15 - 55
Day21 part2     0.23 s      0.06 s      2.14 ms     nan         * 26 - 109
Day22 parse     1.00 ms     0.82 ms     0.18 ms     nan         * 4 - 5
Day22 part1     1.42 ms     0.31 ms     0.03 ms     nan         * 11 - 53
Day22 part2     6.57 ms     0.73 ms     0.11 ms     nan         * 6 - 58
Day23 part1     0.08 s      0.04 s      2.17 ms     nan         * 16 - 36
Day23 part2     2.45 s      0.39 s      0.04 s      9.98 ms     * 39 - 245
Day24 parse     0.27 ms     0.11 ms     0.10 ms     nan         * 1 - 2
Day24 part1     0.01 s      3.14 ms     0.18 ms     nan         * 17 - 79
Day24 part2     8.36 μs     0.05 ms     0.29 μs     nan         * 158 - 28
Day25 parse     7.14 μs     4.02 μs     1.18 μs     nan         * 3 - 6
Day25 part1     1.66 ms     1.16 ms     0.03 ms     nan         * 33 - 47

Total        4356.54 ms  1076.93 ms    77.90 ms    31.43 ms     * 34 - 138
```
