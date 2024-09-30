from parser import *
from os.atomic import Atomic
from wrappers import run_multiline_task

# Replaces ord('a')
alias ord_a = ord("a")


fn maxdict(s: StringSlice) raises -> Tuple[Int, Int, Int]:
    """
    Parse a single line and return a dictionary with maximum values for each ball color
    across all the draws. Internally uses hierarchical parsing to split off the header,
    split draws, and then split colors.
    """
    # Skip header. Game IDs are sequential, anyway.
    alias cOlon = ord(":")
    alias cR = ord("r")
    alias cG = ord("g")
    start = s.find(cOlon) + 2  # ':'
    # Top-level parser for draws - semicolon separated
    draws = make_parser[";"](s[start:])
    red = green = blue = 0
    for d in range(draws.length()):
        # Secondary level parser for comma-separated colors
        colors = make_parser[","](draws.get(d))
        for b in range(colors.length()):
            # split color name and value
            tok = make_parser[" "](colors.get(b))
            v = int(atoi(tok.get(0)))
            col = tok.get(1)
            if col[0] == cR:
                red = max(red, v)
            elif col[0] == cG:
                green = max(green, v)
            else:
                blue = max(blue, v)
    return (red, green, blue)


fn main() raises:
    f = open("day02.txt", "r")
    lines = make_parser["\n"](f.read())
    var sum1 = Atomic[DType.int32](0)
    var sum2 = Atomic[DType.int32](0)

    # Handle one line for the first task. If the maximum ball counts for a given line exceed
    # the limits, update the counter.
    @parameter
    fn step1(l: Int):
        try:
            (r, g, b) = maxdict(lines.get(l))
            if r <= 12 and g <= 13 and b <= 14:
                sum1 += l + 1
        except:
            pass

    # Handle one line for the second task. Just multiply the maximum counts.
    @parameter
    fn step2(l: Int):
        try:
            (r, g, b) = maxdict(lines.get(l))
            sum2 += r * g * b
        except:
            pass

    @parameter
    fn results():
        print(int(sum1.value))
        print(int(sum2.value))

    run_multiline_task[step1, step2, results](lines.length())

    # Same as in part1 - ensure `lines` actually lives through to the end of the program.
    print(lines.length(), "rows")
