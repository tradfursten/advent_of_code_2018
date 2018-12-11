import strutils, sequtils, strscans, terminal, os, re, rdstdin

type Point = ref object
  x, y, velx, vely:int


proc rFile(input:string):string=
  result = readFile(input).strip(trailing = true)

let testInput = rFile("test_input1.txt")


let input = rFile("input.txt")


proc parseInput(input: string): seq[Point] =
  let points = input.splitLines()
    .map(proc(line: string): Point =
      let l = line.findAll(re"-?\d+").map(parseInt)
      result = Point(x: l[0], y: l[1], velx: l[2], vely: l[3])
     )

  result = points

proc move(point: Point) =
  point.x = point.x + point.velx
  point.y += point.vely

proc calculateBonds(points: seq[Point]): (int, int, int, int) =
  var minX, minY, maxX, maxY :int

  for p in points:
    if p.x < minX:
      minX = p.x
    elif p.x > maxX:
      maxX = p.x
    if p.y < minY:
      minY = p.y
    elif p.y > maxY:
      maxY = p.y
  result = (minX, minY, maxX, maxY)


proc solve1(points: seq[Point]) =
  var done = false
  var bounds: (int, int, int, int)

  var seconds = 0

  while not done:
    bounds = calculateBonds(points)
    if bounds[0]-bounds[1] < 12:
      eraseScreen()
      for y in bounds[1]..bounds[3]:
        for x in bounds[0]..bounds[2]:
          if points.anyIt(it.x == x and it.y == y):
            stdout.write("X")
          else:
            stdout.write(".")
        echo ""

      echo "Seconds: ", seconds

      var f : File;
      discard f.open(0, fmRead)

      let s = f.readLine()

    for p in points:
      p.move()
    seconds.inc
     

if paramCount() > 0 and paramStr(0) == "test":
  let parsedTestInput = parseInput(testInput)
  solve1(parsedTestInput)
else:
  let parsed = parseInput(input)
  solve1(parsed)


