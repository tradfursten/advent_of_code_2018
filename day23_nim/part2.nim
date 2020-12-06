import strutils, os, sequtils, re, strformat, sets
import goost
# Define all 8 plane normals and reuse them

var
  near_left = (x: -1, y: 0, z: 1)
  near_top = (x:0, y:1, z: 1)
  near_bottom = (x:0, y: -1, z: 1)

  left_far = (x: -1, y: 0, z: 1)
  left_top = (x: -1, y: 1, z: 0)
  left_bottom = (x: -1, y: -1, z: 0)

  far_right = (x: -1, y: 0, z: 1)
  far_top = (x: 0, y: 1, z: 1)
  far_bottom = (x: 0, y: -1, z: 1)

  right_near = (x: 1, y: 0, z: 1)
  right_top = (x: 1, y: 1, z: 0)
  right_bottom = (x: 1, y: -1, z: 0)

  norm_1 = near_left.cross(near_top)
  norm_2 = near_bottom.cross(near_left)
  norm_3 = left_far.cross(left_top)
  norm_4 = left_bottom.cross(left_far)
  norm_5 = far_right.cross(far_top)
  norm_6 = far_bottom.cross(far_right)
  norm_7 = right_near.cross(right_top)
  norm_8 = right_bottom.cross(right_near)

proc equals(p:Vec3, x, y, z: int): bool = p.x == x and p.y == y and p.z == z

proc inside2(p: Vec3, a: Bot): bool =
  return p.distance(a.p) <= a.r

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
  return inside2(small.top, large) or
    inside2(small.bottom, large) or
    inside2(small.near, large) or
    inside2(small.far, large) or
    inside2(small.left, large) or
    inside2(small.right, large)

proc getNanobots(input: string):seq[Bot] =
  for l in input.splitLines():
    var row = l.findAll(re"-?\d+").map(parseInt)
    result.add((p:(x: row[0], y: row[1],z: row[2]), r: row[3]))

iterator get_neighbours(p: Vec3, skip_set: HashSet[Vec3]): Vec3 =
  for x in (p.x-1)..(p.x+1):
    for y in (p.y-1)..(p.y+1):
      for z in (p.z-1)..(p.z+1):
        if (x:x, y:y, z:z) notin skip_set:
          yield((x:x, y:y, z:z))


type
  SearchPoint = tuple
    p: Vec3
    in_range: int

iterator checkpoints*(b: Bot): Vec3 =
  yield(b.top)
  yield(b.bottom)
  yield(b.near)
  yield(b.far)
  yield(b.left)
  yield(b.right)
  yield(b.p)

proc findStuff(bots: seq[Bot])=
  var
    current: Vec3
    max_overlap = 0
    overlaps = 0
    origin = (x: 0, y: 0, z: 0)
  for a in bots:
    for c in a.checkpoints:
      overlaps = 0
      for b in bots:
        if c.inside2 b:
          overlaps.inc
      if overlaps > max_overlap:
        max_overlap = overlaps
        current = c
      elif overlaps == max_overlap:
        if origin.distance(c) < origin.distance(current):
          current = c
  
  var 
    skip_set = initHashSet[Vec3]()
    cur: SearchPoint
    best: SearchPoint
    nb_range = 0
    count = 0

  cur = (p: current, in_range: max_overlap)


  while true:
    best = cur
    for nb in cur.p.get_neighbours(skip_set):
      nb_range = 0
      for b in bots:
        if nb.inside2 b:
          nb_range.inc()
      if nb_range > best.in_range:
        best = (p: nb, in_range: nb_range)
      elif nb_range == best.in_range:
        if origin.distance(nb) < origin.distance(best.p):
          best.p = nb
    skip_set.clear()
    for nb in cur.p.get_neighbours(skip_set):
      if nb == best.p:
        continue
      skip_set.incl(nb)
    
    count.inc

    if count mod 50_000 == 0:
      echo fmt"#{count} Best: {best}"

    if best == cur:
      echo fmt"#{count} Result: {best}, distance {origin.distance(best.p)}"
      break
    else:
      cur = best
    
  
var input = readFile(paramStr(1)).strip(trailing = true)

var bots = input.getNanobots

echo "Calculating best point"

bots.findStuff()
# fel: 77375119
# fel: 56706898
# fel: 56706898
# fel: 77375120
# RÄTT: 84087816