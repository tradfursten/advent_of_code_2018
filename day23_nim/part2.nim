import strutils, os, sequtils, re, strformat, tables, math
import goost
# Define all 8 plane normals and reuse them

var
  near_left = (x:1, y: 0, z: -1)
  near_top = (x:0, y:1, z: -1)
  near_bottom = (x:0, y: -1, z: -1)

  left_far = (x: -1, y: 0, z: -1)
  left_top = (x: -1, y: 1, z: 0)
  left_bottom = (x: -1, y: -1, z: 0)

  far_right = (x: -1, y: 0, z: 1)
  far_top = (x: 0, y: 1, z: 1)
  far_bottom = (x: 0, y: -1, z: 1)

  right_near = (x: -1, y: 0, z: 1)
  right_top = (x: -1, y: 1, z: 0)
  right_bottom = (x: -1, y: -1, z: 0)

  norm_1 = near_left.cross(near_top)
  norm_2 = near_bottom.cross(near_left)
  norm_3 = left_far.cross(left_top)
  norm_4 = left_bottom.cross(left_far)
  norm_5 = far_right.cross(far_top)
  norm_6 = far_bottom.cross(far_right)
  norm_7 = right_near.cross(right_top)
  norm_8 = right_bottom.cross(right_near)

proc sameSide(n, a, b, p: Vec3): bool =
  var dotInside = n.dot(b - a)
  var dotPoint = n.dot(p - a)
  return (dotInside*dotPoint) >= 0

proc inside(p: Vec3, a: Bot): bool =
  return sameSide(norm_1, a.top, a.bottom, p) and
    sameSide(norm_2, a.bottom, a.top, p) and
    sameSide(norm_3, a.top, a.bottom, p) and
    sameSide(norm_4, a.bottom, a.top, p) and
    sameSide(norm_5, a.top, a.bottom, p) and
    sameSide(norm_6, a.bottom, a.top, p) and
    sameSide(norm_7, a.top, a.bottom, p) and
    sameSide(norm_8, a.bottom, a.top, p)


proc getNanobots(input: string):seq[Bot] =
  for l in input.splitLines():
    var row = l.findAll(re"-?\d+").map(parseInt)
    result.add((p:(x: row[0], y: row[1],z: row[2]), r: row[3]))


proc overlaps(bots: seq[Bot]): int=
  var pointByOverlap = initTable[Vec3, int]()
  for i, a in bots:
    for c in a.corners():
      var overlaps = 0
      for b in bots:
        #echo fmt"Does {a} intersect {b}?"
        if c.inside b:
          #echo fmt"{a} intersect {b}"
          overlaps.inc
        #else:
          #echo fmt"{a} does not intersect {b}"
      #echo fmt"{a} overlaps {overlaps}"
      pointByOverlap[c] = overlaps

  var maxOverlap = 0
  var maxPoint: Vec3
  for k, v in pointByOverlap.pairs:
    if maxOverlap < v:
      maxOverlap = v
      maxPoint = k
  
  #echo fmt"{maxPoint} overlaps {maxOverlap}"
  
  result = (x:0, y:0, z:0).distance(maxPoint)


  
  
var input = readFile(paramStr(1)).strip(trailing = true)

var bots = input.getNanobots

echo "Calculating best point"

echo bots.overlaps()





