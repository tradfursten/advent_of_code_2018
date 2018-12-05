import strutils, sequtils


proc rFile(input:string):string=
  result = readFile(input).strip(trailing = true)

let testInput = rFile("test_input1.txt")


let input = rFile("input.txt")
