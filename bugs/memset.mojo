# https://github.com/modularml/mojo/issues/1368
# fixed

from memory import memset
from array import Array
from memory.unsafe_pointer import UnsafePointer

alias intptr = UnsafePointer[Int32]

fn main():
    # Prints junk, not 1
    buf = intptr.alloc(1000)
    memset(buf, -1, 1000)
    print(buf[0], buf[999])
    # This works
    buff = Array[DType.int32](1024)
    buff.fill(1)
    print(buff[0],buff[1023])    
