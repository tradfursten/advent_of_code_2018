import strutils, sequtils, re, algorithm, tables


proc rFile(input:string):string=
  result = readFile(input).strip(trailing = true)

proc parseInput(input: string):seq[(int, int)] =
  let p = re"(\d+)"
  result = input.splitLines()
    .map(proc(x: string): (int, int) =
        let coords = x.findAll(p).map(parseInt)
        result = (coords[0], coords[1])
    )

proc getClosestDistance(c: (int, int), coords: seq[(int, int)]): (int, (int, int)) =
  let closest = coords
    .map(func(b:(int,int)):(int,(int, int)) = ((c[0]-b[0]).abs + (c[1]-b[1]).abs, b))
    .sorted(cmp)
  if closest[0][0] == closest[1][0]:
    result = (0, (0,0))
  else:
    result = closest[0]

proc sumDistance(c: (int, int), coords: seq[(int, int)]): (int) =
  coords
    .map(func(b:(int,int)):int = (c[0]-b[0]).abs + (c[1]-b[1]).abs)
    .foldl(a + b)



proc solve1(coords: seq[(int, int)]): int =
  var grid = initTable[(int, int), (int, (int, int))]()
  var maxX = 0
  var maxY = 0
  var minX = -100
  var minY = -100
  for c in coords:
    if c[0] > maxX:
      maxX = c[0]
    if c[0] < minX:
      minX = c[0]
    if c[1] > maxY:
      maxY = c[1]
    if c[1] < minY:
      minY = c[1]
  for x in minX..maxX:
    for y in minY..maxY:
      grid[(x,y)] = getClosestDistance((x, y), coords)

  let nonInfinite = coords
    .filter(proc(b: (int, int)): bool =
        for x in minX..maxX:
          if grid[(x, minY)][1] == b or grid[(x, maxY)][1] == b:
            return false
        for y in minY..maxY:
          if grid[(minX, y)][1] == b or grid[(maxX, y)][1] == b:
            return false
        return true
      )
    .map(proc(c: (int, int)): int =
      var count = 0
      for v in grid.values():
        if v[1] == c:
          count = count + 1
      count
    ).sorted(cmp, order = SortOrder.Descending)
  result = nonInfinite[0]


proc solve2(coords: seq[(int, int)], limit: int): int =
  var grid = initTable[(int, int), int]()
  var maxX = 0
  var maxY = 0
  var minX = -100
  var minY = -100
  for c in coords:
    if c[0] > maxX:
      maxX = c[0]
    if c[0] < minX:
      minX = c[0]
    if c[1] > maxY:
      maxY = c[1]
    if c[1] < minY:
      minY = c[1]
  for x in minX..maxX:
    for y in minY..maxY:
      grid[(x,y)] = sumDistance((x, y), coords)

  var count = 0
  for value in grid.values():
    if value < limit:
      count.inc


  result = count




let testInput = rFile("test_input1.txt")
let parsedTestInput = parseInput(testInput)
echo solve1(parsedTestInput)
echo solve2(parsedTestInput, 32)


let input = rFile("input.txt")
let parsedInput = parseInput(input)
echo solve1(parsedInput)
echo solve2(parsedInput, 10000)

