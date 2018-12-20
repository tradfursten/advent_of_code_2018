import strutils, sequtils,re


proc rFile(input:string):string=
  result = readFile(input).strip(trailing = true)

proc parse(input: string) =
  for l in input.splitLines():
    l.findAll(re"\d+").map(parseInt)


let testInput = rFile("test_input1.txt")


let input = rFile("input.txt")
