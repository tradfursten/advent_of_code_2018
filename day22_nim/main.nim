import os, strutils, sequtils, heapqueue, tables

type
  Point = tuple[x: int, y: int]
  Map[T] = array[0..1000, array[0..100, T]]
  Tool = enum Torch, Climbing, None
  Area = enum Rocky, Wet, Narrow
  PositionDetail = tuple
    p: Point
    t: Tool
    time: int
  Path = tuple
    p: Point
    t: Tool

const
  y_limit = 200
  x_limit = 75

template `[]`(m: Map, p: Point): untyped = m[p.y][p.x]
template `[]=`(m: Map, p: Point, v: int): untyped = m[p.y][p.x] = v


proc toPoint(s: string): Point =
  var p = s.split(",").map(parseInt)
  result.x = p[0]
  result.y = p[1]

proc buildMap(p: Point, d: int):Map[int] =
  result[0][0] = d mod 20183

  for y in 0..(p.y+y_limit):
    for x in 0..(p.x+x_limit):
      if y == 0:
        result[y][x] = ((x * 16807) + d) mod 20183
      elif x == 0:
        result[y][x] = ((y * 48271) + d) mod 20183
      else:
        result[y][x] = ((result[y-1][x] * result[y][x-1]) + d) mod 20183
  result[p] = d mod 20183

proc print(m: Map[int], t: Point)=
  for y in 0..t.y:
    for x in 0..t.x:
      if x == 0 and y == 0:
        stdout.write 'M'
      elif x == t.x and y == t.y:
        stdout.write 'T'
      else:
        case (m[y][x] mod 3):
          of 0: stdout.write '.'
          of 1: stdout.write '='
          of 2: stdout.write '|'
          else: discard
    stdout.write '\n'
  stdout.flushFile()

proc area(m: Map[int], t: Point): Map[Area]=
  for y in 0..(t.y+y_limit):
    for x in 0..(t.x+x_limit):
      case (m[y][x] mod 3):
        of 0: result[y][x] = Rocky
        of 1: result[y][x] = Wet
        of 2: result[y][x] = Narrow
        else: discard

proc `<`(a, b: PositionDetail): bool = 
  a.time < b.time

iterator neighbors(c: Point): Point =
  yield(c.x - 1, c.y)
  yield(c.x, c.y - 1)
  yield(c.x + 1, c.y)
  yield(c.x, c.y + 1)

proc changeTool(t: Tool, a: Area): Tool =
  case a:
    of Rocky: 
      case t:
        of Torch: return Climbing 
        else: return Torch
    of Wet:
      case t:
        of Climbing: return None
        else: return Climbing
    of Narrow:
      case t:
        of Torch: return None
        else: return Torch


proc isAllowedTool(a: Area, t: Tool): bool = 
  case a:
    of Rocky: return t != None
    of Wet: return t != Torch
    of Narrow: return t != Climbing

proc isOkCord(p: Point, target: Point): bool = 
  return p.x >= 0 and p.x <= (target.x+10) and p.y >= 0 and p.y <= (target.y+20)


proc path(c: PositionDetail): Path = (p: c.p, t: c.t)


proc shortestPath(m: Map[Area], target: Point): int =
  var
    queue = initHeapQueue[PositionDetail]()
    current: PositionDetail

  var cameFrom = initTable[Path, Path]()
  var costSoFar = initTable[Path, int]()

  costSoFar[(p:(0,0), t: Torch)] = 0
  #cameFrom[current.path()] = current.path()
  queue.push((p: (0, 0), t: Torch, time: 0))
  while queue.len > 0:
    current = queue.pop
    if current.p == target and current.t == Torch:
      echo "found it: ", current
      result = current.time
      break

    
    var otherTool = current.t.changeTool(m[current.p])
    if costSoFar.getOrDefault((p:current.p, t: otherTool), -1) == -1 or costSoFar[(p: current.p, t: otherTool)] > current.time:
      cameFrom[(p:current.p, t:otherTool)] = (p:current.p, t:current.t)
      queue.push((p: current.p, t: otherTool, time: current.time + 7))
      costSoFar[(p: current.p, t: otherTool)] = current.time + 7
    # add neighbors if neighbors not visited or cheaper
    for n in current.p.neighbors:
      if n.isOkCord(target) and m[n].isAllowedTool(current.t):
        var time = current.time + 1
        if costSoFar.getOrDefault((p: n, t:current.t), -1) == -1 or costSoFar[(p:n, t: current.t)] > time:
          cameFrom[(p:n, t:current.t)] = (p:current.p, t:current.t)
          costSoFar[(p: n, t: current.t)] = time
          queue.push((p: n, t: current.t, time: time))
  
 # var totalPath = newSeq[Path]()
 # var c : Path
 # c = (current.p, current.t)
 # totalPath.add c
 # while cameFrom.hasKey c:
 #   echo c
 #   c = cameFrom[c]
 #   totalPath.add c

 # 
 # echo "Total Path"
 # for i, p in totalPath:
 #   echo totalPath[totalPath.high - i]
  
  

    

var depth = paramStr(1).parseInt()
var target = paramStr(2).toPoint
echo depth, ' ', target
var map =  target.buildMap(depth)

var risk = 0

for y in 0..target.y:
  for x in 0..target.x:
    risk = risk + map[y][x] mod 3
echo risk

#map.print target

var areaMap = map.area(target)

echo areaMap.shortestPath target








