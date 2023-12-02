from parser import Parser
from os.atomic import Atomic
from utils.vector import DynamicVector
from wrappers import run_multiline_task


struct MultiMatcher:
    var fcv: DynamicVector[Int8]
    var pfx: DynamicVector[Int32]
    var msk: DynamicVector[Int32]

    fn __init__(inout self):
        self.fcv = DynamicVector[Int8](10)
        self.pfx = DynamicVector[Int32](10)
        self.msk = DynamicVector[Int32](10)

    fn add(inout self, s: String):
        let l = len(s)
        self.fcv.push_back(s._buffer[l - 1])
        var r: Int32 = 0
        var m: Int32 = 0
        for i in range(l - 1):
            r = (r << 8) + ord(s[i])
            m = (m << 8) + 0xFF
        self.pfx.push_back(r)
        self.msk.push_back(m)

    fn check(self, cc: Int8, prev: Int32) -> Int:
        for i in range(10):
            if self.fcv[i] == cc and (prev & self.msk[i]) == self.pfx[i]:
                return i
        return -1


fn main() raises:
    let f = open("day01.txt", "r")
    let p = Parser(f.read())
    var a1 = Atomic[DType.int32](0)
    var a2 = Atomic[DType.int32](0)

    @parameter
    fn digitize1(l: Int):
        let s = p.get(l)
        var d1 = SIMD[DType.int8, 1](0)
        var d2 = SIMD[DType.int8, 1](0)
        let zero = SIMD[DType.int8, 1](ord("0"))
        for i in range(len(s)):
            let c = ord(s[i])
            if c >= ord("0") and c <= ord("9"):
                d1 = c - zero
                break
        for i in range(len(s) - 1, -1, -1):
            let c = ord(s[i])
            if c >= ord("0") and c <= ord("9"):
                d2 = c - zero
                break
        a1 += d1.to_int() * 10 + d2.to_int()

    var m = MultiMatcher()
    var r = MultiMatcher()

    fn reverse(s: String) -> String:
        var r = String()
        for i in range(len(s)):
            r += s[len(s) - i - 1]
        return r

    var words = VariadicList[StringLiteral]("zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine")
    for i in range(len(words)):
        m.add(words[i])
        r.add(reverse(words[i]))

    @parameter
    fn digitize2(l: Int):
        let s = p.get(l)
        var d1 = 0
        var d2 = 0
        let zero = ord('0')
        # last four characters code
        var l4: Int32 = 0
        for i in range(len(s)):
            let c = ord(s[i])
            var d = -1
            if c >= ord("0") and c <= ord("9"):
                d = (c - zero)
            else:
                d = m.check(c, l4)
            # update code
            l4 = (l4 << 8) + c
            if d >= 0:
                d1 = d
                break
        l4 = 0
        for i in range(len(s) - 1, -1, -1):
            let c = ord(s[i])
            var d = -1
            if c >= ord("0") and c <= ord("9"):
                d = (c - zero)
            else:
                d = r.check(c, l4)
            # update code
            l4 = (l4 << 8) + c
            if d >= 0:
                d2 = d
                break

        a2 += d1 * 10 + d2

    @parameter
    fn results():
        print(a1.value.to_int())
        print(a2.value.to_int())
    
    run_multiline_task[digitize1,digitize2](p.length(), results, 12)
    print(p.length(), "rows")