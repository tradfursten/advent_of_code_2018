import strutils, sequtils, sets

let test1 = "+1\n+1\n+1"
let resTest1= test1.splitLines()
  .map(parseInt)
  .foldl(a + b)


let input = readFile("input.txt").strip(trailing = true)

let resultPart1 = input.splitLines()
  .map(parseInt)
  .foldl(a + b)

echo resultPart1


proc solve2(x: string): int =
  var frequences = initSet[int]()
  var frequence = 0
  frequences.incl 0
  var done = false
  while done != true:
    for line in x.splitLines():
      let f = parseInt(line)
      frequence += f
      if frequence in frequences:
        result = frequence
        done = true
        break
      else:
        frequences.incl frequence

echo solve2(input)

#echo solve2("+1\n-1")
#echo solve2("+3\n+3\n+4\n-2\n-4")
#echo solve2("-6\n+3\n+8\n+5\n-6")
