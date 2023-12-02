from utils.vector import DynamicVector

struct Parser:
    # need to hold these
    var contents: String
    var rows: DynamicVector[StringRef]

    # takes ownership of the passed input
    fn __init__(inout self, owned s: String, sep: StringRef = "\n"):
        let l = len(s)
        self.contents = s^
        self.rows = DynamicVector[StringRef](10)
        var start: Int = 0
        while start < l:
            var end = start + self.contents.find(sep, start)
            if end < start:
                end = l
            self.rows.push_back(StringRef(self.contents._as_ptr().offset(start), end-start))
            start = end + len(sep)
    
    # return view of the selected row / item
    fn get(self, row: Int) -> StringRef:
        return self.rows[row]

    fn length(self) -> Int:
        return self.rows.size

# small tests
fn main():
    let a = Parser("abc\ndef\nghi")
    for i in range (a.length()):
        print(a.get(i))
    print(a.length())    
    let b = Parser("abc, def; ghi; foo", "; ")
    for i in range (b.length()):
        print(b.get(i))
