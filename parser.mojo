from utils.vector import DynamicVector

@value
struct StringSlice(CollectionElement, Stringable):
    """
    Represents a view of some string, with basic access primitives. 
    Since it's a @value, it also automatically implements @CollectionElement 
    which is nice - no extra boilerplate needed.
    """
    var ptr: DTypePointer[DType.int8]
    var size: Int

    fn get(self) -> StringRef:
        return StringRef(self.ptr, self.size)

    fn find(self, what: Int8, start: Int = 0) -> Int:
        for i in range(start, self.size):
            if self.ptr[i] == what:
                return i
        return -1

    fn __str__(self) -> String:
        return String(self.get())

    fn __getitem__(self, idx: Int) -> Int8:
        return self.ptr[idx]

    fn __getitem__(self, idxs: slice) -> StringSlice:
        var end = idxs.end
        if end > self.size:
            end = self.size
        return StringSlice(self.ptr.offset(idxs.start), end - idxs.start)


# Custom string-to-int which skips spaces, and works on StringSlices
fn atoi(s: StringSlice) -> Int64:
    alias zero = ord('0')
    alias space = ord(' ')
    alias minus = ord('-')
    var ret: Int = 0
    var sign: Int = 1
    for i in range(s.size):
        let c = s.ptr[i].to_int()
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
        let c = s.ptr[i].to_int()
        let v : Int
        if (c | 32) >= orda: 
            v = ((c | 32) + 10) - orda
        else:
            v = c - zero
        ret = ret * 16 + v 
    return ret


struct Parser:
    """
    This is basically SplitStringUsing(). Give it a String and a separator, take out slices.
    Slices are provided as StringSlice. When parsing from String, copies memory.
    Parsing from Slice only uses the reference.
    """

    # need to hold these
    var contents: DTypePointer[DType.int8]
    var rows: DynamicVector[StringSlice]
    var ptr_size: Int

    # Parse a string with a fixed char delimiter
    fn __init__(inout self, s: String):
        self.ptr_size = len(s)
        self.contents = DTypePointer[DType.int8].alloc(self.ptr_size)
        self.rows = DynamicVector[StringSlice](10)
        memcpy(self.contents, s._as_ptr(), self.ptr_size)

    # Re-parse another StringSlice with a fixed-char delimiter
    fn __init__(inout self, s: StringSlice):
        self.contents = s.ptr
        self.rows = DynamicVector[StringSlice](4)
        self.ptr_size = s.size

    fn __moveinit__(inout self, owned other: Self):
        self.contents = other.contents ^
        self.rows = other.rows ^
        self.ptr_size = other.ptr_size

    fn __getitem__(self, idx: Int) -> StringSlice:
        return self.rows[idx]

    fn parse[sep: Int8](inout self, skip_empty: Bool = True):
        var start: Int = 0
        for i in range(self.ptr_size):
            if self.contents[i] == sep:
                if i != start or not skip_empty:
                    self.rows.push_back(StringSlice(self.contents.offset(start), i - start))
                start = i + 1
        if start < self.ptr_size or (start == self.ptr_size and not skip_empty):
            self.rows.push_back(StringSlice(self.contents.offset(start), self.ptr_size - start))

    # return view of the selected row / item
    fn get(self, row: Int) -> StringSlice:
        return self.rows[row]

    fn length(self) -> Int:
        return self.rows.size


# Since constructors cannot be parametrized, passing the const separator via
# a helper function. Need two of those for each of the source types. 
fn make_parser[sep: Int8](s: String, skip_empty: Bool = True) -> Parser:
    var p = Parser(s)
    p.parse[sep](skip_empty)
    return p ^

fn make_parser[sep: StringLiteral](s: String, skip_empty: Bool = True) -> Parser:
    return make_parser[ord(sep)](s, skip_empty)

fn make_parser[sep: Int8](s: StringSlice, skip_empty: Bool = True) -> Parser:
    var p = Parser(s)
    p.parse[sep](skip_empty)
    return p ^

fn make_parser[sep: StringLiteral](s: StringSlice, skip_empty: Bool = True) -> Parser:
    return make_parser[ord(sep)](s, skip_empty)

# small tests
fn main():
    let a = make_parser[10]("abc\ndef\nghi")
    for i in range(a.length()):
        print(a.get(i).get())
    print(a.length())
    let b = make_parser[59]("abc, def; ghi; foo")
    for i in range(b.length()):
        print(b.get(i).get())
    let c = make_parser[32]("10 20 3")
    for i in range(c.length()):
        print(c.get(i).get())

    let s: StringSlice = c.get(1)
    print(s[1])

    let d = make_parser[10]("This is a test")
    print(d.get(0)[:5])
    print(d.get(0)[5:])
    let e = make_parser[32](d.get(0))
    for i in range(e.length()):
        print(e.get(i).get())

    let n = make_parser[32]("1 2 3")
    for i in range(n.length()):
        print(atoi(n[i]))

