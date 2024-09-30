# https://github.com/modularml/mojo/issues/3578

from algorithm import parallelize
from os.atomic import Atomic

fn main() raises:
    tiles = List[String]()
    tiles.extend(List[String]("abcde", "fghij", "klmno", "pqrst", "uvwxy"))
    dimx = tiles.size
    dimy = len(tiles[0])
    var mmax = Atomic[DType.int64](0)

    # this doesn't reference any globals so is ok
    fn idx(x: Int32, y: Int32) -> Int32:
        return 220 + ((y + 1) % 2) * 110 + x + 1

    # this references dimx, dimy but is not @parameter bound
    fn bar(i: Int) -> SIMD[DType.int32, 4]:
        return SIMD[DType.int32, 4](dimy, i - 2 * dimx - dimy, -1, 0)

    @parameter
    fn foo(start: SIMD[DType.int32, 4]) -> Int64:
        return int(idx(start[0], start[1]))

    @parameter
    fn step2(i: Int):
        mmax.max(foo(bar(i)))

    @parameter
    fn invoke() -> Int64:
        parallelize[step2](4)
        return mmax.value

    # this works, despite bar not having @parameter decorator
    print(foo(bar(1)))
    # and this causes the whole runtime to crash
    print(invoke())

    print(tiles.size, "tokens", dimx, dimy)
