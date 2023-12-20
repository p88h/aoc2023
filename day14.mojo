from parser import *
from wrappers import minibench
from array import Array
from collections.vector import DynamicVector


fn main() raises:
    let f = open("day14.txt", "r")
    let lines = make_parser["\n"](f.read(), False)
    let dim = lines.length()
    var pebv = DynamicVector[Tuple[Int, Int]](1000)
    # work buffers
    var rocks = Array[DType.int32](128 * 128 * 4)
    var pebtmp = Array[DType.int32](128 * 128)
    var pebbles = Array[DType.int32](0)
    alias modulus = 999983
    var hashtab = Array[DType.int32](1000000)

    # input is either fully sorted - first by Y (first coord) then X (second)
    # or just by X. In fist case this will create groups, each with new different
    # and those groups will still be internally sorted by Y, or it will be sorted
    # by new Y, which still allows them to be trivially grouped by X.
    fn rot90(inout ppos: Array[DType.int32], m: Int):
        for i in range(ppos.size // 2):
            let y = ppos[2 * i]
            let x = ppos[2 * i + 1]
            ppos[2 * i] = x
            ppos[2 * i + 1] = m - y - 1

    # group points by X. as long as the points were somewhat / partially sorted by Y,
    # (see above) groups will be sorted by Y
    fn groupbyx(ppos: Array[DType.int32], inout work: Array[DType.int32], ofs: Int, m: Int):
        for x in range(m):
            work[ofs + 128 * x] = 0
        for i in range(ppos.size // 2):
            let y = ppos[2 * i]
            let x = ppos[2 * i + 1].to_int()
            let o = work[ofs + 128 * x].to_int() + 1
            work[ofs + 128 * x + o] = y
            work[ofs + 128 * x] = o

    @parameter
    fn reset():
        for i in range(pebv.size):
            pebbles[2 * i] = pebv[i].get[0, Int]()
            pebbles[2 * i + 1] = pebv[i].get[1, Int]()

    @parameter
    fn parse() -> Int64:
        var rockv = DynamicVector[Tuple[Int, Int]](1000)
        pebv.clear()
        # parse the map and store objects
        for y in range(dim):
            for x in range(dim):
                alias cO = ord("O")
                if lines[y][x] == cO:
                    pebv.push_back((y, x))
                alias cHash = ord("#")
                if lines[y][x] == cHash:
                    rockv.push_back((y, x))
        pebbles = Array[DType.int32](pebv.size * 2)
        var tmp = Array[DType.int32](rockv.size * 2)
        for i in range(rockv.size):
            tmp[2 * i] = rockv[i].get[0, Int]()
            tmp[2 * i + 1] = rockv[i].get[1, Int]()
        # keep rocks pre-grouped by x; and pre-rotated in 4 directions
        for i in range(4):
            let ofs = 128 * 128 * i
            groupbyx(tmp, rocks, ofs, dim)
            var j = 0
            # flatten tmp
            for x in range(dim):
                for o in range(rocks[ofs + 128 * x].to_int()):
                    tmp[2 * j] = rocks[ofs + 128 * x + o + 1]
                    tmp[2 * j + 1] = x
                    j += 1
            rot90(tmp, dim)
        return pebbles.size // 2

    @parameter
    fn tilt(rpos: Int):
        # Distribute pebbles along the x axis.
        groupbyx(pebbles, pebtmp, 0, dim)
        var np = 0
        # take each column
        for x in range(dim):
            var ofs = 0
            var wp = 0
            var rp = 0
            # if there are any rocks AND pebbles remaining:
            while wp < pebtmp[128 * x].to_int() and rp < rocks[rpos + 128 * x].to_int():
                # next rock and pebble y
                let rocky = rocks[rpos + 128 * x + rp + 1]
                let pebby = pebtmp[128 * x + wp + 1]
                # rock is lower than the pebble. consume the rock.
                # set ofs (next viable pebble position) to rocky + 1
                if rocky < pebby:
                    ofs = rocky.to_int() + 1
                    rp += 1
                # consume the pebble, shift it to ofs and update ofs
                else:  # pebby < rocky:
                    pebbles[np * 2] = ofs
                    pebbles[np * 2 + 1] = x
                    np += 1
                    ofs += 1
                    wp += 1
            # consume remaining pebbles:
            while wp < pebtmp[128 * x].to_int():
                pebbles[np * 2] = ofs
                pebbles[np * 2 + 1] = x
                np += 1
                ofs += 1
                wp += 1

    fn load(ppos: Array[DType.int32], m: Int) -> Int:
        var sum = 0
        for i in range(ppos.size // 2):
            sum += m - ppos[2 * i].to_int()
        return sum

    @parameter
    fn part1() -> Int64:
        reset()
        tilt(0)
        return load(pebbles, dim)

    # 32-bit FNV1a hash of the positions.
    # Each value is already in byte range.
    fn fnv1a(ppos: Array[DType.int32]) -> Int:
        var hash: Int32 = 2166136261
        for i in range(ppos.size):
            hash = (hash ^ ppos[i]) * 16777619
        return hash.to_int()

    @parameter
    fn part2() -> Int64:
        reset()
        hashtab.clear()
        var vals = DynamicVector[Int](100)
        var hash = fnv1a(pebbles) % modulus
        while hashtab[hash] == 0:
            hashtab[hash] = vals.size
            vals.push_back(load(pebbles, dim))
            for i in range(4):
                tilt(i * 128 * 128)
                rot90(pebbles, dim)
            hash = fnv1a(pebbles) % modulus
        let cycle_length = vals.size - hashtab[hash].to_int()
        let remaining = (1000000000 - vals.size) % cycle_length
        return vals[hashtab[hash].to_int() + remaining]

    minibench[parse]("parse")
    minibench[part1]("part1")
    minibench[part2]("part2")

    print(lines.length(), dim, "lines")
    print(pebv.size, "pebbles")
    print(pebbles.size, "pebble buffer")
    print(rocks.size, "rock buffer")
    print(pebtmp.size, "temp buffer")
    print(hashtab.size, "hash entries")
