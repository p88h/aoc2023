@value
struct Array[AType: DType](CollectionElement):
    """
    Simple data array with fast clear and initialization.
    """
    var data: DTypePointer[AType]
    var size: Int
    alias simd_width = simdwidthof[AType]()

    fn __init__(inout self, size: Int, value: SIMD[AType, 1] = 0):
        let pad = size + (Self.simd_width - 1) & ~(Self.simd_width - 1)
        # print("pad", size, "to", pad, "align", Self.simd_width)
        self.data = DTypePointer[AType].aligned_alloc(Self.simd_width, pad)
        self.size = size
        self.clear(value)

    fn __getitem__(self, idx: Int) -> SIMD[AType, 1]:
        return self.data[idx]

    fn __getitem__(self, idx: Int32) -> SIMD[AType, 1]:
        return self.data[idx.to_int()]

    fn __setitem__(inout self, idx: Int, val: SIMD[AType, 1]):
        self.data[idx] = val

    fn __setitem__(inout self, idx: Int32, val: SIMD[AType, 1]):
        self.data[idx.to_int()] = val

    fn __del__(owned self):
        self.data.free()

    fn clear(inout self, value: SIMD[AType, 1] = 0):
        let initializer = SIMD[AType, Self.simd_width](value)
        @unroll(4)
        for i in range((self.size + Self.simd_width - 1) // Self.simd_width):
            self.data.aligned_simd_store[Self.simd_width, Self.simd_width](i * Self.simd_width, initializer)
    
    fn swap(inout self, inout other: Self):
        (self.data, other.data) = (other.data ^, self.data ^)
        (self.size, other.size) = (other.size, self.size)

    #  Buffer compat
    fn bytecount(self) -> Int:
        return self.size * sizeof[AType]()

    fn fill(inout self, value: SIMD[AType, 1] = 0):
        self.clear(value)

    fn zero(inout self):
        self.clear(0)
