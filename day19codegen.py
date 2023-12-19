from benchy import minibench
lines = open("day19.txt").read().split("\n")
the_code = None
def parse():
    global the_code
    code = []
    code.append("class xmas:")
    code.append("  def __init__(self,x,m,a,s) -> None:")
    code.append("    self.x = x; self.m = m; self.a = a; self.s = s\n")
    code.append("  def sum(self):")
    code.append("    return self.x+self.m+self.a+self.s\n")
    code.append("  def copy(self):")
    code.append("    return xmas(self.x,self.m,self.a,self.s)\n")

    code.append("def f_A(ho, hoho):")
    code.append("  return (hoho.x - ho.x + 1)*(hoho.m - ho.m + 1)*(hoho.a - ho.a + 1)*(hoho.s - ho.s + 1)\n")
    code.append("def f_R(ho, hoho):")
    code.append("  return 0\n")
    for line in lines:
        pos = line.find('{')
        if pos > 0:
            tok = line[:pos]
            rules = line[pos+1:-1].split(',')
            code.append("def f_{}(ho, hoho):".format(tok))
            code.append("  ret = 0")
            for r in rules:
                if ':' in r:
                    a,b = r.split(':')
                    v,o,n = a[0],a[1],int(a[2:])
                    if o == '<':
                        code.append("  if (hoho.{} < {}):\n    return ret + f_{}(ho.copy(),hoho.copy())".format(v,n,b))
                        code.append("  if (ho.{} < {}):".format(v,n))
                        code.append("    t = hoho.{}; hoho.{} = {}".format(v,v,n-1))
                        code.append("    ret += f_{}(ho.copy(),hoho.copy())".format(b))
                        code.append("    ho.{} = {}; hoho.{} = t".format(v,n,v))
                    else:
                        code.append("  if (ho.{} > {}):\n    return ret + f_{}(ho.copy(),hoho.copy())".format(v,n,b))
                        code.append("  if (hoho.{} > {}):".format(v,n))
                        code.append("    t = ho.{}; ho.{} = {}".format(v,v,n+1))
                        code.append("    ret += f_{}(ho.copy(),hoho.copy())".format(b))
                        code.append("    hoho.{} = {}; ho.{} = t".format(v,n,v))
                else:
                    code.append("  return ret + f_{}(ho,hoho)".format(r))
            code.append("\n")
        elif pos == 0:
            l = line[1:-1]
            code.append("  hohoho = xmas({});".format(l))
            code.append("  merry += hohoho.sum()*f_in(hohoho,hohoho);")
        else:
            code.append("def part1():")
            code.append("  merry=0\n  hohoho=xmas(0,0,0,0)")
    code.append("  return merry\n")
    code.append("def part2():")
    code.append("  return f_in(xmas(1,1,1,1),xmas(4000,4000,4000,4000))\n")
    # the_code = compile("\n".join(code),".tmp","exec")
    the_code = "\n".join(code)
    return 1

parse()
exec(the_code)
print(part1())
print(part2())

minibench({"parse": parse, "part1": part1, "part2": part2})
