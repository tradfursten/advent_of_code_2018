import strutils, sequtils

proc parseLine(line: string): int =
  echo line
  result = line.splitWhitespace()
    .map(parseInt)
    .foldl(a + b)

let input = readFile("test_input.txt")

let lines = input.splitLines()
  .filter(proc (x:string): bool = x.len != 0)
  .map(parseLine)

echo lines
