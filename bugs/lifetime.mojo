# https://github.com/modularml/mojo/issues/1404

from array import Array
from memory import memcpy
from memory.unsafe_pointer import UnsafePointer

struct Keeper:
    var keep: String

    fn __init__(inout self, owned s: String):
        # the behavior is broken regardless of whether we copy or move.
        self.keep = s ^

    fn slice(inout self, start: Int, l: Int) -> StringRef:
        return StringRef(self.keep._steal_ptr().offset(start), l)

    fn size(self) -> Int:
        return len(self.keep)


alias charptr = UnsafePointer[UInt8]


struct ByteKeeper:
    var keep: charptr
    var size: Int

    fn __init__(inout self, owned s: String):
        self.keep = charptr.alloc(len(s))
        self.size = len(s)
        # It seems to be also broken if we manually copy underlying bytes.
        memcpy(self.keep, s._steal_ptr(), len(s))

    fn slice(self, start: Int, l: Int) -> StringRef:
        return StringRef(self.keep.offset(start), l)


fn main():
    keeper = Keeper(String("I want you to hold this"))
    bkeeper = ByteKeeper(String("I want you to hold this"))
    simpler = String("I want you to hold this")
    buffer = Array[DType.uint8](128)
    memcpy(buffer.data, bkeeper.keep, bkeeper.size)

    @parameter
    fn doit():
        for i in range(keeper.size() - 5):
            print(keeper.slice(i, i + 5))
        for i in range(bkeeper.size - 5):
            print(bkeeper.slice(i, i + 5))
        for i in range(len(simpler) - 5):
            print(simpler[i : i + 5])
        for i in range(len(simpler) - 5):
            for j in range(i,i+5):
                print(chr(int(buffer[j])))
            print()

    doit()

    # uncomment to make it actually work
    # print(keeper.size())
    # print(len(simpler))
