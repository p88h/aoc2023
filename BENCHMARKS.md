
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
Day01 part1     0.72 ms     0.14 ms     6.28 μs     0.01 ms     * 23 - 115
Day01 part2     2.84 ms     0.33 ms     0.05 ms     0.02 ms     * 13 - 118
Day02 part1     0.29 ms     0.10 ms     0.03 ms     8.37 μs     * 12 - 34
Day02 part2     0.29 ms     0.10 ms     0.03 ms     8.59 μs     * 12 - 33
Day03 parse     0.61 ms     0.04 ms     0.03 ms     nan         * 1 - 23
Day03 part1     0.36 ms     0.04 ms     5.41 μs     nan         * 6 - 67
Day03 part2     0.80 ms     0.05 ms     0.01 ms     nan         * 3 - 58
Day04 parse     0.41 ms     0.21 ms     0.04 ms     nan         * 5 - 11
Day04 part1     0.08 ms     0.04 ms     0.23 μs     nan         * 190 - 343
Day04 part2     0.12 ms     0.04 ms     0.43 μs     nan         * 103 - 267
Day05 parse     0.06 ms     0.05 ms     9.91 μs     nan         * 4 - 6
Day05 part1     0.05 ms     3.97 μs     1.88 μs     nan         * 2 - 25
Day05 part2     0.22 ms     0.10 ms     5.66 μs     nan         * 17 - 38
Day06 part1     1.39 μs     0.21 μs     0.09 μs     nan         * 2 - 15
Day06 part2     0.57 μs     0.21 μs     0.05 μs     nan         * 3 - 11
Day07 part1     1.04 ms     0.49 ms     0.05 ms     nan         * 9 - 19
Day07 part2     1.09 ms     0.50 ms     0.05 ms     nan         * 9 - 20
Day08 parse     0.15 ms     0.06 ms     2.91 μs     nan         * 20 - 51
Day08 part1     0.46 ms     0.05 ms     0.02 ms     nan         * 2 - 22
Day08 part2     4.34 ms     1.29 ms     0.17 ms     0.04 ms     * 30 - 101
Day09 parse     0.18 ms     0.07 ms     0.03 ms     nan         * 2 - 6
Day09 part1     1.31 ms     0.14 ms     1.85 μs     nan         * 75 - 706
Day09 part2     1.38 ms     0.14 ms     2.01 μs     nan         * 68 - 688
Day09sym parse  0.35 ms     0.08 ms     0.04 ms     nan         * 2 - 9
Day09sym part1  0.11 ms     3.63 μs     0.17 μs     nan         * 20 - 623
Day09sym part2  0.15 ms     4.92 μs     0.17 μs     nan         * 28 - 845
Day10 part1     1.81 ms     0.57 ms     0.08 ms     nan         * 6 - 21
Day10 part2     1.25 ms     0.46 ms     0.04 ms     0.01 ms     * 33 - 91
Day11 part1     1.19 ms     0.19 ms     0.02 ms     nan         * 7 - 47
Day11 part2     1.22 ms     0.19 ms     0.03 ms     nan         * 7 - 47
Day11hv part1   0.36 ms     0.11 ms     8.21 μs     nan         * 12 - 44
Day11hv part2   0.36 ms     0.11 ms     8.18 μs     nan         * 12 - 44
Day12 part1     5.50 ms     1.56 ms     0.37 ms     0.11 ms     * 13 - 49
Day12 part2     0.11 s      0.03 s      2.77 ms     0.60 ms     * 56 - 190
Day13 parse     0.84 ms     0.07 ms     0.01 ms     nan         * 6 - 78
Day13 part1     0.12 ms     5.38 μs     1.08 μs     nan         * 4 - 115
Day13 part2     0.18 ms     0.01 ms     1.91 μs     nan         * 6 - 93
Day14 parse     1.05 ms     0.17 ms     0.03 ms     nan         * 6 - 40
Day14 part1     0.28 ms     0.04 ms     6.34 μs     nan         * 5 - 44
Day14 part2     0.19 s      0.04 s      7.48 ms     nan         * 5 - 24
Day15 part1     0.68 ms     0.14 ms     0.01 ms     nan         * 9 - 45
Day15 part2     1.09 ms     0.33 ms     0.05 ms     nan         * 6 - 23
Day16 part1     2.78 ms     1.06 ms     0.04 ms     nan         * 26 - 69
Day16 part2     0.55 s      0.21 s      9.63 ms     1.42 ms     * 149 - 390
Day17 part1     0.05 s      9.36 ms     1.31 ms     nan         * 7 - 39
Day17 part2     0.13 s      0.02 s      2.88 ms     nan         * 7 - 45
Day18 part1     0.10 ms     0.02 ms     2.80 μs     nan         * 7 - 37
Day18 part2     0.18 ms     0.04 ms     2.42 μs     nan         * 17 - 75
Day19 parse     0.85 ms     0.20 ms     0.03 ms     nan         * 6 - 28
Day19 part1     0.12 ms     0.04 ms     2.80 μs     nan         * 15 - 42
Day19 part2     0.30 ms     0.04 ms     0.01 ms     nan         * 3 - 26
Day20 parse     0.04 ms     9.70 μs     1.20 μs     nan         * 8 - 30
Day20 part1     0.01 s      1.55 ms     0.33 ms     nan         * 4 - 44
Day20 part2     0.06 s      6.27 ms     0.38 ms     nan         * 16 - 151
Day21 part1     3.87 ms     0.89 ms     0.11 ms     nan         * 8 - 36
Day21 part2     0.18 s      0.04 s      2.15 ms     nan         * 20 - 83
Day22 parse     0.53 ms     0.54 ms     0.13 ms     nan         * 4 - 4
Day22 part1     0.02 s      3.46 ms     0.14 ms     nan         * 24 - 140
Day22 part2     4.02 ms     0.50 ms     0.08 ms     nan         * 6 - 50

Total        1351.69 ms   385.01 ms    28.73 ms    17.87 ms     * 21 - 75
```