
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
mojo 0.5.0 (6e50a738)
```

```
Task                    Python      PyPy3       Mojo        Mojo x 24 threads
Day1 Part1 naive        0.81 ms     0.18 ms     0.35 ms     0.05 ms 
Day1 Part2 naive        8.92 ms     0.89 ms     1.21 ms     0.17 ms
Day1 Part1 optimized    0.70 ms     0.26 ms     0.26 ms     0.05 ms 
Day1 Part2 optimized    2.86 ms     0.41 ms     0.22 ms     0.04 ms
```