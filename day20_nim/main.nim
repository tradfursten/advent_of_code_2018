import os, strutils

const limit = 60

type
  Position = tuple[ x:int, y:int ]
  Map = array[-limit..limit, array[-limit..limit, int]]

var input = readFile(paramStr(1)).strip(trailing = true)


template `[]`(m:Map, p: Position): untyped = m[p.x][p.y]
template `[]=`(m:Map, p: Position, v: int): untyped = m[p.x][p.y] = v

proc move(p: var Position, c: char) =
  case c:
    of 'N': p.y.inc()
    of 'E': p.x.inc()
    of 'S': p.y.dec()
    of 'W': p.x.dec()
    else: discard

proc createMap(input: string): Map =
  var
    p : Position
    dist: int
    stack = newSeqOfCap[(Position, int)](100)
  for c in input:
    if c in ['N', 'E', 'S', 'W']:
        p.move c
        dist.inc()
        if result[p] == 0 or result[p] > dist:
          result[p] = dist
    elif c == '|':
      (p, dist) = stack[^1]
    elif c == '(':
      stack.add((p,dist))
    elif c == ')':
      (p, dist) = stack.pop

proc getDistance(m: Map): tuple[ first:int, second:int ] =
  for col in m:
    for y in col:
      if y > result.first: result.first = y
      if y >= 1000: result.second.inc


echo input

var map = input.createMap
var solution = map.getDistance
echo solution.first
echo solution.second