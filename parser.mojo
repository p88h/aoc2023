from utils.vector import DynamicVector

struct Parser:
    var contents: String
    var breaks: DynamicVector[Int]
    fn __init__(inout self, s: String):
        self.contents = s
        self.breaks = DynamicVector[Int](10)
        var ofs: Int = 0
        self.breaks.push_back(-1)
        let c = s.count('\n')
        for i in range(c):
            let p = s.find('\n', ofs)
            ofs += p
            self.breaks.push_back(ofs)
            ofs += 1 
        if (ofs < len(s)):
            self.breaks.push_back(len(s))
    
    fn get(self, row: Int) -> String:
        return self.contents[self.breaks[row]+1:self.breaks[row+1]]

    fn length(self) -> Int:
        return self.breaks.size - 1



