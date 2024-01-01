from parser import *
from math import sqrt
from wrappers import minibench
from algorithm.sort import sort

# Converts the hand (passed in the ss) to a integer value representaion
# high-ish bits represent the rank, low-ish represent the cards themselves
# essentially encoding the whole hand and the renk into a 22-bit value.
# Card ranking is injected via the mapp pointer which is actually a 
# mapping from character values to indexes. 
fn rank[joke: Int](ss: StringSlice, mapp: Pointer[Int]) -> Int:
    var counts = DynamicVector[Int](16)
    var k = DynamicVector[Int](5)

    @unroll
    for i in range(16):
        counts.push_back(0)
    var r = 0
    k.push_back(0)
    # Compute the counts of cards, and the card value index by iterating 
    # through the hand. counts keeps track of occurances of each card;
    # and k counts groups of cards (how many groups of size 1..5)
    @unroll
    for p in range(5):
        let c = mapp.load(ss[p].to_int())
        k.push_back(0)
        k[counts[c]] -= 1
        counts[c] += 1
        k[counts[c]] += 1
        r = r * 14 + c
    # Joker code
    let jc = mapp.load(74)
    # ideally this should be optimized out if joke = 0 at compile time
    let j = counts[jc] * joke
    var s = 6
    # 5-of-a-kind -> there is a group of count 5
    if k[5] > 0:
        s = 0
    # Same for 4-of-a-kind, can be upgraded to 5 with a joker
    elif k[4] > 0:
        s = 1
        if j > 0:
            s = 0
    # Full house, becomes five of a kind with a joker 
    # since the joker has to be either the 3-group or 2-group
    elif (k[3] > 0) and (k[2] > 0):
        s = 2
        if j > 0:
            s = 0
    # Three of a kind, becomes four-of-a-kind with a joker
    elif k[3] > 0:
        s = 3
        if j > 0:
            s = 1
    # Two pairs. Can become either a full-house with one joker
    # or four-of-a-kind with two.
    elif k[2] > 1:
        s = 4
        if j == 1:
            s = 2
        elif j == 2:
            s = 1
    # One pair. Can become a three with a joker.
    elif k[2] > 0:
        s = 5
        if j > 0:
            s = 3        
    # If everything is single, but we have a joker, that makes a pair. 
    elif j > 0:
        s = 5
    # 537824 = 14 ^ 5, the range for card index value. 
    return s * 537824 + r

# For Heap Sort
fn heapify(inout arr: DynamicVector[Int], n: Int, i: Int):
    var m = i
    let l = 2 * i + 1
    let r = 2 * i + 2
    if l < n and arr[i] < arr[l]:
        m = l
    if r < n and arr[m] < arr[r]:
        m = r
    if m != i:
        let t = arr[i]
        arr[i] = arr[m]
        arr[m] = t
        heapify(arr, n, m)

# The Heap Sort. Mojo doesn't have any sorting yet. This is as simple as it gets. 
# Some bucket sort variant might be faster, but not very easy to write in Mojo.
fn heapsort(inout arr: DynamicVector[Int]):
    for i in range(arr.size // 2, -1, -1):
        heapify(arr, arr.size, i)

    for i in range(arr.size - 1, 0, -1):
        let t = arr[i]
        arr[i] = arr[0]
        arr[0] = t
        heapify(arr, i, 0)


fn main() raises:
    let f = open("day07.txt", "r")
    let tokens = make_parser[' '](f.read().replace("\n", " "))
    var ret1 = Atomic[DType.int64](0)
    var ret2 = Atomic[DType.int64](0)
    var mapp = Pointer[Int].alloc(128)
    let alphabet = String("AKQJT98765432")

    # Map characters to their order values
    for i in range(len(alphabet)):
        mapp.store(ord(alphabet[i]), i)

    @parameter
    fn play[joke: Int]() -> Int64:
        # map the joker to 3 or 13
        mapp[74] = 3 + joke * 10
        var codes = DynamicVector[Int](1000)
        for l in range(tokens.length() // 2):
            let hand = tokens.get(l * 2)
            let score = atoi(tokens.get(l * 2 + 1)).to_int()
            let code = rank[joke](hand, mapp)
            codes.push_back(code * 1024 + score)
        sort(codes)
        #heapsort(codes)
        var p = codes.size
        var s = 0
        for i in range(codes.size):
            s += (codes[i] & 1023) * p
            p -= 1
        return s

    @parameter
    fn part1() -> Int64:
        return play[0]()

    @parameter
    fn part2() -> Int64:
        return play[1]()

    minibench[part1]("part1")
    minibench[part2]("part2")
    print(tokens.length(), "tokens")
    mapp.free()
