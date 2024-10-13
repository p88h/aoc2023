from parser import make_parser
from collections import Counter
from os.atomic import Atomic
from wrappers import run_multiline_task


fn maxballs(line: String) raises -> Counter[String]:
    """
    Parse a single line and return a dictionary with maximum values for each ball color
    across all the draws. Internally uses hierarchical parsing to split off the header,
    split draws, and then split colors.
    """
    var games = line.split(": ")[1].split("; ")
    counter = Counter[String]()
    for game_ref in games:
        game = game_ref[]
        game = game.replace(",", "")
        toks = game.split(" ")
        for i in range(len(toks) // 2):
            cnt = int(toks[i * 2])
            col = toks[i * 2 + 1]
            counter[col] = max(counter[col], cnt)
    return counter


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
            var colors = maxballs(str(lines.get(l)))
            if colors["red"] <= 12 and colors["green"] <= 13 and colors["blue"] <= 14:
                sum1 += l + 1
        except:
            pass

    # Handle one line for the second task. Just multiply the maximum counts.
    @parameter
    fn step2(l: Int):
        try:
            var colors = maxballs(str(lines.get(l)))
            sum2 += colors["red"] * colors["green"] * colors["blue"]
        except:
            pass

    @parameter
    fn results():
        print(int(sum1.value))
        print(int(sum2.value))

    run_multiline_task[step1, step2, results](lines.length())

    # Same as in part1 - ensure `lines` actually lives through to the end of the program.
    print(lines.length(), "rows")
