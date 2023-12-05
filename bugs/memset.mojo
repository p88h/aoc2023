# https://github.com/modularml/mojo/issues/1368


from memory import memset

alias intptr = DTypePointer[DType.int32]


fn main():
    let buf = intptr.alloc(1000)
    memset(buf, 1, 1000)
    print(buf.load(0))
    # Prints junk, not 0
