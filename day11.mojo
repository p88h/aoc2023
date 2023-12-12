from parser import *
from wrappers import minibench
from array import Array

fn main() raises:
    let f = open("day11.txt", "r")
    let lines = make_parser[10](f.read())

    @parameter
    fn compute(cosmic_constant: Int64) -> Int64:
        # initializers for blank space detection
        let dimy = lines.length()
        let dimx = lines.get(0).size
        var vexp = Array[DType.int64](dimy)
        var hexp = Array[DType.int64](dimx)
        var hsum = Array[DType.int8](dimy)
        var vsum = Array[DType.int8](dimx)
        # find empty lines
        for i in range(dimy):
            @unroll(4)
            for j in range(dimx):
                hsum[j] |= lines[i][j]
                vsum[i] |= lines[i][j]
        # compute h & v expansion
        alias cDot = ord(".")
        for i in range(dimy):
            if vsum[i] == cDot:
                vexp[i] = vexp[i - 1] + cosmic_constant
            else:
                vexp[i] = vexp[i - 1]
        for i in range(dimx):
            if hsum[i] == cDot:
                hexp[i] = hexp[i - 1] + cosmic_constant
            else:
                hexp[i] = hexp[i - 1]

        # initializers for space sweeper
        var psum = Array[DType.int64](dimy)
        var nsum = Array[DType.int64](dimy)
        var lcnt = Array[DType.int64](dimy)

        var dsum : Int64 = 0  # result
        var vtot : Int64 = 0  # total sum of flipped coordinates
        var stot : Int64 = 0  # total count of all stars
        alias cHash = ord('#')
        for i in range(dimy):
            var pst : Int64 = 0  # sum of coordinates in the left-up quadrant
            var lct : Int64 = 0  # count of stars in the quadrant
            var nst : Int64 = 0  # sum of flipped coordinates
            for j in range(dimx):
                if lines[i][j] == cHash:
                    # psum[j] is the sum of coordinates of all stars so far with x==j
                    # lst is the sum of psum over 0..j now. We have hct stars there.
                    let cp = i + vexp[i] + j + hexp[j]
                    psum[j] += cp
                    lcnt[j] += 1
                    pst += psum[j]
                    lct += lcnt[j]

                    # sum of distances to everything on the left/upwards is equal to
                    # hct times current coordinates minus all other coordinates
                    var dss = lct * cp - pst

                    # vsum is similar but with the x-coordinates negated.
                    # we also keep global vtot & stot for these, so we can compute
                    # the right-up quadrant sum easily
                    let cn = i + vexp[i] - j - hexp[j]
                    nsum[j] += cn
                    nst += nsum[j]
                    vtot += cn
                    stot += 1

                    # Now to get the top-right quadrant
                    dss += (stot - lct) * cn - (vtot - nst)
                    # print(i,j,"pst",pst,"lct",lct,"nst",nst,"stot",stot,"rct",stot - lct,"dss",dss)
                    dsum += dss
                else:
                    pst += psum[j]
                    lct += lcnt[j]
                    nst += nsum[j]
        return dsum


    @parameter
    fn part1() -> Int64:
        return compute(1)


    @parameter
    fn part2() -> Int64:
        return compute(999999)

    minibench[part1]("part1")
    minibench[part2]("part2")

    print(lines.length(), "lines")
