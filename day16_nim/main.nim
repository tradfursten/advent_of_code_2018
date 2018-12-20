import strutils, sequtils, re, tables, sets

var register = [0, 0, 0, 0]

type
  4array = array[4, int]
  Op = enum addr, addi, mulr, muli, banr, bani, borr, bori, setr, seti, gtri, gtir, gtrr, eqri, eqir, eqrr
  TestDate = tuple
    before: 4array
    after: 4array
    instruction: 4array



proc rFile(input:string):string=
  result = readFile(input).strip(trailing = true)

proc parseTestData(input: string)=
  var i = 0
  var data = input.splitLines().mapIt(it.findAll(re"\d+").map(parseInt))
  var testData: seq[TestData] = @[]
  while i < data.len:

    testData.add((before

    i += 4





var registersBefore : array[4,int]
var registersAfter : array[4,int]

let testInput = rFile("test_input1.txt")

let i = parse(testInput)
echo i

let input = rFile("input.txt")
let k = parse(input)
echo k
