from parser import *
from wrappers import minibench
from array import Array

# Encode a string label into an integer code 
@always_inline
fn encode(s: StringSlice) -> Int:
    alias orda = ord('a') 
    var ret = 0
    for i in range(s.size):
        if i == 2:
            break
        ret = ret * 26 + (s[i].to_int()) - orda
    return ret


fn main() raises:
    let f = open("day20.txt", "r")
    let lines = make_parser["\n"](f.read())
    let modules = Array[DType.int64](64)
    let masks = Array[DType.int64](64)
    let counts = Array[DType.int64](64)
    let conns = Array[DType.int8](64+64*8)
    let mapping = Array[DType.int8](26*26)
    var pulses = Array[DType.int8](16000)

    @parameter
    fn parse() -> Int64:
        conns.clear()
        mapping.clear()        
        var cnt = 1
        for i in range(lines.length()):
            let line = lines[i]
            alias cGt = ord('>')
            let p = line.find(cGt)
            if p < 0:
                continue
            alias cb = ord('b')
            alias cOmma = ord(',')
            let r = make_parser[cOmma](line[p+1:line.size])
            var c = SIMD[DType.int8, 8](0)
            c[0] = r.length()
            for i in range(r.length()):
                let code = encode(r[i][1:r[i].size])
                var d : Int = mapping[code].to_int()
                if d == 0: 
                    #print("map",r[i][1:r[i].size],"via",code,"to",cnt)
                    mapping[code] = d = cnt
                    cnt += 1
                c[i+1] = d
            let op : Int64
            let id : Int
            if line[0] != cb:
                let code = encode(line[1:p-2])
                if mapping[code] == 0:
                    #print("map",line[1:p-2],"via",code,"to",cnt)
                    mapping[code] = cnt
                    cnt += 1
                id = mapping[code].to_int()
                alias cAnd = ord('&')
                op = (line[0].to_int() ^ 36) << 60
            else:
                id = 0
                op = 0
            for i in range(c[0].to_int()):
                let d = c[i+1].to_int()
                conns[d] += 1
                masks[d] |= 1<<id
            conns.data.aligned_simd_store[8,8](64 + id * 8, c)
            #print(line[0:p-2],id,c)
            modules[id] = op
        return cnt
    
    @parameter
    fn push() -> SIMD[DType.int32, 2]:
        var pi = 0
        var pc = 2                        
        var pcnt = SIMD[DType.int32, 2](0,0)
        while pi < pc:
            let src = pulses[pi].to_int() 
            let dst = (pulses[pi+1] & 63).to_int()
            var level = (pulses[pi+1] >> 6).to_int()
            var module = modules[dst]
            let c = conns.data.aligned_simd_load[8,8](64+dst * 8)
            let op = (module >> 60)            
            pcnt[level] += 1
            # print(pi//2,src,dst,level,"|",module,op)
            pi += 2
            if op == 1: # %
                if level == 0:
                    module ^= 1
                    level = module.to_int() & 1
                else:
                    # ignore high signals
                    continue
            elif op == 2: # &
                counts[dst] |= level << src
                module &= ~(1 << src)
                module |= (level << src)
                if module & masks[dst] == masks[dst]:
                    level = 0
                else:
                    level = 1    
            # update module state
            modules[dst] = module
            # now broadcast from src
            for i in range(c[0].to_int()):
                pulses[pc] = dst
                pulses[pc+1] = c[i+1] + (level << 6)
                pc += 2            
        #print()
        return pcnt

    @parameter
    fn reset():
        counts.clear()
        for m in range(64):
            modules[m] &= (3<<60)

    @parameter
    fn part1() -> Int64:
        reset()
        var ptot = SIMD[DType.int32, 2](0,0)
        for _ in range(1000):
            ptot += push()
        return ptot[0].cast[DType.int64]()*ptot[1].cast[DType.int64]()
            
    @parameter
    fn part2() -> Int64:
        reset()
        var cnt = 0
        var prod = 1
        var seen : Int64 = 0
        let fid = mapping[465].to_int() # rx
        var monitor = -1
        for i in range(64):
            let c = conns.data.aligned_simd_load[8,8](64+i * 8)
            for j in range(c[0].to_int()):
                if c[j+1] == fid:
                    monitor = i
        while counts[fid] == 0:
            _ = push()
            cnt += 1
            if counts[monitor] != seen:
                seen = counts[monitor]
                prod *= cnt
                if seen == masks[monitor]:
                    return prod
        return cnt

    #print(parse())
    #print(part1())
    #print(part2())
    minibench[parse]("parse")
    minibench[part1]("part1")
    minibench[part2]("part2")

    print(lines.length(), "lines")
    print((modules.size + counts.size + masks.size) * 8, "module data total size")
    print(conns.size + mapping.size + pulses.size, "extra arrays total size")
