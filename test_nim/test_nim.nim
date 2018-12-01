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

proc solve1(input: string): int =
  var prev = input[^1]
  result = 0
  for i in input:
#    echo i & " " & prev
    if i == prev:
      inc(result, parseInt("" & i))
    prev = i

let input2 = readFile("test_2.txt").strip(trailing = true)


echo solve1(input2)

echo solve1(readFile("test_2_a.txt").strip(trailing = true))

proc solve2(input: string): int =
  result = 0
  let half = input.len div 2 
  var i = 0
  while i < half.int:
    if input[i] == input[i + half]:
      inc(result, parseInt("" & input[i]))
      inc(result, parseInt("" & input[i]))
    inc(i)

echo solve2(readFile("test_2.txt").strip(trailing = true))

echo solve2("1212")
