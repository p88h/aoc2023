from parser import *
from wrappers import minibench
from array import Array
from math import abs

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
        ret = ret * 32 + (s[i].to_int()|32) - orda
    return ret

# Evaluate rules, starting from code and processing ranges between elements of ho and hoho
fn eval(rules: Array[DType.int16], code: Int16, ho: int16x4, hoho: int16x4) -> Int64:
    # special handling for terminal states
    if code == 18: return 0
    if code == 1:
        return (hoho - ho + int16x4(1,1,1,1)).cast[DType.int64]().reduce_mul[1]().to_int()
    # unpack the actual rule
    let op = rules.data.simd_load[4](code.to_int() * 4)
    let o = op[0] >> 8
    let i = (op[0] & 0xFF).to_int()
    let n = op[1]
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
    let f = open("day19.txt", "r")
    let lines = make_parser["\n"](f.read())
    let rules = Array[DType.int16](131072)
    let insn = Array[DType.int16](1000)
    var icnt = 0
    var dcnt = -1

    @parameter
    fn parse() -> Int64:
        icnt = 0
        var ridx = 30000 # above 27*32*32
        for k in range(lines.length()):
            let line = lines[k]
            alias cBracket = ord('{}')
            let pos = line.find(cBracket)
            if pos > 0:
                # sv{m>492:gsq,x>1070:R,a>2386:A,mk}
                let tok = line[:pos]
                var c = encode(tok)
                # print(line,tok,c)
                let rrr = make_parser[ord(',')](line[pos+1:line.size-1])
                for i in range(rrr.length()):
                    alias cOlon = ord(':')
                    let r = rrr[i]
                    let pos2 = r.find(cOlon)
                    let op : int16x4
                    # Parse a rule 
                    if pos2 > 0:
                        # m>492:gsq
                        let v = r[0]
                        let o = r[1] ^ 61
                        let n = atoi(r[2:pos2])
                        let b = encode(r[pos2+1:r.size])
                        let j : Int
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
                        op = int16x4((o.to_int() << 8) + j,n.to_int(),b,ridx)
                    else:
                        let b = encode(r)
                        op = int16x4(0,0,b,ridx)
                    rules.data.simd_store[4](c * 4, op)
                    # print(tok,rrr[i],c,op)
                    c = ridx
                    ridx += 1
            elif pos == 0:
                # {x=23,m=2544,a=699,s=22}
                # parse an input
                let rrr = make_parser[ord(',')](line[1:line.size-1])
                var vvv = int16x4(0)
                for i in range(4):
                    vvv[i] = atoi(rrr[i][2:]).to_int()
                # print(line, vvv)
                insn.data.simd_store[4](icnt * 4, vvv)
                icnt += 1
        return icnt
    
    
            
    @parameter
    fn part1() -> Int64:
        var ret : Int64 = 0
        for i in range(icnt):
            let v = insn.data.simd_load[4](i * 4)
            ret += v.cast[DType.int64]().reduce_add().to_int() * eval(rules, 302, v, v)
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
