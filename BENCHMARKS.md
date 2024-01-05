
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
mojo 0.6.1 (876ded2e)
```

```
Task             Python      PyPy3       Mojo       parallel    * speedup
Day01 part1     0.72 ms     0.15 ms     6.43 μs     0.02 ms     * 23 - 111
Day01 part2     2.82 ms     0.32 ms     0.05 ms     0.03 ms     * 11 - 100
Day02 part1     0.29 ms     0.10 ms     0.03 ms     8.38 μs     * 12 - 34
Day02 part2     0.29 ms     0.10 ms     0.03 ms     8.69 μs     * 12 - 32
Day03 parse     0.63 ms     0.07 ms     0.03 ms     nan         * 2 - 23
Day03 part1     0.35 ms     0.04 ms     5.45 μs     nan         * 6 - 64
Day03 part2     0.81 ms     0.05 ms     0.01 ms     nan         * 3 - 60
Day04 parse     0.42 ms     0.21 ms     0.04 ms     nan         * 5 - 11
Day04 part1     0.08 ms     0.04 ms     0.16 μs     nan         * 277 - 511
Day04 part2     0.12 ms     0.04 ms     0.39 μs     nan         * 115 - 312
Day05 parse     0.06 ms     0.05 ms     9.87 μs     nan         * 4 - 6
Day05 part1     0.05 ms     3.94 μs     1.83 μs     nan         * 2 - 26
Day05 part2     0.22 ms     0.11 ms     5.67 μs     nan         * 18 - 39
Day06 part1     1.40 μs     0.21 μs     0.09 μs     nan         * 2 - 15
Day06 part2     0.58 μs     0.20 μs     0.05 μs     nan         * 3 - 11
Day07 part1     1.07 ms     0.48 ms     0.03 ms     nan         * 16 - 36
Day07 part2     1.10 ms     0.50 ms     0.03 ms     nan         * 16 - 36
Day08 parse     0.15 ms     0.06 ms     2.72 μs     nan         * 21 - 56
Day08 part1     0.47 ms     0.05 ms     0.02 ms     nan         * 2 - 23
Day08 part2     4.48 ms     1.29 ms     0.17 ms     0.04 ms     * 29 - 103
Day09 parse     0.18 ms     0.07 ms     0.03 ms     nan         * 2 - 6
Day09 part1     1.26 ms     0.14 ms     1.81 μs     nan         * 78 - 697
Day09 part2     1.31 ms     0.14 ms     2.01 μs     nan         * 68 - 652
Day09sym parse  0.34 ms     0.09 ms     0.03 ms     nan         * 2 - 10
Day09sym part1  0.11 ms     3.66 μs     0.17 μs     nan         * 21 - 618
Day09sym part2  0.15 ms     5.10 μs     0.17 μs     nan         * 29 - 865
Day10 part1     1.82 ms     0.61 ms     0.07 ms     nan         * 8 - 24
Day10 part2     1.25 ms     0.47 ms     0.03 ms     0.01 ms     * 34 - 91
Day11 part1     1.21 ms     0.19 ms     0.03 ms     nan         * 7 - 48
Day11 part2     1.25 ms     0.19 ms     0.03 ms     nan         * 7 - 49
Day11hv part1   0.37 ms     0.11 ms     8.09 μs     nan         * 13 - 45
Day11hv part2   0.37 ms     0.11 ms     8.09 μs     nan         * 13 - 45
Day12 part1     5.53 ms     1.51 ms     0.36 ms     0.10 ms     * 14 - 52
Day12 part2     0.12 s      0.03 s      2.75 ms     0.60 ms     * 55 - 194
Day13 parse     0.83 ms     0.09 ms     0.01 ms     nan         * 8 - 76
Day13 part1     0.14 ms     5.60 μs     1.11 μs     nan         * 5 - 123
Day13 part2     0.17 ms     0.01 ms     1.53 μs     nan         * 8 - 113
Day14 parse     1.06 ms     0.17 ms     0.02 ms     nan         * 7 - 47
Day14 part1     0.28 ms     0.03 ms     5.39 μs     nan         * 6 - 52
Day14 part2     0.18 s      0.04 s      5.83 ms     nan         * 6 - 31
Day15 part1     0.66 ms     0.13 ms     0.01 ms     nan         * 8 - 44
Day15 part2     1.07 ms     0.31 ms     0.05 ms     nan         * 6 - 22
Day16 part1     2.81 ms     1.08 ms     0.04 ms     nan         * 26 - 67
Day16 part2     0.56 s      0.22 s      9.73 ms     1.42 ms     * 152 - 393
Day17 part1     0.05 s      9.32 ms     1.30 ms     nan         * 7 - 39
Day17 part2     0.13 s      0.02 s      2.83 ms     nan         * 7 - 45
Day18 part1     0.10 ms     0.02 ms     2.82 μs     nan         * 7 - 34
Day18 part2     0.18 ms     0.04 ms     2.44 μs     nan         * 17 - 74
Day19 parse     0.85 ms     0.20 ms     0.03 ms     nan         * 6 - 28
Day19 part1     0.11 ms     0.04 ms     2.81 μs     nan         * 14 - 40
Day19 part2     0.29 ms     0.04 ms     0.01 ms     nan         * 3 - 25
Day20 parse     0.04 ms     9.31 μs     1.14 μs     nan         * 8 - 31
Day20 part1     0.01 s      1.50 ms     0.32 ms     nan         * 4 - 44
Day20 part2     0.06 s      5.88 ms     0.35 ms     nan         * 16 - 155
Day21 part1     3.78 ms     0.83 ms     0.10 ms     nan         * 8 - 36
Day21 part2     0.17 s      0.04 s      1.97 ms     nan         * 20 - 87
Day22 parse     0.52 ms     0.54 ms     0.13 ms     nan         * 4 - 4
Day22 part1     1.11 ms     0.17 ms     0.03 ms     nan         * 5 - 33
Day22 part2     4.04 ms     0.50 ms     0.08 ms     nan         * 6 - 49
Day23 part1     0.06 s      0.01 s      1.18 ms     nan         * 12 - 49
Day23 part2     1.68 s      0.28 s      0.03 s      4.82 ms     * 57 - 348
Day24 parse     0.17 ms     0.08 ms     0.11 ms     nan         * 0 - 1
Day24 part1     0.01 s      2.39 ms     0.13 ms     nan         * 18 - 76
Day24 part2     8.20 μs     0.04 ms     0.19 μs     nan         * 197 - 43
Day25 parse     0.65 ms     0.25 ms     0.01 ms     nan         * 23 - 60
Day25 part1     1.18 ms     0.72 ms     0.03 ms     nan         * 22 - 36

Total        3077.65 ms   674.09 ms    58.04 ms    22.05 ms     * 30 - 139
```