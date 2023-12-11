from benchy import minibench

# we first solve the problem using symbolic math to get the
# direct formula that works for any input. In symbolic representation
# we'll use a k-element vector to represent k terms, with 1 at position
# i generated as follows:
def sym(k, i):
    ret = [0] * k
    ret[i] = 1
    return ret

# addition or subtraction is just adding vectors together
def sym_add(seq1, seq2, sign):
    return [seq1[i] + (seq2[i] * sign) for i in range(len(seq1))]

lines = open("day09.txt").read().split("\n")
flat = []
seqs = []
K = 0

# prepare the symbolic forumla in flat and parse inputs into seqs
def prep():
    global flat, K
    seqs.clear()
    for l in lines:
        seqs.append(list(map(int, l.split(" "))))
    flat.clear()
    K = len(seqs[0])
    syms = [sym(K, i) for i in range(K)]
    flat = [0] * K
    for round in range(K):
        for i in range(K - round - 1):
            syms[i] = sym_add(syms[i + 1], syms[i], -1)
        flat = sym_add(flat, syms[K - round - 1], 1)
    return K

def part1():
    sum1 = 0
    for s in seqs:
        for i in range(K):
            sum1 += flat[i] * s[i]
    return sum1

def part2():
    sum2 = 0
    for s in seqs:
        for i in range(K):
            sum2 += flat[i] * s[K - i - 1]
    return sum2

prep()
print(flat)
print(part1())
print(part2())

minibench({"parse": prep, "part1": part1, "part2": part2})