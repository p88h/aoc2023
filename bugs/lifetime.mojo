# https://github.com/modularml/mojo/issues/1404

from memory.buffer import Buffer

struct Keeper:
    var keep: String

    fn __init__(inout self, owned s: String):
        # the behavior is broken regardless of whether we copy or move.
        self.keep = s ^

    fn slice(self, start: Int, l: Int) -> StringRef:
        return StringRef(self.keep._as_ptr().offset(start), l)

    fn size(self) -> Int:
        return len(self.keep)


alias charptr = DTypePointer[DType.int8]


struct ByteKeeper:
    var keep: charptr
    var size: Int

    fn __init__(inout self, owned s: String):
        self.keep = charptr.alloc(len(s))
        self.size = len(s)
        # It seems to be also broken if we manually copy underlying bytes.
        memcpy(self.keep, s._as_ptr(), len(s))

    fn slice(self, start: Int, l: Int) -> StringRef:
        return StringRef(self.keep.offset(start), l)


fn main():
    let keeper = Keeper(String("I want you to hold this"))
    let bkeeper = ByteKeeper(String("I want you to hold this"))
    let simpler = String("I want you to hold this")
    let buffer = Buffer[128,DType.int8].aligned_stack_allocation[64]() 
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
                print_no_newline(chr(buffer[j].to_int()))
            print()

    doit()

    # uncomment to make it actually work
    # print(keeper.size())
    # print(len(simpler))
