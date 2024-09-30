from parser import *
from wrappers import minibench
from array import Array

alias int16x4 = SIMD[DType.int16,4]

# Copy and modify a 4-element vector 
@always_inline
fn replace(t: int16x4, i: Int, v: Int16) -> int16x4:
    var r = t
    r[i] = v
    return r

# Encode a string label into an integer code 
@always_inline
fn encode(s: StringSlice) -> Int:
    alias orda = ord('a') - 1
    var ret = 0
    for i in range(s.size):
        ret = ret * 32 + (int(s[i])|32) - orda
    return ret

# Evaluate rules, starting from code and processing ranges between elements of ho and hoho
fn eval(rules: Array[DType.int16], code: Int16, ho: int16x4, hoho: int16x4) -> Int64:
    # special handling for terminal states
    if code == 18: return 0
    if code == 1:
        return int((hoho - ho + int16x4(1,1,1,1)).cast[DType.int64]().reduce_mul[1]())
    # unpack the actual rule
    op = rules.data.load[width=4](int(code) * 4)
    o = op[0] >> 8
    i = int(op[0] & 0xFF)
    n = op[1]
    # process the rule
    if (o == 3): # '>'
        #print(code,i,">",n,"(",ho[i],"-",hoho[i],")",op[2],op[3])
        # pass through
        if ho[i] > n:
            return eval(rules, op[2], ho, hoho)
        # split
        if hoho[i] > n:
            return eval(rules, op[2], replace(ho, i, n + 1), hoho) + eval(rules, op[3], ho, replace(hoho, i, n))
        # pass through to the next
        return eval(rules, op[3], ho, hoho)
    elif (o == 1): # < 
        #print(code,i,"<",n,"(",ho[i],"-",hoho[i],")",op[2],op[3])
        # same as above
        if hoho[i] < n:
            return eval(rules, op[2], ho, hoho)
        if ho[i] < n:
            return eval(rules, op[2], ho, replace(hoho, i, n - 1)) + eval(rules, op[3], replace(ho, i, n), hoho)
        return eval(rules, op[3], ho, hoho)
    else:
        #print(code,"=>",op[2])
        # Basic jump rule
        return eval(rules, op[2], ho, hoho)

fn main() raises:
    f = open("day19.txt", "r")
    lines = make_parser["\n"](f.read())
    rules = Array[DType.int16](131072)
    insn = Array[DType.int16](1000)
    var icnt = 0
    var dcnt = -1

    @parameter
    fn parse() -> Int64:
        icnt = 0
        var ridx = 30000 # above 27*32*32
        for k in range(lines.length()):
            line = lines[k]
            alias cBracket = ord('{}')
            pos = line.find(cBracket)
            if pos > 0:
                # sv{m>492:gsq,x>1070:R,a>2386:A,mk}
                tok = line[:pos]
                var c = encode(tok)
                # print(line,tok,c)
                rrr = make_parser[ord(',')](line[pos+1:line.size-1])
                for i in range(rrr.length()):
                    alias cOlon = ord(':')
                    r = rrr[i]
                    pos2 = r.find(cOlon)
                    var op : int16x4
                    # Parse a rule 
                    if pos2 > 0:
                        # m>492:gsq
                        v = r[0]
                        o = r[1] ^ 61
                        n = atoi(r[2:pos2])
                        b = encode(r[pos2+1:r.size])
                        var j : Int
                        # xmas -> 0123
                        if v == 120:
                            j = 0
                        elif v == 109:
                            j = 1
                        elif v == 97:
                            j = 2
                        else:
                            j = 3
                        # o, i < 8 bit each
                        # n 16 bit / 32 total
                        # b 16 bit / c 16 bit / 64 total
                        op = int16x4((int(o) << 8) + j,int(n),b,ridx)
                    else:
                        b = encode(r)
                        op = int16x4(0,0,b,ridx)
                    rules.data.store[width=4](c * 4, op)
                    # print(tok,rrr[i],c,op)
                    c = ridx
                    ridx += 1
            elif pos == 0:
                # {x=23,m=2544,a=699,s=22}
                # parse an input
                rrr = make_parser[ord(',')](line[1:line.size-1])
                var vvv = int16x4(0)
                for i in range(4):
                    vvv[i] = int(atoi(rrr[i][2:]))
                # print(line, vvv)
                insn.data.store[width=4](icnt * 4, vvv)
                icnt += 1
        return icnt
    
    
            
    @parameter
    fn part1() -> Int64:
        var ret : Int64 = 0
        for i in range(icnt):
            v = insn.data.load[width=4](i * 4)
            ret += int(v.cast[DType.int64]().reduce_add()) * eval(rules, 302, v, v)
        return ret

    @parameter
    fn part2() -> Int64:
        # this silly thing here makes the iterations different. 
        # without that, the compiler _somehow_ notices everything is the same
        # and doesn't actually run the code, just returns the precomputed results. 
        dcnt += 1
        return eval(rules, 302, int16x4(1+(dcnt%100),1,1,1), int16x4(4000,4000,4000,4000))

    minibench[parse]("parse")
    minibench[part1]("part1")
    minibench[part2]("part2")

    print(lines.length(), "lines")
    print(rules.size + insn.size, "temp array size")
