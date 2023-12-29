p88h's Advent of Code 2023
==========================

This is a repository containing solutions for the 2023 Advent of Code (https://adventofcode.com/).

This years language of choice is 'Mojo vs Python', that is, all solutions are implemented in both languages 
and cross-benchmarked between Python/PyPy and Mojo implementations. 

You can read a bit more about my experience with Mojo on [Medium](https://medium.com/@p88h/advent-of-mojo-6d6d0d00761b)

If you would like to run this yourself, you can do it like so, from the top-level directory of the project:

```
$ mojo run dayXY.mojo
$ {python3|pypy3} dayXY.py
```

This will run the selected day. You need to paste the contents of the specific days input into dayXY.txt.
The final newline should be stripped from the inputs (sorry about this, I actually cut and paste the inputs which doesn't store the final newline).

Only the standard library is required for Mojo solutions. Python solutions may require numpy. 

Benchmarking
============

Each days solution automatically runs
Benchmarks from my system are also included in [BENCHMARKS.md](BENCHMARKS.md) and [BENCHMARKS-M1.md](BENCHMARKS-M1.md) for a MacBook Pro w/M1 chip. 
You can run each day across all platforms and generate the benchmark summary this way:

```
$ for day in `seq 01 25`; do ./run.sh $day; done
$ python3 agg.py
```

This will create temporary `all_{python3|pypy3|mojo}_{pc|mac}.txt` files. Only PC (=anything other than a Mac) and Mac are supported by the `run.sh` script. 

Visualisations
==============

The vis/ directory contains visualisations code - written in Pythin, with PyGame. You can run each one directly:


```
$ python3 vis/dayXY.py
```

Running these requires the pygame package, and you will also need to download [Inconsolata-SemiBold.ttf](https://github.com/googlefonts/Inconsolata/raw/main/fonts/ttf/Inconsolata-SemiBold.ttf) from [Google Fonts](https://fonts.google.com/specimen/Inconsolata) and place it in the `vis` folder. 

Visualisations can also write video to `dayXX.mp4` files automatically, if you pass additional '-r' parameter.

```
$ python3 vis/dayXY.py -r
```

This requires ffmpeg binary installed. You will need to create a 'tmp' directory for the frames. 

Most videos are also published to [YouTube](https://www.youtube.com/playlist?list=PLgRrl8I0Q16_XH4iOGfXA5uaVDlfuyYVC)

Copyright disclaimer
====================

Licensed under the Apache License, Version 2.0 (the "License");
you may not use these files except in compliance with the License.
You may obtain a copy of the License at

   https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
