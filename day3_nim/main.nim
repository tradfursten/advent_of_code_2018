import strutils, sequtils, re, tables

proc rFile(input:string):string=
  result = readFile(input).strip(trailing = true)


proc matchLine(line: string): seq[int] =
  var matches: array[5, string]
  let pattern = re".(\d+) @ (\d+),(\d+): (\d+)x(\d+)"
  if match(line, pattern, matches,0):
    result = matches.map(parseInt)


proc getCoordinates(input: seq[seq[int]]):Table[string, string] =
  var hits = 0
  var c = ""
  var coordinates = initTable[string, string]()
  for line in input:
      for x in line[1]..(line[1] + line[3] - 1):
        for y in line[2]..(line[2] + line[4] - 1):
          c = $x & "," & $y
          if not coordinates.hasKey(c):
            coordinates[c] = $line[0]
          else:
            coordinates[c] = "X"

  result = coordinates

proc overlaps(line: seq[int], coordinates: Table[string, string]):bool =
  var c = ""
  result = false
  for x in line[1]..(line[1] + line[3] - 1):
    for y in line[2]..(line[2] + line[4] - 1):
      c = $x & "," & $y
      if coordinates[c] == "X":
        result = true
        return


proc solve1(input: string):int =
  let parsedLines = input.splitLines()
    .map(matchLine)
  var coordinates = getCoordinates(parsedLines)
  result = 0
  for value in coordinates.values():
    if value == "X":
      result.inc

proc solve2(input: string):string =
  let parsedLines = input.splitLines()
    .map(matchLine)
  var coordinates = getCoordinates(parsedLines)

  for line in parsedLines:
    if not overlaps(line, coordinates):
      result = $line[0]
      break


  

let testInput1 = rFile("test_input1.txt")
echo solve1(testInput1)
echo solve2(testInput1)


let input = rFile("input.txt")
echo solve1(input)
echo solve2(input)


