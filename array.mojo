from memory.unsafe_pointer import UnsafePointer
from sys.info import simdwidthof, sizeof

@value
struct Array[AType: DType](CollectionElement):
    """
    Simple data array with fast clear and initialization.
    """
    alias simd_width = simdwidthof[AType]()
    var data: UnsafePointer[SIMD[AType, 1]]
    var size: Int
    var dynamic_size: Int

    fn __init__(inout self, size: Int, value: SIMD[AType, 1] = 0):
        pad = size + (Self.simd_width - 1) & ~(Self.simd_width - 1)
        # print("pad", size, "to", pad, "align", Self.simd_width)
        self.data = UnsafePointer[SIMD[AType, 1], alignment=Self.simd_width].alloc(pad)
        self.size = size
        self.dynamic_size = size
        self.fill(value)

    fn __getitem__(self, idx: Int) -> SIMD[AType, 1]:
        return self.data[idx]

    fn __getitem__(self, idx: Int32) -> SIMD[AType, 1]:
        return self.data[int(idx)]

    fn __setitem__(inout self, idx: Int, val: SIMD[AType, 1]):
        self.data[idx] = val

    fn __setitem__(inout self, idx: Int32, val: SIMD[AType, 1]):
        self.data[int(idx)] = val

    fn __del__(owned self):
        self.data.free()

    fn fill(inout self, value: SIMD[AType, 1] = 0):
        initializer = SIMD[AType, Self.simd_width](value)
        for i in range((self.size + Self.simd_width - 1) // Self.simd_width):
            self.data.store[width=Self.simd_width](i * Self.simd_width, initializer)
    
    fn swap(inout self, inout other: Self):
        (self.data, other.data) = (other.data, self.data)
        (self.size, other.size) = (other.size, self.size)

    #  Buffer compat
    fn bytecount(self) -> Int:
        return self.size * sizeof[AType]()

    fn zero(inout self):
        self.fill(0)

    fn load[width: Int, T: IntLike](self, ofs: T) -> SIMD[AType, width]:
        return self.data.load[width=width](ofs)

    fn store[width: Int, T: IntLike](self, ofs: T, val: SIMD[AType, width]):
        self.data.store[width=width](ofs, val)

    fn load[T: IntLike](self, ofs: T) -> SIMD[AType, 1]:
        return self.data.load[width=1](ofs)

    fn store[T: IntLike](self, ofs: T, val: SIMD[AType, 1]):
        self.data.store[width=1](ofs, val)