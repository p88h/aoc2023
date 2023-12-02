from utils.vector import DynamicVector


struct Parser:
    var contents: String
    var starts: DynamicVector[Int]
    var ends: DynamicVector[Int]

    fn __init__(inout self, s: String, sep: String = "\n"):
        self.contents = s
        self.starts = DynamicVector[Int](10)
        self.ends = DynamicVector[Int](10)
        var start: Int = 0
        while start < len(s):
            var end = start + s.find(sep, start)
            if end < start:
                end = len(s)
            self.starts.push_back(start)
            self.ends.push_back(end)
            start = end + len(sep)

    fn get(self, row: Int) -> String:
        return self.contents[self.starts[row] : self.ends[row]]

    fn length(self) -> Int:
        return self.starts.size
