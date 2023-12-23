from array import Array

fn fnv1a(ppos: Array[DType.int8]) -> Int32:
    var hash: Int32 = 2166136261
    for i in range(ppos.size):
        hash = (hash ^ ppos[i].cas) * 16777619
    return hash