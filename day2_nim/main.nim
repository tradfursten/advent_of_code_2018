import strutils, sequtils
import tables


proc countTwoAndThrees(x: string): (int, int) =
  var letterCount = initTable[char, int]()
  for i in 0..<x.len:
    let count = letterCount.getOrDefault(x[i], 0)
    letterCount[x[i]] = count + 1 
  var three = 0
  var two = 0
#  echo letterCount
  for y in letterCount.values():
    if y == 3:
      three.inc
    if y == 2:
      two.inc
#  echo x & " " & $two & " " & $three
  result = (two, three)

proc `+`(a, b: (int, int)):(int, int) =
  var first = 0
  var second = 0
  if b[0] != 0:
    first = 1
  if b[1] != 0:
    second = 1
#  echo "$1 + $2 = $3 and $4 + $5 = $6"%  [$first, $a[0], $(first + a[0]), $second, $a[1], $(second + a[1])]
  result = (first+a[0], second+a[1])


proc `<`(a, b: (int, string, string)): (int, string, string) =
  if a[0] < b[0]:
    result = a
  else:
    result = b
  
let test_input = readFile("test_input.txt").strip(trailing = true)


#let test = test_input.splitLines()
#  .map(countTwoAndThrees)
#let folded = test.foldl(a + b)
#
#let resTest = folded[0] * folded[1]
#
#echo test
#echo folded
#echo "$1 * $2 = $3" % [$folded[0], $folded[1], $resTest]

let input = readFile("input.txt").strip(trailing = true)

let unFolded = input.splitLines()
  .map(countTwoAndThrees)
let result1 = unFolded
  .foldl(a + b, (0, 0))

echo "$1 * $2 = $3" % [$result1[0], $result1[1], $(result1[0] * result1[1])]

let testInputPart2 = readFile("test_input_part2.txt").strip(trailing = true)

proc findClosest(x:string): (int, string, string) =
  var distance = x.len
  var mostSimilar = ""
  for line in input.splitLines():
    if x != line:
      var current = x.editDistance(line)
      if current < distance:
        distance = current
        mostSimilar = line
  result = (distance, x, mostSimilar)

# let closestSeq = testInputPart2.splitLines()
#   .map(findClosest)
# 
# echo closestSeq
# 
# echo closestSeq.foldl(a < b)
#

echo input.splitLines()
  .map(findClosest)
  .foldl(a < b)

