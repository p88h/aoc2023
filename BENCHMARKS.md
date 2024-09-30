
All benchmarks running on 12-core / 24-thread Intel Core I7-13700K

OS: Win11 + WSL2 / Ubuntu 24.04 

Compilers:
```
$ python --version
Python 3.12.3
$ pypy3 --version
Python 3.10.14 (7.3.17+dfsg-2~ppa1~ubuntu24.04, Sep 08 2024, 09:46:00)
[PyPy 7.3.17 with GCC 13.2.0]
$ mojo --version
mojo 24.5.0 (e8aacb95)
```

```
Day01 part1     0.74 ms     0.15 ms     7.70 μs     2.95 μs     * 49 - 252
Day01 part2     3.03 ms     0.33 ms     0.05 ms     7.11 μs     * 46 - 426
Day02 part1     0.32 ms     0.11 ms     0.11 ms     0.02 ms     * 4 - 12
Day02 part2     0.32 ms     0.11 ms     0.11 ms     0.02 ms     * 4 - 13
Day03 parse     0.57 ms     0.04 ms     0.02 ms     nan         * 2 - 30
Day03 part1     0.39 ms     0.04 ms     7.90 μs     nan         * 4 - 49
Day03 part2     0.79 ms     0.05 ms     0.01 ms     nan         * 4 - 69
Day04 parse     0.51 ms     0.22 ms     0.04 ms     nan         * 6 - 14
Day04 part1     0.07 ms     0.04 ms     0.15 μs     nan         * 290 - 452
Day04 part2     0.10 ms     0.05 ms     0.39 μs     nan         * 119 - 267
Day05 parse     0.08 ms     0.05 ms     0.03 ms     nan         * 1 - 3
Day05 part1     0.05 ms     3.82 μs     2.93 μs     nan         * 1 - 18
Day05 part2     0.26 ms     0.10 ms     7.57 μs     nan         * 13 - 34
Day06 part1     1.69 μs     0.21 μs     0.24 μs     nan         * 0 - 7
Day06 part2     0.69 μs     0.22 μs     0.06 μs     nan         * 4 - 12
Day07 part1     1.14 ms     0.48 ms     0.02 ms     nan         * 22 - 53
Day07 part2     1.18 ms     0.50 ms     0.02 ms     nan         * 21 - 51
Day08 parse     0.17 ms     0.06 ms     3.96 μs     nan         * 14 - 42
Day08 part1     0.53 ms     0.05 ms     0.02 ms     nan         * 2 - 26
Day08 part2     4.75 ms     1.26 ms     0.15 ms     0.05 ms     * 26 - 99
Day09 parse     0.25 ms     0.07 ms     0.05 ms     nan         * 1 - 4
Day09 part1     1.23 ms     0.14 ms     1.91 μs     nan         * 72 - 643
Day09 part2     1.26 ms     0.14 ms     1.91 μs     nan         * 70 - 659
Day09sym parse  0.37 ms     0.08 ms     0.06 ms     nan         * 1 - 6
Day09sym part1  0.12 ms     3.77 μs     0.17 μs     nan         * 21 - 696
Day09sym part2  0.15 ms     5.73 μs     0.17 μs     nan         * 33 - 886
Day10 part1     1.77 ms     0.56 ms     0.08 ms     nan         * 7 - 22
Day10 part2     1.28 ms     0.46 ms     0.03 ms     0.01 ms     * 31 - 87
Day11 part1     1.24 ms     0.18 ms     0.02 ms     nan         * 9 - 61
Day11 part2     1.28 ms     0.18 ms     0.02 ms     nan         * 9 - 64
Day11hv part1   0.33 ms     0.11 ms     6.50 μs     nan         * 16 - 50
Day11hv part2   0.34 ms     0.11 ms     8.43 μs     nan         * 12 - 39
Day12 part1     5.44 ms     1.50 ms     0.42 ms     0.07 ms     * 20 - 73
Day12 part2     0.12 s      0.03 s      3.29 ms     0.61 ms     * 53 - 195
Day13 parse     0.77 ms     0.07 ms     0.01 ms     nan         * 6 - 70
Day13 part1     0.11 ms     5.15 μs     1.17 μs     nan         * 4 - 93
Day13 part2     0.15 ms     0.01 ms     1.75 μs     nan         * 6 - 86
Day14 parse     1.02 ms     0.16 ms     0.04 ms     nan         * 4 - 27
Day14 part1     0.25 ms     0.03 ms     4.78 μs     nan         * 7 - 52
Day14 part2     0.17 s      0.04 s      3.79 ms     nan         * 9 - 45
Day15 part1     0.71 ms     0.12 ms     0.02 ms     nan         * 8 - 45
Day15 part2     1.17 ms     0.32 ms     0.04 ms     nan         * 7 - 26
Day16 part1     2.81 ms     1.04 ms     0.03 ms     nan         * 32 - 88
Day16 part2     0.48 s      0.18 s      4.03 ms     0.73 ms     * 241 - 660
Day17 part1     0.03 s      5.28 ms     2.40 ms     nan         * 2 - 13
Day17 part2     0.07 s      0.01 s      4.89 ms     nan         * 2 - 14
Day18 part1     0.11 ms     0.02 ms     2.91 μs     nan         * 7 - 37
Day18 part2     0.21 ms     0.04 ms     2.60 μs     nan         * 15 - 80
Day19 parse     0.98 ms     0.20 ms     0.07 ms     nan         * 2 - 13
Day19 part1     0.12 ms     0.04 ms     2.50 μs     nan         * 14 - 46
Day19 part2     0.32 ms     0.04 ms     0.01 ms     nan         * 3 - 29
Day20 parse     0.03 ms     9.75 μs     2.97 μs     nan         * 3 - 11
Day20 part1     0.01 s      1.51 ms     0.32 ms     nan         * 4 - 33
Day20 part2     0.04 s      5.97 ms     0.39 ms     nan         * 15 - 110
Day21 part1     3.96 ms     0.84 ms     0.14 ms     nan         * 5 - 27
Day21 part2     0.18 s      0.04 s      1.87 ms     nan         * 21 - 98
Day22 parse     0.63 ms     0.54 ms     0.15 ms     nan         * 3 - 4
Day22 part1     0.88 ms     0.17 ms     0.03 ms     nan         * 5 - 28
Day22 part2     2.92 ms     0.49 ms     0.12 ms     nan         * 4 - 24
Day23 part1     0.06 s      0.01 s      1.66 ms     nan         * 7 - 37
Day23 part2     1.96 s      0.27 s      0.03 s      5.95 ms     * 45 - 330
Day24 parse     0.21 ms     0.07 ms     0.10 ms     nan         * 0 - 2
Day24 part1     0.01 s      1.88 ms     0.13 ms     0.03 ms     * 54 - 336
Day24 part2     7.98 μs     0.04 ms     0.19 μs     nan         * 194 - 43
Day25 parse     0.69 ms     0.25 ms     0.01 ms     nan         * 22 - 64
Day25 part1     1.16 ms     0.72 ms     0.02 ms     nan         * 32 - 51

Total        3204.99 ms   607.63 ms    51.77 ms    24.10 ms     * 25 - 132
```