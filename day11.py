from benchy import minibench

lines = open("day11.txt").read().split("\n")

def compute(cosmic_constant):
    # initializers for blank space detection
    vexp = [0] * len(lines)
    hexp = [0] * len(lines[0])
    vsum = [0] * len(lines)
    hsum = [0] * len(lines[0])
    # find empty lines
    for i in range(len(lines)):
        for j in range(len(lines[i])):
            hsum[j] |= ord(lines[i][j])
            vsum[i] |= ord(lines[i][j])
    # compute h & v expansion
    for i in range(len(vsum)):
        if vsum[i] == ord("."):
            vexp[i] = vexp[i - 1] + cosmic_constant
        else:
            vexp[i] = vexp[i - 1]
        if hsum[i] == ord("."):
            hexp[i] = hexp[i - 1] + cosmic_constant
        else:
            hexp[i] = hexp[i - 1]

    # initializers for space sweeper
    psum = [0] * len(lines[0])
    nsum = [0] * len(lines[0])
    lcnt = [0] * len(lines[0])

    dsum = 0  # result
    vtot = 0  # total sum of flipped coordinates
    stot = 0  # total count of all stars
    for i in range(len(lines)):
        if i > 0:
            vsum[i] = vsum[i - 1]
        pst = 0  # sum of coordinates in the left-up quadrant
        lct = 0  # count of stars in the quadrant
        nst = 0  # sum of flipped coordinates
        for j in range(len(lines[i])):
            if lines[i][j] == "#":
                # psum[j] is the sum of coordinates of all stars so far with x==j
                # lst is the sum of psum over 0..j now. We have hct stars there.
                cp = i + vexp[i] + j + hexp[j]
                psum[j] += cp
                lcnt[j] += 1
                pst += psum[j]
                lct += lcnt[j]

                # sum of distances to everything on the left/upwards is equal to
                # hct times current coordinates minus all other coordinates
                dss = lct * cp - pst

                # vsum is similar but with the x-coordinates negated.
                # we also keep global vtot & stot for these, so we can compute
                # the right-up quadrant sum easily
                cn = i + vexp[i] - j - hexp[j]
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

def part1():
    return compute(1)

def part2():
    return compute(999999)

print(part1())
print(part2())

minibench({"part1": part1, "part2": part2})