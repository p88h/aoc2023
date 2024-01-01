from parser import *
from algorithm import parallelize
from wrappers import minibench
from memory import memset


struct MicroSet:
    """
    Helper to classify character sets. Only works for characters in the map (L-|F7J.S).
    """

    var bits: Int

    # Initialize and insert all chars
    fn __init__(inout self, chars: String):
        self.bits = 0
        for i in range(len(chars)):
            # Use &0x1F as the 'hash function' because it's enough and allows to store
            # result space into bits of an integer.
            let ofs = chars._buffer[i].to_int() & 0x1F
            self.bits |= 1 << ofs

    fn contains(self, code: Int8) -> Bool:
        return self.bits & (1 << (code.to_int() & 0x1F)) != 0

@value
struct MicroMap[VType: DType, width: Int](CollectionElement):
    """
    This MicroMap allows to assign some integer value to characters.
    Works just like MicroSet, but with values.
    Stores data in a SIMD vector. Which is probably an overkill.
    """

    var items: DTypePointer[VType]

    fn __init__(inout self):
        self.items = DTypePointer[VType].aligned_alloc(32, 128)
        memset(self.items, 0, 128)

    fn __del__(owned self):
        self.items.free()

    fn __getitem__(self, key: Int8) -> SIMD[VType, width]:
        let ofs = (key.to_int() & 0x1F) * width
        return self.items.aligned_simd_load[width, 32](ofs)

    fn __getitem__(self, key: String) -> SIMD[VType, width]:
        return self[key._buffer[0]]

    fn __setitem__(inout self, key: Int8, value: SIMD[VType, width]):
        let ofs = (key.to_int() & 0x1F) * width
        self.items.aligned_simd_store[width, 32](ofs, value)

    fn __setitem__(inout self, key: String, value: SIMD[VType, width]):
        self[key._buffer[0]] = value


fn main() raises:
    let f = open("day10.txt", "r")
    let lines = make_parser['\n'](f.read())
    let distance = DTypePointer[DType.int32].alloc(lines.length() * 256)
    var sum = Atomic[DType.int64](0)

    alias map_type = DType.int16

    fn build_dirmap() -> MicroMap[map_type, 4]:
        var mapping = MicroMap[map_type, 4]()
        mapping["7"] = SIMD[map_type, 4](0, -1, 1, 0)
        mapping["J"] = SIMD[map_type, 4](0, -1, -1, 0)
        mapping["-"] = SIMD[map_type, 4](0, 1, 0, -1)
        mapping["L"] = SIMD[map_type, 4](0, 1, -1, 0)
        mapping["F"] = SIMD[map_type, 4](1, 0, 0, 1)
        mapping["|"] = SIMD[map_type, 4](1, 0, -1, 0)
        return mapping ^

    @parameter
    fn part1() -> Int64:
        memset(distance, 0, lines.length() * 256)
        var sy = 0
        var sx = 0
        for y in range(lines.length()):
            alias cS = ord("S")
            let pos = lines[y].find(cS)
            if pos >= 0:
                sy = y
                sx = pos
                break
        let start = (sy << 8) + sx
        distance[start] = 1
        # Figure out where to go from here, looking at neighbors.
        var current = start
        alias h1 = MicroSet("J-7")
        if h1.contains(lines[sy][sx + 1]):
            current = (sy << 8) + sx + 1
        alias h2 = MicroSet("L-F")
        if h2.contains(lines[sy][sx - 1]):
            current = (sy << 8) + sx - 1
        alias v1 = MicroSet("F|7")
        if v1.contains(lines[sy - 1][sx]):
            current = ((sy - 1) << 8) + sx
        alias v2 = MicroSet("L|J")
        if v2.contains(lines[sy + 1][sx]):
            current = ((sy + 1) << 8) + sx
        distance[current] = 1
        let mapping = build_dirmap()
        var dst = 1
        var prev = start
        while current != start:
            dst += 1
            distance[current] = dst
            let y = current >> 8
            let x = current & 0xFF
            let tup = mapping[lines[y][x]]
            var next = (((y + tup[0].to_int()) << 8) + x + tup[1].to_int())
            if next == prev:
                next = ((y + tup[2].to_int()) << 8) + x + tup[3].to_int()
            prev = current
            current = next
        return dst // 2

    @parameter
    fn step2(y: Int):
        var skip = 32
        var out = True
        var cnt = 0
        for x in range(lines[y].size):
            if distance[(y << 8) + x] != 0:
                alias cF = ord("F")
                alias cL = ord("L")
                alias cD = ord("-")
                alias c7 = ord("7")
                alias cJ = ord("J")
                # start of the fence, maybe
                if lines[y][x] == cF:
                    skip = c7
                elif lines[y][x] == cL:
                    skip = cJ
                elif lines[y][x] == cD:
                    # walking along the fence, whatever.
                    continue
                else:
                    # equivalent to "|" now
                    if lines[y][x] != skip:
                        out = not out
                    # stop walking along the fence
                    skip = 32
            elif not out:
                cnt += 1
        sum += cnt

    @parameter
    fn part2() -> Int64:
        sum = 0
        for y in range(lines.length()):
            step2(y)
        return sum.value

    @parameter
    fn part2_parallel() -> Int64:
        sum = 0
        parallelize[step2](lines.length(), 4)
        return sum.value

    minibench[part1]("part1")
    minibench[part2]("part2")
    minibench[part2_parallel]("part2 parallel")

    print(lines.length(), "lines")
    distance.free()
