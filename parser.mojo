from utils.vector import DynamicVector


struct Parser:
    """
    This is basically SplitStringUsing(). Give it a String and a separator, take out slices.
    Slices are provided as StringRef's. The string is eaten. Nothing is (or should be) copied.
    """

    # need to hold these
    var contents: DTypePointer[DType.int8]
    var rows: DynamicVector[StringRef]

    # takes ownership of the passed input
    fn __init__(inout self, s: String, sep: StringRef = "\n"):
        let l = len(s)
        self.contents = DTypePointer[DType.int8].alloc(len(s))
        self.rows = DynamicVector[StringRef](10)
        memcpy(self.contents, s._as_ptr(), len(s))
        var start: Int = 0
        while start < l:
            # Find next occurence of the separator
            var end = start + s.find(sep, start)
            # Or the end
            if end < start:
                end = l
            # ignore empty tokens                
            if start == end:
                start += len(sep)
                continue
            # Pre-create the StringRef's
            self.rows.push_back(StringRef(self.contents.offset(start), end - start))
            start = end + len(sep)

    # return view of the selected row / item
    fn get(self, row: Int) -> StringRef:
        return self.rows[row]

    fn length(self) -> Int:
        return self.rows.size


# small tests
fn main():
    let a = Parser("abc\ndef\nghi")
    for i in range(a.length()):
        print(a.get(i))
    print(a.length())
    let b = Parser("abc, def; ghi; foo", "; ")
    for i in range(b.length()):
        print(b.get(i))
    let c = Parser("10 20 3", " ")
    for i in range(c.length()):
        print(c.get(i))
