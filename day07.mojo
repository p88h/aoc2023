from parser import *
from math import sqrt
from wrappers import minibench
from quicksort import qsort
from array import Array


fn main() raises:
    f = open("day07.txt", "r")
    tokens = make_parser[" "](f.read().replace("\n", " "))
    mapp = Array[DType.int32](128)
    codes = Array[DType.int32](tokens.length() // 2)
    counts = Array[DType.int8](128)

    # Converts the hand (passed in the ss) to a integer value representaion
    # high-ish bits represent the rank, low-ish represent the cards themselves
    # essentially encoding the whole hand and the renk into a 22-bit value.
    # Card ranking is injected via the mapp pointer which is actually a
    # mapping from character values to indexes.
    @parameter
    fn rank[joke: Int](ss: StringSlice) -> Int:
        counts.fill(1)
        var r = 0

        # Compute the counts of cards, and the card value index by iterating
        # through the hand. counts keeps track of occurances of each card;
        for p in range(5):
            c = int(mapp[int(ss[p])])
            counts[c] += 1
            r = r * 14 + c
        # Joker code
        jc = mapp.load(74)
        # ideally this should be optimized out if joke = 0 at compile time
        j = int(counts[int(jc)]) * joke
        var s = 6
        # This allows us to determine the top card counts.
        # counts are all +1 to make them non-zero
        # the possible values are:
        # 5:0 - 6, 4:1 - 10, 3:2 - 12, 3:1:1 - 16, 2:2:1 - 18, 2:1:1:1 - 24, 1:1:1:1:1 - 32
        kpro = counts.load[width=16](0).reduce_mul()
        # 5-of-a-kind -> there is a group of count 5
        if kpro == 6:
            s = 0
        # Same for 4-of-a-kind, can be upgraded to 5 with a joker
        elif kpro == 10:
            s = 1
            if j > 1:
                s = 0
        # Full house, becomes five of a kind with a joker
        # since the joker has to be either the 3-group or 2-group
        elif kpro == 12:
            s = 2
            if j > 1:
                s = 0
        # Three of a kind, becomes four-of-a-kind with a joker
        elif kpro == 16:
            s = 3
            if j > 1:
                s = 1
        # Two pairs. Can become either a full-house with one joker
        # or four-of-a-kind with two.
        elif kpro == 18:
            s = 4
            if j == 2:
                s = 2
            elif j == 3:
                s = 1
        # One pair. Can become a three with a joker.
        elif kpro == 24:
            s = 5
            if j > 1:
                s = 3
        # If everything is single, but we have a joker, that makes a pair.
        elif j > 1:
            s = 5
        # 537824 = 14 ^ 5, the range for card index value.
        return s * 537824 + r

    @parameter
    fn prep() -> Int64:
        alphabet = String("AKQJT98765432")
        # Map characters to their order values
        for i in range(len(alphabet)):
            mapp.store(ord(alphabet[i]), i)
        return len(alphabet)

    @parameter
    fn play[joke: Int]() -> Int64:
        # map the joker to 3 or 13
        mapp[74] = 3 + joke * 10
        for l in range(tokens.length() // 2):
            code = rank[joke](tokens[l * 2])
            score = atoi(tokens[l * 2 + 1])
            codes[l] = code * 1024 + int(score)
        qsort[1](codes)
        var p = codes.size
        var s: Int32 = 0
        for i in range(codes.size):
            s += (codes[i] & 1023) * p
            p -= 1
        return int(s)

    @parameter
    fn part1() -> Int64:
        return play[0]()

    @parameter
    fn part2() -> Int64:
        return play[1]()

    print(prep())
    minibench[part1]("part1")
    minibench[part2]("part2")
    print(tokens.length(), "tokens")
    print(codes.bytecount() + counts.bytecount() + mapp.bytecount(), "bytes")
