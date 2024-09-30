from parser import *
from wrappers import minibench
from array import Array


fn main() raises:
    f = open("day15.txt", "r")
    tokens = make_parser[","](f.read())
    var boxes = Array[DType.uint32](256 * 16)
    alias modulus = 999983

    # AOC task hash function
    fn hash(s: StringSlice) -> Int:
        var v = 0
        for i in range(s.size): 
            v = int((v + s[i].cast[DType.uint8]()) * 17) & 255
        return v
    
    @parameter
    fn part1() -> Int64:
        var sum = 0
        for i in range(tokens.length()):
            sum += hash(tokens[i])
        return sum

    # a slightly better hash function
    fn fnv1a(s: StringSlice) -> UInt32:
        var hash: UInt32 = 2166136261
        for i in range(s.size):
            hash = (hash ^ s[i].cast[DType.uint32]()) * 16777619
        return hash

    @parameter
    fn part2() -> Int64:
        for i in range(256):
            boxes[i*16] = 1            
        for t in range(tokens.length()):
            tok = tokens[t]
            alias cDash = ord('-')
            if tok[tok.size-1] == cDash:
                l = tok[:tok.size-1]
                hc = hash(l)
                fc = fnv1a(l) % modulus
                var d = 0
                # remove fc from box
                for i in range(1,int(boxes[hc*16])):
                    if boxes[hc*16+i] & 0xFFFFFF == fc:
                        d = 1
                    elif d > 0:
                        boxes[hc*16+i-d] = boxes[hc*16+i] 
                if d > 0:
                    boxes[hc*16] -= d
            else: # =X
                l = tok[:tok.size-2]
                hc = hash(l)
                fc = fnv1a(l) % modulus
                alias cZero = ord('0')
                st = (tok[tok.size-1] - cZero).cast[DType.uint32]() << 24
                var add = True
                # add (fc,st) to box
                for i in range(1,int(boxes[hc*16])):
                    if boxes[hc*16+i] & 0xFFFFFF == fc:
                        boxes[hc*16+i] = st + fc
                        add = False
                        break
                if add:
                    boxes[hc*16 + int(boxes[hc*16])] = st + fc
                    boxes[hc*16] += 1
        var sum = 0
        for i in range(256):
            for j in range(1, int(boxes[i*16])):
                sum += (i+1)*j*int(boxes[i*16+j] >> 24)
        return sum       

    minibench[part1]("part1")
    minibench[part2]("part2")

    print(tokens.length(), "tokens")
    print(boxes.bytecount(), "boxes")
