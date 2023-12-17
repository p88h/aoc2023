from parser import *
from os.atomic import Atomic
from utils.vector import DynamicVector
from wrappers import run_multiline_task


struct MultiMatcher:
    """
    In part 2, this code implements a Rabin-Karp style multi-pattern matcher.
    To simplify things, since patterns are up to 5 chars, we keep a unique
    code that represents the last four characters by simply packing them into
    an integer. The match is executed by looking up which patterns end in the
    _current_ letter and then checking if the code for the last 4 letters match.
    Shorter words are appropriately masked, so that we only check appropriate
    number of bytes always.
    """

    # These holds the decomposed representation of inserted patterns: final character,
    # prefix code, and byte mask, respectively. This could have used a struct, but you
    # can't stuff arbitrary types into a DynamicVector.
    # You can stuff Tuples, apparently, but tuple handling in Mojo is a bit awkward too.
    var fcv: DynamicVector[Int8]
    var pfx: DynamicVector[Int32]
    var msk: DynamicVector[Int32]

    fn __init__(inout self, words: VariadicList[StringLiteral]):
        # Pre-allocate just enough capacity
        self.fcv = DynamicVector[Int8](10)
        self.pfx = DynamicVector[Int32](10)
        self.msk = DynamicVector[Int32](10)
        for i in range(len(words)):
            self.add(words[i])

    fn add(inout self, s: String):
        let l = len(s)
        # s._buffer[l - 1] == ord(s[i]); but works faster it seems
        # Not sure if accessing _buffer is discouraged? Probably will break one day.
        self.fcv.push_back(s._buffer[l - 1])
        var r: Int32 = 0
        var m: Int32 = 0
        # While iterators are supported in Mojo, none of the standard library
        # types implement them, have to use range(), which does work.
        for i in range(l - 1):
            r = (r << 8) + s._buffer[i].to_int()
            m = (m << 8) + 0xFF
        self.pfx.push_back(r)
        self.msk.push_back(m)

    fn check(self, cc: Int8, prev: Int32) -> Int:
        # check all patterns
        for i in range(10):
            if self.fcv[i] == cc and (prev & self.msk[i]) == self.pfx[i]:
                return i
        return -1

fn main() raises:
    let f = open("day01.txt", "r")
    let p = make_parser['\n'](f.read())
    # Since we want the parallel code to work correctly, we store the sums in atomic integers
    var a1 = Atomic[DType.int32](0)
    var a2 = Atomic[DType.int32](0)
    # Used in place of ord('0') and ord('9') which were super slow at runtime
    alias zero = ord('0')
    alias nine = ord('9')

    # This function processes a single line of the input for task one and increments the sum as needed.
    @parameter
    fn digitize1(l: Int):
        let s = p.get(l)
        var d1 = 0
        var d2 = 0
        # Check forward to find first digit
        for i in range(s.size):
            let c = s[i].to_int()
            if c >= zero and c <= nine:
                d1 = c - zero
                break
        # Check backward to find last digit
        for i in range(s.size - 1, -1, -1):
            let c = s[i].to_int()
            if c >= zero and c <= nine:
                d2 = c - zero
                break
        # That's it
        a1 += d1 * 10 + d2

    # Construct matchers for all words. When looking backwards, the words have to be reversed.
    # Fun fact - VariadicList apparently can hold literals, but cannot hold Strings.
    # Variadic since other list variants only make sense in some very specific contexts
    # like when you only use predetermined list sizes and don't iterate over the list.
    let m = MultiMatcher(VariadicList[StringLiteral]("zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"))
    let r = MultiMatcher(VariadicList[StringLiteral]("orez", "eno", "owt", "eerht", "ruof", "evif", "xis", "neves", "thgie", "enin"))

    # Similar to the part 1, this does the digits checks and also uses the multi-matchers
    # to find words.
    @parameter
    fn digitize2(l: Int):
        let s = p.get(l)
        var d1 = 0
        var d2 = 0
        # last four characters code
        var l4: Int32 = 0
        for i in range(s.size):
            let c = s[i].to_int()
            var d = -1
            if c >= zero and c <= nine:
                d = c - zero
            else:
                d = m.check(c, l4)
            # update code
            l4 = (l4 << 8) + c
            if d >= 0:
                d1 = d
                break
        l4 = 0
        for i in range(s.size - 1, -1, -1):
            let c = s[i].to_int()
            var d = -1
            if c >= zero and c <= nine:
                d = c - zero
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

    # this wraps executing the step functions, benchmarking them etc.
    run_multiline_task[digitize1, digitize2](p.length(), results, 12)

    # While this looks like debug info, Mojo actually sometimes forgets I need the parser in all these step
    # tasks, and happily crashes rather than keeping it around. This holds it in place until that happens.
    print(p.length(), "rows")
    print(m.pfx.size, "prefixes")
    print(r.pfx.size, "rprefixes")
