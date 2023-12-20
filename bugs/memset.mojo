# https://github.com/modularml/mojo/issues/1368


from memory import memset
from memory.buffer import Buffer
alias intptr = DTypePointer[DType.int32]


fn main():
    # Prints junk, not 0
    let buf = intptr.alloc(1000)
    memset(buf, 1, 1000)
    print(buf.load(0),buf.load(999))
    let buf2 = intptr.aligned_alloc(16,1024)
    memset(buf2, 1, 1000)
    print(buf.aligned_simd_load[16,16](0),buf.aligned_simd_load[16,16](1008))
    # This works
    let buff = Buffer[1024,DType.int32].aligned_stack_allocation[16]()
    buff.fill(1)
    print(buff[0],buff[1023])
    print(buff.aligned_simd_load[16,16](0),buff.aligned_simd_load[16,16](1008))
