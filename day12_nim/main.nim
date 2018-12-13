import strutils, sequtils, tables, re

type
  Rule = ref object
    input: seq[int]
    output: int

  Plants = tuple
    generation: seq[(int, int)]
    rules: seq[Rule]

proc rFile(input:string):string=
  result = readFile(input).strip(trailing = true)

proc parseInput(input: string): Plants =
  var i = 0
  var initialState : seq[(int, int)]
  var rules : seq[Rule]
  var tmpRule: Rule
  for line in input.splitLines():
    if i == 0:
      var j = 0
      for plant in line.findAll(re"\.|#"):
        if plant == "#":
          initialState.add((j, 1))
        j.inc

    elif line != "":
      var k = 0
      var parsedSymbol:int
      tmpRule = new Rule
      echo line
      for rulePlant in line.findAll(re"\.|#"):
        if rulePlant == "#":
          parsedSymbol = 1
        else:
          parsedSymbol = 0
        if k < 5:
          tmpRule.input.add(parsedSymbol)
        else:
          tmpRule.output = parsedSymbol
        k.inc
      echo tmpRule.input, " -> ", tmpRule.output
      rules.add(tmpRule)

    i.inc
  result = (initialState, rules)

proc evaluateRules(index: int, pots: seq[(int,int)], rules: seq[Rule]): (int,int) =
  var i: int
  var match: bool
  var part = @[index-2, index-1, index, index+1, index+2]
    .map(func(i:int):(int, int) =
      if pots.filterIt(it[0] == i).mapIt(it[1]).len > 0:
        result = (i, 1)
      else:
        result = (i, 0)
      )
  var rule: Rule
  for r in rules:
    i = 0
    match = true
    for p in r.input:
      if p != part[i][1]:
        match = false
        break
      i.inc

    if match:
      rule = r
      break
  if match:
    result = (index,rule.output)
  else:
    result = (index,0)

proc generation(plants:var Plants, generation: int64): Plants =
  let pots = plants.generation
  var thisGeneration : seq[(int, int)]
  var minPot = pots.mapIt(it[0]).min() - 3
  var maxPot = pots.mapIt(it[0]).max() + 3
  var evaluated :(int, int)
  for j in minPot..maxPot:
    evaluated = evaluateRules(j, pots, plants.rules)
    if evaluated[1] == 1:
      thisGeneration.add(evaluated)
  plants.generation = thisGeneration

  result = plants


proc toString(pots: seq[(int,int)]): string =
  var minPot = pots.mapIt(it[0]).min() - 3
  var maxPot = pots.mapIt(it[0]).max() + 3
  var pot: seq[(int, int)]
  result = ""
  for i in minPot..maxPot:
    pot = pots.filterIt(it[0] == i)
    if pot.len > 0 and pot[0][1] == 1:
      result &= "#"
    else:
      result &= "."



let testInput = rFile("test_input1.txt")

var parsedTest = parseInput(testInput)
var g = parsedTest
echo "Gen: ", 0, " ", g.generation.filterIt(it[1] == 1).mapIt(it[0]).foldl(a + b)
for i in 1..20:
  g = generation(g, i.int64)
  echo "Gen: ", i, " ", g.generation.filterIt(it[1] == 1).mapIt(it[0]).foldl(a + b)



let input = rFile("input.txt")
var parsed = parseInput(input)
g = parsed
var lastSum = g.generation.filterIt(it[1] == 1).mapIt(it[0]).foldl(a + b).int64
var lastDelta = 0.int64
var newSum, newDelta: int64
var finalSum:int64
let finalGeneration = 50000000000
for i in 1..finalGeneration:
  g = generation(g, i)
  newSum = g.generation.filterIt(it[1] == 1).mapIt(it[0]).foldl(a + b)
  newDelta = newSum - lastSum
  if newDelta == lastDelta:
    finalSum = (finalGeneration - i) * newDelta + newSum
    break
  lastSum = newSum
  lastDelta = newDelta

echo finalSum
    


