from benchy import minibench

lines = open("day11.txt").read().split("\n")

def compute(cosmic_constant):
    # initializers for blank space detection
    vexp = [cosmic_constant] * len(lines)
    hexp = [cosmic_constant] * len(lines[0])
    vcnt = [0] * len(lines)
    hcnt = [0] * len(lines[0])    
    # find empty lines and count stars at each x and y separately
    for i in range(len(lines)):
        for j in range(len(lines[i])):
            if lines[i][j] == '#':
                vexp[i]=hexp[j]=1
                vcnt[i]+=1
                hcnt[j]+=1
    sum = 0
    for (a,b) in [(hcnt,hexp),(vcnt,vexp)]:
        pos = cnt = dst = 0
        for i in range(len(a)):
            cnt += a[i]
            dst += a[i]*pos
            sum += a[i]*(cnt*pos - dst)
            pos += b[i]
    return sum

def part1():
    return compute(2)

def part2():
    return compute(1000000)

print(part1())
print(part2())

minibench({"part1": part1, "part2": part2})