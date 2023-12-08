
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
Task             Python      PyPy3       Mojo        Mojo parallel
Day1 Part1      1.15 ms     0.23 ms    [7.53 μs]    0.06 ms (x24)
Day1 Part2      4.99 ms     0.52 ms    [0.07 ms]    0.11 ms (x24)
Day2 Part1      0.40 ms     0.16 ms    [0.09 ms]    0.03 ms (x24)
Day2 Part2      0.41 ms     0.16 ms    [0.09 ms]    0.03 μs (x24)
Day3 Parser     0.97 ms     0.08 ms    [0.03 ms]    n/a
Day3 Part1      0.49 ms     0.06 ms    [7.96 μs]    n/a
Day3 Part2      1.22 ms     0.09 ms    [0.02 ms]    n/a
Day4 Parser     0.64 ms     0.34 ms    [0.03 ms]    n/a
Day4 Part1      0.11 ms     0.06 ms    [0.35 μs]    n/a
Day4 Part2      0.16 ms     0.07 ms    [0.68 μs]    n/a
Day5 Parser     0.10 ms     0.06 ms    [0.02 ms]    n/a
Day5 Part1      0.07 ms     5.90 μs    [3.74 μs]    n/a
Day5 Part2      0.35 ms     0.14 ms    [8.04 μs]    n/a
Day6 Part1      1.91 μs     0.36 μs    [0.22 μs]    n/a
Day6 Part2      0.81 μs     0.29 μs    [0.08 μs]    n/a
Day7 Part1      1.75 ms     0.74 ms    [0.13 ms]    n/a
Day7 Part2      1.79 ms     0.77 ms    [0.13 ms]    n/a
Day8 Parse      0.26 ms     0.11 ms    [2.97 μs]    n/a
Day8 Part1      0.77 ms     0.10 ms    [0.03 ms]    n/a
Day8 Part2      7.09 ms     1.93 ms    [0.25 ms]    0.09 ms (x6)
```