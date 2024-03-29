from parser import *
from os.atomic import Atomic
from collections.vector import DynamicVector
from wrappers import run_multiline_task

# Replaces ord('a')
alias ord_a = ord('a')


struct PseudoDict:
    """
    Implements a String->Integer "dictionary". Uses a very sophisticated dictionary hashing function.
    i.e. the first letter of the handled string. Since these are unique (in this task), this is sufficient.
    """

    var vals: DynamicVector[Int]

    fn __init__(inout self, ival: Int = 0):
        # We will just use 26 buckets, one for each letter from a..z
        self.vals = DynamicVector[Int](26)
        for i in range(26):
            self.vals.push_back(ival)

    # To be able to pass this dict around, like return it from a function we need a move constructor
    # In C++, trivial move constructors like this one are generated by default, so probably
    # Mojo should not need this boilerplate one day?
    fn __moveinit__(inout self, owned existing: Self):
        self.vals = existing.vals ^

    # Our dictionary has only an update maximum operation, put_max
    fn put_max(inout self, s: StringSlice, v: Int):
        let id = (s[0] - ord_a).to_int()
        if self.vals[id] < v:
            self.vals[id] = v

    # Just a regular get
    fn get(self, s: String) -> Int:
        let id = (s._buffer[0] - ord_a).to_int()
        return self.vals[id]


fn maxdict(s: StringSlice) -> PseudoDict:
    """
    Parse a single line and return a dictionary with maximum values for each ball color
    across all the draws. Internally uses hierarchical parsing to split off the header,
    split draws, and then split colors.
    """
    # Skip header. Game IDs are sequential, anyway.
    alias cOlon = ord(':')
    let start = s.find(cOlon) + 2 # ':'
    # Top-level parser for draws - semicolon separated
    let draws = make_parser[';'](s[start:])
    var mballs = PseudoDict()
    for d in range(draws.length()):
        # Secondary level parser for comma-separated colors
        let colors = make_parser[','](draws.get(d))
        for b in range(colors.length()):
            # split color name and value
            let tok = make_parser[' '](colors.get(b))
            let v = atoi(tok.get(0))
            let col = tok.get(1)
            mballs.put_max(col, v.to_int())
    return mballs ^


fn main() raises:
    let f = open("day02.txt", "r")
    let lines = make_parser['\n'](f.read())
    var sum1 = Atomic[DType.int32](0)
    var sum2 = Atomic[DType.int32](0)

    # Handle one line for the first task. If the maximum ball counts for a given line exceed
    # the limits, update the counter.
    @parameter
    fn step1(l: Int):
        let mballs = maxdict(lines.get(l))
        if mballs.get("r") <= 12 and mballs.get("g") <= 13 and mballs.get("b") <= 14:
            sum1 += l + 1

    # Handle one line for the second task. Just multiply the maximum counts.
    @parameter
    fn step2(l: Int):
        let mballs = maxdict(lines.get(l))
        sum2 += mballs.get("r") * mballs.get("g") * mballs.get("b")

    @parameter
    fn results():
        print(sum1.value.to_int())
        print(sum2.value.to_int())

    run_multiline_task[step1, step2, results](lines.length(), 24)

    # Same as in part1 - ensure `lines` actually lives through to the end of the program.
    print(lines.length(), "rows")
