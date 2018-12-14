import strutils, sequtils


proc createRecepie(recepies:var string, elfs: (int, int)): (int, int) =
  let e1 = int(recepies[elfs[0]]) - int('0')
  let e2 = int(recepies[elfs[1]]) - int('0')
  let sum = e1 + e2
  recepies &= sum
  result = ((elfs[0] + e1+1) mod recepies.len,(elfs[1] + e2+1) mod recepies.len)
  
proc createRecepie(recepies:var seq[int], elfs: (int, int)): (int, int) =
  let sum = recepies[elfs[0]] + recepies[elfs[1]]
  for c in ($sum):
    recepies.add(parseInt($c))
  result = ((elfs[0] + recepies[elfs[0]]+1) mod recepies.len,(elfs[1] + recepies[elfs[1]]+1) mod recepies.len)

proc toString(recepies: seq[int], elfs: (int, int)): string =
  var i = 0
  result = ""
  for r in recepies:
    if i == elfs[0]:
      result &= "(" & $r & ")"
    elif i == elfs[1]:
      result &= "[" & $r & "]"
    else:
      result &= " " & $r & " "
    i.inc
      
proc getAsString(recepies: seq[int]): string =
  result = recepies.join("")

proc getScore(recepies: seq[int], start: int): string =
  result = recepies[start..<(start+10)].join("")

proc foundIndex(recepies: seq[int], f: int): int =
  #result = recepies.getAsString().find($f)
  result = -1
  let s = $f
  if s.len < recepies.len and recepies[recepies.len-1-s.len..recepies.len-1].join("") == s:
    result = recepies.len-1-s.len
  if s.len+1 < recepies.len and recepies[recepies.len-2-s.len..recepies.len-2].join("") == s:
    result = recepies.len-1-s.len

proc foundIndex(recepies: string, input: string): int =
  result = recepies[recepies.len - input.len-10..<recepies.len].find(input)

var recepies = newSeq[int]()
var elfs = (0, 1)

recepies.add 3
recepies.add 7

let input = 306281

var i = 2
while i < input + 11:
  elfs = recepies.createRecepie(elfs)
  i.inc
  if i mod 1000 == 0:
    echo i

#echo recepies.getScore(5)
#echo recepies.getScore(9)
#echo recepies.getScore(18)
#echo recepies.getScore(2018)
#echo recepies.getScore(input)

var r2 = recepies.join("")
var i2 = $input
var e2 = elfs
while r2.foundIndex(i2) == -1:
  e2 = r2.createRecepie(e2)
  i.inc
  if i mod 1000 == 0:
    echo i


echo r2.find(i2)
