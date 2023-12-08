from utils.vector import DynamicVector
from memory import memcpy

alias charptr = DTypePointer[DType.int8]

struct StringBag:
    var bufs : DynamicVector[charptr]
    var sdv : DynamicVector[StringRef]
    var size : Int

    fn __init__(inout self):
        self.bufs = DynamicVector[charptr](10)
        self.sdv = DynamicVector[StringRef](10)
        self.size = 0

    fn __init__(inout self, src: VariadicList[StringLiteral]):
        self.bufs = DynamicVector[charptr](10)
        self.sdv = DynamicVector[StringRef](10)
        self.size = 0
        for i in range(len(src)):
            self.add(src[i])

    fn add(inout self, ss: String):
        let db = charptr.alloc(len(ss))
        self.bufs.push_back(db)
        memcpy[DType.int8](db, ss._as_ptr(), len(ss))
        self.sdv.push_back(StringRef(db, len(ss)))
        self.size += 1

    fn get(self, pos: Int) -> StringRef:
        return self.sdv[pos]
    

fn main():    
    let ll = VariadicList[StringLiteral]("Hello", "World")    
    let sb = StringBag(ll)
    for i in range(sb.size):
        print(sb.get(i))
    
