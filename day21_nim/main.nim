import strutils, sequtils, re, tables, sets, os

type Op = enum ADDR, ADDI, MULR, MULI, BANR, BANI, BORR, BORI, SETR, SETI, GTIR, GTRI, GTRR, EQIR, EQRI, EQRR

type Instruction = tuple[op: Op, parameters: array[3, int]]

var registers = [0, 0, 0, 0, 0, 0]

var ip = 0

template A():int = registers[ins.parameters[0]]
template B():int = registers[ins.parameters[1]]
template C():int = registers[ins.parameters[2]]
template value_A():int = ins.parameters[0]
template value_B():int = ins.parameters[1]
template value_C():int = ins.parameters[2]


proc exec(ins: Instruction) =
  case Op(ins.op):
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

proc parseInstruction(line: string):Instruction=
  let r = line.findAll(re"\w+")
  result.op =  parseEnum[Op](toUpperAscii(r[0]))
  result.parameters = [parseInt(r[1]), parseInt(r[2]), parseInt(r[3])]

proc parseInput(input:string):seq[Instruction]=
  let data = input.splitLines();
  var i = 0
  ip = data[0].findAll(re"\d")[0].parseInt()
  i.inc()
  while i < data.len:
    result.add(data[i].parseInstruction())
    i.inc()

var eqrs = newSeq[int]()

proc runProgram(k: seq[Instruction])=
  var i = 0
  var ip_value = 0

  while ip_value >= 0 and ip_value < k.len: # and i < 100:
    registers[ip] = ip_value
    #Used to find the breakpoint
    if k[ip_value].op == EQRR:
      echo ip_value, '\t', registers, '\t', k[ip_value], ' ', i
      if eqrs.contains(registers[5]):
        return
      else:
        eqrs.add(registers[5])
    #  return
    exec(k[ip_value])
    ip_value = registers[ip]
    ip_value.inc()
    i.inc()
    #if i > 100 and registers[2] != 10551305:
    #  return
  

let input = rFile(paramStr(1))#rFile("test_input.txt")
let k = parseInput(input)
registers = [16457176, 0, 0, 0, 0, 0]
k.runProgram()

echo "Part 1: ", registers[0]

eqrs = newSeq[int]()

registers = [0, 0, 0, 0, 0, 0]
k.runProgram()
echo "Part 2: ", eqrs[eqrs.len-1]



