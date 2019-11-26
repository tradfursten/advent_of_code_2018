import strutils, os, sequtils, re, strformat, tables, math

type
  Vec3 = tuple
    x: int
    y: int
    z: int
  Bot = tuple
    p: Vec3
    r: int
  #Map[T] = array[0..x_lim, array[0..y_lim, array[0..z_lim, T]]]

template `<`(a, b: Bot): bool =
  a.r < b.r

template `+`(a, b: Vec3): Vec3 = (x: a.x + b.x, y: a.y + b.y, z: a.z + b.z)
template `-`(a,b: Vec3): Vec3 = (x: a.x-b.x, y: a.y-b.y, z: a.z-b.z)

proc cross(a,b: Vec3): Vec3 = (x:(a.y*b.z - a.z*b.y), y:(a.z*b.x - a.x*b.z), z:(a.x*b.y - a.y*b.x))
proc dot(a,b: Vec3): int = a.x*b.x + a.y*b.y + a.z*b.z

proc top(b: Bot): Vec3 = b.p + (x:0, y: b.r, z:0)
proc bottom(b: Bot): Vec3 = b.p + (x:0, y: (-b.r), z:0)
proc left(b: Bot): Vec3 = b.p + (x:b.r, y: 0, z:0)
proc right(b: Bot): Vec3 = b.p + (x:(-b.r), y: 0, z:0)
proc near(b: Bot): Vec3 = b.p + (x:0, y: 0, z: (-b.r))
proc far(b: Bot): Vec3 = b.p + (x:0, y: 0, z:b.r)

proc getNanobots(input: string):seq[Bot] =
  for l in input.splitLines():
    var row = l.findAll(re"-?\d+").map(parseInt)
    result.add((p:(x: row[0], y: row[1],z: row[2]), r: row[3]))

proc distance(a, b: Vec3): int =
  result = abs(a.x - b.x) + abs(a.y - b.y) + abs(a.z - b.z)

proc distance(a, b: Bot): int =
  result = a.p.distance(b.p)

proc inRange(strongest: Bot, bots: seq[Bot]): int =
  var distance: int
  var inRange: bool
  for b in bots:
    distance = strongest.distance b
    inRange = distance <= strongest.r
    #echo fmt"The nanobot at {b.p} is distance {distance} away, and is {inRange}"
    if distance <= strongest.r: result.inc


proc singlePlane(a, b, c, d, p: Vec3): bool =
  var norm = (a - b).cross(a - c)
  var dot = norm.dot(d - a)
  var dot_point = norm.dot(p - a)
  #if p == (x: 12, y: 12, z: 12):
  #  echo fmt"{dot} * {dot_point}, norm {norm} {a} {b} {c}"
  return dot * dot_point >= 0


proc inside(a: Bot, p: Vec3, print = false): bool =
  #if print:
  #  echo fmt"{a} {p}"
  return singlePlane(a.near, a.left, a.top, a.right, p) and
    singlePlane(a.near, a.bottom, a.left, a.right, p) and
    singlePlane(a.left, a.far, a.top, a.near, p) and
    singlePlane(a.left, a.bottom, a.far, a.near, p) and
    singlePlane(a.far, a.right, a.top, a.left, p) and
    singlePlane(a.far, a.bottom, a.right, a.left, p) and
    singlePlane(a.right, a.near, a.top, a.far, p) and
    singlePlane(a.right, a.bottom, a.near, a.far, p)

proc intersect(a, b: Bot): bool =
  var
    small:Bot
    large: Bot
  if a.r >= b.r:
    small = b
    large = a
  else:
    small = a
    large = b
  return inside(large, small.top) or
    inside(large, small.bottom) or
    inside(large, small.near) or
    inside(large, small.far) or
    inside(large, small.left) or
    inside(large, small.right)

  

iterator corners(b: Bot): Vec3 =
  yield(b.top)
  yield(b.bottom)
  yield(b.near)
  yield(b.far)
  yield(b.left)
  yield(b.right)

proc overlaps(bots: seq[Bot]): int=
  var botsByOverlaps = initTable[int, tuple[id: int, bot: Bot]]()
  for i, a in bots:
    var overlaps = 0
    for b in bots:
      #echo fmt"Does {a} intersect {b}?"
      if a.intersect(b):
        #echo fmt"{a} intersect {b}"
        overlaps.inc
      #else:
        #echo fmt"{a} does not intersect {b}"
    echo fmt"{a} overlaps {overlaps}"
    if not botsByOverlaps.hasKey(overlaps) or botsByOverlaps[overlaps].bot.r > a.r:
      botsByOverlaps[overlaps] = (id: i, bot: a)
  var maxOverlap = 0
  for k in botsByOverlaps.keys:
    if maxOverlap < k: maxOverlap = k
  
  var targetBot = botsByOverlaps[maxOverlap].bot
  echo fmt"The bot with most intersections: {maxOverlap} and least range: {targetBot}"
  var currentMax = 0
  var maxPoint: Vec3
  for c in targetBot.corners():
    var o = 0
    for b in bots:
      if b.inside(c, true): 
        o.inc
      else:
        echo fmt"{c} does not overlap {b}"
    echo fmt"{c} has {o} overlaps"
    if o > currentMax:
      maxPoint = c
      currentMax = o
  echo fmt"Max overlaps {currentMax} for {maxPoint}"
  result = (x:0, y:0, z:0).distance(maxPoint)



var input = readFile(paramStr(1)).strip(trailing = true)

var bots = input.getNanobots

var strongest = bots.max
echo strongest
echo strongest.inRange bots
      

echo bots.overlaps()