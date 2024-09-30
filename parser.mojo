from memory.unsafe_pointer import UnsafePointer
from memory import memcpy
from collections import List

from wrappers import minibench

@value
struct StringSlice(CollectionElement, Stringable, Formattable):
    """
    Represents a view of some string, with basic access primitives. 
    Since it's a @value, it also automatically implements @CollectionElement 
    which is nice - no extra boilerplate needed.
    """
    var ptr: UnsafePointer[UInt8]
    var size: Int

    fn get(self) -> StringRef:
        return StringRef(self.ptr, self.size)

    fn find(self, what: UInt8, start: Int = 0) -> Int:
        for i in range(start, self.size):
            if self.ptr[i] == what:
                return i
        return -1

    fn __str__(self) -> String:
        return String(self.get())

    fn __getitem__(self, idx: Int) -> UInt8:
        return self.ptr[idx]

    fn __getitem__(self, idxs: Slice) -> StringSlice:
        var end = idxs.end.or_else(self.size + 1)
        if end > self.size:
            end = self.size
        start = idxs.start.or_else(0)
        return StringSlice(self.ptr.offset(start), end - start)
    
    fn format_to(self, inout writer: Formatter):
        writer.write(str(self))



# Convert a line to a packet SIMD list, with some customization over skipping and stuff
fn atomi[width: Int, AType: DType, skipspace: Bool = True, negative: Bool = True](s: StringSlice) -> SIMD[AType, width]:
    alias zero = ord('0')
    alias nine = ord('9')
    alias minus = ord('-')
    alias space = ord(' ')
    var ret = SIMD[AType, width](0)
    var rp = 0
    var sign: Int = 1
    for i in range(s.size):
        c = int(s[i])
        if c >= zero and c <= nine:
            ret[rp] = ret[rp] * 10 + c - zero
        elif negative and c == minus:
            sign = -1
        elif skipspace and c == space:
            continue
        else:
            if negative:
                ret[rp] *= sign
                sign = 1
            rp += 1
    if negative:
        ret[rp] *= sign
    return ret

# Custom string-to-int which skips spaces, and works on StringSlices
fn atoi(s: StringSlice) -> Int64:
    alias zero = ord('0')
    alias space = ord(' ')
    alias minus = ord('-')
    var ret: Int = 0
    var sign: Int = 1
    for i in range(s.size):
        c = int(s[i])
        if c == minus:
            sign = -1
        elif c != space:
            ret = ret * 10 + c - zero
    return ret * sign

# converts a hex string to number
fn xtoi(s: StringSlice) -> Int64:
    alias orda = ord('a')
    alias zero = ord('0')
    var ret: Int = 0
    for i in range(s.size):
        c = int(s[i])
        if (c | 32) >= orda: 
            v = ((c | 32) + 10) - orda
        else:
            v = c - zero
        ret = ret * 16 + v 
    return ret

@value
struct Parser:
    """
    This is basically SplitStringUsing(). Give it a String and a separator, take out slices.
    Slices are provided as StringSlice. When parsing from String, copies memory.
    Parsing from Slice only uses the reference.
    """

    # need to hold these
    var contents: UnsafePointer[UInt8]
    var rows: List[StringSlice]
    var ptr_size: Int
    var own: Bool

    # Parse a string with a fixed char delimiter
    fn __init__(inout self, s: String):
        self.ptr_size = len(s)
        self.contents = UnsafePointer[UInt8].alloc(self.ptr_size)
        self.own = True
        self.rows = List[StringSlice]()
        memcpy(self.contents, s.unsafe_ptr(), self.ptr_size)

    fn __del__(owned self):
        if self.own:
            self.contents.free()

    # Re-parse another StringSlice with a fixed-char delimiter
    fn __init__(inout self, s: StringSlice):
        self.own = False
        self.contents = s.ptr
        self.rows = List[StringSlice]()
        self.ptr_size = s.size

    fn __moveinit__(inout self, owned other: Self):
        self.contents = other.contents
        self.rows = other.rows ^
        self.ptr_size = other.ptr_size
        self.own = other.own
        other.own = False

    fn __getitem__(self, idx: Int) -> StringSlice:
        return self.rows[idx]

    fn parse[sep: UInt8](inout self, skip_empty: Bool = True):
        var start: Int = 0
        for i in range(self.ptr_size):
            if self.contents[i] == sep:
                if i != start or not skip_empty:
                    self.rows.append(StringSlice(self.contents.offset(start), i - start))
                start = i + 1
        if start < self.ptr_size or (start == self.ptr_size and not skip_empty):
            self.rows.append(StringSlice(self.contents.offset(start), self.ptr_size - start))

    # return view of the selected row / item
    fn get(self, row: Int) -> StringSlice:
        return self.rows[row]

    fn length(self) -> Int:
        return self.rows.size


# Since constructors cannot be parametrized, passing the const separator via
# a helper function. Need two of those for each of the source types. 
fn make_parser[sep: UInt8](s: String, skip_empty: Bool = True) -> Parser:
    var p = Parser(s)
    p.parse[sep](skip_empty)
    return p ^

fn make_parser[sep: StringLiteral](s: String, skip_empty: Bool = True) -> Parser:
    return make_parser[ord(sep)](s, skip_empty)

fn make_parser[sep: UInt8](s: StringSlice, skip_empty: Bool = True) -> Parser:
    var p = Parser(s)
    p.parse[sep](skip_empty)
    return p ^

fn make_parser[sep: StringLiteral](s: StringSlice, skip_empty: Bool = True) -> Parser:
    return make_parser[ord(sep)](s, skip_empty)

# small tests
fn main() raises:
    a = make_parser[10]("abc\ndef\nghi")
    for i in range(a.length()):
        print(a.get(i).get())
    print(a.length())
    b = make_parser[59]("abc, def; ghi; foo")
    for i in range(b.length()):
        print(b.get(i).get())
    c = make_parser[32]("10 20 3")
    for i in range(c.length()):
        print(c.get(i).get())

    s = c.get(1)
    print(s[1])

    d = make_parser[10]("This is a test")
    print(d.get(0)[:5])
    print(d.get(0)[5:])
    e = make_parser[32](d.get(0))
    for i in range(e.length()):
        print(e.get(i).get())

    n = make_parser[32]("1 2 3")
    for i in range(n.length()):
        print(atoi(n[i]))

    print(a.length(),b.length(),c.length(),d.length(),e.length(),n.length())

    sf = open("day13.txt", "r").read()

    @parameter
    fn splitParse() -> Int64 :
        try:
            lines = sf.split("\n")
            return len(lines)
        except:
            return 0
        

    @parameter
    fn customParse() -> Int64:
        lines = make_parser["\n"](sf, False)
        return lines.length()

    
    minibench[splitParse]("string.split")
    minibench[customParse]("make_parser")
    
    

