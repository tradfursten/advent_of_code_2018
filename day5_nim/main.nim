import strutils, sequtils


proc rFile(input:string):string=
  result = readFile(input).strip(trailing = true)

proc triggerd(a:char, b:char): bool =
  if ord(a) < 97:
    result = a == char(ord(b) - 32)
    #echo "capital ", a, " ", ord(a), " ", b, " ", ord(b), " ", result
  else:
    result = b == char(ord(a) - 32)
    #echo "non capital ", a, " ", ord(a), " ", b, " ", ord(b), " ", result


func solve1(input: string): string =
  var done = false
  var data = input
  var i = 0
  while i < data.high:
    if i < data.high:
      if triggerd(data[i], data[i+1]):
        data.delete(i, i + 1)
        dec i, 2
        done = false
    inc i
    if i < 0:
      i = 0
  result = data

proc solve2(input: string): int =

  var length : seq[int]
  var data = input
  for x in {'a'..'z'}:
    let data = input.multiReplace(($x, "")).multiReplace(($(char(ord(x)-32)), ""))
    length.add(solve1(data).len)

  result = min(length)




let testInput = rFile("test_input1.txt")
let test1 = solve1(testInput)
echo test1, " ", test1.len
echo solve2(testInput)

let input = rFile("input.txt")
echo solve1(input).len
echo solve2(input)
