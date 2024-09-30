# https://github.com/modularml/mojo/issues/1482
# fixed

from memory.unsafe_pointer import UnsafePointer

fn main():
    array = UnsafePointer[Int].alloc(1000000)
    bug = 1000 % (array[0] | 1)
    print(bug)