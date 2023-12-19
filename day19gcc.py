import os
from benchy import minibench
lines = open("day19.txt").read().split("\n")
code = []
code.append("#include <iostream>")
code.append('#define ANKERL_NANOBENCH_IMPLEMENT')
code.append('#include "nanobench.h"')
code.append("using namespace std;")
code.append("typedef struct xmas { int64_t x,m,a,s; int64_t sum() { return x+m+a+s; }} xmas;")
code.append("long long f_A(xmas ho, xmas hoho) {")
code.append("  return (hoho.x - ho.x + 1)*(hoho.m - ho.m + 1)*(hoho.a - ho.a + 1)*(hoho.s - ho.s + 1);\n}\n")
code.append("long long f_R(xmas ho, xmas hoho) {")
code.append("  return 0;\n}\n")
body = []
for line in lines:
    pos = line.find('{')
    if pos > 0:
        tok = line[:pos]
        rules = line[pos+1:-1].split(',')
        code.append("long long f_{}(xmas ho, xmas hoho);".format(tok))
    
        body.append("long long f_{}(xmas ho, xmas hoho) {{".format(tok))
        body.append("  long long ret = 0;")
        for r in rules:
            if ':' in r:
                a,b = r.split(':')
                v,o,n = a[0],a[1],int(a[2:])
                if o == '<':
                    body.append("  if (hoho.{} < {}) return ret + f_{}(ho,hoho);".format(v,n,b))
                    body.append("  if (ho.{} < {}) {{".format(v,n))
                    body.append("    int64_t t = hoho.{}; hoho.{} = {};".format(v,v,n-1))
                    body.append("    ret += f_{}(ho,hoho);".format(b))
                    body.append("    ho.{} = {}; hoho.{} = t;\n  }}".format(v,n,v))
                else:
                    body.append("  if (ho.{} > {}) return ret + f_{}(ho,hoho);".format(v,n,b))
                    body.append("  if (hoho.{} > {}) {{".format(v,n))
                    body.append("    int64_t t = ho.{}; ho.{} = {};".format(v,v,n+1))
                    body.append("    ret += f_{}(ho,hoho);".format(b))
                    body.append("    hoho.{} = {}; ho.{} = t;\n  }}".format(v,n,v))
            else:
                body.append("  return ret + f_{}(ho,hoho);".format(r))
        body.append("}\n")
    elif pos == 0:
        l = line[1:-1].replace(',',';').replace(';',',.')
        code.append("  hohoho={{.{}}};".format(l))
        code.append("  merry += hohoho.sum()*f_in(hohoho,hohoho);")
    else:
        code.extend(body)
        code.append("\nint64_t part1() {")
        code.append("  long long merry=0;\n  xmas hohoho;")
code.append("  return merry;\n}")
code.append("\nint64_t part2() {")
code.append("  return f_in({1,1,1,1},xmas{4000,4000,4000,4000});\n}")
code.append("\nint main() {")
code.append("  cout << part1() << endl;")
code.append("  cout << part2() << endl;")
code.append('  int64_t tot = 0;')
code.append('  ankerl::nanobench::Bench().minEpochIterations(100).run(')
code.append('      "part1", [&] { tot += part1(); ankerl::nanobench::doNotOptimizeAway(tot);});')
code.append('  ankerl::nanobench::Bench().minEpochIterations(100).run(')
code.append('      "part2", [&] { tot += part1(); ankerl::nanobench::doNotOptimizeAway(tot);});')
code.append("  return 0;\n}")
cc = open("day19.cc",'w')
cc.write("\n".join(code))
os.system("g++ -std=c++20 -O2 day19.cc -o day19")
os.system("./day19")
