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
        ret = ret * 26 + (int(s[i])) - orda
    return ret

fn main() raises:
    f = open("day20.txt", "r")
    lines = make_parser["\n"](f.read())
    modules = Array[DType.int64](64)
    masks = Array[DType.int64](64)
    counts = Array[DType.int64](64)
    conns = Array[DType.int8](9*64)
    mapping = Array[DType.int8](32*32)
    pulses = Array[DType.int8](16000)

    @parameter
    fn parse() -> Int64:
        masks.zero()
        conns.zero()
        mapping.zero()
        var cnt = 1
        for i in range(lines.length()):
            line = lines[i]
            alias cGt = ord('>')
            p = line.find(cGt)
            if p < 0:
                continue
            alias cb = ord('b')
            alias cOmma = ord(',')
            r = make_parser[cOmma](line[p+1:line.size])
            var c = SIMD[DType.int8, 8](0)
            c[0] = r.length()
            for i in range(r.length()):
                code = encode(r[i][1:r[i].size])
                var d : Int = int(mapping[code])
                if d == 0: 
                    #print("map",r[i][1:r[i].size],"via",code,"to",cnt)
                    mapping[code] = d = cnt
                    cnt += 1
                c[i+1] = d
            var op : Int64
            var id : Int
            if line[0] != cb:
                code = encode(line[1:p-2])
                if mapping[code] == 0:
                    #print("map",line[1:p-2],"via",code,"to",cnt)
                    mapping[code] = cnt
                    cnt += 1
                id = int(mapping[code])
                alias cAnd = ord('&')
                op = (int(line[0]) ^ 36) << 60
            else:
                id = 0
                op = 0
            for i in range(int(c[0])):
                d = int(c[i+1])
                conns[d] += 1
                masks[d] |= 1<<id
            conns.data.store[width=8](64 + id * 8, c)
            #print(line[0:p-2],id,c)
            modules[id] = op
        return cnt
    
    @parameter
    fn push() -> SIMD[DType.int32, 2]:
        var pi = 0
        var pc = 2
        var pcnt = SIMD[DType.int32, 2](0,0)
        pulses[0] = 0
        pulses[1] = 0
        while pi < pc:
            src = int(pulses[pi]) 
            dst = int(pulses[pi+1] & 63)
            var level = int(pulses[pi+1] >> 6)
            var module = modules[dst]
            c = conns.data.load[width=8](64+dst * 8)
            op = (module >> 60)
            pcnt[level] += 1
            #print(pi//2,src,dst,level,"|",module&~(op<<60),op,masks[dst])
            pi += 2
            if op == 1: # %
                if level == 0:
                    module ^= 1
                    level = int(module) & 1
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
            for i in range(int(c[0])):
                pulses[pc] = dst
                pulses[pc+1] = c[i+1] + (level << 6)
                #print(level,">",c[i+1])
                pc += 2            
        #print()
        return pcnt

    @parameter
    fn reset():
        counts.zero()
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
        fid = int(mapping[465]) # rx
        var monitor = -1
        for i in range(64):
            c = conns.data.load[width=8](64+i * 8)
            for j in range(int(c[0])):
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

    minibench[parse]("parse")
    minibench[part1]("part1")
    minibench[part2]("part2")

    print(lines.length(), "lines")
    print(modules.bytecount() + counts.bytecount() + masks.bytecount(), "module data total size")
    print(conns.bytecount() + mapping.bytecount() + pulses.bytecount(), "extra arrays total size")
