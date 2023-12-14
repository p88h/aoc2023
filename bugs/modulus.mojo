# https://github.com/modularml/mojo/issues/1482

fn main():
    let array = DTypePointer[DType.int32].alloc(1000000)
    let bug = 1000 % (array[0] | 1)