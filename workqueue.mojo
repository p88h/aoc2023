from array import Array

struct LFQ:
    alias queue_size = 1 << 16
    var data: Array[DType.int32]
    var wp: Atomic[DType.int32]
    var rp: Atomic[DType.int32]


    fn __init__(inout self):
        self.data = Array[DType.int32](Self.queue_size)
        self.wp = 0
        self.rp = 0

    fn push(inout self, value: Int32):
        let pos = self.wp.fetch_add(1)
        self.data[pos % Self.queue_size] = value
    
    fn pop(inout self) -> Int32:
        self.rp.