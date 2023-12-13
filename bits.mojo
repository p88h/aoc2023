# Count the bits in a SIMD vector. Mojo doesn't expose the intrinsics that do this
# natively, shame. But we can reduce at least, so we just need 3 shifting steps.
fn bitcnt(r: SIMD[DType.int32, 1]) -> Int:
    let m : SIMD[DType.int8, 4] = r.cast[DType.uint8]()
    # odd / even bits
    let s55 = SIMD[DType.uint8, 4](0x55)
    # two-bit mask
    let s33 = SIMD[DType.uint8, 4](0x33)
    # four-bit mask
    let s0F = SIMD[DType.uint8, 4](0x0F)
    # ref: Hacker's Delight or https://en.wikipedia.org/wiki/Hamming_weight    
    var mm = m - ((m >> 1) & s55)
    print(m,mm)
    mm = (mm & s33) + ((mm >> 2) & s33)
    print(mm)
    mm = (mm + (mm >> 4)) & s0F    
    print(mm)
    return mm.reduce_add[1]().to_int()


fn main():
    var b = 0
    for i in range(30):
        let a = 1 << i
        b += a
        print(a, b, bitcnt(a), bitcnt(b))
