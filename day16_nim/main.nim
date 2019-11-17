import strutils, sequtils, re, tables, sets

type Quad = array[4, int]

type TestData = tuple[before, instruction, after: Quad]

type Op = enum ADDR, ADDI, MULR, MULI, BANR, BANI, BORR, BORI, SETR, SETI, GTIR, GTRI, GTRR, EQIR, EQRI, EQRR

var registers = [0, 0, 0, 0]

template A():int = registers[ins[1]]
template B():int = registers[ins[2]]
template C():int = registers[ins[3]]
template value_A():int = ins[1]
template value_B():int = ins[2]
template value_C():int = ins[3]


proc exec(ins: Quad) =
  case Op(ins[0]):
    of ADDR: C = A + B
    of ADDI: C = A + value_B
    of MULR: C = A * B
    of MULI: C = A * value_B
    of BANR: C = A and B
    of BANI: C = A and value_B
    of BORR: C = A or B
    of BORI: C = A or value_B
    of SETR: C = A
    of SETI: C = value_A
    of GTIR: C = (value_A > B).int
    of GTRI: C = (A > value_B).int
    of GTRR: C = (A > B).int
    of EQIR: C = (value_A == B).int
    of EQRI: C = (A == value_B).int
    of EQRR: C = (A == B).int



proc rFile(input:string):string=
  result = readFile(input).strip(trailing = true)

proc parseQuad(line: string):Quad=
  let r = line.findAll(re"\d+").map(parseInt)
  [r[0], r[1], r[2], r[3]]

proc parseInput(input:string):seq[TestData]=
  let data = input.splitLines();
  var i = 0
  while i < data.len:
    result.add((data[i].parseQuad, data[i+1].parseQuad, data[i+2].parseQuad))
    inc(i, 4)


proc getPosibleOps(testData: TestData): tuple[value: int, ops:set[Op]] =
  result.value = testData.instruction[0]
  for op in Op:
    var test = testData.instruction
    test[0] = op.int
    registers = testData.before
    exec(test)
    if registers == testData.after:
      result.ops.incl(op)



let input = rFile("input.txt")
let k = parseInput(input)
var posible = k.map(getPosibleOps)
var posiblePart1 = posible.filterIt(it.ops.card >= 3).len
echo posiblePart1

var mapping = initTable[int, Op]()
var foundOps:set[Op]

while toSeq(Op).len - mapping.len > 0:
  for exampleWithOneOp in posible.filterIt(it.ops.card == 1):
    foundOps.incl(exampleWithOneOp.ops)
    mapping[exampleWithOneOp.value] = toSeq(exampleWithOneOp.ops.items)[0]
  
  for x in posible.mitems:
    x.ops.excl(foundOps)

var program = rFile("inputPart2.txt").splitLines().map(parseQuad)

registers = [0, 0, 0, 0]
for instruction in program:
  var withMappedOperation = instruction
  withMappedOperation[0] = mapping[instruction[0]].int
  exec(withMappedOperation)

echo registers
