
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
Day01 part1     0.72 ms     0.14 ms     6.46 μs     0.02 ms     * 22 - 112
Day01 part2     2.84 ms     0.33 ms     0.06 ms     0.03 ms     * 12 - 105
Day02 part1     0.29 ms     0.10 ms     0.03 ms     9.40 μs     * 11 - 30
Day02 part2     0.29 ms     0.10 ms     0.03 ms     9.79 μs     * 10 - 29
Day03 parse     0.61 ms     0.04 ms     0.03 ms     nan         * 1 - 23
Day03 part1     0.36 ms     0.04 ms     5.57 μs     nan         * 6 - 65
Day03 part2     0.80 ms     0.05 ms     0.01 ms     nan         * 4 - 76
Day04 parse     0.41 ms     0.21 ms     0.04 ms     nan         * 5 - 11
Day04 part1     0.08 ms     0.04 ms     0.23 μs     nan         * 188 - 339
Day04 part2     0.12 ms     0.04 ms     0.43 μs     nan         * 103 - 268
Day05 parse     0.06 ms     0.05 ms     0.01 ms     nan         * 4 - 5
Day05 part1     0.05 ms     3.97 μs     1.86 μs     nan         * 2 - 26
Day05 part2     0.22 ms     0.10 ms     5.51 μs     nan         * 18 - 39
Day06 part1     1.39 μs     0.21 μs     0.10 μs     nan         * 2 - 14
Day06 part2     0.57 μs     0.21 μs     0.06 μs     nan         * 3 - 9
Day07 part1     1.04 ms     0.49 ms     0.05 ms     nan         * 10 - 21
Day07 part2     1.09 ms     0.50 ms     0.05 ms     nan         * 10 - 22
Day08 parse     0.15 ms     0.06 ms     2.83 μs     nan         * 20 - 52
Day08 part1     0.46 ms     0.05 ms     0.02 ms     nan         * 2 - 22
Day08 part2     4.34 ms     1.29 ms     0.17 ms     0.04 ms     * 29 - 100
Day09 parse     0.18 ms     0.07 ms     0.03 ms     nan         * 2 - 5
Day09 part1     1.31 ms     0.14 ms     2.03 μs     nan         * 69 - 643
Day09 part2     1.38 ms     0.14 ms     2.03 μs     nan         * 68 - 680
Day09sym parse  0.35 ms     0.08 ms     0.03 ms     nan         * 2 - 10
Day09sym part1  0.11 ms     3.63 μs     0.17 μs     nan         * 21 - 632
Day09sym part2  0.15 ms     4.92 μs     0.17 μs     nan         * 28 - 860
Day10 part1     1.81 ms     0.57 ms     0.08 ms     nan         * 6 - 21
Day10 part2     1.25 ms     0.46 ms     0.04 ms     0.02 ms     * 29 - 80
Day11 part1     1.19 ms     0.19 ms     0.02 ms     nan         * 7 - 48
Day11 part2     1.22 ms     0.19 ms     0.02 ms     nan         * 7 - 48
Day11hv part1   0.36 ms     0.11 ms     8.09 μs     nan         * 13 - 44
Day11hv part2   0.36 ms     0.11 ms     8.12 μs     nan         * 13 - 44
Day12 part1     5.50 ms     1.56 ms     0.37 ms     0.11 ms     * 14 - 49
Day12 part2     0.11 s      0.03 s      2.78 ms     0.63 ms     * 53 - 180
Day13 parse     0.84 ms     0.07 ms     0.01 ms     nan         * 6 - 81
Day13 part1     0.12 ms     5.38 μs     1.17 μs     nan         * 4 - 106
Day13 part2     0.18 ms     0.01 ms     1.91 μs     nan         * 6 - 93
Day14 parse     1.05 ms     0.17 ms     0.04 ms     nan         * 4 - 27
Day14 part1     0.28 ms     0.04 ms     5.95 μs     nan         * 6 - 46
Day14 part2     0.19 s      0.04 s      7.40 ms     nan         * 5 - 25
Day15 part1     0.68 ms     0.14 ms     0.01 ms     nan         * 9 - 47
Day15 part2     1.09 ms     0.33 ms     0.05 ms     nan         * 6 - 22
Day16 part1     2.78 ms     1.08 ms     0.04 ms     nan         * 25 - 64
Day16 part2     0.56 s      0.22 s      9.74 ms     1.41 ms     * 153 - 394
Day17 part1     0.05 s      9.36 ms     1.32 ms     nan         * 7 - 39
Day17 part2     0.13 s      0.02 s      2.87 ms     nan         * 7 - 45
Day18 part1     0.10 ms     0.02 ms     2.55 μs     nan         * 8 - 40
Day18 part2     0.18 ms     0.04 ms     2.35 μs     nan         * 18 - 78
Day19 parse     0.85 ms     0.20 ms     0.03 ms     nan         * 8 - 33
Day19 part1     0.12 ms     0.04 ms     2.75 μs     nan         * 15 - 42
Day19 part2     0.30 ms     0.04 ms     0.01 ms     nan         * 3 - 27

Total        1072.31 ms   327.80 ms    25.52 ms     nan         * 12 - 42
```